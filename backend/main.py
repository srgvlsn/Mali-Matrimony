from fastapi import FastAPI, Depends, HTTPException, status, File, UploadFile, Form, WebSocket, WebSocketDisconnect
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from sqlalchemy.orm import Session
from typing import List, Optional, Dict
import uvicorn
import os
import shutil
import uuid
import asyncio
from datetime import datetime, timedelta, timezone

from . import models, schemas, database
from .database import engine, get_db

from passlib.context import CryptContext
from pydantic import BaseModel

# Create tables
models.Base.metadata.create_all(bind=engine)

app = FastAPI(title="Mali Matrimony API", version="0.6.9")

# Mount uploads directory to serve images
os.makedirs("backend/uploads", exist_ok=True)
app.mount("/uploads", StaticFiles(directory="backend/uploads"), name="uploads")

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# WebSocket Connection Manager
class ConnectionManager:
    def __init__(self):
        self.active_connections: Dict[str, List[WebSocket]] = {}
        self.admin_connections: List[WebSocket] = []

    async def connect(self, websocket: WebSocket, user_id: str):
        await websocket.accept()
        if user_id.startswith("admin_"):
            self.admin_connections.append(websocket)
        else:
            if user_id not in self.active_connections:
                self.active_connections[user_id] = []
            self.active_connections[user_id].append(websocket)

    def disconnect(self, websocket: WebSocket, user_id: str):
        if user_id.startswith("admin_"):
            if websocket in self.admin_connections:
                self.admin_connections.remove(websocket)
        else:
            if user_id in self.active_connections:
                self.active_connections[user_id].remove(websocket)
                if not self.active_connections[user_id]:
                    del self.active_connections[user_id]

    async def broadcast_to_admins(self, message: dict):
        to_remove = []
        for connection in self.admin_connections:
            try:
                await connection.send_json(message)
            except Exception as e:
                print(f"Error broadcasting to admin: {e}")
                to_remove.append(connection)
        
        for conn in to_remove:
            if conn in self.admin_connections:
                self.admin_connections.remove(conn)

    async def send_personal_message(self, message: dict, user_id: str):
        if user_id in self.active_connections:
            to_remove = []
            for connection in self.active_connections[user_id]:
                try:
                    await connection.send_json(message)
                except Exception as e:
                    print(f"Error sending to user {user_id}: {e}")
                    to_remove.append(connection)
            
            for conn in to_remove:
                if conn in self.active_connections[user_id]:
                    self.active_connections[user_id].remove(conn)
            
            if not self.active_connections[user_id]:
                del self.active_connections[user_id]

manager = ConnectionManager()

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

async def check_premium_expiries():
    """
    Background task to check for premium expiries and send reminders.
    Runs every hour.
    """
    while True:
        try:
            db = database.SessionLocal()
            now = datetime.now(timezone.utc)
            
            # Find all premium users
            premium_users = db.query(models.User).filter(
                models.User.is_premium == True,
                models.User.premium_expiry_date != None
            ).all()
            
            for user in premium_users:
                expiry = user.premium_expiry_date
                time_left = expiry - now
                
                reminder_type = None
                message = None
                
                # Expiry Check
                if time_left.total_seconds() <= 0:
                    # Downgrade user
                    user.is_premium = False
                    user.premium_expiry_date = None
                    user.last_premium_reminder = 'expired'
                    
                    # Notify user
                    new_notif = models.Notification(
                        id=str(uuid.uuid4()),
                        user_id=user.id,
                        title="Premium Membership Expired",
                        message="Your premium membership has expired. Upgrade now to continue enjoying premium benefits!",
                        type="system"
                    )
                    db.add(new_notif)
                    
                    # Push real-time update
                    await manager.send_personal_message(
                        {"type": "profile_updated", "user_id": user.id},
                        user.id
                    )
                
                # Reminder Checks (only if not already sent for this interval)
                elif time_left <= timedelta(days=1) and user.last_premium_reminder != '1d':
                    reminder_type = '1d'
                    message = "Your premium membership expires in 1 day! Renew now to stay premium."
                elif time_left <= timedelta(days=2) and user.last_premium_reminder not in ['1d', '2d']:
                    reminder_type = '2d'
                    message = "Your premium membership expires in 2 days. Don't forget to renew!"
                elif time_left <= timedelta(days=3) and user.last_premium_reminder not in ['1d', '2d', '3d']:
                    reminder_type = '3d'
                    message = "Your premium membership expires in 3 days. Renew now!"
                elif time_left <= timedelta(days=7) and user.last_premium_reminder not in ['1d', '2d', '3d', '7d']:
                    reminder_type = '7d'
                    message = "Your premium membership expires in 1 week."
                elif time_left <= timedelta(days=14) and user.last_premium_reminder not in ['1d', '2d', '3d', '7d', '14d']:
                    reminder_type = '14d'
                    message = "Your premium membership expires in 2 weeks."
                elif time_left <= timedelta(days=30) and user.last_premium_reminder not in ['1d', '2d', '3d', '7d', '14d', '30d']:
                    reminder_type = '30d'
                    message = "Your premium membership expires in 1 month. Plan ahead!"
                
                if reminder_type and message:
                    user.last_premium_reminder = reminder_type
                    new_notif = models.Notification(
                        id=str(uuid.uuid4()),
                        user_id=user.id,
                        title="Premium Renewal Reminder",
                        message=message,
                        type="system"
                    )
                    db.add(new_notif)
                    
                    # Push real-time update
                    await manager.send_personal_message(
                        {"type": "new_notification", "title": "Premium Renewal Reminder"},
                        user.id
                    )
            
            db.commit()
            db.close()
            
        except Exception as e:
            print(f"Error in premium expiry check task: {e}")
            
        # Wait for 1 hour before next check
        # For testing purposes, you could reduce this, but 1 hour is reasonable for production.
        await asyncio.sleep(3600)

