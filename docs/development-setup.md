# Development Environment Setup

This document provides comprehensive instructions for setting up the Likha Licensing Platform development environment using Docker Compose.

## Architecture Overview

The Likha Licensing Platform is built as a **monolith application** using Spring Modulith architecture:

- **Backend**: Spring Boot 3.2+ with Spring Modulith (Java 21)
- **Frontend**: React 18+ with TypeScript and Vite (built and served by Spring Boot)
- **Database**: PostgreSQL 15+ with schema-per-tenant multi-tenancy
- **Storage**: MinIO S3-compatible object storage for document management
- **Caching**: Redis (optional but recommended)
- **Package Structure**: `app.likha.*` 

## Prerequisites

Before setting up the development environment, ensure you have:

- **Docker** (version 20.10+)
- **Docker Compose** (version 2.0+ or docker-compose 1.29+)
- **Git** for version control
- **4GB+ RAM** available for containers

## Quick Start

1. **Clone and navigate to the repository**:
   ```bash
   cd /path/to/likha-licensing
   ```

2. **Start the development environment**:
   ```bash
   ./scripts/dev-start.sh
   ```

3. **Access the application**:
   - Application: http://localhost:8080
   - Database: localhost:5432 (postgres/postgres)
   - MinIO Console: http://localhost:9001 (minioadmin/minioadmin123)
   - Adminer: http://localhost:8081 (optional, use `--profile tools`)

## Detailed Setup Instructions

### 1. Environment Configuration

The development environment uses environment variables for configuration. The setup script will automatically create a `.env` file from the template if one doesn't exist.

**Manual configuration** (optional):
```bash
cp .env.example .env
# Edit .env with your preferred settings
```

Key configuration options:
- `POSTGRES_PASSWORD`: Database password (default: postgres)
- `MINIO_ROOT_USER`: MinIO admin username (default: minioadmin)
- `MINIO_ROOT_PASSWORD`: MinIO admin password (default: minioadmin123)
- `MINIO_DEFAULT_BUCKETS`: Default S3 bucket name (default: likha-licensing-docs)
- `JWT_SECRET`: JWT signing secret (change for production)
- `SPRING_PROFILES_ACTIVE`: Spring profile (default: dev)

### 2. Starting Services

The development environment includes the following services:

| Service | Port | Purpose |
|---------|------|---------|
| `app` | 8080 | Spring Boot application (includes frontend) |
| `postgres` | 5432 | PostgreSQL database |
| `minio` | 9000, 9001 | MinIO S3 storage (API & Console) |
| `redis` | 6379 | Redis cache (optional) |
| `adminer` | 8081 | Database administration tool |

**Start all services**:
```bash
./scripts/dev-start.sh
```

**Start with database tools**:
```bash
docker-compose --profile tools up -d
```

### 3. Development Workflow

#### Hot Reload Support

The development setup supports hot reload for both backend and frontend:

- **Backend**: Spring Boot DevTools automatically restarts the application when Java files change
- **Frontend**: Changes to React files trigger a frontend rebuild and static asset refresh

#### Frontend Development

The frontend is built using Vite and integrated into the Spring Boot application:

1. **Frontend source**: `frontend/src/`
2. **Built assets**: `frontend/dist/` → `backend/src/main/resources/static/`
3. **Development server**: Frontend is served by Spring Boot (not standalone Vite server)

#### Database Schema Management

The application uses **schema-per-tenant** multi-tenancy:

- **Shared tables**: `public.tenants`, `public.users`
- **Tenant schemas**: `tenant_default`, `tenant_001`, `tenant_002`, etc.
- **Migration management**: Flyway handles database schema migrations

#### S3 Storage Management

The application uses **MinIO S3-compatible storage** for document management:

- **Default bucket**: `likha-licensing-docs` (created automatically)
- **API endpoint**: http://localhost:9000 (for application access)
- **Console access**: http://localhost:9001 (minioadmin/minioadmin123)
- **Tenant isolation**: Documents are organized by tenant prefix in S3 keys

### 4. Development Scripts

The `scripts/` directory contains helpful development utilities:

#### Application Management
```bash
# Start development environment
./scripts/dev-start.sh

# View application logs
./scripts/dev-logs.sh [service]

# Stop development environment
./scripts/dev-stop.sh

# Stop and clean all data
./scripts/dev-stop.sh --clean
```

#### Database Management
```bash
# Open PostgreSQL shell
./scripts/dev-db.sh shell

# List tenant schemas
./scripts/dev-db.sh tenants

# Create new tenant
./scripts/dev-db.sh create-tenant acme-corp "Acme Corporation"

# Backup database
./scripts/dev-db.sh backup

# Reset database (WARNING: destroys all data)
./scripts/dev-db.sh reset
```

