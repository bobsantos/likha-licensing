#!/bin/bash

# CM-0001-T001: Docker Development Environment Setup - Acceptance Tests
# These tests validate that the complete development environment meets all requirements

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

echo -e "${BLUE}🧪 CM-0001-T001: Docker Development Environment Acceptance Tests${NC}"
echo -e "${BLUE}================================================================${NC}"
echo ""

# Function to run a test
run_test() {
    local test_name="$1"
    local test_command="$2"
    local expected_outcome="$3"
    
    echo -n "Testing: $test_name ... "
    
    if eval "$test_command" > /dev/null 2>&1; then
        echo -e "${GREEN}✅ PASS${NC}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${RED}❌ FAIL${NC}"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        FAILED_TESTS+=("$test_name: $expected_outcome")
    fi
}

# Function to run a test with output capture
run_test_with_output() {
    local test_name="$1"
    local test_command="$2"
    local expected_pattern="$3"
    local description="$4"
    
    echo -n "Testing: $test_name ... "
    
    local output
    output=$(eval "$test_command" 2>&1)
    local exit_code=$?
    
    if [ $exit_code -eq 0 ] && echo "$output" | grep -q "$expected_pattern"; then
        echo -e "${GREEN}✅ PASS${NC}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${RED}❌ FAIL${NC}"
        echo -e "${YELLOW}   Expected: $description${NC}"
        echo -e "${YELLOW}   Got: $output${NC}"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        FAILED_TESTS+=("$test_name: $description")
    fi
}

# Determine Docker Compose command
if docker compose version &> /dev/null 2>&1; then
    COMPOSE_CMD="docker compose"
else
    COMPOSE_CMD="docker-compose"
fi

echo -e "${BLUE}📋 ACCEPTANCE CRITERIA TESTS${NC}"
echo ""

# AC1: Development environment starts with single command (docker-compose up)
echo -e "${YELLOW}AC1: Single Command Startup${NC}"
run_test "Docker Compose file exists" "test -f docker-compose.yaml" "docker-compose.yaml should exist"
run_test "Docker Compose file is valid" "$COMPOSE_CMD config" "docker-compose.yaml should be valid YAML"

# AC2: Database is accessible and properly configured  
echo -e "${YELLOW}AC2: Database Configuration${NC}"
run_test "PostgreSQL service defined" "$COMPOSE_CMD config | grep -q 'postgres:'" "PostgreSQL service should be defined"
run_test "Database environment variables set" "$COMPOSE_CMD config | grep -q 'POSTGRES_DB'" "Database environment should be configured"
run_test "Database port exposed" "$COMPOSE_CMD config | grep -q 'published.*5432'" "Database port should be exposed"
run_test "Database health check configured" "$COMPOSE_CMD config | grep -q 'pg_isready'" "Database health check should be present"

# AC3: MinIO S3 storage is running and accessible
echo -e "${YELLOW}AC3: MinIO S3 Storage${NC}"
run_test "MinIO service defined" "$COMPOSE_CMD config | grep -q 'minio'" "MinIO service should be defined in docker-compose"
run_test "MinIO API port exposed" "$COMPOSE_CMD config | grep -q '9000'" "MinIO API port should be exposed"
run_test "MinIO Console port exposed" "$COMPOSE_CMD config | grep -q '9001'" "MinIO Console port should be exposed"
run_test "MinIO bucket initialization service" "$COMPOSE_CMD config | grep -q 'minio-init'" "MinIO initialization service should be defined"
run_test "MinIO health check configured" "$COMPOSE_CMD config | grep -q 'minio/health/live'" "MinIO health check should be present"

# AC4: All services communicate properly
echo -e "${YELLOW}AC4: Service Communication${NC}"
run_test "Services use same network" "$COMPOSE_CMD config | grep -q 'likha-network'" "All services should use same network"
run_test "App depends on database" "$COMPOSE_CMD config | grep -A 5 'app:' | grep -q 'depends_on'" "App should depend on database"

# AC5: Environment variables are properly configured
echo -e "${YELLOW}AC5: Environment Configuration${NC}"
run_test "Spring profiles configured" "$COMPOSE_CMD config | grep -q 'SPRING_PROFILES_ACTIVE'" "Spring profiles should be set"
run_test "Database connection configured" "$COMPOSE_CMD config | grep -q 'SPRING_DATASOURCE_URL'" "Database connection should be configured"

