#!/bin/bash

# Likha Licensing Platform - Database Management Script
# This script provides database management utilities for development

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Determine Docker Compose command
if docker compose version &> /dev/null 2>&1; then
    COMPOSE_CMD="docker compose"
else
    COMPOSE_CMD="docker-compose"
fi

COMMAND=${1:-help}

case $COMMAND in
    "shell"|"psql")
        echo -e "${BLUE}🗄️  Opening PostgreSQL shell...${NC}"
        echo -e "${YELLOW}💡 Connected to database: likha_licensing${NC}"
        echo -e "${YELLOW}💡 Exit with: \\q${NC}"
        echo ""
        $COMPOSE_CMD exec postgres psql -U postgres -d likha_licensing
        ;;
    
    "reset")
        echo -e "${RED}⚠️  This will reset the database and lose all data!${NC}"
        read -p "Are you sure? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo -e "${YELLOW}🔄 Resetting database...${NC}"
            $COMPOSE_CMD stop app
            $COMPOSE_CMD exec postgres psql -U postgres -d likha_licensing -c "DROP SCHEMA IF EXISTS tenant_default CASCADE;"
            $COMPOSE_CMD exec postgres psql -U postgres -d likha_licensing -c "DROP SCHEMA IF EXISTS tenant_001 CASCADE;"
            $COMPOSE_CMD exec postgres psql -U postgres -d likha_licensing -c "DROP SCHEMA IF EXISTS tenant_002 CASCADE;"
            $COMPOSE_CMD exec postgres psql -U postgres -d likha_licensing -c "DROP SCHEMA IF EXISTS tenant_003 CASCADE;"
            $COMPOSE_CMD exec postgres psql -U postgres -d likha_licensing -c "DROP TABLE IF EXISTS public.tenants CASCADE;"
            $COMPOSE_CMD exec postgres psql -U postgres -d likha_licensing -c "DROP TABLE IF EXISTS public.users CASCADE;"
            $COMPOSE_CMD restart postgres
            sleep 5
            echo -e "${GREEN}✅ Database reset completed${NC}"
            echo -e "${YELLOW}🔄 Restarting application to reinitialize database...${NC}"
            $COMPOSE_CMD start app
        else
            echo -e "${BLUE}ℹ️  Database reset cancelled${NC}"
        fi
        ;;
    
    "backup")
        BACKUP_FILE="backup_$(date +%Y%m%d_%H%M%S).sql"
        echo -e "${YELLOW}💾 Creating database backup: $BACKUP_FILE${NC}"
        $COMPOSE_CMD exec -T postgres pg_dump -U postgres -d likha_licensing > $BACKUP_FILE
        echo -e "${GREEN}✅ Backup created: $BACKUP_FILE${NC}"
        ;;
    
    "restore")
        if [ -z "$2" ]; then
            echo -e "${RED}❌ Please specify backup file: scripts/dev-db.sh restore <backup_file.sql>${NC}"
            exit 1
        fi
        BACKUP_FILE=$2
        if [ ! -f "$BACKUP_FILE" ]; then
            echo -e "${RED}❌ Backup file not found: $BACKUP_FILE${NC}"
            exit 1
        fi
        echo -e "${YELLOW}📥 Restoring database from: $BACKUP_FILE${NC}"
        $COMPOSE_CMD exec -T postgres psql -U postgres -d likha_licensing < $BACKUP_FILE
        echo -e "${GREEN}✅ Database restored from backup${NC}"
        ;;
    
    "tenants")
        echo -e "${BLUE}👥 Current tenant schemas:${NC}"
        $COMPOSE_CMD exec postgres psql -U postgres -d likha_licensing -c "SELECT schema_name FROM information_schema.schemata WHERE schema_name LIKE 'tenant_%' ORDER BY schema_name;"
        echo ""
        echo -e "${BLUE}📋 Tenant configuration:${NC}"
        $COMPOSE_CMD exec postgres psql -U postgres -d likha_licensing -c "SELECT tenant_id, tenant_name, schema_name, active, created_at FROM public.tenants ORDER BY created_at;"
        ;;
    
    "create-tenant")
        if [ -z "$2" ]; then
            echo -e "${RED}❌ Please specify tenant ID: scripts/dev-db.sh create-tenant <tenant_id>${NC}"
            exit 1
        fi
        TENANT_ID=$2
        TENANT_NAME=${3:-"$TENANT_ID"}
        SCHEMA_NAME="tenant_${TENANT_ID}"
        
        echo -e "${YELLOW}🏗️  Creating tenant: $TENANT_ID${NC}"
        
        # Create schema
        $COMPOSE_CMD exec postgres psql -U postgres -d likha_licensing -c "CREATE SCHEMA IF NOT EXISTS $SCHEMA_NAME;"
        $COMPOSE_CMD exec postgres psql -U postgres -d likha_licensing -c "GRANT ALL ON SCHEMA $SCHEMA_NAME TO postgres;"
        
        # Add tenant record
        $COMPOSE_CMD exec postgres psql -U postgres -d likha_licensing -c "INSERT INTO public.tenants (tenant_id, tenant_name, schema_name) VALUES ('$TENANT_ID', '$TENANT_NAME', '$SCHEMA_NAME') ON CONFLICT (tenant_id) DO NOTHING;"
        
        echo -e "${GREEN}✅ Tenant created: $TENANT_ID${NC}"
        ;;
    
    "drop-tenant")
        if [ -z "$2" ]; then
            echo -e "${RED}❌ Please specify tenant ID: scripts/dev-db.sh drop-tenant <tenant_id>${NC}"
            exit 1
        fi
        TENANT_ID=$2
        SCHEMA_NAME="tenant_${TENANT_ID}"
        
        echo -e "${RED}⚠️  This will permanently delete tenant: $TENANT_ID${NC}"
        read -p "Are you sure? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo -e "${YELLOW}🗑️  Dropping tenant: $TENANT_ID${NC}"
            
            # Drop schema
            $COMPOSE_CMD exec postgres psql -U postgres -d likha_licensing -c "DROP SCHEMA IF EXISTS $SCHEMA_NAME CASCADE;"
            
            # Remove tenant record
            $COMPOSE_CMD exec postgres psql -U postgres -d likha_licensing -c "DELETE FROM public.tenants WHERE tenant_id = '$TENANT_ID';"
            
            echo -e "${GREEN}✅ Tenant dropped: $TENANT_ID${NC}"
        else
            echo -e "${BLUE}ℹ️  Tenant drop cancelled${NC}"
        fi
        ;;
    
    "help"|*)
        echo -e "${BLUE}🗄️  Likha Licensing Platform - Database Management${NC}"
        echo ""
        echo -e "${YELLOW}Available commands:${NC}"
        echo -e "  shell          Open PostgreSQL shell"
        echo -e "  reset          Reset database (WARNING: destroys all data)"
        echo -e "  backup         Create database backup"
        echo -e "  restore <file> Restore from backup file"
        echo -e "  tenants        List all tenant schemas and configuration"
        echo -e "  create-tenant <id> [name]  Create new tenant schema"
        echo -e "  drop-tenant <id>           Drop tenant schema (WARNING: destroys tenant data)"
        echo -e "  help           Show this help message"
        echo ""
        echo -e "${BLUE}Examples:${NC}"
        echo -e "  scripts/dev-db.sh shell"
        echo -e "  scripts/dev-db.sh create-tenant acme-corp 'Acme Corporation'"
        echo -e "  scripts/dev-db.sh backup"
        echo -e "  scripts/dev-db.sh restore backup_20240101_120000.sql"
        ;;
esac