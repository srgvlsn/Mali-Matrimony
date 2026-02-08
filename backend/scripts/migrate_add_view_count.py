"""
Migration script to add view_count column and fix shortlist table
"""
from database import engine
from sqlalchemy import text

def migrate():
    with engine.connect() as conn:
        # Add view_count column to users table
        try:
            conn.execute(text("ALTER TABLE users ADD COLUMN view_count INTEGER DEFAULT 0"))
            conn.commit()
            print("✅ Added view_count column to users table")
        except Exception as e:
            if "already exists" in str(e).lower():
                print("ℹ️  view_count column already exists")
            else:
                print(f"❌ Error adding view_count: {e}")
        
        # Fix shortlists table - add user_id as primary key
        try:
            # Drop existing table and recreate with correct schema
            conn.execute(text("DROP TABLE IF EXISTS shortlists CASCADE"))
            conn.execute(text("""
                CREATE TABLE shortlists (
                    user_id VARCHAR NOT NULL,
                    shortlisted_user_id VARCHAR NOT NULL,
                    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                    PRIMARY KEY (user_id, shortlisted_user_id),
                    FOREIGN KEY(user_id) REFERENCES users (id) ON DELETE CASCADE,
                    FOREIGN KEY(shortlisted_user_id) REFERENCES users (id) ON DELETE CASCADE
                )
            """))
            conn.commit()
            print("✅ Fixed shortlists table schema")
        except Exception as e:
            print(f"❌ Error fixing shortlists table: {e}")

if __name__ == "__main__":
    migrate()
    print("\n✅ Migration completed!")
