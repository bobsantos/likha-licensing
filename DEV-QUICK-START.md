# Quick Start - Development Environment

**Likha Licensing Platform** - Spring Modulith Monolith with React Frontend

## Prerequisites
- Docker & Docker Compose
- 4GB+ RAM available

## Start Development Environment
```bash
./scripts/dev-start.sh
```

## Access Points
- **Application**: http://localhost:8080
- **Database**: localhost:5432 (postgres/postgres)
- **MinIO Console**: http://localhost:9001 (minioadmin/minioadmin123)
- **Health Check**: http://localhost:8080/actuator/health

## Useful Commands
```bash
# View logs (all services)
./scripts/dev-logs.sh

# View specific service logs
./scripts/dev-logs.sh minio

# Database shell
./scripts/dev-db.sh shell

# Stop environment
./scripts/dev-stop.sh

# Clean restart
./scripts/dev-stop.sh --clean && ./scripts/dev-start.sh
```

## Architecture
- **Monolith**: Single Spring Boot JAR with embedded frontend
- **Multi-tenant**: Schema-per-tenant PostgreSQL database
- **Package**: `app.likha.*` (NOT com.licensing)
- **Hot Reload**: Enabled for both Java and React code

## Tenant Testing
```bash
# Set tenant context with header
curl -H "X-Tenant-ID: tenant-001" http://localhost:8080/api/endpoint

# List tenants
./scripts/dev-db.sh tenants

# Create tenant
./scripts/dev-db.sh create-tenant mycompany "My Company"
```

For detailed setup and troubleshooting, see [docs/development-setup.md](docs/development-setup.md).