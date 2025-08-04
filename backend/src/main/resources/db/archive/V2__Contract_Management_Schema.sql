-- Contract Management Database Schema
-- Implements file management with S3 integration and batch upload support
-- Multi-tenant isolation using schema-per-tenant approach
-- Version: 2.0
-- Date: 2025-08-02

-- ==============================================================================
-- UPLOAD SESSIONS TABLE
-- ==============================================================================
-- Tracks batch upload operations across tenants
-- Enables atomic multi-file upload processing
CREATE TABLE IF NOT EXISTS upload_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id VARCHAR(50) NOT NULL,
    session_name VARCHAR(255),
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    total_files INTEGER NOT NULL DEFAULT 0,
    completed_files INTEGER NOT NULL DEFAULT 0,
    failed_files INTEGER NOT NULL DEFAULT 0,
    total_size_bytes BIGINT DEFAULT 0,
    processed_size_bytes BIGINT DEFAULT 0,
    initiated_by_user_id UUID,
    error_message TEXT,
    metadata JSONB,
    created_at TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP(6),
    
    -- Constraints
    CONSTRAINT fk_upload_sessions_tenant FOREIGN KEY (tenant_id) REFERENCES tenants(tenant_id),
    CONSTRAINT chk_upload_session_status CHECK (status IN ('PENDING', 'IN_PROGRESS', 'COMPLETED', 'FAILED', 'CANCELLED')),
    CONSTRAINT chk_upload_session_files CHECK (completed_files >= 0 AND failed_files >= 0 AND total_files >= 0),
    CONSTRAINT chk_upload_session_size CHECK (total_size_bytes >= 0 AND processed_size_bytes >= 0)
);

-- ==============================================================================
-- CONTRACTS TABLE  
-- ==============================================================================
-- Stores contract file metadata with S3 integration
-- Supports multi-tenant isolation and batch operations
CREATE TABLE IF NOT EXISTS contracts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id VARCHAR(50) NOT NULL,
    
    -- File Identification
    filename VARCHAR(255) NOT NULL,
    original_filename VARCHAR(255) NOT NULL,
    display_name VARCHAR(255),
    
    -- File Properties
    file_size BIGINT NOT NULL,
    mime_type VARCHAR(100) NOT NULL,
    file_extension VARCHAR(10),
    checksum VARCHAR(64) NOT NULL,
    checksum_algorithm VARCHAR(10) NOT NULL DEFAULT 'SHA256',
    
    -- S3/MinIO Integration
    s3_bucket VARCHAR(100) NOT NULL,
    s3_key VARCHAR(500) NOT NULL,
    s3_version_id VARCHAR(100),
    s3_etag VARCHAR(100),
    
    -- Upload Session Reference
    upload_session_id UUID,
    upload_order INTEGER,
    
    -- Status and Processing
    status VARCHAR(20) NOT NULL DEFAULT 'UPLOADING',
    processing_status VARCHAR(20) DEFAULT 'PENDING',
    virus_scan_status VARCHAR(20) DEFAULT 'PENDING',
    virus_scan_result TEXT,
    
    -- Business Metadata
    contract_type VARCHAR(50),
    contract_category VARCHAR(50),
    contract_tags TEXT[],
    contract_description TEXT,
    contract_value DECIMAL(15,2),
    contract_currency VARCHAR(3),
    effective_date DATE,
    expiration_date DATE,
    
    -- System Metadata
    created_by_user_id UUID,
    updated_by_user_id UUID,
    created_at TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP(6),
    
    -- Technical Metadata
    content_length BIGINT,
    content_encoding VARCHAR(50),
    last_accessed_at TIMESTAMP(6),
    access_count INTEGER NOT NULL DEFAULT 0,
    
    -- Constraints
    CONSTRAINT fk_contracts_tenant FOREIGN KEY (tenant_id) REFERENCES tenants(tenant_id),
    CONSTRAINT fk_contracts_upload_session FOREIGN KEY (upload_session_id) REFERENCES upload_sessions(id),
    CONSTRAINT fk_contracts_created_by FOREIGN KEY (created_by_user_id) REFERENCES users(id),
    CONSTRAINT fk_contracts_updated_by FOREIGN KEY (updated_by_user_id) REFERENCES users(id),
    CONSTRAINT chk_contract_status CHECK (status IN ('UPLOADING', 'UPLOADED', 'PROCESSING', 'READY', 'ERROR', 'DELETED')),
    CONSTRAINT chk_processing_status CHECK (processing_status IN ('PENDING', 'IN_PROGRESS', 'COMPLETED', 'FAILED')),
    CONSTRAINT chk_virus_scan_status CHECK (virus_scan_status IN ('PENDING', 'SCANNING', 'CLEAN', 'INFECTED', 'ERROR')),
    CONSTRAINT chk_contract_file_size CHECK (file_size > 0),
    CONSTRAINT chk_contract_value CHECK (contract_value IS NULL OR contract_value >= 0),
    CONSTRAINT chk_contract_dates CHECK (expiration_date IS NULL OR effective_date IS NULL OR expiration_date >= effective_date),
    CONSTRAINT unique_s3_key_per_tenant UNIQUE (tenant_id, s3_key),
    CONSTRAINT unique_checksum_per_tenant UNIQUE (tenant_id, checksum, file_size)
);

