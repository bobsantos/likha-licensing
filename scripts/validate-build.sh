#!/bin/bash

# Likha Licensing Platform - Build Validation Script
# This script validates the build environment before running Maven

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Determine project root
if [[ -f "pom.xml" && -d "backend" && -d "frontend" ]]; then
    PROJECT_ROOT="$(pwd)"
elif [[ -f "../pom.xml" && -d "../backend" && -d "../frontend" ]]; then
    PROJECT_ROOT="$(cd .. && pwd)"
elif [[ -f "../../pom.xml" && -d "../../backend" && -d "../../frontend" ]]; then
    PROJECT_ROOT="$(cd ../.. && pwd)"
else
    print_error "Cannot determine project root. Please run from project root, backend/, or scripts/ directory."
    exit 1
fi

print_status "Project root detected: $PROJECT_ROOT"

# Change to project root
cd "$PROJECT_ROOT"

print_status "Starting build validation..."

# Check Java version
print_status "Checking Java version..."
if command_exists java; then
    JAVA_VERSION=$(java -version 2>&1 | grep "openjdk version\|java version" | awk '{print $3}' | tr -d '"' | cut -d'.' -f1)
    if [[ "$JAVA_VERSION" -ge 21 ]]; then
        print_success "Java $JAVA_VERSION detected"
    else
        print_error "Java 21 or higher required. Found: Java $JAVA_VERSION"
        exit 1
    fi
else
    print_error "Java not found in PATH"
    exit 1
fi

# Check Maven version
print_status "Checking Maven version..."
if command_exists mvn; then
    MVN_VERSION=$(mvn -version | grep "Apache Maven" | awk '{print $3}')
    print_success "Maven $MVN_VERSION detected"
else
    print_error "Maven not found in PATH"
    exit 1
fi

# Check Node.js (if frontend is not skipped)
FRONTEND_SKIP="${FRONTEND_SKIP:-false}"
if [[ "$FRONTEND_SKIP" != "true" ]]; then
    print_status "Checking Node.js version..."
    if command_exists node; then
        NODE_VERSION=$(node --version)
        print_success "Node.js $NODE_VERSION detected"
    else
        print_warning "Node.js not found. Frontend build may fail."
        print_warning "To skip frontend: export FRONTEND_SKIP=true"
    fi

    # Check npm
    print_status "Checking npm version..."
    if command_exists npm; then
        NPM_VERSION=$(npm --version)
        print_success "npm $NPM_VERSION detected"
    else
        print_warning "npm not found. Frontend build may fail."
    fi
fi

# Validate project structure
print_status "Validating project structure..."

# Check root POM
if [[ -f "pom.xml" ]]; then
    print_success "Root pom.xml found"
else
    print_error "Root pom.xml not found"
    exit 1
fi

# Check backend
if [[ -d "backend" && -f "backend/pom.xml" ]]; then
    print_success "Backend module found"
else
    print_error "Backend module not found (backend/pom.xml)"
    exit 1
fi

# Check frontend (if not skipped)
if [[ "$FRONTEND_SKIP" != "true" ]]; then
    if [[ -d "frontend" ]]; then
        print_success "Frontend directory found"
        
        if [[ -f "frontend/package.json" ]]; then
            print_success "Frontend package.json found"
        else
            print_error "Frontend package.json not found"
            print_error "Run: cd frontend && npm init"
            exit 1
        fi
        
        if [[ -d "frontend/node_modules" ]]; then
            print_success "Frontend dependencies installed"
        else
            print_warning "Frontend dependencies not installed"
            print_warning "Run: cd frontend && npm install"
        fi
    else
        print_error "Frontend directory not found"
        print_error "Solutions:"
        print_error "  1. Create frontend directory and set up React app"
        print_error "  2. Skip frontend build: export FRONTEND_SKIP=true"
        exit 1
    fi
else
    print_warning "Frontend build skipped (FRONTEND_SKIP=true)"
fi

# Check Docker (optional)
if command_exists docker; then
    print_success "Docker detected"
    if docker info >/dev/null 2>&1; then
        print_success "Docker daemon running"
    else
        print_warning "Docker daemon not running"
    fi
else
    print_warning "Docker not found (optional for development)"
fi

print_success "Build validation completed successfully!"
print_status "You can now run:"
print_status "  mvn clean package                    # Full build"
print_status "  mvn clean package -Dfrontend.skip=true  # Backend only"
print_status "  mvn clean package -Pbackend-only        # Backend only (profile)"