#!/bin/bash
# Initial setup guide for URL Shortener Docker deployment
# Run this once before starting the service

set -e

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_DIR"

echo "=============================================================="
echo "   🐳 URL SHORTENER DOCKER SETUP GUIDE"
echo "=============================================================="
echo ""

# Check if docker is installed
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker is not installed on this machine.${NC}"
    echo "Please install Docker first:"
    echo "  macOS: brew install --cask docker"
    echo "  Linux: curl -fsSL https://get.docker.com | sh"
    exit 1
fi

echo -e "${GREEN}✓ Docker is installed${NC}"
echo ""

# Check if docker-compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo -e "${YELLOW}⚠️  Docker Compose not found. Checking for compose plugin...${NC}"
    if docker compose version &> /dev/null; then
        echo "Using Docker Compose v2 (built-in)..."
    else
        echo -e "${RED}❌ Please install Docker Compose:${NC}"
        echo "  macOS: brew install docker-compose"
        echo "  Linux: apt install docker-compose"
        exit 1
    fi
fi

echo -e "${GREEN}✓ Docker Compose is available${NC}"
echo ""

# Check if .env exists
if [ ! -f .env ]; then
    log_info "Creating configuration files..."
    
    # Create base .env file
    cat > .env << 'ENVEOF'
# ==========================================
# URL Shortener Docker Environment
# IMPORTANT: Change DB_PASSWORD before using!
# ==========================================

DATABASE_URL=postgresql://${DB_USER:-urlshortener}:${DB_PASSWORD:-YOUR_CHANGE_THIS_PASSWORD123!}@database:5432/urlshortener
DB_HOST=database
DB_PORT=5432
DB_NAME=urlshortener
ENVEOF
    
    log_success ".env created"
    echo ""
    echo -e "${YELLOW}⚠️  IMPORTANT: Edit .env file with your credentials!${NC}"
    echo "You can use:"
    echo "  nano .env       # to edit the file"
    echo ""
fi

echo "=============================================================="
echo "   📦 PROJECT STRUCTURE"
echo "=============================================================="
echo ""

ls -la | grep -E "\.(py|md|sh|yml|txt|conf)$" | awk '{print "  "$NF}' | sed 's/[0-9]//g'
echo ""

echo "=============================================================="
echo "   🚀 TO START THE SERVICE"
echo "=============================================================="
echo ""
echo "1. Edit .env file with your database credentials:"
echo "   nano .env"
echo "   (Change DB_PASSWORD to something secure!)"
echo ""
echo "2. Start the service:"
echo "   ./deploy.sh start"
echo ""
echo "3. Access the API:"
echo "   Swagger Docs: http://localhost:8000/docs"
echo "   Health Check: curls localhost:8000/health"
echo ""

echo "=============================================================="
echo "   🔍 NEXT ACTIONS"
echo "=============================================================="
echo ""
echo "   View this guide again: bash setup.sh"
echo "   See deployment script: ./deploy.sh help"
echo "   Full documentation: README.md"
echo ""
