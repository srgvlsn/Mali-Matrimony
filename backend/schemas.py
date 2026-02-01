from pydantic import BaseModel, ConfigDict
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
    religion: str
    caste: str
    sub_caste: str
    mother_tongue: str
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
    rashi: Optional[str] = None
    nakshatra: Optional[str] = None
    birth_time: Optional[str] = None
    birth_place: Optional[str] = None
    is_verified: bool = False
    is_premium: bool = False

class UserCreate(UserBase):
    id: str

class UserResponse(UserBase):
    id: str
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
