# FastAPI URL Shortener Service

A simple, production-ready URL shortening service using FastAPI and PostgreSQL.

## Features

- ✅ Auto-generated 7-character short codes (alphanumeric: a-zA-Z0-9)
- ✅ Case-insensitive short code matching (case doesn't matter)
- ✅ Unique code generation with collision prevention
- ✅ RESTful API with proper HTTP status codes
- ✅ SQL injection protection via SQLAlchemy
- ✅ PostgreSQL backend

## Quick Start

### 1. Setup Environment

```bash
# Copy and configure the env file
cp .env.example .env

# Edit .env with your PostgreSQL credentials
nano .env
```

### 2. Setup Virtual Environment (Recommended)

```bash
# Create virtual environment
python3 -m venv .venv

# Activate it
source .venv/bin/activate  # macOS/Linux
# or: .venv\Activate.ps1   # Windows PowerShell
# or: source .venv/activate.fish  # Fish shell

# Verify activation
which python  # Should show: .venv/bin/python
python --version  # Should show: Python 3.x
```

### 3. Install Dependencies

```bash
pip install -r requirements.txt
```

### 3. Run the Service

```bash
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

### 4. Access API Documentation

Open `http://localhost:8000/docs` in your browser for Swagger UI.

## API Endpoints

### Create Short URL

**POST `/api/v1/shorten`**

Request Body:
```json
{
  "original_url": "https://www.example.com/very-long-url?param=value&foo=bar",
  "code_length": 7
}
```

Response:
```json
{
  "id": 1,
  "original_url": "https://www.example.com/...",
  "short_code": "aB3dE9f",
  "created_at": "2026-10-01T12:00:00.000000"
}
```

### Get Short URL Info

**GET `/api/v1/{short_code}`**

Returns the short code, original URL, and creation timestamp.  
Case-insensitive lookup (abc = ABC = AbC works).

Status codes:
- **200**: Found
- **400**: Invalid short code
- **404**: Not found

### Delete Short URL

**DELETE `/api/v1/{short_code}`**

Deletes the short URL record.

### Redirect Handler (Optional)

The service returns a 302 redirect with Location header.

## Database Schema

```sql
CREATE TABLE short_urls (
    id SERIAL PRIMARY KEY,
    original_url TEXT NOT NULL,
    short_code VARCHAR(7) UNIQUE NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);
```

## Configuration

| Environment Variable | Description | Default |
|---------------------|-------------|---------|
| DATABASE_URL | PostgreSQL connection string | localhost:5432/urlshortener |
| HOST | Server host | 0.0.0.0 |
| PORT | Server port | 8000 |

## Project Structure

```
url_shortner/
├── app/
│   ├── __init__.py
│   ├── database.py      # PostgreSQL engine & sessions
│   └── models.py        # ShortURL model
├── api/
│   └── v1/
│       └── routers/
│           ├── __init__.py
│           └── urls.py  # API endpoints
├── main.py              # FastAPI application
├── requirements.txt     # Dependencies
├── .env                 # Database config (DO NOT COMMIT)
├── .venv/               # Virtual environment (Python packages)
└── README.md            # Documentation
```

## License

MIT


---

## 🐳 Docker Setup & Deployment

### Prerequisites
- [Docker](https://www.docker.com/products/docker/#download) installed
- [Docker Compose](https://docs.docker.com/compose/install/) installed

### Quick Start with Docker

```bash
# 1. Configure environment variables (optional, defaults are provided)
nano .env
# Or just use defaults in .env.docker

# 2. Build and start services
docker-compose up -d --build

# 3. View logs
docker-compose logs -f web database

# 4. Test the service
curl http://localhost:8000/health
curl http://localhost:8000/docs

# 5. Stop services
docker-compose down
```

### Custom Configuration

Edit `.env` to customize:

```bash
DB_USER=your_db_user          # Database username
DB_PASSWORD=your_password      # Database password  
DB_PORT=5432                  # PostgreSQL port
APP_PORT=8000                 # Application port
```

### Build Image Only (without running)

```bash
docker-compose build --no-cache
docker run -d \
  -p 8000:8000 \
  -e "DATABASE_URL=postgresql://..." \
  urlshortener-api
```

### Access Services

- **API**: http://localhost:8000
- **Swagger UI**: http://localhost:8000/docs
- **PostgreSQL**: localhost:5432 (internal container, not exposed by default)

---

## 📦 Complete Docker Architecture

```
┌─────────────────────────────────────┐
│         docker-compose.yml          │
└─────────────────────────────────────┘
           ════════════════════

     ┌──────────────────┐  ┌──────────────────┐
     │    PostgreSQL    │  │   FastAPI App    │
     │   (Postgres:15)  │  │   (Build from    │
     │                   │  │    Dockerfile)   │
     ├──────────────────┤  ├──────────────────┤
     │ DB:5432          │  │ App:8000        │
     │ -v pgdata:/...   │  │ HEALTHCHECK ✅   │
     ✓ Healthcheck ✓    │  ✓ Depends on DB   │
     └──────────────────┘  └──────────────────┘
           ┌─────────────────────────┐
           │      Docker Volume      │
           │      pgdata             │
           │    (Persistent Data)    │
           └─────────────────────────┘
```

### Architecture Features

- ✅ **Health Checks** - Database health check before app starts
- ✅ **Data Persistence** - PostgreSQL data stored in Docker volume
- ✅ **Auto-rebuild** - `docker-compose up --build` rebuilds on changes
- ✅ **Environment Variables** - Secure via `.env` file (not in images)
- ✅ **Clean Architecture** - Separate containers for DB and app

### Cleanup Commands

```bash
# Stop and remove containers
docker-compose down

# Remove containers, volumes, and networks
docker-compose down -v

# Rebuild with updated code
docker-compose up -d --build
```


---

## 📚 Quick Reference Commands

### Development (Direct Python)
```bash
# Install dependencies (on your deployment machine)
pip install -r requirements.txt

# Start directly without Docker (for testing)
uvicorn main:app --reload --host 0.0.0.0 --port 8000 &

# Run tests
python test_api.py
```

### Docker Deployment
```bash
# Initial setup (one-time only)
./deploy.sh setup          # Creates .env from example

# Edit .env with your database credentials:
nano .env                 # Update DB_USER, DB_PASSWORD

# Start all services  
./deploy.sh start         # Starts both API + PostgreSQL

# View logs
./deploy.sh logs          # Watch container logs

# Check status
./deploy.sh ps            # See running containers

# Stop service
./deploy.sh stop          # Shut down everything
```

### API Examples (cURL)

#### Create Short URL
```bash
curl -X POST http://localhost:8000/api/v1/shorten \
  -H "Content-Type: application/json" \
  -d '{"original_url": "https://www.example.com/my-long-url-here"}'
  
# Response:
# {
#   "id": 1,
#   "original_url": "https://www.example.com/my-long-url-here",
#   "short_code": "kR3mPn9",
#   "created_at": "2026-10-01T..."
# }
```

#### Get Short URL Info (any case works!)
```bash
curl http://localhost:8000/api/v1/kR3mPn9
curl http://localhost:8000/api/v1/kr3mpn9    # lowercase also works!
curl http://localhost:8000/api/v1/KR3MPN9    # UPPERCASE also works!
```

#### Delete Short URL
```bash
curl -X DELETE http://localhost:8000/api/v1/kR3mPn9
```

### Production Deployment Options

#### Option 1: Systemd (Linux)
Create `/etc/systemd/system/url-shortener.service`:
```ini
[Unit]
Description=URL Shortener API Service
After=network.target postgresql.service

[Service]
User=www-data
Group=www-data
WorkingDirectory=/path/to/url_shortner
Environment="PATH=/usr/local/bin:/usr/bin"
ExecStart=/usr/local/bin/uvicorn main:app --host 0.0.0.0 --port 8000
Restart=always

[Install]
WantedBy=multi-user.target
```

#### Option 2: Docker Production (docker-compose.prod.yml)
Create a production compose file with:
- HTTPS enabled (Traefik/Nginx reverse proxy)
- Read-only filesystem
- No .env in image
- Health checks
- Resource limits

See `deploy.sh` script for more advanced usage.

---

## 🔒 Security Considerations

1. **Database Password**: Never expose `.env` files publicly or commit to version control without proper secrets management (GitHub Actions, Docker Secrets, etc.)

2. **HTTPS**: Always use SSL/TLS in production (Let's Encrypt via Caddy/Nginx)

3. **CORS Configuration**: The API allows requests only from localhost for development security:
   ```python
   # In main.py - Allows specific origins only
   allow_origins=[
       "http://127.0.0.1:8000",
       "http://localhost:8000",
   ]
   ```
   For production, update with your domain or configure via a reverse proxy (Nginx/Traefik).

4. **Rate Limiting**: Add middleware for rate limiting if needed:
   ```python
   from fastapi.middleware.cors import CORSMiddleware
   from starlette.middleware import Middleware
   
   # Example with slowapi for rate limiting
   ```

5. **Input Validation**: The app already validates URL length and generates secure codes

6. **Secrets Management**: Store API keys, database credentials in environment variables or secrets managers (AWS Secrets Manager, Azure Key Vault, HashiCorp Vault).

---

## 📊 Monitoring & Maintenance

### Check Health
```bash
curl http://localhost:8000/health
# Expected: {"status": "healthy", "service": "URL Shortener"}
```

### Database Backup (PostgreSQL)
```bash
docker exec urlshortener-db pg_dump -U postgres urlshortener > backup.sql
docker cp urlshortener-db:/var/lib/postgresql/data/pgdata /backup/path
```

### Clean Up Old Entries
```sql
-- Example: Delete short URLs older than 1 year
DELETE FROM short_urls WHERE created_at < NOW() - INTERVAL '1 year';
```

---

## 📦 Project Files Explained

| File | Purpose |
|------|---------|
| `Dockerfile` | Builds the FastAPI application image |
| `docker-compose.yml` | Orchestrates PostgreSQL + API containers |
| `docker-compose.override.yml` | Development overrides (mounted code, port changes) |
| `.env` | Environment variables (DO NOT COMMIT) |
| `.env.docker` | Docker-specific environment template |
| `init.sql` | Database schema initialization |
| `main.py` | FastAPI application entry point |
| `api/v1/routers/urls.py` | API route handlers |
| `app/models.py` | SQLAlchemy database models |
| `app/database.py` | Database connection pool |
| `requirements.txt` | Python package dependencies |
| `test_api.py` | Automated testing script |
| `deploy.sh` | Deployment automation script |

---

## 📮 License & Attribution

MIT License - Feel free to use, modify, and distribute.

Built with ❤️ using FastAPI, SQLAlchemy, and PostgreSQL.

Happy Shortening! 🎉
