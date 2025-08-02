#!/bin/bash

# CM-0001-T001: Docker Development Environment Runtime Tests
# These tests validate that running services are healthy and functional

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test results tracking
TESTS_PASSED=0
TESTS_FAILED=0
FAILED_TESTS=()

echo -e "${BLUE}🚀 CM-0001-T001: Docker Development Environment Runtime Tests${NC}"
echo -e "${BLUE}================================================================${NC}"
echo ""

# Function to run a test with timeout
run_runtime_test() {
    local test_name="$1"
    local test_command="$2"
    local expected_outcome="$3"
    local timeout_seconds="${4:-30}"
    
    echo -n "Testing: $test_name ... "
    
    # Use gtimeout if available (macOS with coreutils), otherwise use bash with job control
    if command -v gtimeout > /dev/null 2>&1; then
        if gtimeout "$timeout_seconds" bash -c "$test_command" > /dev/null 2>&1; then
            echo -e "${GREEN}✅ PASS${NC}"
            TESTS_PASSED=$((TESTS_PASSED + 1))
        else
            echo -e "${RED}❌ FAIL${NC}"
            TESTS_FAILED=$((TESTS_FAILED + 1))
            FAILED_TESTS+=("$test_name: $expected_outcome")
        fi
    else
        # Fallback for systems without timeout command
        if eval "$test_command" > /dev/null 2>&1; then
            echo -e "${GREEN}✅ PASS${NC}"
            TESTS_PASSED=$((TESTS_PASSED + 1))
        else
            echo -e "${RED}❌ FAIL${NC}"
            TESTS_FAILED=$((TESTS_FAILED + 1))
            FAILED_TESTS+=("$test_name: $expected_outcome")
        fi
    fi
}

# Function to test HTTP endpoint
test_http_endpoint() {
    local test_name="$1"
    local url="$2"
    local expected_status="${3:-200}"
    local timeout_seconds="${4:-30}"
    
    echo -n "Testing: $test_name ... "
    
    local status
    # Use gtimeout if available, otherwise use curl's built-in timeout
    if command -v gtimeout > /dev/null 2>&1; then
        status=$(gtimeout "$timeout_seconds" curl -s -o /dev/null -w "%{http_code}" "$url" 2>/dev/null || echo "000")
    else
        status=$(curl --max-time "$timeout_seconds" -s -o /dev/null -w "%{http_code}" "$url" 2>/dev/null || echo "000")
    fi
    
    if [ "$status" = "$expected_status" ]; then
        echo -e "${GREEN}✅ PASS (HTTP $status)${NC}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${RED}❌ FAIL (HTTP $status, expected $expected_status)${NC}"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        FAILED_TESTS+=("$test_name: Expected HTTP $expected_status, got $status")
    fi
}

# Check if services are running
echo -e "${YELLOW}Checking if Docker services are running...${NC}"

# Determine Docker Compose command
if docker compose version &> /dev/null 2>&1; then
    COMPOSE_CMD="docker compose"
else
    COMPOSE_CMD="docker-compose"
fi

# Check if services are up
if ! $COMPOSE_CMD ps | grep -q "Up"; then
    echo -e "${RED}❌ Docker services are not running!${NC}"
    echo -e "${YELLOW}Please run 'scripts/dev-start.sh' first${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Docker services are running${NC}"
echo ""

# RT1: Database connectivity and health
echo -e "${YELLOW}RT1: Database Service Health${NC}"
run_runtime_test "PostgreSQL container is running" "docker ps | grep -q 'likha-postgres'" "PostgreSQL container should be running"
run_runtime_test "PostgreSQL accepts connections" "docker exec likha-postgres pg_isready -U postgres -d likha_licensing" "PostgreSQL should accept connections"
run_runtime_test "Database port is accessible" "nc -z localhost 5432" "PostgreSQL port should be accessible from host"

# RT2: MinIO S3 service health
echo -e "${YELLOW}RT2: MinIO S3 Service Health${NC}"
run_runtime_test "MinIO container is running" "docker ps | grep -q 'likha-minio'" "MinIO container should be running"
test_http_endpoint "MinIO API health endpoint" "http://localhost:9000/minio/health/live" "200" 30
test_http_endpoint "MinIO Console accessibility" "http://localhost:9001" "200" 30
run_runtime_test "MinIO bucket initialization completed" "docker logs likha-minio-init 2>&1 | grep -q 'MinIO initialization completed'" "MinIO bucket should be created"

