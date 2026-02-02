from fastapi import FastAPI, Depends, HTTPException, status, File, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from sqlalchemy.orm import Session
from typing import List, Optional
import uvicorn
import os
import shutil
import uuid

from . import models, schemas, database
from .database import engine, get_db

# Create directories
os.makedirs("backend/uploads", exist_ok=True)

# Create tables
models.Base.metadata.create_all(bind=engine)

app = FastAPI(title="Mali Matrimony API")

# Mount uploads directory to serve images
app.mount("/uploads", StaticFiles(directory="backend/uploads"), name="uploads")

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
def read_root():
    return {"message": "Welcome to Mali Matrimony API"}

@app.post("/upload", response_model=schemas.ApiResponse)
async def upload_file(file: UploadFile = File(...)):
    # Generate unique filename
    file_extension = os.path.splitext(file.filename)[1]
    unique_filename = f"{uuid.uuid4()}{file_extension}"
    file_path = f"backend/uploads/{unique_filename}"
    
    # Save file
    with open(file_path, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)
    
    # Return the accessible URL
    # Note: In a real setup, this would be your domain or local IP
    file_url = f"/uploads/{unique_filename}"
    
    return schemas.ApiResponse(
        status="success",
        message="File uploaded successfully",
        data={"url": file_url}
    )

# ==================== Auth API ====================

@app.post("/auth/register", response_model=schemas.ApiResponse)
def register_user(user: schemas.UserCreate, db: Session = Depends(get_db)):
    db_user = db.query(models.User).filter(models.User.id == user.id).first()
    if db_user:
        raise HTTPException(status_code=400, detail="User already registered")
    
    try:
        new_user = models.User(**user.model_dump())
        db.add(new_user)
        db.commit()
        db.refresh(new_user)
        
        return schemas.ApiResponse(
            status="success",
            message="User registered successfully",
            data=schemas.UserResponse.model_validate(new_user).model_dump()
        )
    except Exception as e:
        db.rollback()
        # Check for unique constraint violation (like phone number)
        error_str = str(e).lower()
        if "unique constraint" in error_str or "duplicate key" in error_str:
            if "phone" in error_str:
                raise HTTPException(status_code=400, detail="Phone number is already registered")
            raise HTTPException(status_code=400, detail="Registration failed: Data already exists")
        
        print(f"Registration Error: {e}")
        raise HTTPException(status_code=500, detail=f"Internal server error: {str(e)}")

@app.post("/auth/login", response_model=schemas.ApiResponse)
def login_user(phone: str, db: Session = Depends(get_db)):
    user = db.query(models.User).filter(models.User.phone == phone).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    return schemas.ApiResponse(
        status="success",
        message="Login successful",
        data=schemas.UserResponse.model_validate(user).model_dump()
    )

# ==================== Profile API ====================

@app.get("/profiles", response_model=schemas.ApiResponse)
def get_all_profiles(db: Session = Depends(get_db)):
    users = db.query(models.User).all()
    user_data = [schemas.UserResponse.model_validate(u).model_dump() for u in users]
    return schemas.ApiResponse(
        status="success",
        message="Profiles fetched successfully",
        data=user_data
    )

@app.get("/profiles/{user_id}", response_model=schemas.ApiResponse)
def get_profile(user_id: str, db: Session = Depends(get_db)):
    user = db.query(models.User).filter(models.User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="Profile not found")
    
    return schemas.ApiResponse(
        status="success",
        message="Profile fetched",
        data=schemas.UserResponse.model_validate(user).model_dump()
    )

@app.put("/profiles/{user_id}", response_model=schemas.ApiResponse)
def update_profile(user_id: str, user_update: schemas.UserBase, db: Session = Depends(get_db)):
    db_user = db.query(models.User).filter(models.User.id == user_id).first()
    if not db_user:
        raise HTTPException(status_code=404, detail="Profile not found")
    
    update_data = user_update.model_dump(exclude_unset=True)
    for key, value in update_data.items():
        setattr(db_user, key, value)
    
    db.commit()
    db.refresh(db_user)
    return schemas.ApiResponse(
        status="success",
        message="Profile updated",
        data=schemas.UserResponse.model_validate(db_user).model_dump()
    )

