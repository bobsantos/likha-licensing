#!/bin/bash
set -e

echo "🧪 Testing CI Pipeline Locally"
echo "==============================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to run command and check result
run_check() {
    local description=$1
    local command=$2
    
    echo -e "\n${YELLOW}→ ${description}${NC}"
    echo "Command: $command"
    
    if eval $command; then
        echo -e "${GREEN}✅ ${description} - PASSED${NC}"
        return 0
    else
        echo -e "${RED}❌ ${description} - FAILED${NC}"
        return 1
    fi
}

# Database setup
echo -e "\n${YELLOW}🐘 Database Setup${NC}"
POSTGRES_CONTAINER_NAME="test-postgres-ci"
POSTGRES_TEST_PORT=5433

# Clean up any existing test container
echo "Cleaning up existing test containers..."
docker stop $POSTGRES_CONTAINER_NAME 2>/dev/null || true
docker rm $POSTGRES_CONTAINER_NAME 2>/dev/null || true

# Check if port 5432 is available, if not use the existing dev database
if netstat -ln | grep -q ":5432 "; then
    echo -e "${BLUE}ℹ️  Port 5432 is in use (likely dev environment). Using existing database...${NC}"
    USE_EXISTING_DB=true
    export POSTGRES_HOST=localhost
    export POSTGRES_PORT=5432
    export POSTGRES_DB=postgres
    export POSTGRES_USER=postgres
    export POSTGRES_PASSWORD=postgres
else
    echo "Starting dedicated test PostgreSQL container on port $POSTGRES_TEST_PORT..."
    USE_EXISTING_DB=false
    docker run -d \
        --name $POSTGRES_CONTAINER_NAME \
        -e POSTGRES_USER=postgres \
        -e POSTGRES_PASSWORD=postgres \
        -e POSTGRES_DB=postgres \
        -p $POSTGRES_TEST_PORT:5432 \
        postgres:15

    # Wait for PostgreSQL to be ready
    echo "Waiting for PostgreSQL to be ready..."
    sleep 15
    
    # Test connection
    for i in {1..30}; do
        if docker exec $POSTGRES_CONTAINER_NAME pg_isready -U postgres; then
            echo "PostgreSQL is ready!"
            break
        fi
        echo "Waiting for PostgreSQL... ($i/30)"
        sleep 1
    done

    export POSTGRES_HOST=localhost
    export POSTGRES_PORT=$POSTGRES_TEST_PORT
    export POSTGRES_DB=postgres
    export POSTGRES_USER=postgres
    export POSTGRES_PASSWORD=postgres
fi

# Export environment variables
export SPRING_PROFILES_ACTIVE=test

# Test database connection
echo -e "\n${YELLOW}🔗 Testing Database Connection${NC}"
if [ "$USE_EXISTING_DB" = true ]; then
    # Test connection to existing database
    if docker exec likha-postgres pg_isready -U postgres; then
        echo -e "${GREEN}✅ Database connection - PASSED${NC}"
    else
        echo -e "${RED}❌ Database connection - FAILED${NC}"
        echo "Error: Cannot connect to existing database. Make sure the dev environment is running."
        exit 1
    fi
fi

# Test commands
TESTS_PASSED=0
TESTS_FAILED=0

# Backend Tests
echo -e "\n${YELLOW}🏗️  BACKEND TESTS${NC}"
echo "=================="

if run_check "Java Version Check" "java -version"; then
    ((TESTS_PASSED++))
else
    ((TESTS_FAILED++))
fi

if run_check "Maven Validate" "mvn validate -Dfrontend.skip=true"; then
    ((TESTS_PASSED++))
else
    ((TESTS_FAILED++))
fi

if run_check "Maven Clean Compile" "mvn clean compile -Dfrontend.skip=true"; then
    ((TESTS_PASSED++))
else
    ((TESTS_FAILED++))
fi

if run_check "Backend Tests" "mvn clean test -Pci -Dfrontend.skip=true"; then
    ((TESTS_PASSED++))
else
    ((TESTS_FAILED++))
fi

# Frontend Tests
echo -e "\n${YELLOW}🎨 FRONTEND TESTS${NC}"
echo "=================="

cd frontend

if run_check "Node Version Check" "node --version"; then
    ((TESTS_PASSED++))
else
    ((TESTS_FAILED++))
fi

if run_check "NPM Install" "npm ci"; then
    ((TESTS_PASSED++))
else
    ((TESTS_FAILED++))
fi

if run_check "ESLint" "npm run lint"; then
    ((TESTS_PASSED++))
else
    ((TESTS_FAILED++))
fi

if run_check "TypeScript Check" "npx tsc --noEmit"; then
    ((TESTS_PASSED++))
else
    ((TESTS_FAILED++))
fi

if run_check "Frontend Build" "npm run build"; then
    ((TESTS_PASSED++))
else
    ((TESTS_FAILED++))
fi

cd ..

# Cleanup
echo -e "\n${YELLOW}🧹 Cleanup${NC}"
if [ "$USE_EXISTING_DB" = false ]; then
    echo "Stopping and removing test database container..."
    docker stop $POSTGRES_CONTAINER_NAME || true
    docker rm $POSTGRES_CONTAINER_NAME || true
else
    echo "Using existing database - no cleanup needed"
fi

# Summary
echo -e "\n${YELLOW}📊 SUMMARY${NC}"
echo "=========="
echo -e "Tests Passed: ${GREEN}${TESTS_PASSED}${NC}"
echo -e "Tests Failed: ${RED}${TESTS_FAILED}${NC}"

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "\n${GREEN}🎉 All tests passed! Ready to push.${NC}"
    exit 0
else
    echo -e "\n${RED}❌ Some tests failed. Fix issues before pushing.${NC}"
    exit 1
fi