-- ==============================================================================
-- CONTRACT VERSIONS TABLE
-- ==============================================================================
-- Tracks version history for contracts that are updated/replaced
CREATE TABLE IF NOT EXISTS contract_versions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    contract_id UUID NOT NULL,
    version_number INTEGER NOT NULL,
    s3_bucket VARCHAR(100) NOT NULL,
    s3_key VARCHAR(500) NOT NULL,
    s3_version_id VARCHAR(100),
    checksum VARCHAR(64) NOT NULL,
    file_size BIGINT NOT NULL,
    mime_type VARCHAR(100) NOT NULL,
    created_by_user_id UUID,
    created_at TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    notes TEXT,
    
    -- Constraints
    CONSTRAINT fk_contract_versions_contract FOREIGN KEY (contract_id) REFERENCES contracts(id) ON DELETE CASCADE,
    CONSTRAINT fk_contract_versions_created_by FOREIGN KEY (created_by_user_id) REFERENCES users(id),
    CONSTRAINT chk_version_number CHECK (version_number > 0),
    CONSTRAINT chk_version_file_size CHECK (file_size > 0),
    CONSTRAINT unique_contract_version UNIQUE (contract_id, version_number)
);

-- ==============================================================================
-- CONTRACT ACCESS LOG TABLE
-- ==============================================================================
-- Audit trail for contract file access and downloads
CREATE TABLE IF NOT EXISTS contract_access_log (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    contract_id UUID NOT NULL,
    user_id UUID,
    access_type VARCHAR(20) NOT NULL,
    ip_address INET,
    user_agent TEXT,
    access_timestamp TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    bytes_transferred BIGINT,
    success BOOLEAN NOT NULL DEFAULT true,
    error_message TEXT,
    
    -- Constraints
    CONSTRAINT fk_contract_access_contract FOREIGN KEY (contract_id) REFERENCES contracts(id) ON DELETE CASCADE,
    CONSTRAINT fk_contract_access_user FOREIGN KEY (user_id) REFERENCES users(id),
    CONSTRAINT chk_access_type CHECK (access_type IN ('VIEW', 'DOWNLOAD', 'PREVIEW', 'METADATA')),
    CONSTRAINT chk_bytes_transferred CHECK (bytes_transferred IS NULL OR bytes_transferred >= 0)
);

-- ==============================================================================
-- PERFORMANCE INDEXES
-- ==============================================================================

