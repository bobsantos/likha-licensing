#!/bin/bash
set -e

echo "✅ Pre-Push Validation Checklist"
echo "================================="
echo "Run this script before pushing to ensure CI pipeline success"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
CHECKS_PASSED=0
CHECKS_FAILED=0
TOTAL_CHECKS=0

# Function to run validation check
validate() {
    local description=$1
    local command=$2
    local critical=${3:-true}
    
    ((TOTAL_CHECKS++))
    echo -e "\n${BLUE}🔍 ${description}${NC}"
    echo "Command: $command"
    
    if eval $command >/dev/null 2>&1; then
        echo -e "${GREEN}✅ PASS: ${description}${NC}"
        ((CHECKS_PASSED++))
        return 0
    else
        if [ "$critical" = "true" ]; then
            echo -e "${RED}❌ FAIL: ${description}${NC}"
            ((CHECKS_FAILED++))
            return 1
        else
            echo -e "${YELLOW}⚠️  WARNING: ${description}${NC}"
            return 0
        fi
    fi
}

# Function to show command output for failed checks
validate_with_output() {
    local description=$1
    local command=$2
    local critical=${3:-true}
    
    ((TOTAL_CHECKS++))
    echo -e "\n${BLUE}🔍 ${description}${NC}"
    echo "Command: $command"
    
    if eval $command; then
        echo -e "${GREEN}✅ PASS: ${description}${NC}"
        ((CHECKS_PASSED++))
        return 0
    else
        if [ "$critical" = "true" ]; then
            echo -e "${RED}❌ FAIL: ${description}${NC}"
            ((CHECKS_FAILED++))
            return 1
        else
            echo -e "${YELLOW}⚠️  WARNING: ${description}${NC}"
            return 0
        fi
    fi
}

echo -e "\n${YELLOW}📋 SYSTEM REQUIREMENTS${NC}"
echo "======================"

validate "Java 21 or higher" "java -version 2>&1 | grep -E '(version \"21|version \"[2-9][0-9])'"
validate "Maven 3.8.1 or higher" "mvn --version | grep -E 'Apache Maven [3-9]\.[8-9]|Apache Maven [4-9]'"
validate "Node.js 18 or higher" "node --version | grep -E 'v(1[8-9]|[2-9][0-9])'"
validate "Docker available" "docker --version"

echo -e "\n${YELLOW}📁 PROJECT STRUCTURE${NC}"
echo "===================="

validate "Root POM exists" "test -f pom.xml"
validate "Backend POM exists" "test -f backend/pom.xml"
validate "Frontend package.json exists" "test -f frontend/package.json"
validate "Frontend package-lock.json exists" "test -f frontend/package-lock.json"
validate "CI workflow exists" "test -f .github/workflows/ci.yml"
validate "Backend source directory" "test -d backend/src/main/java"
validate "Backend test directory" "test -d backend/src/test/java"
validate "Frontend source directory" "test -d frontend/src"

echo -e "\n${YELLOW}🏗️  BACKEND VALIDATION${NC}"
echo "======================"

validate "Maven validate" "mvn validate -Dfrontend.skip=true -q"
validate "Backend compiles" "mvn clean compile -Dfrontend.skip=true -q"

# Start PostgreSQL for testing
echo -e "\n${BLUE}🐘 Starting PostgreSQL for tests...${NC}"
if ! docker ps | grep -q test-postgres; then
    docker run -d \
        --name test-postgres \
        -e POSTGRES_USER=postgres \
        -e POSTGRES_PASSWORD=postgres \
        -e POSTGRES_DB=postgres \
        -p 5432:5432 \
        postgres:15 >/dev/null 2>&1
    
    echo "Waiting for PostgreSQL to be ready..."
    sleep 10
fi

# Set test environment
export SPRING_PROFILES_ACTIVE=test
export POSTGRES_HOST=localhost
export POSTGRES_PORT=5432
export POSTGRES_DB=postgres
export POSTGRES_USER=postgres
export POSTGRES_PASSWORD=postgres

validate_with_output "Backend tests pass" "mvn test -Pci -Dfrontend.skip=true -q"

echo -e "\n${YELLOW}🎨 FRONTEND VALIDATION${NC}"
echo "======================"

cd frontend

validate "Node modules are installed" "test -d node_modules"
if [ ! -d "node_modules" ]; then
    echo -e "${YELLOW}Installing frontend dependencies...${NC}"
    npm ci >/dev/null 2>&1
fi

validate_with_output "ESLint passes" "npm run lint"
validate_with_output "TypeScript compiles" "npx tsc --noEmit"
validate_with_output "Frontend builds successfully" "npm run build"

# Check if test script exists and run it
if npm run | grep -q "test"; then
    validate_with_output "Frontend tests pass" "npm run test -- --run" "false"
else
    echo -e "${YELLOW}⚠️  No frontend test script found${NC}"
fi

cd ..

echo -e "\n${YELLOW}🔒 SECURITY CHECKS${NC}"
echo "=================="

validate "No high-severity npm vulnerabilities" "cd frontend && npm audit --audit-level=high" "false"
validate "OWASP dependency check passes" "mvn org.owasp:dependency-check-maven:check -Dfrontend.skip=true -q" "false"

echo -e "\n${YELLOW}🚀 INTEGRATION TESTS${NC}"
echo "===================="

validate_with_output "Full integration build" "mvn clean package -Pci -DskipTests -q"

echo -e "\n${YELLOW}📊 GIT STATUS${NC}"
echo "============="

# Check git status
if git status --porcelain | grep -q .; then
    echo -e "${YELLOW}⚠️  You have uncommitted changes:${NC}"
    git status --porcelain
    echo -e "\n${YELLOW}💡 Consider committing these changes before pushing${NC}"
else
    echo -e "${GREEN}✅ Working directory is clean${NC}"
fi

# Check current branch
CURRENT_BRANCH=$(git branch --show-current)
echo -e "Current branch: ${BLUE}${CURRENT_BRANCH}${NC}"

# Cleanup
echo -e "\n${YELLOW}🧹 Cleaning up...${NC}"
docker stop test-postgres >/dev/null 2>&1 || true
docker rm test-postgres >/dev/null 2>&1 || true

echo -e "\n${YELLOW}📊 SUMMARY${NC}"
echo "=========="
echo -e "Total checks: ${BLUE}${TOTAL_CHECKS}${NC}"
echo -e "Passed: ${GREEN}${CHECKS_PASSED}${NC}"
echo -e "Failed: ${RED}${CHECKS_FAILED}${NC}"

if [ $CHECKS_FAILED -eq 0 ]; then
    echo -e "\n${GREEN}🎉 ALL CHECKS PASSED!${NC}"
    echo -e "${GREEN}✅ Ready to push to GitHub${NC}"
    echo ""
    echo -e "${YELLOW}📋 Recommended next steps:${NC}"
    echo "1. git add ."
    echo "2. git commit -m 'Your commit message'"
    echo "3. git push origin $CURRENT_BRANCH"
    echo ""
    echo -e "${BLUE}💡 The GitHub Actions pipeline should now pass successfully!${NC}"
    exit 0
else
    echo -e "\n${RED}❌ SOME CHECKS FAILED${NC}"
    echo -e "${RED}Please fix the issues above before pushing${NC}"
    echo ""
    echo -e "${YELLOW}🔧 Need help? Run these scripts:${NC}"
    echo "• ./scripts/debug-ci-failures.sh - Detailed diagnostics"
    echo "• ./scripts/quick-fixes.sh - Automated fixes"
    echo "• ./scripts/test-ci-locally.sh - Full local CI simulation"
    exit 1
fi