@app.on_event("startup")
async def startup_event():
    # Start background task
    asyncio.create_task(check_premium_expiries())

@app.get("/")
def read_root():
    return {"message": "Welcome to Mali Matrimony API"}

@app.get("/ping")
def ping():
    return {"ping": "pong"}


@app.websocket("/ws/{user_id}")
async def websocket_endpoint(websocket: WebSocket, user_id: str):
    await manager.connect(websocket, user_id)
    
    # Notify others that user is online (Optimization: Broadcast only to relevant users in future)
    # For now, we skip broad 'online' broadcast to avoid noise, 
    # relying on specific status checks or implement if requested.
    
    try:
        while True:
            # Expect JSON messages for events like typing
            data = await websocket.receive_json()
            
            # Handle Typing Events
            if data.get('type') in ['typing_started', 'typing_stopped']:
                receiver_id = data.get('receiver_id')
                if receiver_id:
                    # Forward the event to the receiver
                    await manager.send_personal_message({
                        "type": data['type'],
                        "sender_id": user_id
                    }, receiver_id)
                    
    except WebSocketDisconnect:
        manager.disconnect(websocket, user_id)

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
async def register_user(user: schemas.UserCreate, db: Session = Depends(get_db)):
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
        
        # Notify Admins: Real-time user registration
        await manager.broadcast_to_admins({
            "type": "user_registered",
            "user_id": new_user.id,
            "user_name": new_user.name,
            "timestamp": datetime.now(timezone.utc).isoformat()
        })
        
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

    
    # Total users
    total_users = db.query(models.User).count()
    
    # Verified users
    verified_users = db.query(models.User).filter(models.User.is_verified == True).count()
    
    # Premium users
    premium_users = db.query(models.User).filter(models.User.is_premium == True).count()
    
    # Pending verification (not verified)
    pending_verification = db.query(models.User).filter(models.User.is_verified == False).count()
    
    # Recent registrations (last 7 days)
    seven_days_ago = datetime.now(timezone.utc) - timedelta(days=7)
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
def get_all_profiles(include_inactive: bool = False, db: Session = Depends(get_db)):
    query = db.query(models.User)
    if not include_inactive:
        query = query.filter(models.User.is_active == True)
    users = query.all()
    user_data = [schemas.UserResponse.model_validate(u).model_dump() for u in users]
    return schemas.ApiResponse(
        status="success",
        message="Profiles fetched successfully",
        data=user_data
    )