# RT3: Redis cache service health
echo -e "${YELLOW}RT3: Redis Cache Service Health${NC}"
run_runtime_test "Redis container is running" "docker ps | grep -q 'likha-redis'" "Redis container should be running"
run_runtime_test "Redis accepts connections" "docker exec likha-redis redis-cli ping | grep -q 'PONG'" "Redis should accept connections"
run_runtime_test "Redis port is accessible" "nc -z localhost 6379" "Redis port should be accessible from host"

# RT4: Backend application health
echo -e "${YELLOW}RT4: Backend Application Health${NC}"
run_runtime_test "Backend container is running" "docker ps | grep -q 'likha-app'" "Backend container should be running"

# Wait a bit for backend to fully start
echo -n "Waiting for backend application to start (30s) ... "
sleep 30
echo -e "${GREEN}Done${NC}"

test_http_endpoint "Backend health check endpoint" "http://localhost:8080/actuator/health" "200" 60
test_http_endpoint "Backend application root" "http://localhost:8080" "401" 30

# RT5: Service integration tests
echo -e "${YELLOW}RT5: Service Integration${NC}"
run_runtime_test "Backend can connect to database" "docker logs likha-app 2>&1 | grep -q 'Started.*in.*seconds'" "Backend should start successfully with database connection"
run_runtime_test "Flyway migrations executed" "docker logs likha-app 2>&1 | grep -q -i 'flyway.*community'" "Database migrations should execute"

# RT6: Development tools accessibility
echo -e "${YELLOW}RT6: Development Tools${NC}"
if $COMPOSE_CMD ps | grep -q 'adminer'; then
    test_http_endpoint "Adminer database tool" "http://localhost:8081" "200" 30
else
    echo "Adminer not running (tools profile not active) - skipping"
fi

# RT7: Networking and communication
echo -e "${YELLOW}RT7: Network Communication${NC}"
run_runtime_test "Services connected on same network" "docker network inspect likha-licensing-network | grep -q 'likha-app'" "All services should be on the same network"
run_runtime_test "Backend successfully connects to services" "docker logs likha-app 2>&1 | grep -q 'Started.*Application.*in.*seconds'" "Backend should start successfully indicating service connectivity"
run_runtime_test "All required containers present" "test $(docker ps --format '{{.Names}}' | grep -E '(likha-app|likha-postgres|likha-minio|likha-redis)' | wc -l) -eq 4" "All 4 main containers should be running"

echo ""
echo -e "${BLUE}📊 RUNTIME TEST RESULTS SUMMARY${NC}"
echo -e "${BLUE}================================${NC}"
echo -e "Tests Passed: ${GREEN}$TESTS_PASSED${NC}"
echo -e "Tests Failed: ${RED}$TESTS_FAILED${NC}"
echo -e "Total Tests: $((TESTS_PASSED + TESTS_FAILED))"

if [ $TESTS_FAILED -gt 0 ]; then
    echo ""
    echo -e "${RED}❌ FAILED RUNTIME TESTS:${NC}"
    for failed_test in "${FAILED_TESTS[@]}"; do
        echo -e "${RED}   • $failed_test${NC}"
    done
    echo ""
    echo -e "${YELLOW}💡 Debugging tips:${NC}"
    echo -e "   1. Check service logs: docker logs <container-name>"
    echo -e "   2. Verify service health: docker ps"
    echo -e "   3. Check network connectivity: docker network ls"
    echo -e "   4. Restart services if needed: scripts/dev-stop.sh && scripts/dev-start.sh"
    echo ""
    exit 1
else
    echo ""
    echo -e "${GREEN}🎉 ALL RUNTIME TESTS PASSED!${NC}"
    echo -e "${GREEN}Docker Development Environment is fully functional${NC}"
    echo ""
    echo -e "${BLUE}🔗 DEVELOPMENT ENDPOINTS:${NC}"
    echo -e "   • Backend API: http://localhost:8080"
    echo -e "   • Backend Health: http://localhost:8080/actuator/health"
    echo -e "   • MinIO Console: http://localhost:9001 (minioadmin/minioadmin123)"
    echo -e "   • MinIO API: http://localhost:9000"
    if $COMPOSE_CMD ps | grep -q 'adminer'; then
        echo -e "   • Database Tool: http://localhost:8081"
    fi
    echo ""
fi