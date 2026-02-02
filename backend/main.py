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

from passlib.context import CryptContext
from pydantic import BaseModel

# Password hashing configuration
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def verify_password(plain_password, hashed_password):
    return pwd_context.verify(plain_password, hashed_password)

def get_password_hash(password):
    return pwd_context.hash(password)

# OTP Models (since simple, defining here or move to schemas)
class OTPRequest(BaseModel):
    phone: str

class OTPVerify(BaseModel):
    phone: str
    otp: str

# In-memory OTP store (for demo purposes)
otp_store = {}

# ... existing code ...

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

# ==================== User Auth API ====================

@app.post("/auth/request-otp", response_model=schemas.ApiResponse)
def request_otp(request: OTPRequest, db: Session = Depends(get_db)):
    # Check if user exists
    user = db.query(models.User).filter(models.User.phone == request.phone).first()
    if not user:
        raise HTTPException(status_code=404, detail="Phone number not registered")
        
    # Generate mock OTP (always 123456 or random for logs)
    otp = "123456"
    otp_store[request.phone] = otp
    print(f"OTP for {request.phone}: {otp}") # Log OTP for testing
    
    return schemas.ApiResponse(
        status="success",
        message="OTP sent successfully (Check console/logs for '123456')",
        data={"otp_sent": True} # In real app, don't send OTP back
    )

@app.post("/auth/verify-otp", response_model=schemas.ApiResponse)
def verify_otp_login(request: OTPVerify, db: Session = Depends(get_db)):
    # Verify OTP
    stored_otp = otp_store.get(request.phone)
    if not stored_otp or stored_otp != request.otp:
        raise HTTPException(status_code=400, detail="Invalid or expired OTP")
    
    # Clear OTP
    otp_store.pop(request.phone, None)
    
    # Login user
    user = db.query(models.User).filter(models.User.phone == request.phone).first()
    if not user:
         raise HTTPException(status_code=404, detail="User not found")
         
    return schemas.ApiResponse(
        status="success",
        message="OTP Login successful",
        data=schemas.UserResponse.model_validate(user).model_dump()
    )


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

# ==================== Admin Auth API ====================

@app.post("/admin/login", response_model=schemas.ApiResponse)
def admin_login(creds: schemas.AdminLogin, db: Session = Depends(get_db)):
    admin = db.query(models.Admin).filter(models.Admin.username == creds.username).first()
    if not admin:
        raise HTTPException(status_code=401, detail="Invalid admin credentials")
    
    if not verify_password(creds.password, admin.password_hash):
        raise HTTPException(status_code=401, detail="Invalid admin credentials")
    
    return schemas.ApiResponse(
        status="success",
        message="Admin login successful",
        data=schemas.AdminResponse.model_validate(admin).model_dump()
    )

# ==================== User Auth API ====================

@app.post("/auth/register", response_model=schemas.ApiResponse)
def register_user(user: schemas.UserCreate, db: Session = Depends(get_db)):
    db_user = db.query(models.User).filter(models.User.id == user.id).first()
    if db_user:
        raise HTTPException(status_code=400, detail="User already registered")
    
    try:
        user_dict = user.model_dump()
        password = user_dict.pop('password', None)
        if password:
            user_dict['password_hash'] = get_password_hash(password)
        
        new_user = models.User(**user_dict)
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
def login_user(login_data: schemas.UserLogin, db: Session = Depends(get_db)):
    user = db.query(models.User).filter(models.User.phone == login_data.phone).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    # If user has a password, verify it
    if user.password_hash:
        if not verify_password(login_data.password, user.password_hash):
            raise HTTPException(status_code=401, detail="Invalid password")
    
    return schemas.ApiResponse(
        status="success",
        message="Login successful",
        data=schemas.UserResponse.model_validate(user).model_dump()
    )

# ==================== Analytics API ====================

@app.get("/analytics", response_model=schemas.AnalyticsResponse)
def get_analytics(db: Session = Depends(get_db)):
    from datetime import datetime, timedelta
    
    # Total users
    total_users = db.query(models.User).count()
    
    # Verified users
    verified_users = db.query(models.User).filter(models.User.is_verified == True).count()
    
    # Premium users
    premium_users = db.query(models.User).filter(models.User.is_premium == True).count()
    
    # Pending verification (not verified)
    pending_verification = db.query(models.User).filter(models.User.is_verified == False).count()
    
    # Recent registrations (last 7 days)
    seven_days_ago = datetime.now() - timedelta(days=7)
    recent_registrations = db.query(models.User).filter(
        models.User.created_at >= seven_days_ago
    ).count()
    
    # Gender distribution
    male_users = db.query(models.User).filter(models.User.gender == 'male').count()
    female_users = db.query(models.User).filter(models.User.gender == 'female').count()
    
    return schemas.AnalyticsResponse(
        total_users=total_users,
        verified_users=verified_users,
        premium_users=premium_users,
        pending_verification=pending_verification,
        recent_registrations=recent_registrations,
        male_users=male_users,
        female_users=female_users
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
