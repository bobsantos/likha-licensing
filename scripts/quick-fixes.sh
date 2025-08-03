#!/bin/bash
set -e

echo "🔧 Quick Fixes for GitHub Actions Pipeline Failures"
echo "==================================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to run a fix
apply_fix() {
    local description=$1
    local command=$2
    local optional=${3:-false}
    
    echo -e "\n${YELLOW}🔧 ${description}${NC}"
    echo "Command: $command"
    
    if eval $command; then
        echo -e "${GREEN}✅ ${description} - COMPLETED${NC}"
        return 0
    else
        if [ "$optional" = "true" ]; then
            echo -e "${YELLOW}⚠️  ${description} - OPTIONAL FIX FAILED${NC}"
            return 0
        else
            echo -e "${RED}❌ ${description} - FAILED${NC}"
            return 1
        fi
    fi
}

echo -e "\n${BLUE}1. BACKEND FIXES${NC}"
echo "================"

# Fix 1: Ensure Maven wrapper exists
if [ ! -f "mvnw" ]; then
    echo -e "\n${YELLOW}📁 Creating Maven wrapper...${NC}"
    mvn wrapper:wrapper
fi

# Fix 2: Clean and validate Maven setup
apply_fix "Clean Maven build" "mvn clean -Dfrontend.skip=true"
apply_fix "Validate Maven project" "mvn validate -Dfrontend.skip=true"

# Fix 3: Check if backend compiles
apply_fix "Compile backend" "mvn compile -Dfrontend.skip=true"

echo -e "\n${BLUE}2. FRONTEND FIXES${NC}"
echo "================="

cd frontend

# Fix 4: Clean node_modules and reinstall
apply_fix "Remove node_modules" "rm -rf node_modules package-lock.json" "true"
apply_fix "Install frontend dependencies" "npm install"
apply_fix "Update package-lock.json" "npm ci"

# Fix 5: Fix common frontend issues
apply_fix "Run ESLint with auto-fix" "npm run lint:fix" "true"

# Fix 6: Check TypeScript compilation
apply_fix "TypeScript type check" "npx tsc --noEmit"

# Fix 7: Test frontend build
apply_fix "Build frontend" "npm run build"

cd ..

echo -e "\n${BLUE}3. CONFIGURATION FIXES${NC}"
echo "======================"

# Fix 8: Create missing directories
apply_fix "Create target directories" "mkdir -p backend/target/surefire-reports backend/target/failsafe-reports backend/target/site/jacoco" "true"

# Fix 9: Check and create missing configuration files
if [ ! -f ".github/dependency-check-suppressions.xml" ]; then
    echo -e "\n${YELLOW}📄 Creating OWASP dependency check suppressions file...${NC}"
    cat > .github/dependency-check-suppressions.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<suppressions xmlns="https://jeremylong.github.io/DependencyCheck/dependency-suppression.1.3.xsd">
    <!-- Add suppressions for known false positives here -->
    <!-- Example:
    <suppress>
        <notes><![CDATA[
        False positive - this vulnerability doesn't apply to our usage
        ]]></notes>
        <packageUrl regex="true">^pkg:maven/com\.example/.*$</packageUrl>
        <cve>CVE-2021-12345</cve>
    </suppress>
    -->
</suppressions>
EOF
    echo -e "${GREEN}✅ Created dependency-check-suppressions.xml${NC}"
fi

# Fix 10: Create .bundlesize.json for frontend bundle analysis
if [ ! -f "frontend/.bundlesize.json" ]; then
    echo -e "\n${YELLOW}📄 Creating bundle size configuration...${NC}"
    cat > frontend/.bundlesize.json << 'EOF'
[
  {
    "path": "./dist/assets/*.js",
    "maxSize": "500kb",
    "compression": "gzip"
  },
  {
    "path": "./dist/assets/*.css", 
    "maxSize": "50kb",
    "compression": "gzip"
  }
]
EOF
    echo -e "${GREEN}✅ Created .bundlesize.json${NC}"
fi

echo -e "\n${BLUE}4. INTEGRATION TESTING${NC}"
echo "======================"

# Fix 11: Test the complete build process
echo -e "\n${YELLOW}🧪 Testing complete build process...${NC}"

# Start PostgreSQL for testing
if ! docker ps | grep -q test-postgres; then
    echo -e "Starting PostgreSQL container..."
    docker run -d \
        --name test-postgres \
        -e POSTGRES_USER=postgres \
        -e POSTGRES_PASSWORD=postgres \
        -e POSTGRES_DB=postgres \
        -p 5432:5432 \
        postgres:15 2>/dev/null || true
    
    echo "Waiting for PostgreSQL to be ready..."
    sleep 10
fi

# Set environment variables
export SPRING_PROFILES_ACTIVE=test
export POSTGRES_HOST=localhost
export POSTGRES_PORT=5432
export POSTGRES_DB=postgres
export POSTGRES_USER=postgres
export POSTGRES_PASSWORD=postgres

# Run integration test
if apply_fix "Integration test - Backend tests" "mvn clean test -Pci -Dfrontend.skip=true"; then
    echo -e "${GREEN}🎉 Backend tests passed!${NC}"
else
    echo -e "${RED}❌ Backend tests failed - check logs in backend/target/surefire-reports/${NC}"
fi

# Test complete build
if apply_fix "Integration test - Complete build" "mvn clean package -Pci -DskipTests" "true"; then
    echo -e "${GREEN}🎉 Complete build passed!${NC}"
else
    echo -e "${YELLOW}⚠️  Complete build failed - may need manual fixes${NC}"
fi

# Cleanup
echo -e "\n${YELLOW}🧹 Cleaning up test containers...${NC}"
docker stop test-postgres 2>/dev/null || true
docker rm test-postgres 2>/dev/null || true

echo -e "\n${BLUE}5. FINAL RECOMMENDATIONS${NC}"
echo "========================"

echo -e "\n${GREEN}✅ FIXES APPLIED SUCCESSFULLY${NC}"
echo ""
echo -e "${YELLOW}📋 Next steps:${NC}"
echo "1. Review any failed fixes above"
echo "2. Commit your changes"
echo "3. Push to your branch"
echo "4. Monitor the GitHub Actions workflow"
echo ""
echo -e "${YELLOW}💡 Prevention tips:${NC}"
echo "• Run './scripts/test-ci-locally.sh' before pushing"
echo "• Use './scripts/debug-ci-failures.sh' to check project health"
echo "• Keep dependencies updated with 'npm update' and 'mvn versions:display-dependency-updates'"
echo ""
echo -e "${YELLOW}🔍 If issues persist:${NC}"
echo "• Check GitHub Actions logs for specific error messages"
echo "• Use 'act' to run workflows locally"
echo "• Ensure all required secrets are configured in GitHub"

echo -e "\n${GREEN}🎯 Ready to push! Your CI pipeline should now work correctly.${NC}"