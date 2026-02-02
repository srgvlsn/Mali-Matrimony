"""
Seed script to create 6 dummy profiles for testing
Uses direct SQL to avoid import issues
"""
import os
import uuid
import random
import requests
from datetime import datetime, timedelta, date
import psycopg2
from passlib.context import CryptContext

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

# Database connection
DB_URL = "postgresql://postgres:1234567890@localhost:5432/mali_matrimony"

# Unsplash image URLs for realistic photos
MALE_PHOTOS = [
    "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&h=400&fit=crop",
    "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400&h=400&fit=crop",
    "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=400&h=400&fit=crop",
    "https://images.unsplash.com/photo-1560250097-0b93528c311a?w=400&h=400&fit=crop",
    "https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=400&h=400&fit=crop",
    "https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=400&h=400&fit=crop",
]

FEMALE_PHOTOS = [
    "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400&h=400&fit=crop",
    "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=400&h=400&fit=crop",
    "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400&h=400&fit=crop",
    "https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=400&h=400&fit=crop",
    "https://images.unsplash.com/photo-1488426862026-3ee34a7d66df?w=400&h=400&fit=crop",
    "https://images.unsplash.com/photo-1517841905240-472988babdf9?w=400&h=400&fit=crop",
]

HOROSCOPE_URL = "https://via.placeholder.com/400x600/FFD700/000000?text=Horoscope"

MARITAL_STATUSES = ["Never Married", "Divorced", "Widowed"]
CASTES = ["Mali", "Maratha", "Brahmin", "Lingayat", "Jain"]
EDUCATION = ["BE/B.Tech", "ME/M.Tech", "MBA", "MBBS", "BDS", "CA", "LLB", "BSc", "MSc"]
OCCUPATIONS = ["Software Engineer", "Doctor", "Lawyer", "Teacher", "Business Owner", "Banker", "Government Employee"]
LOCATIONS = ["Pune", "Mumbai", "Bangalore", "Hyderabad", "Chennai", "Delhi", "Kolkata", "Nagpur"]
MOTHER_TONGUES = ["Marathi", "Hindi", "Kannada", "Telugu", "Tamil"]

MALE_PROFILES = [
    {"name": "Rahul Deshmukh", "age": 28, "height": 5.9, "income": "15-20 LPA"},
    {"name": "Vikram Patil", "age": 32, "height": 5.11, "income": "20-30 LPA"},
    {"name": "Arjun Kulkarni", "age": 26, "height": 5.8, "income": "10-15 LPA"},
]

FEMALE_PROFILES = [
    {"name": "Priya Sharma", "age": 25, "height": 5.4, "income": "8-12 LPA"},
    {"name": "Sneha Joshi", "age": 27, "height": 5.3, "income": "12-18 LPA"},
    {"name": "Ananya Deshpande", "age": 24, "height": 5.5, "income": "5-8 LPA"},
]

def download_image(url, upload_dir):
    """Download image and save to uploads folder"""
    try:
        response = requests.get(url, timeout=15)
        if response.status_code == 200:
            filename = f"{uuid.uuid4()}.jpg"
            filepath = os.path.join(upload_dir, filename)
            with open(filepath, 'wb') as f:
                f.write(response.content)
            return f"/uploads/{filename}"
    except Exception as e:
        print(f"⚠️ Failed to download image: {e}")
    return None

