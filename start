#!/bin/bash
echo "=============================================================="
echo "   🚀 URL SHORTENER STARTUP SCRIPT"
echo "=============================================================="

# Check if .env exists
if [ ! -f .env ]; then
    echo ""
    echo -e "${YELLOW}⚠️  .env file not found!${NC}"
    echo "Please run: ./setup.sh or edit .env manually"
    echo ""
    exit 1
fi

# Check if docker-compose.yml exists
if [ ! -f docker-compose.yml ]; then
    log_error "docker-compose.yml not found!"
    exit 1
fi

echo ""
echo -e "${GREEN}Checking services...${NC}"

# Check Docker status
if ! docker info &> /dev/null; then
    echo -e "${RED}❌ Docker daemon is not running!${NC}"
    echo "Please start Docker Desktop first."
    exit 1
fi

echo -e "${GREEN}✓ Docker is running${NC}"

# Start services
docker-compose up -d --build

sleep 15

echo ""
echo -e "${GREEN}Services started successfully!${NC}"
echo ""
echo "=============================================================="
echo "   🌐 ACCESS THE SERVICE"
echo "=============================================================="
echo ""
echo "- Swagger UI (API Documentation): http://localhost:8000/docs"
echo "- Health Check Endpoint: curl localhost:8000/health"  
echo "- API Root: http://localhost:8000/"
echo ""
echo "=============================================================="
echo "   📊 STATUS OF RUNNING CONTAINERS"
echo "=============================================================="

docker-compose ps

echo ""
echo "=============================================================="
echo "   🛠️  USEFUL COMMANDS"
echo "=============================================================="
echo ""
echo "./deploy.sh logs     View logs"
echo "./deploy.sh stop     Stop services"
echo "./setup.sh           Reset configuration"
echo ""
echo -e "${GREEN}✅ Startup complete! Access http://localhost:8000/docs${NC}"
