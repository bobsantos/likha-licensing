#!/bin/bash

# Likha Licensing Platform - Development Environment Startup Script
# This script starts the complete development environment using Docker Compose

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Starting Likha Licensing Platform Development Environment${NC}"
echo ""

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}❌ Docker is not running. Please start Docker and try again.${NC}"
    exit 1
fi

# Check if Docker Compose is available
if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null 2>&1; then
    echo -e "${RED}❌ Docker Compose is not available. Please install Docker Compose and try again.${NC}"
    exit 1
fi

# Determine Docker Compose command
if docker compose version &> /dev/null 2>&1; then
    COMPOSE_CMD="docker compose"
else
    COMPOSE_CMD="docker-compose"
fi

echo -e "${YELLOW}📋 Checking environment configuration...${NC}"

# Check if .env file exists
if [ ! -f ".env" ]; then
    echo -e "${YELLOW}⚠️  .env file not found. Creating from template...${NC}"
    if [ -f ".env.example" ]; then
        cp .env.example .env
        echo -e "${GREEN}✅ Created .env file from template${NC}"
        echo -e "${YELLOW}📝 Please review and update .env file with your preferred settings${NC}"
    else
        echo -e "${RED}❌ .env.example template not found${NC}"
        exit 1
    fi
fi

echo -e "${YELLOW}🧹 Cleaning up any existing containers...${NC}"
# Remove any existing containers with the same names to prevent conflicts
docker rm -f likha-app likha-postgres likha-redis likha-minio likha-minio-init likha-adminer 2>/dev/null || true
$COMPOSE_CMD --profile tools down --remove-orphans --timeout 10

echo -e "${YELLOW}📦 Building application container...${NC}"
$COMPOSE_CMD build app

echo -e "${YELLOW}🏗️  Starting services...${NC}"
$COMPOSE_CMD --profile tools up -d

echo ""
echo -e "${GREEN}✅ Development environment started successfully!${NC}"
echo ""
echo -e "${BLUE}📍 Available Services:${NC}"
echo -e "   🌐 Application: http://localhost:8080"
echo -e "   🗄️  Database: localhost:5432 (postgres/postgres)"
echo -e "   🛠️  Adminer: http://localhost:8081"
echo -e "   📊 Redis: localhost:6379"
echo -e "   🗂️  MinIO S3: http://localhost:9000 (API), http://localhost:9001 (Console)"
echo ""
echo -e "${BLUE}📋 Useful Commands:${NC}"
echo -e "   View logs: ${COMPOSE_CMD} logs -f"
echo -e "   Stop services: ${COMPOSE_CMD} --profile tools down"
echo -e "   Restart app: ${COMPOSE_CMD} restart app"
echo -e "   Database shell: ${COMPOSE_CMD} exec postgres psql -U postgres -d likha_licensing"
echo ""
echo -e "${YELLOW}⏳ Validating service startup...${NC}"

# Function to check if curl is available
check_curl() {
    if ! command -v curl &> /dev/null; then
        echo -e "${RED}❌ curl is required for health checks but not found${NC}"
        echo -e "${YELLOW}   Please install curl: brew install curl (macOS) or apt-get install curl (Ubuntu)${NC}"
        exit 1
    fi
}

# Function to get container logs for troubleshooting
get_service_logs() {
    local service=$1
    local lines=${2:-20}
    echo -e "${YELLOW}📋 Last $lines lines from $service logs:${NC}"
    echo "---"
    $COMPOSE_CMD logs --tail=$lines $service 2>/dev/null || echo "Could not retrieve logs for $service"
    echo "---"
}

# Function to check service health with timeout
wait_for_service() {
    local service_name=$1
    local health_check_cmd=$2
    local timeout_seconds=$3
    local check_interval=${4:-2}
    local description=$5
    
    echo -n "⏳ Waiting for $description"
    local elapsed=0
    local success=false
    
    while [ $elapsed -lt $timeout_seconds ]; do
        if eval "$health_check_cmd" > /dev/null 2>&1; then
            echo -e " ${GREEN}✅ Ready${NC}"
            success=true
            break
        fi
        echo -n "."
        sleep $check_interval
        elapsed=$((elapsed + check_interval))
    done
    
    if [ "$success" = false ]; then
        echo -e " ${RED}❌ Timeout after ${timeout_seconds}s${NC}"
        echo -e "${RED}❌ $description failed to start within $timeout_seconds seconds${NC}"
        echo ""
        get_service_logs $service_name
        return 1
    fi
    
    return 0
}