@app.get("/profiles/{user_id}", response_model=schemas.ApiResponse)
async def get_profile(user_id: str, viewer_id: Optional[str] = None, db: Session = Depends(get_db)):
    user = db.query(models.User).filter(models.User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="Profile not found")
    
    # If there's a viewer and they are not viewing their own profile
    if viewer_id and viewer_id != user_id:
        viewer = db.query(models.User).filter(models.User.id == viewer_id).first()
        if viewer:
            # Increment view count
            user.view_count += 1
            
            # Check if viewer has already notified this user (Deduplication)
            existing_notif = db.query(models.Notification).filter(
                models.Notification.user_id == user_id,
                models.Notification.type == "profileView",
                models.Notification.related_user_id == viewer_id
            ).first()

            if not existing_notif:
                # Create notification for the profile owner
                new_notif = models.Notification(
                    id=str(uuid.uuid4()),
                    user_id=user_id,
                    title="Profile Viewed",
                    message=f"{viewer.name} viewed your profile!",
                    type="profileView",
                    related_user_id=viewer_id
                )
                db.add(new_notif)
                
                # Push real-time update
                await manager.send_personal_message(
                    {"type": "new_notification", "title": "Profile Viewed"},
                    user_id
                )
            
            db.commit()
    
    return schemas.ApiResponse(
        status="success",
        message="Profile fetched",
        data=schemas.UserResponse.model_validate(user).model_dump()
    )

