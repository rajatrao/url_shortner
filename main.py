"""FastAPI URL Shortener Service."""
from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware

from app.database import engine, Base
from api.v1.routers.urls import router as urls_router

# Create database tables
Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="URL Shortener API",
    description="Auto-generated 7-character short codes with PostgreSQL",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc",
    openapi_url="/openapi.json",
)

# CORS Configuration - Only allow localhost
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://127.0.0.1:8000",
        "http://localhost:8000",
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(urls_router)


@app.get("/", tags=["Root"])
def read_root():
    """Health check endpoint."""
    return {
        "message": "Welcome to URL Shortener API",
        "docs": "/docs",
        "endpoints": [
            {"method": "POST", "path": "/", "description": "Create a short URL"},
            {"method": "GET", "path": "/{short_code}", "description": "Get URL info"},
            {"method": "DELETE", "path": "/{short_code}", "description": "Delete a short URL"},
        ]
    }


@app.get("/health", tags=["Health"])
def health_check():
    """Health check endpoint."""
    return {"status": "healthy", "service": "URL Shortener"}