def create_profiles():
    upload_dir = os.path.join(os.path.dirname(__file__), "uploads")
    os.makedirs(upload_dir, exist_ok=True)
    
    conn = psycopg2.connect(DB_URL)
    cur = conn.cursor()
    
    created_count = 0
    
    # Create male profiles
    for i, profile in enumerate(MALE_PROFILES):
        user_id = f"user_{int(datetime.now().timestamp() * 1000) + i}"
        phone = f"900000000{i}"
        
        # Check if phone exists
        cur.execute("SELECT id FROM users WHERE phone = %s", (phone,))
        if cur.fetchone():
            print(f"⏭️ Skipping {profile['name']} - phone already exists")
            continue
        
        print(f"📥 Downloading images for {profile['name']}...")
        main_photo = download_image(MALE_PHOTOS[i], upload_dir)
        additional_photo = download_image(MALE_PHOTOS[i + 3], upload_dir)
        horoscope = download_image(HOROSCOPE_URL, upload_dir)
        
        photos = [p for p in [main_photo, additional_photo] if p]
        dob = date.today() - timedelta(days=profile["age"] * 365)
        mt = random.choice(MOTHER_TONGUES)
        
        cur.execute("""
            INSERT INTO users (id, name, phone, password_hash, email, age, height, gender, 
                marital_status, dob, caste, mother_tongue, languages, education, occupation,
                income, location, hometown, photos, horoscope_image_url, bio, is_verified, view_count)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        """, (
            user_id,
            profile["name"],
            phone,
            pwd_context.hash("password123"),
            f"{profile['name'].lower().replace(' ', '.')}@example.com",
            profile["age"],
            profile["height"],
            "Male",
            random.choice(MARITAL_STATUSES),
            dob,
            random.choice(CASTES),
            mt,
            ["English", mt],
            random.choice(EDUCATION),
            random.choice(OCCUPATIONS),
            profile["income"],
            random.choice(LOCATIONS),
            random.choice(LOCATIONS),
            photos,
            horoscope,
            f"Hi, I'm {profile['name'].split()[0]}. Looking for a life partner who values family and tradition.",
            random.choice([True, False]),
            0
        ))
        created_count += 1
        print(f"✅ Created: {profile['name']}")
    
    # Create female profiles  
    for i, profile in enumerate(FEMALE_PROFILES):
        user_id = f"user_{int(datetime.now().timestamp() * 1000) + i + 10}"
        phone = f"900000001{i}"
        
        cur.execute("SELECT id FROM users WHERE phone = %s", (phone,))
        if cur.fetchone():
            print(f"⏭️ Skipping {profile['name']} - phone already exists")
            continue
        
        print(f"📥 Downloading images for {profile['name']}...")
        main_photo = download_image(FEMALE_PHOTOS[i], upload_dir)
        additional_photo = download_image(FEMALE_PHOTOS[i + 3], upload_dir)
        horoscope = download_image(HOROSCOPE_URL, upload_dir)
        
        photos = [p for p in [main_photo, additional_photo] if p]
        dob = date.today() - timedelta(days=profile["age"] * 365)
        mt = random.choice(MOTHER_TONGUES)
        
        cur.execute("""
            INSERT INTO users (id, name, phone, password_hash, email, age, height, gender,
                marital_status, dob, caste, mother_tongue, languages, education, occupation,
                income, location, hometown, photos, horoscope_image_url, bio, is_verified, view_count)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        """, (
            user_id,
            profile["name"],
            phone,
            pwd_context.hash("password123"),
            f"{profile['name'].lower().replace(' ', '.')}@example.com",
            profile["age"],
            profile["height"], 
            "Female",
            random.choice(MARITAL_STATUSES),
            dob,
            random.choice(CASTES),
            mt,
            ["English", mt],
            random.choice(EDUCATION),
            random.choice(OCCUPATIONS),
            profile["income"],
            random.choice(LOCATIONS),
            random.choice(LOCATIONS),
            photos,
            horoscope,
            f"Hi, I'm {profile['name'].split()[0]}. Seeking a partner who respects traditions and believes in togetherness.",
            random.choice([True, False]),
            0
        ))
        created_count += 1
        print(f"✅ Created: {profile['name']}")
    
    conn.commit()
    cur.close()
    conn.close()
    
    print(f"\n🎉 Created {created_count} dummy profiles!")
    print("📱 All profiles have password: password123")

if __name__ == "__main__":
    create_profiles()
