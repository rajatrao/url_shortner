"""Database configuration and connection."""
from sqlalchemy import create_engine
from app.models import Base  # Import Base from models
from sqlalchemy.orm import sessionmaker, Session
from typing import Generator
import os

DATABASE_URL = os.getenv(
    "DATABASE_URL", 
    f"postgresql://urlshortener:${{DB_PASSWORD:-postgresSecure123!}}@localhost:5432/urlshortener"
)

engine = create_engine(DATABASE_URL, pool_recycle=3600, pool_size=10, max_overflow=20)

SessionLocal = sessionmaker(bind=engine, autocommit=False, autoflush=False)


def get_db() -> Generator[Session, None, None]:
    """Dependency to get database session."""
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