### 5. Multi-Tenant Testing

The development environment comes pre-configured with sample tenant schemas:

- `tenant_default` - Default tenant for development
- `tenant_001` - Sample tenant 1
- `tenant_002` - Sample tenant 2
- `tenant_003` - Sample tenant 3

**Testing multi-tenancy**:
```bash
# Test tenant isolation by setting X-Tenant-ID header
curl -H "X-Tenant-ID: tenant-001" http://localhost:8080/api/some-endpoint
```

### 6. Monitoring and Health Checks

The development environment includes comprehensive health monitoring:

**Spring Boot Actuator endpoints**:
- Health check: http://localhost:8080/actuator/health
- Metrics: http://localhost:8080/actuator/metrics
- Spring Modulith info: http://localhost:8080/actuator/modulith

**Database health**:
```bash
# Check PostgreSQL status
docker-compose exec postgres pg_isready -U postgres

# View connection info
docker-compose exec postgres psql -U postgres -c "SELECT * FROM pg_stat_activity;"
```

## Troubleshooting

### Common Issues

#### Port Conflicts
If ports 8080, 5432, 9000, 9001, or 6379 are already in use:
1. Stop conflicting services
2. Modify ports in `docker-compose.yaml`
3. Update corresponding configuration

#### Database Connection Issues
```bash
# Check PostgreSQL logs
./scripts/dev-logs.sh postgres

# Verify database connectivity
docker-compose exec postgres pg_isready -U postgres -d likha_licensing
```

#### Application Startup Issues
```bash
# Check application logs
./scripts/dev-logs.sh app

# Restart application container
docker-compose restart app
```

#### MinIO Storage Issues
```bash
# Check MinIO logs
./scripts/dev-logs.sh minio

# Verify MinIO API connectivity
curl -I http://localhost:9000/minio/health/live

# Access MinIO Console
# Navigate to http://localhost:9001 (minioadmin/minioadmin123)
```

#### Frontend Build Issues
```bash
# Rebuild frontend manually
docker-compose exec app sh -c "cd frontend && npm run build"

# Copy assets to Spring Boot static resources
docker-compose exec app sh -c "cp -r frontend/dist/* src/main/resources/static/"
```

### Performance Optimization

#### Docker Performance
- **Increase Docker memory**: Allocate at least 4GB RAM to Docker
- **Use Docker Desktop WSL2**: On Windows, use WSL2 backend for better performance
- **Volume mounting**: Consider using named volumes for better I/O performance

#### Application Performance
- **Maven dependency cache**: The setup uses a named volume for Maven cache (`maven_cache`)
- **Node.js dependency cache**: Frontend dependencies are cached in `frontend_node_modules` volume
- **Database connection pooling**: Configured via HikariCP settings in `application-dev.yml`

### Clean Restart
If you encounter persistent issues:
```bash
# Stop and remove all containers, volumes, and networks
./scripts/dev-stop.sh --clean

# Remove Docker images and build cache
docker system prune -a

# Start fresh
./scripts/dev-start.sh
```

## Development Best Practices

### Code Organization
- **Spring Modulith modules**: Organize code in domain modules under `app.likha.*`
- **Frontend components**: Use feature-based organization in `frontend/src/`
- **Database migrations**: Place Flyway scripts in `backend/src/main/resources/db/migration/`

### Testing Strategy
- **Unit tests**: Run with `mvn test` (inside container or locally)
- **Integration tests**: Use Testcontainers for database integration tests
- **Multi-tenant tests**: Test tenant isolation and data segregation

### Security Considerations
- **Development only**: The provided credentials are for development only
- **JWT secrets**: Change JWT secret for any non-local environment
- **Database access**: PostgreSQL is accessible on localhost for development convenience

### Container Debugging
```bash
# Execute bash in application container
docker-compose exec app bash

# View container resource usage
docker stats

# Inspect container configuration
docker-compose config
```

## Next Steps

Once your development environment is running:

1. **Explore the codebase**: Start with `backend/src/main/java/app/likha/`
2. **Review API documentation**: Access SpringDoc OpenAPI at `/swagger-ui.html`
3. **Test multi-tenancy**: Create test tenants and verify isolation
4. **Run tests**: Execute the test suite to ensure everything works
5. **Start developing**: Begin implementing your features following Spring Modulith patterns

For more information about the application architecture and development guidelines, see:
- [Architecture Decision Records](adr/)
- [6-Month MVP Vision](6-month-mvp-vision.md)
- [Project Roadmap](roadmap.md)

## Support

If you encounter issues not covered in this documentation:
1. Check the [troubleshooting section](#troubleshooting) above
2. Review container logs using `./scripts/dev-logs.sh`
3. Verify your Docker and system requirements
4. Consider a clean restart with `./scripts/dev-stop.sh --clean`