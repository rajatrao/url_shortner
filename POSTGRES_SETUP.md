# 🐘 PostgreSQL Database Setup in Docker

## ✅ Configuration Complete!

The URL Shortener service is now fully configured to work with PostgreSQL in Docker. All necessary files have been created and configured.

---

## 📁 Critical Files Created

| File | Purpose | Location |
|------|---------|----------|
| `docker-compose.yml` | Orchestrates DB + API containers | `/hackathon/url_shortner/docker-compose.yml` |
| `.env` | Database credentials & config | `/hackathon/url_shortner/.env` |
| `pg_hba.conf` | PostgreSQL authentication rules | `/hackathon/url_shortner/pg_hba.conf` |
| `init.sql` | Database schema initialization | `/hackathon/url_shortner/init.sql` |

---

## 🔐 Database Connection Configuration

### Environment Variables (.env)

```bash
DB_USER=urlshortener              # PostgreSQL username
DB_PASSWORD=YourSecurePassword!23  # ← CHANGE THIS!
POSTGRES_DB=urlshortener          # Database name
```

### Docker Compose Network Setup

The services create an isolated Docker network where:
- **API container** connects to database using hostname `database`
- No direct localhost connection needed (Docker handles it)
- Port 5432 exposed for external access if needed

---

## 🚀 Deployment Steps

### 1. Edit Database Credentials

```bash
cd /Users/rajat/Downloads/hackathon/url_shortner
nano .env              # Edit with YOUR password!
```

**SECURITY WARNING**: Change `DB_PASSWORD` before use in production!

### 2. Start the Service

```bash
# Full docker-compose setup
docker-compose up -d --build

# Or use the deployment script  
./deploy.sh start
```

The service will:
1. Pull PostgreSQL 15 Alpine image
2. Create database with your credentials
3. Initialize schema from `init.sql`
4. Start FastAPI application

### 3. Access the Service

- Swagger UI: `http://localhost:8000/docs`
- Health check: `curl http://localhost:8000/health`

---

## 📊 PostgreSQL Architecture

```
┌─────────────────────────────────────┐
│          Docker Host                │
├─────────────────────────────────────┤
│                                     │
│   ┌─────────────────┐    ┌─────────┐│
│   │  urlshortener-db│    │urlshort-├──→ Port 8000 (API)
│   │                 │    │ ner-api ││     Port 5432 (DB)
│   │ PostgreSQL:15   │◄──►│         ││
│   ├─────────────────┤    └─────────┘│
│   │ Password-based auth│              │
│   ├── Health check enabled              │
│   ├── Auto-initialization on start       │
│   └── Data persisted in pvolume        │
│                                     │
│  urlshortener-network (internal)     │
│         ↓                            │
└─────────────────────────────────────┘
```

---

## 🔧 Troubleshooting

### Can't connect to database?

```bash
# Check if PostgreSQL container is running
docker-compose ps

# View database logs
docker-compose logs database

# Restart services  
docker-compose restart
```

### Database initialization failed?

```bash
# Rebuild and restart
docker-compose --no-cache build
docker-compose up -d

# Or reset completely
docker-compose down -v  # -v removes volumes
./deploy.sh start       # Start fresh
```

---

## 📝 PostgreSQL Configuration

### pg_hba.conf (Authentication)

```
# TYPE  DATABASE        USER            ADDRESS                 METHOD
local   all             postgres                                     peer
local   all             all                                       md5
host    all             all             127.0.0.1/32            md5
host    all             all             ::1/128                 md5
host    urlshortener    all             0.0.0.0/0               pam
```

- **Peer**: Local connections trust the OS user
- **md5**: Password-based authentication for network connections
- **pam**: System authentication (optional, for host connections)

---

## ✅ Verification Checklist

Before starting the service:

- [ ] Docker installed and running
- [ ] `.env` file exists with your credentials
- [ ] `DB_PASSWORD` changed from default
- [ ] Database schema initialized on first start
- [ ] Both containers show as "Up" in `docker-compose ps`

---

## 🎯 Quick Start Command

```bash
cd /Users/rajat/Downloads/hackathon/url_shortner
./deploy.sh start     # Sets up and starts everything!
```

Then open: http://localhost:8000/docs

---

**Need more help?** See the [setup.sh](file:///Users/rajat/Downloads/hackathon/url_shortner/setup.sh) guide for detailed troubleshooting steps.

