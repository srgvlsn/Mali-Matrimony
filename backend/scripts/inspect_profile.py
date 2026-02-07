from backend.database import SessionLocal
from backend.models import User
from sqlalchemy import text

def inspect_user():
    db = SessionLocal()
    try:
        # Fetch user by phone
        user = db.query(User).filter(User.phone == '9000000010').first()
        
        if not user:
            print("User not found!")
            return

        print(f"Inspecting User: {user.name} ({user.phone})")
        
        # List of string fields checked in Dart
        string_fields = [
            'name', 'phone', 'email', 'education', 'occupation', 'company', 
            'income', 'location', 'hometown', 'work_mode', 'father_name', 
            'mother_name', 'caste', 'sub_caste', 'mother_tongue', 'bio', 
            'partner_preferences', 'horoscope_image_url'
        ]

        missing_fields = []
        
        print("\n--- String Fields ---")
        for field in string_fields:
            val = getattr(user, field, None)
            display_val = f"'{val}'" if val is not None else "None"
            print(f"{field}: {display_val}")
            
            if val is None or (isinstance(val, str) and val.strip() == ''):
                missing_fields.append(field)

        print("\n--- Other Fields ---")
        print(f"age: {user.age} (Expected > 0)")
        if user.age <= 0: missing_fields.append('age')
        
        print(f"height: {user.height} (Expected > 0)")
        if user.height <= 0: missing_fields.append('height')
        
        print(f"siblings: {user.siblings} (Expected >= 0)")
        # siblings always passes in dart logic if it's an int >= 0
        
        print(f"languages: {user.languages} (Expected not empty)")
        if not user.languages or len(user.languages) == 0: missing_fields.append('languages')
        
        print(f"photos: {user.photos} (Expected not empty)")
        if not user.photos or len(user.photos) == 0: missing_fields.append('photos')

        print("\n--- Result ---")
        print(f"Missing Fields involved in score: {missing_fields}")
        
    finally:
        db.close()

if __name__ == "__main__":
    inspect_user()