-- Upload Sessions Indexes
CREATE INDEX IF NOT EXISTS idx_upload_sessions_tenant_id ON upload_sessions (tenant_id);
CREATE INDEX IF NOT EXISTS idx_upload_sessions_status ON upload_sessions (status);
CREATE INDEX IF NOT EXISTS idx_upload_sessions_created_at ON upload_sessions (created_at);
CREATE INDEX IF NOT EXISTS idx_upload_sessions_tenant_status ON upload_sessions (tenant_id, status);

-- Contracts Indexes
CREATE INDEX IF NOT EXISTS idx_contracts_tenant_id ON contracts (tenant_id);
CREATE INDEX IF NOT EXISTS idx_contracts_status ON contracts (status);
CREATE INDEX IF NOT EXISTS idx_contracts_upload_session_id ON contracts (upload_session_id);
CREATE INDEX IF NOT EXISTS idx_contracts_created_at ON contracts (created_at);
CREATE INDEX IF NOT EXISTS idx_contracts_tenant_status ON contracts (tenant_id, status);
CREATE INDEX IF NOT EXISTS idx_contracts_tenant_created_at ON contracts (tenant_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_contracts_s3_bucket_key ON contracts (s3_bucket, s3_key);
CREATE INDEX IF NOT EXISTS idx_contracts_checksum ON contracts (checksum);
CREATE INDEX IF NOT EXISTS idx_contracts_mime_type ON contracts (mime_type);
CREATE INDEX IF NOT EXISTS idx_contracts_contract_type ON contracts (contract_type);
CREATE INDEX IF NOT EXISTS idx_contracts_effective_date ON contracts (effective_date);
CREATE INDEX IF NOT EXISTS idx_contracts_expiration_date ON contracts (expiration_date);
CREATE INDEX IF NOT EXISTS idx_contracts_created_by ON contracts (created_by_user_id);
CREATE INDEX IF NOT EXISTS idx_contracts_deleted_at ON contracts (deleted_at) WHERE deleted_at IS NULL;

-- Contract Versions Indexes
CREATE INDEX IF NOT EXISTS idx_contract_versions_contract_id ON contract_versions (contract_id);
CREATE INDEX IF NOT EXISTS idx_contract_versions_created_at ON contract_versions (created_at);
CREATE INDEX IF NOT EXISTS idx_contract_versions_contract_version ON contract_versions (contract_id, version_number DESC);

-- Contract Access Log Indexes
CREATE INDEX IF NOT EXISTS idx_contract_access_contract_id ON contract_access_log (contract_id);
CREATE INDEX IF NOT EXISTS idx_contract_access_user_id ON contract_access_log (user_id);
CREATE INDEX IF NOT EXISTS idx_contract_access_timestamp ON contract_access_log (access_timestamp);
CREATE INDEX IF NOT EXISTS idx_contract_access_type ON contract_access_log (access_type);
CREATE INDEX IF NOT EXISTS idx_contract_access_contract_timestamp ON contract_access_log (contract_id, access_timestamp DESC);

-- ==============================================================================
-- TRIGGERS FOR UPDATED_AT AUTOMATION
-- ==============================================================================

-- Create updated_at trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply triggers to relevant tables
CREATE TRIGGER update_upload_sessions_updated_at BEFORE UPDATE ON upload_sessions 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_contracts_updated_at BEFORE UPDATE ON contracts 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ==============================================================================
-- TENANT SCHEMA INITIALIZATION
-- ==============================================================================

-- Create tables in default tenant schema for immediate use
-- Note: In production, these would be created dynamically for each new tenant

-- Upload Sessions for default tenant
CREATE TABLE IF NOT EXISTS tenant_default.upload_sessions (
    LIKE upload_sessions INCLUDING ALL
);

-- Contracts for default tenant  
CREATE TABLE IF NOT EXISTS tenant_default.contracts (
    LIKE contracts INCLUDING ALL
);

-- Contract Versions for default tenant
CREATE TABLE IF NOT EXISTS tenant_default.contract_versions (
    LIKE contract_versions INCLUDING ALL
);

-- Contract Access Log for default tenant
CREATE TABLE IF NOT EXISTS tenant_default.contract_access_log (
    LIKE contract_access_log INCLUDING ALL
);

-- Add foreign key constraints for tenant schema tables
ALTER TABLE tenant_default.upload_sessions 
    ADD CONSTRAINT fk_upload_sessions_tenant 
    FOREIGN KEY (tenant_id) REFERENCES public.tenants(tenant_id);

ALTER TABLE tenant_default.contracts 
    ADD CONSTRAINT fk_contracts_tenant 
    FOREIGN KEY (tenant_id) REFERENCES public.tenants(tenant_id);

ALTER TABLE tenant_default.contracts 
    ADD CONSTRAINT fk_contracts_upload_session 
    FOREIGN KEY (upload_session_id) REFERENCES tenant_default.upload_sessions(id);

ALTER TABLE tenant_default.contracts 
    ADD CONSTRAINT fk_contracts_created_by 
    FOREIGN KEY (created_by_user_id) REFERENCES public.users(id);

ALTER TABLE tenant_default.contracts 
    ADD CONSTRAINT fk_contracts_updated_by 
    FOREIGN KEY (updated_by_user_id) REFERENCES public.users(id);

ALTER TABLE tenant_default.contract_versions 
    ADD CONSTRAINT fk_contract_versions_contract 
    FOREIGN KEY (contract_id) REFERENCES tenant_default.contracts(id) ON DELETE CASCADE;

ALTER TABLE tenant_default.contract_versions 
    ADD CONSTRAINT fk_contract_versions_created_by 
    FOREIGN KEY (created_by_user_id) REFERENCES public.users(id);

ALTER TABLE tenant_default.contract_access_log 
    ADD CONSTRAINT fk_contract_access_contract 
    FOREIGN KEY (contract_id) REFERENCES tenant_default.contracts(id) ON DELETE CASCADE;

ALTER TABLE tenant_default.contract_access_log 
    ADD CONSTRAINT fk_contract_access_user 
    FOREIGN KEY (user_id) REFERENCES public.users(id);

-- ==============================================================================
-- GRANT PERMISSIONS
-- ==============================================================================

-- Grant permissions on default tenant schema tables
GRANT ALL ON tenant_default.upload_sessions TO postgres;
GRANT ALL ON tenant_default.contracts TO postgres;
GRANT ALL ON tenant_default.contract_versions TO postgres;
GRANT ALL ON tenant_default.contract_access_log TO postgres;

-- ==============================================================================
-- SAMPLE DATA FOR DEVELOPMENT
-- ==============================================================================

-- Insert sample upload session for testing
INSERT INTO tenant_default.upload_sessions (
    tenant_id, 
    session_name, 
    status, 
    total_files, 
    completed_files,
    total_size_bytes,
    metadata
) VALUES (
    'default',
    'Initial Contract Upload Batch',
    'COMPLETED',
    0,
    0,
    0,
    '{"description": "Initial setup - no files uploaded yet"}'::jsonb
) ON CONFLICT DO NOTHING;

-- ==============================================================================
-- SCHEMA VALIDATION
-- ==============================================================================

-- Verify table creation and structure
DO $$
BEGIN
    -- Check if all required tables exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'upload_sessions' AND table_schema = 'public') THEN
        RAISE EXCEPTION 'upload_sessions table was not created successfully';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'contracts' AND table_schema = 'public') THEN
        RAISE EXCEPTION 'contracts table was not created successfully';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'contract_versions' AND table_schema = 'public') THEN
        RAISE EXCEPTION 'contract_versions table was not created successfully';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'contract_access_log' AND table_schema = 'public') THEN
        RAISE EXCEPTION 'contract_access_log table was not created successfully';
    END IF;
    
    -- Check tenant schema tables
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'contracts' AND table_schema = 'tenant_default') THEN
        RAISE EXCEPTION 'tenant_default.contracts table was not created successfully';
    END IF;
    
    RAISE NOTICE 'Contract Management Schema V2 successfully created and validated';
END $$;