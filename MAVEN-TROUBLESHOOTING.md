# Maven Troubleshooting Guide

## Parent POM Resolution Issues

### Problem Symptoms
- Error: "Non-resolvable parent POM" with `licensing-platform-parent:pom:0.0.1-SNAPSHOT`
- IDE showing Maven resolution errors
- Frontend Maven plugin execution failures in IDE

### Root Cause Analysis
The Maven parent-child configuration is **correctly configured**:
- Root POM: `app.likha:licensing-platform-parent:0.0.1-SNAPSHOT`
- Backend POM: `app.likha:licensing-platform:0.0.1-SNAPSHOT` 
- Relative path: `../pom.xml` (correct)

The issue is typically **IDE-specific**, not a Maven configuration problem.

## Solutions

### 1. Command Line Verification
First, verify that Maven works from command line:
```bash
# From project root
mvn clean validate
mvn clean compile
mvn clean install
```

### 2. IDE Cache Clear

**VS Code:**
```
Cmd+Shift+P → "Java: Reload Projects"
Cmd+Shift+P → "Java: Clean Workspace"
```

**IntelliJ IDEA:**
```
View → Tool Windows → Maven → Refresh icon
File → Invalidate Caches and Restart
```

**Eclipse:**
```
Right-click project → Refresh
Right-click project → Maven → Reload Projects
```

### 3. Profile-Based Solutions

**Backend-Only Development:**
```bash
mvn clean compile -Pbackend-only
```

**Skip Frontend During Development:**
```bash
mvn clean compile -Dfrontend.skip=true
```

### 4. IDE Configuration

**VS Code Settings** (`.vscode/settings.json`):
```json
{
    "maven.terminal.customEnv": [
        {
            "environmentVariable": "MAVEN_OPTS",
            "value": "-Dfrontend.skip=true"
        }
    ]
}
```

### 5. Available Maven Profiles

- `dev` (default): Development with frontend
- `backend-only`: Skip frontend build
- `prod`: Production build
- `ci`: CI/CD optimized
- `ide`: Auto-activated for IDE compatibility (skips frontend)

## Validation Commands

```bash
# Verify parent POM structure
mvn help:effective-pom

# List active profiles
mvn help:active-profiles

# Validate configuration
mvn validate

# Build backend only
mvn clean compile -Pbackend-only

# Full build with frontend
mvn clean package
```

## File Structure Verification

Expected structure:
```
/Users/bobsantos/likha/dev/likha-licensing/
├── pom.xml                    (parent POM)
├── backend/
│   └── pom.xml               (child POM with relativePath=../pom.xml)
└── frontend/
    └── package.json
```

## Troubleshooting Checklist

- [ ] Command line `mvn clean compile` works
- [ ] Parent POM exists at project root
- [ ] Backend POM has correct `<relativePath>../pom.xml</relativePath>`
- [ ] IDE project refreshed/reloaded
- [ ] IDE caches cleared
- [ ] VS Code settings configured for frontend skip (if needed)
- [ ] Correct Maven and Java versions (Maven 3.8.1+, Java 21+)

## Emergency Recovery

If all else fails:
```bash
# Clean everything
mvn clean
rm -rf ~/.m2/repository/app/likha/
mvn clean install -U

# Or skip frontend entirely
mvn clean install -Dfrontend.skip=true
```