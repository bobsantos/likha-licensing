#!/bin/bash
set -e

echo "🔍 GitHub Actions Failure Debugging Guide"
echo "========================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "\n${BLUE}📋 PRE-FLIGHT CHECKS${NC}"
echo "===================="

# Check Java version
echo -e "\n${YELLOW}☕ Java Version:${NC}"
java -version 2>&1 | head -3

# Check Maven version  
echo -e "\n${YELLOW}🔨 Maven Version:${NC}"
mvn --version | head -1

# Check Node version
echo -e "\n${YELLOW}🟢 Node Version:${NC}"
node --version

# Check NPM version
echo -e "\n${YELLOW}📦 NPM Version:${NC}"
npm --version

echo -e "\n${BLUE}🔍 PROJECT STRUCTURE VALIDATION${NC}"
echo "================================="

# Check if required files exist
echo -e "\n${YELLOW}📁 Checking required files:${NC}"

files=(
    "pom.xml"
    "backend/pom.xml" 
    "frontend/package.json"
    "frontend/package-lock.json"
    ".github/workflows/ci.yml"
)

for file in "${files[@]}"; do
    if [ -f "$file" ]; then
        echo -e "  ✅ $file"
    else
        echo -e "  ❌ $file ${RED}(MISSING)${NC}"
    fi
done

# Check backend source structure
echo -e "\n${YELLOW}🏗️  Backend structure:${NC}"
if [ -d "backend/src/main/java" ]; then
    echo -e "  ✅ backend/src/main/java"
    echo -e "    📄 Java files: $(find backend/src/main/java -name "*.java" | wc -l)"
else
    echo -e "  ❌ backend/src/main/java ${RED}(MISSING)${NC}"
fi

if [ -d "backend/src/test/java" ]; then
    echo -e "  ✅ backend/src/test/java"
    echo -e "    🧪 Test files: $(find backend/src/test/java -name "*Test.java" | wc -l)"
else
    echo -e "  ❌ backend/src/test/java ${RED}(MISSING)${NC}"
fi

# Check frontend structure
echo -e "\n${YELLOW}🎨 Frontend structure:${NC}"
if [ -d "frontend/src" ]; then
    echo -e "  ✅ frontend/src"
    echo -e "    📄 TS/TSX files: $(find frontend/src -name "*.ts" -o -name "*.tsx" | wc -l)"
else
    echo -e "  ❌ frontend/src ${RED}(MISSING)${NC}"
fi

echo -e "\n${BLUE}🔧 CONFIGURATION VALIDATION${NC}"
echo "============================"

# Check Maven profiles
echo -e "\n${YELLOW}📋 Maven profiles:${NC}"
mvn help:all-profiles | grep -A 2 "Profile Id"

# Check if CI profile exists
if mvn help:all-profiles | grep -q "ci"; then
    echo -e "  ✅ CI profile found"
else
    echo -e "  ⚠️  CI profile not found - this might cause issues"
fi

# Check frontend dependencies
echo -e "\n${YELLOW}📦 Frontend dependencies status:${NC}"
cd frontend
if [ -f "package-lock.json" ]; then
    if npm ls >/dev/null 2>&1; then
        echo -e "  ✅ All dependencies satisfied"
    else
        echo -e "  ⚠️  Some dependencies might be missing - run 'npm ci'"
    fi
else
    echo -e "  ❌ package-lock.json missing - run 'npm install'"
fi
cd ..

echo -e "\n${BLUE}🚨 COMMON FAILURE SCENARIOS${NC}"
echo "============================"

echo -e "\n${YELLOW}1. Backend Test Failures:${NC}"
echo "  💡 Run locally: mvn clean test -Pci -Dfrontend.skip=true"
echo "  💡 Check logs: backend/target/surefire-reports/"
echo "  💡 Database: Ensure PostgreSQL is running on port 5432"

echo -e "\n${YELLOW}2. Frontend Build Failures:${NC}" 
echo "  💡 Run locally: cd frontend && npm ci && npm run build"
echo "  💡 Check: TypeScript errors with 'npx tsc --noEmit'"
echo "  💡 Check: ESLint errors with 'npm run lint'"

echo -e "\n${YELLOW}3. Security Scan Failures:${NC}"
echo "  💡 OWASP: Usually continues on error, check reports"
echo "  💡 npm audit: Run 'npm audit fix' in frontend directory"
echo "  💡 Trivy: Container security scanning, usually informational"

echo -e "\n${YELLOW}4. Missing Artifacts:${NC}"
echo "  💡 Check build paths in workflow match actual output"
echo "  💡 Backend JAR: backend/target/*.jar"
echo "  💡 Frontend dist: frontend/dist/"

echo -e "\n${BLUE}🔧 QUICK FIXES${NC}"
echo "=============="

echo -e "\n${YELLOW}Run these commands to fix common issues:${NC}"
echo "  # Clean everything"
echo "  mvn clean && rm -rf frontend/node_modules frontend/dist"
echo ""
echo "  # Reinstall frontend dependencies"  
echo "  cd frontend && npm ci && cd .."
echo ""
echo "  # Test backend only"
echo "  mvn clean test -Dfrontend.skip=true"
echo ""
echo "  # Test frontend only"
echo "  cd frontend && npm run lint && npm run build && cd .."
echo ""
echo "  # Full integration test"
echo "  mvn clean package -Pci"

echo -e "\n${GREEN}🎯 Next Steps:${NC}"
echo "=============="
echo "1. Fix any missing files/directories shown above"
echo "2. Run the suggested commands to identify specific errors"  
echo "3. Check GitHub Actions logs for exact error messages"
echo "4. Use 'act' to test workflows locally before pushing"
echo "5. Ensure all tests pass locally before pushing to GitHub"

echo -e "\n${BLUE}📊 For detailed analysis, run:${NC}"
echo "./scripts/test-ci-locally.sh"