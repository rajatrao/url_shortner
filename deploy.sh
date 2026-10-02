#!/bin/bash
# Deploy script for URL Shortener Service
# Usage: ./deploy.sh [command]

set -e

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_DIR"


# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color


log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}


case "${1:-status}" in
    start)
        log_info "Starting URL Shortener with Docker..."
        
        # Check if .env exists, create from example if not
        if [ ! -f .env ]; then
            log_warn ".env file not found. Creating from template..."
            cp .env.docker .env 2>/dev/null || echo "# Edit .env for your database credentials" > .env
            log_info "Please edit .env with your PostgreSQL credentials!"
        fi
        
        # Build and start
        docker-compose up -d --build
        sleep 15
        
        log_success "Services started!"
        ;;
    
    stop)
        log_info "Stopping URL Shortener..."
        docker-compose down
        log_success "All services stopped"
        ;;
    
    restart)
        log_info "Restarting URL Shortener..."
        docker-compose down
        sleep 2
        make start >/dev/null 2>&1 || docker-compose up -d --build
        log_success "Services restarted"
        ;;
    
    logs)
        NAMESPACE="${2:---follow}"
        log_info "Viewing container logs..."
        echo ""
        echo "$NAMESPACE" | grep -q "^-" && docker-compose logs "$NAMESPACE" || docker-compose logs -f
        ;;
    
    ps)
        log_info "Container Status:"
        docker-compose ps
        ;;
        
    build)
        log_info "Building Docker images..."
        docker-compose build --no-cache
        log_success "Build complete!"
        ;;

    clean)
        log_warn "Cleaning up containers and volumes..."
        docker-compose down -v
        log_success "Cleanup complete!"
        ;;
    
    setup)
        log_info "Setting up environment..."
        
        # Create .env if doesn't exist
        if [ ! -f .env ]; then
            cat > .env << 'ENVEOF'
# Database Configuration - UPDATE THESE VALUES!
DB_USER=urlshortener
# WARNING: Change this password before using in production!  
DB_PASSWORD=YourSecurePassword123!@#$%

# Server Configuration  
APP_PORT=8000
DB_PORT=5432
ENVEOF
            log_success ".env created with defaults"
            
            echo ""
            log_warn "IMPORTANT: Edit .env file to set your database credentials!"
            echo "You can edit it with:"
            echo "  nano .env    # or vim/nano/your preferred editor"
        fi
        
        log_success "Setup complete!"
        ;;

    help|usage)
        cat << HELPTEXT | column -t
       _______                    _   __     __          ___  __       
      / ____/\ \                | | / /    / /   _____/ (_)/ /    
     / /   /__\ \              | |/ /    / /   / __ \    | |/ /   
    / /___  /--\ \  ___  ______|   <   _< /   / /_/ /    |   <  
      \____\/__/ / / / / / /____/_|\_// \/   \____/       |_| \_\ 
     ============================================================

URL Shortener Deployment Script

Usage: ./deploy.sh {command} [options]

Commands:
  start          Start all services (rebuilds if needed)
  stop           Stop all containers  
  restart        Restart everything
  logs [--tail]  View container logs (optional line count)
  ps             Show container status
  build          Rebuild Docker images without running
  clean          Remove containers and volumes
  setup          Initialize environment files
  help           Show this help message

Environment Variables (edit .env):
  DB_USER        PostgreSQL username (default: urlshortener)  
  DB_PASSWORD    PostgreSQL password (CHANGE THIS!)
  APP_PORT       API port (default: 8000)
  DB_PORT        Database port (default: 5432)

Access Points:
  http://localhost:8000/docs        Swagger UI / API docs
  http://localhost:8000/health      Health check endpoint
HELPTEXT
        ;;

    *)
        log_error "Unknown command: $1"
        echo ""
        ./deploy.sh help
        exit 1
        ;;
esac

log_success "Command completed!"
