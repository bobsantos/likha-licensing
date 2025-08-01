#!/bin/bash
set -e

# Schema-per-tenant multi-tenancy setup for PostgreSQL
# This script runs during PostgreSQL container initialization
# Architecture: Single database with isolated schemas per tenant

# Create schemas for multi-tenancy within the main database
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    -- Create default tenant schema
    CREATE SCHEMA IF NOT EXISTS tenant_default;
    
    -- Create sample tenant schemas
    CREATE SCHEMA IF NOT EXISTS tenant_001;
    CREATE SCHEMA IF NOT EXISTS tenant_002;
    CREATE SCHEMA IF NOT EXISTS tenant_003;
    
    -- Grant permissions
    GRANT ALL ON SCHEMA tenant_default TO $POSTGRES_USER;
    GRANT ALL ON SCHEMA tenant_001 TO $POSTGRES_USER;
    GRANT ALL ON SCHEMA tenant_002 TO $POSTGRES_USER;
    GRANT ALL ON SCHEMA tenant_003 TO $POSTGRES_USER;
    
    -- Create public tables that are shared across tenants
    CREATE TABLE IF NOT EXISTS public.tenants (
        id SERIAL PRIMARY KEY,
        tenant_id VARCHAR(255) UNIQUE NOT NULL,
        tenant_name VARCHAR(255) NOT NULL,
        schema_name VARCHAR(255) NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        active BOOLEAN DEFAULT true
    );
    
    -- Insert default tenant data
    INSERT INTO public.tenants (tenant_id, tenant_name, schema_name) 
    VALUES 
        ('default', 'Default Tenant', 'tenant_default'),
        ('tenant-001', 'Tenant 001', 'tenant_001'),
        ('tenant-002', 'Tenant 002', 'tenant_002'),
        ('tenant-003', 'Tenant 003', 'tenant_003')
    ON CONFLICT (tenant_id) DO NOTHING;
    
    -- Create user management table (shared across tenants)
    CREATE TABLE IF NOT EXISTS public.users (
        id SERIAL PRIMARY KEY,
        username VARCHAR(255) UNIQUE NOT NULL,
        email VARCHAR(255) UNIQUE NOT NULL,
        password_hash VARCHAR(255) NOT NULL,
        tenant_id VARCHAR(255) NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        active BOOLEAN DEFAULT true,
        FOREIGN KEY (tenant_id) REFERENCES public.tenants(tenant_id)
    );
    
    -- Create indexes for better performance
    CREATE INDEX IF NOT EXISTS idx_users_tenant_id ON public.users(tenant_id);
    CREATE INDEX IF NOT EXISTS idx_users_email ON public.users(email);
    CREATE INDEX IF NOT EXISTS idx_tenants_tenant_id ON public.tenants(tenant_id);
EOSQL

echo "Schema-per-tenant database structure created successfully"