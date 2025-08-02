#!/bin/bash

# Likha Licensing Platform - Development Logs Script
# This script shows logs from the development environment

set -e

# Colors for output
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

echo -e "${BLUE}📋 Likha Licensing Platform - Development Logs${NC}"
echo ""

# Check if services are running
if ! $COMPOSE_CMD ps | grep "Up" > /dev/null; then
    echo -e "${YELLOW}⚠️  No services appear to be running. Start them with: scripts/dev-start.sh${NC}"
    exit 1
fi

# Default to following logs for app service, but allow override
SERVICE=${1:-app}

if [ "$SERVICE" = "help" ] || [ "$SERVICE" = "--help" ] || [ "$SERVICE" = "-h" ]; then
    echo -e "${BLUE}Likha Licensing Platform - Development Logs Script${NC}"
    echo ""
    echo "Usage: $0 [SERVICE]"
    echo ""
    echo "Available services:"
    echo "  app         Spring Boot application (default)"
    echo "  postgres    PostgreSQL database"
    echo "  redis       Redis cache"
    echo "  minio       MinIO S3 storage"
    echo "  adminer     Database management tool"
    echo "  all         All services"
    echo ""
    echo "Examples:"
    echo "  $0                # Follow app logs"
    echo "  $0 postgres       # Follow database logs"
    echo "  $0 all            # Follow all service logs"
    exit 0
elif [ "$SERVICE" = "all" ]; then
    echo -e "${GREEN}📊 Following logs for all services...${NC}"
    echo -e "${YELLOW}💡 Press Ctrl+C to stop${NC}"
    echo ""
    $COMPOSE_CMD logs -f
else
    echo -e "${GREEN}📊 Following logs for service: $SERVICE${NC}"
    echo -e "${YELLOW}💡 Press Ctrl+C to stop${NC}"
    echo -e "${BLUE}Available services: app, postgres, redis, minio, adminer${NC}"
    echo ""
    $COMPOSE_CMD logs -f $SERVICE
fi