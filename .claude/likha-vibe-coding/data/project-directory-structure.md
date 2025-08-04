# Project Directory Structure for Likha Licensing Platform

A comprehensive Spring Modulith monolith with React frontend, complete DevOps infrastructure, and production-ready architecture.

## Root Directory Structure

```
/Users/bobsantos/likha/dev/likha-licensing/
├── frontend/                              # React frontend application
├── backend/                               # Spring Boot backend (Spring Modulith)
├── scripts/                               # Development and automation scripts
├── .github/                               # CI/CD workflows and GitHub configuration
└── .claude/                               # Claude Code configuration and documentation
```

## Frontend Structure (React + TypeScript + Vite)

```
frontend/
├── public/                                # Static assets
├── src/                                   # React source code
│   └── pages/                            # Page components
├── dist/                                 # Vite build output
└── node_modules/                         # NPM dependencies
```

**Frontend Technology Stack:**
- **React 18.2+** with TypeScript
- **Vite 5.0+** for build tooling and dev server
- **Tailwind CSS 3.3+** for styling
- **React Router DOM 6.20+** for routing
- **TanStack Query 5.12+** for server state management
- **Zustand 4.4+** for client state management
- **React Hook Form 7.48+** with Zod validation
- **Axios 1.6+** for HTTP requests

## Backend Structure (Spring Boot + Spring Modulith)

```
backend/
├── src/
│   ├── main/
│   │   ├── java/
│   │   │   └── app/
│   │   │       └── likha/                # Root package (app.likha)
│   │   │           └── config/          # Configuration classes
│   │   └── resources/
│   │       ├── db/                      # Database management
│   │       │   ├── migration/           # Active Flyway migrations
│   │       │   └── archive/             # Archived migrations
│   │       └── static/                  # Frontend build output (served by Spring Boot)
│   │           └── assets/              # Bundled JS/CSS files
│   └── test/
│       └── java/
│           └── app/
│               └── likha/
│                   ├── config/          # Configuration tests
│                   └── infrastructure/  # Infrastructure tests
└── target/                              # Maven build output
    ├── classes/                         # Compiled Java classes
    ├── test-classes/                    # Compiled test classes
    ├── site/jacoco/                     # Code coverage reports
    └── surefire-reports/                # Test reports
```

**Backend Technology Stack:**
- **Spring Boot 3.2+** with Java 21
- **Spring Modulith** for modular monolith architecture
- **PostgreSQL 16** with multi-tenant schema design
- **Spring Security** with JWT authentication
- **Spring Data JPA** with Spring JDBC
- **Flyway** for database migrations
- **Maven** for build management
- **JaCoCo** for code coverage
- **Testcontainers** for integration testing

## Infrastructure and DevOps

### Scripts Directory
```
scripts/                                 # Development and automation scripts
    # Complete development environment management
    # Database operations and validation
    # CI pipeline simulation and testing
    # Pre-commit validation and checklist execution
    # MinIO S3 bucket initialization
```

### CI/CD Pipeline
```
.github/
└── workflows/                           # GitHub Actions CI/CD pipelines
    # Comprehensive CI pipeline with parallel execution
    # Security and quality analysis workflows
    # Production deployment pipeline
    # OWASP dependency checking and suppressions
```

**CI/CD Features:**
- **Parallel execution** (Backend CI, Frontend CI, Security scanning)
- **Multi-architecture builds** (AMD64/ARM64)
- **GitHub Container Registry** integration
- **Trivy security scanning** (filesystem + container)
- **OWASP dependency checking**
- **JaCoCo code coverage** analysis
- **Repository variable-controlled** deployments

### Docker Configuration

**Production Build:**
- Multi-stage Docker build for optimized production images
- Development Docker environment with hot reload capabilities

**Service Orchestration (docker-compose.yaml):**
- PostgreSQL 16 (Multi-tenant database)
- Spring Boot Application (Main application server)
- Redis 7 (Caching and session management)
- MinIO (S3-compatible object storage)
- MinIO Init (Automated bucket setup)
- Adminer (Database management UI)

## Claude Code Configuration

```
.claude/
└── likha-vibe-coding/
    ├── checklist/                      # Development process guidelines
    │   # Agent delegation and task planning
    ├── data/                           # Technical documentation and references
    │   # Backend/frontend tech stacks and project structure
    └── prod-dev/                       # Development workflow management
        # Task tracking and development todos
```

## Development Environment Architecture

**Multi-Service Development Stack:**
- **Application**: Spring Boot with embedded frontend
- **Database**: PostgreSQL 16 (schema-per-tenant multi-tenancy)
- **Caching**: Redis 7 for session management
- **Object Storage**: MinIO (S3-compatible) with automated bucket setup
- **Database UI**: Adminer for database management
- **Monitoring**: Spring Boot Actuator with health endpoints

**Key Architecture Patterns:**
- **Schema-per-tenant multi-tenancy** for data isolation
- **Event-driven architecture** with Spring Modulith
- **Security-first approach** with comprehensive scanning
- **Infrastructure as Code** with Docker Compose
- **Frontend-backend integration** via Maven frontend plugin

**Package Naming Convention:**
- Root package: `app.likha`
- Main application class: `app.likha.LicensingPlatformApplication`
- Future modules will follow: `app.likha.{module}` pattern
