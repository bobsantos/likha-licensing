-- Initial database setup for Spring Modulith Event Publication
-- This creates the event_publication table required by Spring Modulith for event externalization
-- Version: 1.0
-- Date: 2025-08-01

-- Create event_publication table for Spring Modulith
CREATE TABLE IF NOT EXISTS event_publication (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    completion_date TIMESTAMP(6),
    event_type VARCHAR(512) NOT NULL,
    listener_id VARCHAR(512) NOT NULL,
    publication_date TIMESTAMP(6) NOT NULL,
    serialized_event TEXT NOT NULL
);

-- Create index for performance
CREATE INDEX IF NOT EXISTS idx_event_publication_completion_date 
ON event_publication (completion_date);

CREATE INDEX IF NOT EXISTS idx_event_publication_publication_date 
ON event_publication (publication_date);

-- Create tenants table for multi-tenancy support
CREATE TABLE IF NOT EXISTS tenants (
    tenant_id VARCHAR(50) PRIMARY KEY,
    tenant_name VARCHAR(255) NOT NULL,
    schema_name VARCHAR(63) NOT NULL UNIQUE,
    active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT valid_schema_name CHECK (schema_name ~ '^[a-z][a-z0-9_]*$')
);

-- Create users table for basic authentication
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id VARCHAR(50) NOT NULL,
    username VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_users_tenant FOREIGN KEY (tenant_id) REFERENCES tenants(tenant_id),
    CONSTRAINT unique_username_per_tenant UNIQUE (tenant_id, username),
    CONSTRAINT unique_email_per_tenant UNIQUE (tenant_id, email)
);

-- Insert default tenant
INSERT INTO tenants (tenant_id, tenant_name, schema_name) 
VALUES ('default', 'Default Tenant', 'tenant_default')
ON CONFLICT (tenant_id) DO NOTHING;

-- Create schema for default tenant
CREATE SCHEMA IF NOT EXISTS tenant_default;

-- Grant permissions on default tenant schema
GRANT ALL ON SCHEMA tenant_default TO postgres;