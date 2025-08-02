#!/bin/bash

# Likha Licensing Platform - Development Environment Stop Script
# This script stops the development environment and optionally cleans up

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Determine Docker Compose command
if docker compose version &> /dev/null 2>&1; then
    COMPOSE_CMD="docker compose"
else
    COMPOSE_CMD="docker-compose"
fi

echo -e "${BLUE}🛑 Stopping Likha Licensing Platform Development Environment${NC}"
echo ""

# Parse arguments
CLEAN_VOLUMES=false

# Show help
if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    echo -e "${BLUE}Likha Licensing Platform - Development Environment Stop Script${NC}"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --clean, -c      Stop services and remove all volumes/data"
    echo "  --clean-all, -ca Stop services, remove volumes/data, and clean Docker images"
    echo "  --help, -h       Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                    # Standard stop"
    echo "  $0 --clean           # Stop and remove all data"
    echo "  $0 --clean-all       # Stop, remove data, and clean Docker images"
    exit 0
fi

if [ "$1" = "--clean" ] || [ "$1" = "-c" ]; then
    CLEAN_VOLUMES=true
    echo -e "${YELLOW}⚠️  Clean mode: Will remove all volumes and data${NC}"
    echo ""
fi

# Stop and remove containers
echo -e "${YELLOW}🔄 Stopping services...${NC}"

if [ "$CLEAN_VOLUMES" = true ]; then
    echo -e "${YELLOW}🛑 Force stopping all containers...${NC}"
    
    # Force stop containers by name (in case they're unresponsive)
    docker stop likha-app likha-postgres likha-redis likha-minio likha-minio-init likha-adminer 2>/dev/null || true
    docker kill likha-app likha-postgres likha-redis likha-minio likha-minio-init likha-adminer 2>/dev/null || true
    
    # Remove containers by name to ensure cleanup
    echo -e "${YELLOW}🗑️  Removing containers...${NC}"
    docker rm -f likha-app likha-postgres likha-redis likha-minio likha-minio-init likha-adminer 2>/dev/null || true
    
    # Use compose down with volumes and remove orphans
    $COMPOSE_CMD down -v --remove-orphans --timeout 10
    
    # Wait a moment for cleanup to complete
    sleep 2
    
    echo -e "${YELLOW}🧹 Cleaning up volumes...${NC}"
    
    # Remove volumes with project prefix (new format)
    docker volume rm likha-licensing_postgres_data 2>/dev/null || true
    docker volume rm likha-licensing_redis_data 2>/dev/null || true
    docker volume rm likha-licensing_minio_data 2>/dev/null || true
    docker volume rm likha-licensing_maven_cache 2>/dev/null || true
    docker volume rm likha-licensing_frontend_node_modules 2>/dev/null || true
    
    # Remove volumes with underscore prefix (legacy format)
    docker volume rm likha-licensing-postgres_data 2>/dev/null || true
    docker volume rm likha-licensing-redis_data 2>/dev/null || true
    docker volume rm likha-licensing-minio_data 2>/dev/null || true
    docker volume rm likha-licensing-maven_cache 2>/dev/null || true
    docker volume rm likha-licensing-frontend_node_modules 2>/dev/null || true
    
    # Clean up any orphaned containers from this project
    echo -e "${YELLOW}🧹 Removing orphaned containers...${NC}"
    docker container prune -f --filter "label=com.docker.compose.project=likha-licensing" 2>/dev/null || true
    
    # Clean up any dangling networks
    docker network rm likha-licensing-network 2>/dev/null || true
    docker network prune -f --filter "label=com.docker.compose.project=likha-licensing" 2>/dev/null || true
    
    # Verify containers are completely removed
    echo -e "${YELLOW}🔍 Verifying container cleanup...${NC}"
    REMAINING_CONTAINERS=$(docker ps -a --filter "name=likha-" --format "{{.Names}}" 2>/dev/null || true)
    if [ -n "$REMAINING_CONTAINERS" ]; then
        echo -e "${YELLOW}⚠️  Found remaining containers: $REMAINING_CONTAINERS${NC}"
        echo -e "${YELLOW}🗑️  Force removing remaining containers...${NC}"
        echo "$REMAINING_CONTAINERS" | xargs -r docker rm -f 2>/dev/null || true
    fi
    
    echo -e "${GREEN}✅ Complete cleanup finished${NC}"
else
    # Standard shutdown without cleanup
    $COMPOSE_CMD down --remove-orphans --timeout 10
fi

# Clean up dangling images if requested
if [ "$1" = "--clean-all" ] || [ "$1" = "-ca" ]; then
    echo -e "${YELLOW}🧹 Cleaning up Docker images and build cache...${NC}"
    docker system prune -f
    echo -e "${GREEN}✅ Docker cleanup completed${NC}"
fi

echo ""
echo -e "${GREEN}✅ Development environment stopped successfully${NC}"
echo ""
echo -e "${BLUE}📋 Commands:${NC}"
echo -e "   Start again: scripts/dev-start.sh"
echo -e "   Clean restart: scripts/dev-stop.sh --clean && scripts/dev-start.sh"
echo ""

if [ "$CLEAN_VOLUMES" = true ]; then
    echo -e "${RED}⚠️  All data has been removed. Next startup will initialize fresh databases.${NC}"
fi