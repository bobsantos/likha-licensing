-- Fix User ID Type Compatibility
-- Change users.id from INTEGER to UUID for consistency with contract schema

-- First, drop foreign key constraints that reference users.id
ALTER TABLE users DROP CONSTRAINT IF EXISTS users_tenant_id_fkey;

-- Create new users table with UUID primary key
CREATE TABLE users_new (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    username VARCHAR(255) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    tenant_id VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    active BOOLEAN DEFAULT true
);

-- Copy existing data, generating new UUIDs for each user
INSERT INTO users_new (username, email, password_hash, tenant_id, created_at, updated_at, active)
SELECT username, email, password_hash, tenant_id, created_at, updated_at, active
FROM users;

-- Drop old users table
DROP TABLE users CASCADE;

-- Rename new table
ALTER TABLE users_new RENAME TO users;

-- Recreate indexes
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_tenant_id ON users(tenant_id);

-- Recreate foreign key constraint to tenants table
ALTER TABLE users ADD CONSTRAINT users_tenant_id_fkey 
    FOREIGN KEY (tenant_id) REFERENCES tenants(tenant_id);