# Function to validate Spring Boot health endpoint
validate_spring_boot_health() {
    local health_response
    health_response=$(curl -s --max-time 5 http://localhost:8080/actuator/health 2>/dev/null)
    local curl_exit_code=$?
    
    if [ $curl_exit_code -ne 0 ]; then
        return 1
    fi
    
    # Check if response contains "UP" status
    if echo "$health_response" | grep -q '"status":"UP"'; then
        return 0
    else
        echo -e "${YELLOW}⚠️  Health endpoint returned: $health_response${NC}"
        return 1
    fi
}

# Ensure curl is available
check_curl

# Comprehensive service validation
echo ""
echo -e "${BLUE}🔍 Validating service health...${NC}"

# 1. Wait for PostgreSQL
if ! wait_for_service "postgres" "$COMPOSE_CMD exec -T postgres pg_isready -U postgres -d likha_licensing" 60 2 "PostgreSQL database"; then
    echo -e "${RED}❌ PostgreSQL startup failed${NC}"
    echo -e "${YELLOW}💡 Try: $COMPOSE_CMD logs postgres${NC}"
    exit 1
fi

# 2. Wait for Redis
if ! wait_for_service "redis" "$COMPOSE_CMD exec -T redis redis-cli ping | grep -q PONG" 30 2 "Redis cache"; then
    echo -e "${RED}❌ Redis startup failed${NC}"
    echo -e "${YELLOW}💡 Try: $COMPOSE_CMD logs redis${NC}"
    exit 1
fi

# 2.1. Wait for MinIO
if ! wait_for_service "minio" "curl -s --max-time 5 http://localhost:9000/minio/health/live > /dev/null" 60 2 "MinIO S3 storage"; then
    echo -e "${RED}❌ MinIO startup failed${NC}"
    echo -e "${YELLOW}💡 Try: $COMPOSE_CMD logs minio${NC}"
    exit 1
fi

# 2.5. Wait for Adminer
if ! wait_for_service "adminer" "curl -s --max-time 5 http://localhost:8081 > /dev/null" 30 2 "Adminer database manager"; then
    echo -e "${RED}❌ Adminer startup failed${NC}"
    echo -e "${YELLOW}💡 Try: $COMPOSE_CMD logs adminer${NC}"
    exit 1
fi

# 3. Wait for Spring Boot application
echo -n "⏳ Waiting for Spring Boot application"
spring_boot_ready=false
timeout_seconds=90
elapsed=0
check_interval=3

while [ $elapsed -lt $timeout_seconds ]; do
    if validate_spring_boot_health; then
        echo -e " ${GREEN}✅ Ready${NC}"
        spring_boot_ready=true
        break
    fi
    echo -n "."
    sleep $check_interval
    elapsed=$((elapsed + check_interval))
done

if [ "$spring_boot_ready" = false ]; then
    echo -e " ${RED}❌ Timeout after ${timeout_seconds}s${NC}"
    echo ""
    echo -e "${RED}❌ Spring Boot application failed to start or become healthy${NC}"
    echo ""
    echo -e "${YELLOW}🔍 Checking application logs for errors...${NC}"
    get_service_logs "app" 30
    echo ""
    echo -e "${YELLOW}💡 Troubleshooting steps:${NC}"
    echo -e "   1. Check full logs: $COMPOSE_CMD logs app"
    echo -e "   2. Check if port 8080 is already in use: lsof -i :8080"
    echo -e "   3. Restart services: $COMPOSE_CMD restart"
    echo -e "   4. If issues persist, rebuild: $COMPOSE_CMD down && $COMPOSE_CMD build --no-cache"
    echo ""
    exit 1
fi

# 4. Final comprehensive health validation
echo ""
echo -e "${BLUE}🧪 Running final health validation...${NC}"

# Check all service endpoints
services_healthy=true

# PostgreSQL connection test
echo -n "🗄️  PostgreSQL connection"
if $COMPOSE_CMD exec -T postgres psql -U postgres -d likha_licensing -c "SELECT 1;" > /dev/null 2>&1; then
    echo -e " ${GREEN}✅${NC}"
else
    echo -e " ${RED}❌${NC}"
    services_healthy=false
fi

# Redis connection test
echo -n "📊 Redis connection"
if $COMPOSE_CMD exec -T redis redis-cli set test_key "test_value" > /dev/null 2>&1 && \
   $COMPOSE_CMD exec -T redis redis-cli get test_key | grep -q "test_value" > /dev/null 2>&1 && \
   $COMPOSE_CMD exec -T redis redis-cli del test_key > /dev/null 2>&1; then
    echo -e " ${GREEN}✅${NC}"
else
    echo -e " ${RED}❌${NC}"
    services_healthy=false
fi

# Spring Boot detailed health check
echo -n "🌐 Application health endpoint"
health_response=$(curl -s --max-time 10 http://localhost:8080/actuator/health 2>/dev/null)
if echo "$health_response" | grep -q '"status":"UP"'; then
    echo -e " ${GREEN}✅${NC}"
    # Check for any component failures
    if echo "$health_response" | grep -q '"status":"DOWN"'; then
        echo -e "${YELLOW}⚠️  Some health components are DOWN:${NC}"
        echo "$health_response" | grep -E '"status":"DOWN"|"status":"OUT_OF_SERVICE"' | head -3
        services_healthy=false
    fi
else
    echo -e " ${RED}❌${NC}"
    echo -e "${YELLOW}   Response: $health_response${NC}"
    services_healthy=false
fi

# Check application startup endpoint (if available)
echo -n "🚀 Application startup status"
if curl -s --max-time 5 http://localhost:8080/actuator/health/readiness > /dev/null 2>&1; then
    echo -e " ${GREEN}✅${NC}"
else
    # Not all Spring Boot apps have readiness probe, so this is optional
    echo -e " ${YELLOW}⚠️  (readiness probe not available)${NC}"
fi

# Check MinIO availability
echo -n "🗂️  MinIO S3 availability"
if curl -s --max-time 5 http://localhost:9000/minio/health/live > /dev/null 2>&1; then
    echo -e " ${GREEN}✅${NC}"
else
    echo -e " ${RED}❌${NC}"
    services_healthy=false
fi

# Check Adminer availability
echo -n "🛠️  Adminer availability"
if curl -s --max-time 5 http://localhost:8081 > /dev/null 2>&1; then
    echo -e " ${GREEN}✅${NC}"
else
    echo -e " ${RED}❌${NC}"
    services_healthy=false
fi

if [ "$services_healthy" = false ]; then
    echo ""
    echo -e "${RED}❌ Some services are not healthy. Please check the logs above.${NC}"
    echo -e "${YELLOW}💡 Run 'scripts/dev-logs.sh all' to see all service logs${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}🎉 All services are healthy and ready!${NC}"
echo ""
echo -e "${BLUE}📍 Available Services:${NC}"
echo -e "   🌐 Application: http://localhost:8080 (Status: ${GREEN}Healthy${NC})"
echo -e "   🗄️  PostgreSQL: localhost:5432 (Status: ${GREEN}Connected${NC})"
echo -e "   📊 Redis: localhost:6379 (Status: ${GREEN}Connected${NC})"
echo -e "   🗂️  MinIO S3: http://localhost:9000 (Status: ${GREEN}Running${NC})"
echo -e "   🛠️  Adminer: http://localhost:8081 (Status: ${GREEN}Available${NC})"
echo ""
echo -e "${BLUE}📋 Useful Commands:${NC}"
echo -e "   View logs: $COMPOSE_CMD logs -f [service]"
echo -e "   Stop services: $COMPOSE_CMD --profile tools down"
echo -e "   Restart app: $COMPOSE_CMD restart app"
echo -e "   Database shell: $COMPOSE_CMD exec postgres psql -U postgres -d likha_licensing"
echo -e "   Follow all logs: scripts/dev-logs.sh all"
echo ""
echo -e "${GREEN}💡 Development environment is ready for use!${NC}"