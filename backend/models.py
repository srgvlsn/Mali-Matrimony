from sqlalchemy import Column, String, Integer, Double, Boolean, DateTime, ForeignKey, Text, ARRAY
from sqlalchemy.sql import func
from .database import Base

class User(Base):
    __tablename__ = "users"

    id = Column(String, primary_key=True, index=True)
    name = Column(String, nullable=False)
    phone = Column(String, unique=True, index=True)
    email = Column(String)
    age = Column(Integer, nullable=False)
    height = Column(Double, nullable=False)
    gender = Column(String, nullable=False)
    marital_status = Column(String, nullable=False)
    religion = Column(String, nullable=False)
    caste = Column(String, nullable=False)
    sub_caste = Column(String, nullable=False)
    mother_tongue = Column(String, nullable=False)
    education = Column(String)
    occupation = Column(String)
    company = Column(String)
    income = Column(String)
    location = Column(String)
    hometown = Column(String)
    work_mode = Column(String)
    father_name = Column(String)
    father_occupation = Column(String)
    mother_name = Column(String)
    mother_occupation = Column(String)
    siblings = Column(Integer, default=0)
    photos = Column(ARRAY(String))
    bio = Column(Text)
    partner_preferences = Column(Text)
    horoscope_image_url = Column(Text)
    rashi = Column(String)
    nakshatra = Column(String)
    birth_time = Column(String)
    birth_place = Column(String)
    is_verified = Column(Boolean, default=False)
    is_premium = Column(Boolean, default=False)
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
