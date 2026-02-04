from sqlalchemy import Column, String, Integer, Double, Boolean, DateTime, ForeignKey, Text, ARRAY, Date
from sqlalchemy.sql import func
from .database import Base

class User(Base):
    __tablename__ = "users"

    id = Column(String, primary_key=True, index=True)
    name = Column(String, nullable=False)
    phone = Column(String, unique=True, index=True)
    password_hash = Column(String, nullable=True)
    email = Column(String)
    age = Column(Integer, nullable=False)
    height = Column(Double, nullable=False)
    gender = Column(String, nullable=False)
    marital_status = Column(String, nullable=False)
    dob = Column(Date)
    caste = Column(String)
    sub_caste = Column(String)
    mother_tongue = Column(String, nullable=False)
    languages = Column(ARRAY(String))
    education = Column(String)
    occupation = Column(String)
    company = Column(String)
    income = Column(String)
    location = Column(String)
    hometown = Column(String)
    work_mode = Column(String)
    father_name = Column(String)
    mother_name = Column(String)
    siblings = Column(Integer, default=0)
    photos = Column(ARRAY(String))
    bio = Column(Text)
    partner_preferences = Column(Text)
    horoscope_image_url = Column(Text)
    is_verified = Column(Boolean, default=False)
    is_premium = Column(Boolean, default=False)
    is_hidden = Column(Boolean, default=False)
    show_phone = Column(Boolean, default=True)
    show_email = Column(Boolean, default=True)
    view_count = Column(Integer, default=0)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

class Interest(Base):
    __tablename__ = "interests"

    id = Column(String, primary_key=True, index=True)
    sender_id = Column(String, ForeignKey("users.id", ondelete="CASCADE"))
    receiver_id = Column(String, ForeignKey("users.id", ondelete="CASCADE"))
    status = Column(String, nullable=False, default="pending")
    timestamp = Column(DateTime(timezone=True), server_default=func.now())

class Shortlist(Base):
    __tablename__ = "shortlists"

    user_id = Column(String, ForeignKey("users.id", ondelete="CASCADE"), primary_key=True)
    shortlisted_user_id = Column(String, ForeignKey("users.id", ondelete="CASCADE"), primary_key=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

class Admin(Base):
    __tablename__ = "admins"

    id = Column(String, primary_key=True, index=True) # UUID
    username = Column(String, unique=True, index=True, nullable=False) # e.g., admin@mali
    password_hash = Column(String, nullable=False)
    role = Column(String, default="superadmin")
    created_at = Column(DateTime(timezone=True), server_default=func.now())

class Notification(Base):
    __tablename__ = "notifications"

    id = Column(String, primary_key=True, index=True)
    user_id = Column(String, ForeignKey("users.id", ondelete="CASCADE"), index=True)
    title = Column(String, nullable=False)
    message = Column(Text, nullable=False)
    type = Column(String, nullable=False) # newMatch, profileView, message, interestReceived, interestAccepted, system
    is_read = Column(Boolean, default=False)
    related_user_id = Column(String, ForeignKey("users.id", ondelete="SET NULL"), nullable=True)
    timestamp = Column(DateTime(timezone=True), server_default=func.now())
class ChatMessage(Base):
    __tablename__ = "chat_messages"

    id = Column(String, primary_key=True, index=True)
    sender_id = Column(String, ForeignKey("users.id", ondelete="CASCADE"), index=True)
    receiver_id = Column(String, ForeignKey("users.id", ondelete="CASCADE"), index=True)
    text = Column(Text, nullable=False)
    is_read = Column(Boolean, default=False)
    timestamp = Column(DateTime(timezone=True), server_default=func.now())