# ==================== Interest API ====================

@app.post("/interests", response_model=schemas.ApiResponse)
def send_interest(interest: schemas.InterestCreate, db: Session = Depends(get_db)):
    new_interest = models.Interest(**interest.model_dump())
    db.add(new_interest)
    db.commit()
    db.refresh(new_interest)
    return schemas.ApiResponse(
        status="success",
        message="Interest sent",
        data=schemas.InterestResponse.model_validate(new_interest).model_dump()
    )

@app.put("/interests/{interest_id}", response_model=schemas.ApiResponse)
def update_interest_status(interest_id: str, status: str, db: Session = Depends(get_db)):
    interest = db.query(models.Interest).filter(models.Interest.id == interest_id).first()
    if not interest:
        raise HTTPException(status_code=404, detail="Interest not found")
    
    interest.status = status
    db.commit()
    db.refresh(interest)
    return schemas.ApiResponse(
        status="success",
        message=f"Interest status updated to {status}",
        data=schemas.InterestResponse.model_validate(interest).model_dump()
    )

@app.get("/interests/{user_id}", response_model=schemas.ApiResponse)
def get_user_interests(user_id: str, db: Session = Depends(get_db)):
    interests = db.query(models.Interest).filter(
        (models.Interest.sender_id == user_id) | (models.Interest.receiver_id == user_id)
    ).all()
    
    interest_data = [schemas.InterestResponse.model_validate(i).model_dump() for i in interests]
    return schemas.ApiResponse(
        status="success",
        message="Interests fetched",
        data=interest_data
    )

# ==================== Shortlist API ====================

@app.post("/shortlists", response_model=schemas.ApiResponse)
def toggle_shortlist(shortlist: schemas.ShortlistCreate, db: Session = Depends(get_db)):
    existing = db.query(models.Shortlist).filter(
        models.Shortlist.user_id == shortlist.user_id,
        models.Shortlist.shortlisted_user_id == shortlist.shortlisted_user_id
    ).first()
    
    if existing:
        db.delete(existing)
        db.commit()
        return schemas.ApiResponse(status="success", message="Removed from shortlist")
    else:
        new_shortlist = models.Shortlist(**shortlist.model_dump())
        db.add(new_shortlist)
        db.commit()
        return schemas.ApiResponse(status="success", message="Added to shortlist")

@app.get("/shortlists/{user_id}", response_model=schemas.ApiResponse)
def get_shortlisted_profiles(user_id: str, db: Session = Depends(get_db)):
    shortlisted_ids = db.query(models.Shortlist.shortlisted_user_id).filter(
        models.Shortlist.user_id == user_id
    ).all()
    
    ids = [s[0] for s in shortlisted_ids]
    users = db.query(models.User).filter(models.User.id.in_(ids)).all()
    user_data = [schemas.UserResponse.model_validate(u).model_dump() for u in users]
    
    return schemas.ApiResponse(
        status="success",
        message="Shortlisted profiles fetched",
        data=user_data
    )

@app.delete("/profiles/{user_id}", response_model=schemas.ApiResponse)
def delete_profile(user_id: str, db: Session = Depends(get_db)):
    db_user = db.query(models.User).filter(models.User.id == user_id).first()
    if not db_user:
        raise HTTPException(status_code=404, detail="Profile not found")
    
    db.delete(db_user)
    db.commit()
    return schemas.ApiResponse(
        status="success",
        message="Profile deleted successfully"
    )

if __name__ == "__main__":
    uvicorn.run("backend.main:app", host="0.0.0.0", port=8000, reload=True)
