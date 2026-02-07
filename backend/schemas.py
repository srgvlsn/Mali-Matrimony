from pydantic import BaseModel, ConfigDict, field_validator
from typing import List, Optional
from datetime import datetime

class UserBase(BaseModel):
    name: str
    phone: Optional[str] = None
    email: Optional[str] = None
    age: int
    height: float
    gender: str
    marital_status: str
    dob: Optional[datetime] = None
    caste: Optional[str] = None
    sub_caste: Optional[str] = None
    mother_tongue: str
    languages: List[str] = []
    education: Optional[str] = None
    occupation: Optional[str] = None
    company: Optional[str] = None
    income: Optional[str] = None
    location: Optional[str] = None
    hometown: Optional[str] = None
    work_mode: Optional[str] = None
    father_name: Optional[str] = None
    mother_name: Optional[str] = None
    siblings: int = 0
    photos: List[str] = []
    bio: Optional[str] = None
    partner_preferences: Optional[str] = ""
    horoscope_image_url: Optional[str] = None
    is_verified: bool = False
    is_premium: bool = False
    is_hidden: bool = False
    show_phone: bool = True
    show_email: bool = True
    is_active: bool = True
    premium_expiry_date: Optional[datetime] = None
    last_premium_reminder: Optional[str] = None

    @field_validator('languages', 'photos', mode='before')
    @classmethod
    def ensure_list(cls, v):
        if v is None:
            return []
        return v

class UserCreate(UserBase):
    id: str
    password: Optional[str] = None

class UserResponse(UserBase):
    id: str
    view_count: int = 0
    created_at: datetime
    model_config = ConfigDict(from_attributes=True)

class InterestCreate(BaseModel):
    id: str
    sender_id: str
    receiver_id: str
    status: str = "pending"

class InterestResponse(InterestCreate):
    timestamp: datetime
    model_config = ConfigDict(from_attributes=True)

class ShortlistCreate(BaseModel):
    user_id: str
    shortlisted_user_id: str

class ApiResponse(BaseModel):
    status: str
    message: str
    data: Optional[dict | list] = None

class AnalyticsResponse(BaseModel):
    total_users: int
    verified_users: int
    premium_users: int
    pending_verification: int
    recent_registrations: int
    male_users: int
    female_users: int

class AdminLogin(BaseModel):
    username: str
    password: str

class UserLogin(BaseModel):
    phone: str
    password: str

class AdminResponse(BaseModel):
    id: str
    username: str
    role: str
    model_config = ConfigDict(from_attributes=True)

class NotificationCreate(BaseModel):
    id: str
    user_id: str
    title: str
    message: str
    type: str
    related_user_id: Optional[str] = None

class NotificationResponse(BaseModel):
    id: str
    user_id: str
    title: str
    message: str
    type: str
    is_read: bool
    related_user_id: Optional[str] = None
    timestamp: datetime
    model_config = ConfigDict(from_attributes=True)
class UserAnalytics(BaseModel):
    total_views: int
    interests_received: int
    shortlisted_by: int
    interests_sent: int
    model_config = ConfigDict(from_attributes=True)

class ChatMessageCreate(BaseModel):
    id: str
    receiver_id: str
    text: str
    attachment_url: Optional[str] = None
    attachment_type: Optional[str] = None

class ChatMessageResponse(BaseModel):
    id: str
    sender_id: str
    receiver_id: str
    text: str
    is_read: bool
    timestamp: datetime
    attachment_url: Optional[str] = None
    attachment_type: Optional[str] = None
    model_config = ConfigDict(from_attributes=True)

class ConversationResponse(BaseModel):
    id: str
    other_user_id: str
    other_user_name: str
    other_user_photo: Optional[str] = None
    last_message: str
    last_message_time: datetime
    unread_count: int
    is_last_message_me: bool
    model_config = ConfigDict(from_attributes=True)

class UserSettingsUpdate(BaseModel):
    is_hidden: Optional[bool] = None
    show_phone: Optional[bool] = None
    show_email: Optional[bool] = None
