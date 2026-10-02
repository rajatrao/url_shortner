"""URL shortening API endpoints."""
from fastapi import APIRouter, HTTPException, Depends
from sqlalchemy.orm import Session
import secrets
import string

from app.database import get_db
from app.models import ShortURL

router = APIRouter(prefix="/api/v1", tags=["Short URLs"])


def generate_unique_code(length: int = 7, db: Session = Depends(get_db)) -> str:
    """Generate a unique short code (lowercase only for consistent lookup)."""
    characters = string.ascii_lowercase + string.digits
    while True:
        short_code = ''.join(secrets.choice(characters) for _ in range(length))
        exists = db.query(ShortURL).filter(
            ShortURL.short_code == short_code
        ).first()
        if not exists:
            return short_code


@router.post("/shorten", response_model=dict, summary="Create a shortened URL")
def create_short_url(original_url: str, code_length: int = 7, db: Session = Depends(get_db)):
    """Create a new shortened URL with auto-generated 7-char code."""
    if len(original_url.strip()) == 0:
        raise HTTPException(status_code=400, detail="Original URL cannot be empty")
    
    if len(original_url) > 2048:
        raise HTTPException(status_code=400, detail="URL too long (max 2048 characters)")
    
    # Check for duplicate URLs (case-insensitive)
    existing = db.query(ShortURL).filter(
        ShortURL.original_url == original_url.lower()
    ).first()
    
    if existing:
        return {
            "short_code": existing.short_code,
            "original_url": existing.original_url,
            "created_at": existing.created_at.isoformat() if existing.created_at else None
        }
    
    db_url = ShortURL(original_url=original_url.lower())
    
    count = 0
    while True:
        db_url.short_code = generate_unique_code(code_length, db)
        exists = db.query(ShortURL).filter(
            ShortURL.short_code == db_url.short_code
        ).first()
        if not exists:
            break
        count += 1
        if count > 50:
            raise HTTPException(status_code=500, detail="Could not generate unique short code")
    
    db.add(db_url)
    db.commit()
    db.refresh(db_url)
    
    return {
        "short_code": db_url.short_code,
        "original_url": db_url.original_url,
        "created_at": db_url.created_at.isoformat() if db_url.created_at else None
    }


@router.get("/{short_code}", response_model=dict, summary="Get shortened URL info")
def get_short_url(short_code: str, db: Session = Depends(get_db)):
    """Get information about a shortened URL."""
    if not short_code:
        raise HTTPException(status_code=400, detail="Short code is required")
    
    # Case-insensitive lookup
    short_url = db.query(ShortURL).filter(
        ShortURL.short_code == short_code.lower()
    ).first()
    
    if not short_url:
        raise HTTPException(status_code=404, detail="Short URL not found")
    
    return {
        "short_code": short_url.short_code.lower(),
        "original_url": short_url.original_url,
        "created_at": short_url.created_at.isoformat() if short_url.created_at else None,
        "status": "active"
    }


@router.delete("/{short_code}", summary="Delete a shortened URL")
def delete_short_url(short_code: str, db: Session = Depends(get_db)):
    """Delete a shortened URL."""
    if not short_code:
        raise HTTPException(status_code=400, detail="Short code is required")
    
    short_url = db.query(ShortURL).filter(
        ShortURL.short_code == short_code.lower()
    ).first()
    
    if not short_url:
        raise HTTPException(status_code=404, detail="Short URL not found")
    
    db.delete(short_url)
    db.commit()
    
    return {"message": "Short URL deleted successfully"}


@router.get("/")
def get_all_urls(db: Session = Depends(get_db)):
    """Get all shortened URLs."""
    urls = db.query(ShortURL).order_by(ShortURL.created_at.desc()).all()
    return {
        "urls": [
            {
                "short_code": url.short_code,
                "original_url": url.original_url,
                "created_at": url.created_at.isoformat() if url.created_at else None
            } for url in urls
        ],
        "count": len(urls)
    }

