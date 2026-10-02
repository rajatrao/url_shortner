#!/bin/bash
# Verification script for PostgreSQL Docker setup
PROJECT_DIR="$(pwd)"
cd "$PROJECT_DIR"

echo "=========================================="
echo "   PostgreSQL Configuration Check"
echo "=========================================="
echo ""

checksPassed=0
checksTotal=0

check_file() {
    local file=$1
    local desc=$2
    if [ -f "$file" ]; then
        echo -e "  ✓ $desc"
        ((checksPassed++))
        ((checksTotal++))
        return 0
    else
        echo -e "  ✗ $desc (NOT FOUND)"
        ((checksTotal++))
        return 1
    fi
}

check_env() {
    if [ -f ".env" ]; then
        # Check if default password is still there
        if grep -q "Change THIS\|# IMPORTANT" .env; then
            echo "  ⚠️  Default password in place (change before use!)"
            ((checksPassed++))
            ((checksTotal++))
        else
            echo "  ✓ .env file configured"
            ((checksPassed++))
            ((checksTotal++))
        fi
    else
        echo -e "  ✗ .env not found"
        ((checksTotal++))
    fi
}

check_docker_compose() {
    if [ -f "docker-compose.yml" ]; then
        # Check for healthcheck
        if grep -q "healthcheck:" docker-compose.yml; then
            echo "  ✓ Health checks configured"
            ((checksPassed++))
            ((checksTotal++))
        else
            check_file "docker-compose.yml" "Docker compose file exists"
        fi
    else
        check_file "docker-compose.yml" "Docker compose file exists"
    fi
}

# Run checks
check_env
check_docker_compose
check_file "pg_hba.conf" "PostgreSQL authentication config"
check_file "init.sql" "Database initialization script" 
check_file "Dockerfile" "Application Dockerfile"
check_file ".env.docker" "Environment template"
check_file "requirements.txt" "Python dependencies"

echo ""
echo "=========================================="
echo "   Summary: $checksPassed/$checksTotal checks passed"
echo "=========================================="

if [ $checksPassed -eq $checksTotal ]; then
    echo -e "\n  ✅ All configuration files are ready!"
    echo ""
    echo "  Next steps:"
    echo "   1. Edit .env with your secure password"  
    echo "   2. Run: ./deploy.sh start"
    echo "   3. Access: http://localhost:8000/docs"
else
    echo -e "\n  ⚠️   Some files need attention."
fi