# AC6: Backend services can connect to database and S3
echo -e "${YELLOW}AC6: Backend Integration${NC}"
run_test "JPA configuration present" "$COMPOSE_CMD config | grep -q 'SPRING_JPA'" "JPA configuration should be present"
run_test "Flyway migration configured" "$COMPOSE_CMD config | grep -q 'SPRING_FLYWAY'" "Flyway should be configured"
run_test "S3 endpoint configured" "$COMPOSE_CMD config | grep -q 'AWS_S3_ENDPOINT'" "S3 endpoint should be configured"
run_test "S3 bucket name configured" "$COMPOSE_CMD config | grep -q 'AWS_S3_BUCKET_NAME'" "S3 bucket name should be configured"
run_test "S3 credentials configured" "$COMPOSE_CMD config | grep -q 'AWS_ACCESS_KEY_ID'" "S3 access credentials should be configured"
run_test "App depends on MinIO" "$COMPOSE_CMD config | grep -A 10 'app:' | grep -A 5 'depends_on:' | grep -q 'minio'" "App should depend on MinIO service"

# AC7: Security configurations are in place
echo -e "${YELLOW}AC7: Security Configuration${NC}"
run_test "Security user configured" "$COMPOSE_CMD config | grep -q 'SPRING_SECURITY_USER'" "Security user should be configured"
run_test "Multi-tenancy enabled" "$COMPOSE_CMD config | grep -q 'APP_MULTITENANCY_ENABLED'" "Multi-tenancy should be enabled"

# Additional Infrastructure Tests
echo -e "${YELLOW}Additional Infrastructure Validation${NC}"
run_test "Redis cache service defined" "$COMPOSE_CMD config | grep -q 'redis'" "Redis service should be defined"
run_test "Volume persistence configured" "$COMPOSE_CMD config | grep -q 'postgres_data'" "Data volumes should be configured"
run_test "Development tools available" "$COMPOSE_CMD --profile tools config | grep -q 'adminer'" "Development tools should be available with tools profile"

# Environment File Tests
echo -e "${YELLOW}Environment Configuration Files${NC}"
run_test "Environment example file exists" "test -f .env.example" ".env.example should exist for new developers"

# Script Tests
echo -e "${YELLOW}Development Scripts${NC}"
run_test "Development start script exists" "test -f scripts/dev-start.sh" "Development start script should exist"
run_test "Development start script is executable" "test -x scripts/dev-start.sh" "Start script should be executable"
run_test "Development stop script exists" "test -f scripts/dev-stop.sh" "Development stop script should exist"

echo ""
echo -e "${BLUE}📊 TEST RESULTS SUMMARY${NC}"
echo -e "${BLUE}========================${NC}"
echo -e "Tests Passed: ${GREEN}$TESTS_PASSED${NC}"
echo -e "Tests Failed: ${RED}$TESTS_FAILED${NC}"
echo -e "Total Tests: $((TESTS_PASSED + TESTS_FAILED))"

if [ $TESTS_FAILED -gt 0 ]; then
    echo ""
    echo -e "${RED}❌ FAILED TESTS:${NC}"
    for failed_test in "${FAILED_TESTS[@]}"; do
        echo -e "${RED}   • $failed_test${NC}"
    done
    echo ""
    echo -e "${YELLOW}💡 To fix failing tests:${NC}"
    echo -e "   1. Review the docker-compose.yaml file"
    echo -e "   2. Ensure all required services are defined"
    echo -e "   3. Check environment variable configurations"
    echo -e "   4. Verify service dependencies and networking"
    echo ""
    exit 1
else
    echo ""
    echo -e "${GREEN}🎉 ALL ACCEPTANCE TESTS PASSED!${NC}"
    echo -e "${GREEN}Docker Development Environment meets all requirements${NC}"
    echo ""
fi

echo -e "${BLUE}🔍 NEXT STEPS FOR FULL VALIDATION:${NC}"
echo -e "   1. Run 'scripts/dev-start.sh' to start the environment"
echo -e "   2. Run 'scripts/test-dev-environment-runtime.sh' to test running services"
echo -e "   3. Verify all services are healthy and communicating"
echo ""