@app.get("/profiles/{user_id}/analytics", response_model=schemas.ApiResponse)
async def get_user_analytics(user_id: str, db: Session = Depends(get_db)):
    user = db.query(models.User).filter(models.User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
        
    interests_received = db.query(models.Interest).filter(
        models.Interest.receiver_id == user_id,
        models.Interest.status == "pending"
    ).count()

    interests_sent = db.query(models.Interest).filter(
        models.Interest.sender_id == user_id
    ).count()
    
    shortlisted_by = db.query(models.Shortlist).filter(
        models.Shortlist.shortlisted_user_id == user_id
    ).count()
    
    analytics = schemas.UserAnalytics(
        total_views=user.view_count,
        interests_received=interests_received,
        shortlisted_by=shortlisted_by,
        interests_sent=interests_sent
    )
    
    return schemas.ApiResponse(
        status="success",
        message="Analytics fetched",
        data=analytics.model_dump()
    )

@app.put("/profiles/{user_id}", response_model=schemas.ApiResponse)
async def update_profile(user_id: str, user_update: schemas.UserBase, db: Session = Depends(get_db)):
    db_user = db.query(models.User).filter(models.User.id == user_id).first()
    if not db_user:
        raise HTTPException(status_code=404, detail="Profile not found")
    
    update_data = user_update.model_dump(exclude_unset=True)
    
    # Handle verification status changes
    if 'is_verified' in update_data:
        if update_data['is_verified'] and not db_user.is_verified:
            # Create fresh notification on verification
            new_notif = models.Notification(
                id=str(uuid.uuid4()),
                user_id=user_id,
                title="Profile Verified",
                message="Congratulations! Your profile has been verified by the admin.",
                type="profileVerified"
            )
            db.add(new_notif)
            # Push real-time update
            await manager.send_personal_message(
                {"type": "new_notification", "title": "Profile Verified"},
                user_id
            )
        elif not update_data['is_verified'] and db_user.is_verified:
            # Revoke: Delete existing "Profile Verified" notifications
            db.query(models.Notification).filter(
                models.Notification.user_id == user_id,
                models.Notification.title == "Profile Verified"
            ).delete()

    # Handle premium membership changes
    if 'is_premium' in update_data:
        if update_data['is_premium'] and not db_user.is_premium:
            # User upgraded to premium
            # Check for existing premium notification to deduplicate
            existing_premium_notif = db.query(models.Notification).filter(
                models.Notification.user_id == user_id,
                models.Notification.type == "premiumMembership"
            ).first()

            if not existing_premium_notif:
                new_notif = models.Notification(
                    id=str(uuid.uuid4()),
                    user_id=user_id,
                    title="Premium Membership Active",
                    message="You are a premium member now.... enjoy.....",
                    type="premiumMembership"
                )
                db.add(new_notif)
            
            # Reset reminders on new/renewed premium
            db_user.last_premium_reminder = None
            
            # Push real-time update
            await manager.send_personal_message(
                {"type": "new_notification", "title": "Premium Membership Active"},
                user_id
            )
            
            # Notify admins
            await manager.broadcast_to_admins({
                "type": "payment_completed",
                "user_id": user_id,
                "user_name": db_user.name,
                "timestamp": datetime.now(timezone.utc).isoformat()
            })

    for key, value in update_data.items():
        setattr(db_user, key, value)
    
    db.commit()
    db.refresh(db_user)

    # Universal Real-Time Sync: Notify the user and all admins
    await manager.send_personal_message(
        {"type": "profile_updated", "user_id": user_id},
        user_id
    )
    await manager.broadcast_to_admins({
        "type": "profile_updated",
        "user_id": user_id,
        "user_name": db_user.name,
        "timestamp": datetime.now(timezone.utc).isoformat()
    })

    return schemas.ApiResponse(
        status="success",
        message="Profile updated",
        data=schemas.UserResponse.model_validate(db_user).model_dump()
    )

@app.put("/profiles/{user_id}/settings", response_model=schemas.ApiResponse)
async def update_user_settings(user_id: str, settings: schemas.UserSettingsUpdate, db: Session = Depends(get_db)):
    db_user = db.query(models.User).filter(models.User.id == user_id).first()
    if not db_user:
        raise HTTPException(status_code=404, detail="User not found")
    
    update_data = settings.model_dump(exclude_unset=True)
    for key, value in update_data.items():
        setattr(db_user, key, value)
    
    db.commit()
    db.refresh(db_user)

    # Broadcast real-time settings update (privacy changes)
    await manager.broadcast_to_admins({
        "type": "profile_updated",
        "user_id": user_id,
        "user_name": db_user.name,
        "timestamp": datetime.now(timezone.utc).isoformat()
    })
    # Notify the user themselves
    await manager.send_personal_message(
        {"type": "profile_updated", "user_id": user_id},
        user_id
    )

    return schemas.ApiResponse(
        status="success",
        message="Settings updated",
        data=schemas.UserResponse.model_validate(db_user).model_dump()
    )

@app.delete("/users/{user_id}", response_model=schemas.ApiResponse)
async def delete_user(user_id: str, db: Session = Depends(get_db)):
    db_user = db.query(models.User).filter(models.User.id == user_id).first()
    if not db_user:
        raise HTTPException(status_code=404, detail="User not found")
    
    # Delete related notifications and messages (handled by CASCADE in DB)
    db.delete(db_user)
    db.commit()
    
    return schemas.ApiResponse(
        status="success",
        message="Account deleted successfully"
    )

# ==================== Notification API ====================

@app.get("/notifications/{user_id}", response_model=schemas.ApiResponse)
def get_user_notifications(user_id: str, db: Session = Depends(get_db)):
    notifications = db.query(models.Notification).filter(
        models.Notification.user_id == user_id
    ).order_by(models.Notification.timestamp.desc()).all()
    
    notif_data = [schemas.NotificationResponse.model_validate(n).model_dump() for n in notifications]
    return schemas.ApiResponse(
        status="success",
        message="Notifications fetched",
        data=notif_data
    )

@app.put("/notifications/{notification_id}/read", response_model=schemas.ApiResponse)
def mark_notification_read(notification_id: str, db: Session = Depends(get_db)):
    notification = db.query(models.Notification).filter(models.Notification.id == notification_id).first()
    if not notification:
        raise HTTPException(status_code=404, detail="Notification not found")
    
    notification.is_read = True
    db.commit()
    return schemas.ApiResponse(
        status="success",
        message="Notification marked as read"
    )

# ==================== Interest API ====================

@app.post("/interests", response_model=schemas.ApiResponse)
async def send_interest(interest: schemas.InterestCreate, db: Session = Depends(get_db)):
    # Check if user exists
    receiver = db.query(models.User).filter(models.User.id == interest.receiver_id).first()
    if not receiver:
        raise HTTPException(status_code=404, detail="Receiver not found")

    new_interest = models.Interest(**interest.model_dump())
    db.add(new_interest)
    
    # Create notification for receiver
    new_notif = models.Notification(
        id=str(uuid.uuid4()),
        user_id=interest.receiver_id,
        title="New Interest Received",
        message="Someone is interested in your profile!",
        type="interestReceived",
        related_user_id=interest.sender_id
    )
    db.add(new_notif)
    
    db.commit()
    db.refresh(new_interest)
    
    # Push real-time update to receiver
    await manager.send_personal_message(
        {"type": "new_notification", "title": "New Interest Received"},
        interest.receiver_id
    )
    
    # Notify Admins: Real-time interaction log
    await manager.broadcast_to_admins({
        "type": "interest_sent",
        "sender_id": interest.sender_id,
        "receiver_id": interest.receiver_id,
        "timestamp": datetime.now(timezone.utc).isoformat()
    })
    
    return schemas.ApiResponse(
        status="success",
        message="Interest sent",
        data=schemas.InterestResponse.model_validate(new_interest).model_dump()
    )

@app.put("/interests/{interest_id}", response_model=schemas.ApiResponse)
async def update_interest_status(interest_id: str, status: str, db: Session = Depends(get_db)):
    interest = db.query(models.Interest).filter(models.Interest.id == interest_id).first()
    if not interest:
        raise HTTPException(status_code=404, detail="Interest not found")
    
    old_status = interest.status
    interest.status = status
    
    if status == "accepted" and old_status != "accepted":
        # Create notification for sender
        new_notif = models.Notification(
            id=str(uuid.uuid4()),
            user_id=interest.sender_id,
            title="Interest Accepted",
            message="Your interest has been accepted!",
            type="interestAccepted",
            related_user_id=interest.receiver_id
        )
        db.add(new_notif)
        
        # Push real-time update to sender
        await manager.send_personal_message(
            {"type": "new_notification", "title": "Interest Accepted"},
            interest.sender_id
        )
        
        # Notify Admins: Real-time interaction update
        await manager.broadcast_to_admins({
            "type": "interest_accepted",
            "sender_id": interest.sender_id,
            "receiver_id": interest.receiver_id,
            "timestamp": datetime.now(timezone.utc).isoformat()
        })

        # IMPROVEMENT: Automatic Chat Initiation
        # Create a real database message so the conversation is persistent and visible in both screens
        init_msg = models.ChatMessage(
            id=str(uuid.uuid4()),
            sender_id=interest.sender_id,
            receiver_id=interest.receiver_id,
            text="You matched! Say Hi 👋",
            is_read=True
        )
        db.add(init_msg)
        
        # Push real-time update to both (especially the sender who didn't trigger this)
        # We wrap in try block to handle cases where they aren't online
        try:
            msg_data = schemas.ChatMessageResponse.model_validate(init_msg).model_dump()
            msg_data["timestamp"] = msg_data["timestamp"].isoformat()
            payload = {"type": "new_message", "data": msg_data}
            await manager.send_personal_message(payload, interest.sender_id)
            await manager.send_personal_message(payload, interest.receiver_id)
        except Exception as e:
            print(f"WS Broadcast error: {e}")
    
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
async def toggle_shortlist(shortlist: schemas.ShortlistCreate, db: Session = Depends(get_db)):
    existing = db.query(models.Shortlist).filter(
        models.Shortlist.user_id == shortlist.user_id,
        models.Shortlist.shortlisted_user_id == shortlist.shortlisted_user_id
    ).first()
    
    if existing:
        db.delete(existing)
        db.commit()
        msg = "Removed from shortlist"
    else:
        new_shortlist = models.Shortlist(**shortlist.model_dump())
        db.add(new_shortlist)
        db.commit()
        msg = "Added to shortlist"
        
    # Push real-time update to the owner (in case they have multiple devices)
    await manager.send_personal_message(
        {"type": "shortlist_updated"},
        shortlist.user_id
    )
    
    # Notify Admins
    await manager.broadcast_to_admins({
        "type": "shortlist_toggled",
        "user_id": shortlist.user_id,
        "target_id": shortlist.shortlisted_user_id,
        "action": "added" if not existing else "removed"
    })
    
    return schemas.ApiResponse(status="success", message=msg)

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
async def delete_profile(user_id: str, db: Session = Depends(get_db)):
    db_user = db.query(models.User).filter(models.User.id == user_id).first()
    if not db_user:
        raise HTTPException(status_code=404, detail="Profile not found")
    
    db.delete(db_user)
    db.commit()
    
    # Notify Admins: Real-time user removal
    await manager.broadcast_to_admins({
        "type": "profile_deleted",
        "user_id": user_id,
        "user_name": db_user.name
    })
    
    return schemas.ApiResponse(
        status="success",
        message="Profile deleted successfully"
    )

# ==================== Chat API ====================

@app.get("/chat/conversations/{user_id}", response_model=schemas.ApiResponse)
def get_conversations(user_id: str, db: Session = Depends(get_db)):
    # This query finds the latest message for each distinct conversation partner
    # and counts unread messages from them.
    from sqlalchemy import or_, desc

    # 1. Get all unique conversation partners from messages
    messages = db.query(models.ChatMessage).filter(
        or_(
            models.ChatMessage.sender_id == user_id,
            models.ChatMessage.receiver_id == user_id
        )
    ).order_by(desc(models.ChatMessage.timestamp)).all()

    partners = {}
    for msg in messages:
        other_id = msg.receiver_id if msg.sender_id == user_id else msg.sender_id
        if other_id not in partners:
            partners[other_id] = msg

    # 2. Match-based logic is now simplified because we create a real message on match
    # No more mock messages needed here.
    # We still fetch partners from actual messages above.

    conversations = []
    for other_id, last_msg in partners.items():
        other_user = db.query(models.User).filter(models.User.id == other_id).first()
        if not other_user:
            continue
            
        unread_count = db.query(models.ChatMessage).filter(
            models.ChatMessage.sender_id == other_id,
            models.ChatMessage.receiver_id == user_id,
            models.ChatMessage.is_read == False
        ).count()
        
        conversations.append({
            "id": last_msg.id, 
            "other_user_id": other_id,
            "other_user_name": other_user.name,
            "other_user_photo": other_user.photos[0] if other_user.photos else None,
            "last_message": last_msg.text,
            "last_message_time": last_msg.timestamp,
            "unread_count": unread_count,
            "is_last_message_me": last_msg.sender_id == user_id
        })
        
    # Re-sort to show latest interactions first (messages or new matches)
    conversations.sort(key=lambda x: x['last_message_time'], reverse=True)

    return schemas.ApiResponse(
        status="success",
        message="Conversations fetched",
        data=conversations
    )

@app.get("/chat/messages", response_model=schemas.ApiResponse)
def get_chat_messages(user_id: str, other_user_id: str, db: Session = Depends(get_db)):
    from sqlalchemy import or_, and_
    
    messages = db.query(models.ChatMessage).filter(
        or_(
            and_(models.ChatMessage.sender_id == user_id, models.ChatMessage.receiver_id == other_user_id),
            and_(models.ChatMessage.sender_id == other_user_id, models.ChatMessage.receiver_id == user_id)
        )
    ).order_by(models.ChatMessage.timestamp).all()
    
    # Mark messages from the other user as read
    db.query(models.ChatMessage).filter(
        models.ChatMessage.sender_id == other_user_id,
        models.ChatMessage.receiver_id == user_id,
        models.ChatMessage.is_read == False
    ).update({"is_read": True})
    db.commit()
    
    data = [schemas.ChatMessageResponse.model_validate(m).model_dump() for m in messages]
    return schemas.ApiResponse(status="success", message="Messages fetched", data=data)

@app.post("/chat/read", response_model=schemas.ApiResponse)
def mark_messages_as_read(user_id: str, other_user_id: str, db: Session = Depends(get_db)):
    db.query(models.ChatMessage).filter(
        models.ChatMessage.sender_id == other_user_id,
        models.ChatMessage.receiver_id == user_id,
        models.ChatMessage.is_read == False
    ).update({"is_read": True})
    db.commit()
    return schemas.ApiResponse(status="success", message="Messages marked as read")

@app.post("/chat/send", response_model=schemas.ApiResponse)
async def send_message(msg_data: schemas.ChatMessageCreate, sender_id: str, db: Session = Depends(get_db)):
    new_msg = models.ChatMessage(
        id=msg_data.id,
        sender_id=sender_id,
        receiver_id=msg_data.receiver_id,
        text=msg_data.text,
        attachment_url=msg_data.attachment_url,
        attachment_type=msg_data.attachment_type
    )
    db.add(new_msg)
    db.commit()
    db.refresh(new_msg)
    
    
    # Send via WebSocket
    payload = {
        "type": "new_message",
        "data": schemas.ChatMessageResponse.model_validate(new_msg).model_dump()
    }
    # Payload format needs to handle datetime serialization
    payload["data"]["timestamp"] = payload["data"]["timestamp"].isoformat()
    
    await manager.send_personal_message(payload, msg_data.receiver_id)
    
    return schemas.ApiResponse(status="success", message="Message sent", data=schemas.ChatMessageResponse.model_validate(new_msg).model_dump())

@app.post("/chat/upload", response_model=schemas.ApiResponse)
async def upload_chat_attachment(file: UploadFile = File(...)):
    try:
        file_id = str(uuid.uuid4())
        extension = os.path.splitext(file.filename)[1]
        file_name = f"{file_id}{extension}"
        file_path = f"backend/uploads/{file_name}"
        
        with open(file_path, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)
            
        # Return relative URL, client should prepend base URL
        url = f"/uploads/{file_name}" 
        
        return schemas.ApiResponse(
            status="success", 
            message="File uploaded successfully", 
            data={"url": url, "type": "image"} # Assuming image for now
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    uvicorn.run("backend.main:app", host="0.0.0.0", port=8000, reload=True)
