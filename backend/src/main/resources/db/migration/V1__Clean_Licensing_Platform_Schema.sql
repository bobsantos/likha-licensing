-- Clean Licensing Platform Database Schema
-- Comprehensive schema with consistent UUID types throughout
-- Includes core entities: Tenants, Users, Licensors, Licensees, Brands, Contracts, and Files
-- Multi-tenant isolation using schema-per-tenant approach with enhanced security
-- Version: 1.0 (Clean Slate)
-- Date: 2025-08-04

-- ==============================================================================
-- CORE EXTENSIONS AND FUNCTIONS
-- ==============================================================================

-- Enable required PostgreSQL extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Create updated_at trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ==============================================================================
-- 1. TENANTS TABLE - Multi-tenant foundation
-- ==============================================================================

CREATE TABLE IF NOT EXISTS tenants (
    tenant_id VARCHAR(50) PRIMARY KEY,
    tenant_name VARCHAR(255) NOT NULL,
    schema_name VARCHAR(63) NOT NULL UNIQUE,
    active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT valid_schema_name CHECK (schema_name ~ '^[a-z][a-z0-9_]*$')
);

-- ==============================================================================
-- 2. USERS TABLE - Authentication and authorization
-- ==============================================================================

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

-- ==============================================================================
-- 3. SPRING MODULITH EVENT PUBLICATION TABLE
-- ==============================================================================

CREATE TABLE IF NOT EXISTS event_publication (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    completion_date TIMESTAMP(6),
    event_type VARCHAR(512) NOT NULL,
    listener_id VARCHAR(512) NOT NULL,
    publication_date TIMESTAMP(6) NOT NULL,
    serialized_event TEXT NOT NULL
);

-- ==============================================================================
-- 4. LICENSORS TABLE - Rights holders
-- ==============================================================================

CREATE TABLE IF NOT EXISTS licensors (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id VARCHAR(50) NOT NULL,
    
    -- Basic Information
    name VARCHAR(255) NOT NULL,
    legal_name VARCHAR(255),
    registration_number VARCHAR(100),
    tax_id VARCHAR(50),
    
    -- Contact Information
    primary_contact_name VARCHAR(255),
    primary_contact_email VARCHAR(255),
    primary_contact_phone VARCHAR(50),
    website_url VARCHAR(500),
    
    -- Address Information
    address_line1 VARCHAR(255),
    address_line2 VARCHAR(255),
    city VARCHAR(100),
    state_province VARCHAR(100),
    postal_code VARCHAR(20),
    country VARCHAR(100),
    
    -- Business Details
    business_type VARCHAR(50), -- 'INDIVIDUAL', 'CORPORATION', 'LLC', 'PARTNERSHIP', 'NON_PROFIT'
    industry VARCHAR(100),
    company_size VARCHAR(20), -- 'SMALL', 'MEDIUM', 'LARGE', 'ENTERPRISE'
    annual_revenue DECIMAL(15,2),
    revenue_currency VARCHAR(3),
    
    -- Metadata
    notes TEXT,
    tags TEXT[],
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE', -- 'ACTIVE', 'INACTIVE', 'SUSPENDED'
    
    -- Audit Fields
    created_by_user_id UUID,
    updated_by_user_id UUID,
    created_at TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP(6),
    
    -- Constraints
    CONSTRAINT fk_licensors_tenant FOREIGN KEY (tenant_id) REFERENCES tenants(tenant_id),
    CONSTRAINT fk_licensors_created_by FOREIGN KEY (created_by_user_id) REFERENCES users(id),
    CONSTRAINT fk_licensors_updated_by FOREIGN KEY (updated_by_user_id) REFERENCES users(id),
    CONSTRAINT chk_licensor_status CHECK (status IN ('ACTIVE', 'INACTIVE', 'SUSPENDED')),
    CONSTRAINT chk_licensor_business_type CHECK (business_type IN ('INDIVIDUAL', 'CORPORATION', 'LLC', 'PARTNERSHIP', 'NON_PROFIT')),
    CONSTRAINT chk_licensor_company_size CHECK (company_size IN ('SMALL', 'MEDIUM', 'LARGE', 'ENTERPRISE')),
    CONSTRAINT chk_licensor_annual_revenue CHECK (annual_revenue IS NULL OR annual_revenue >= 0),
    CONSTRAINT unique_licensor_name_per_tenant UNIQUE (tenant_id, name)
);

-- ==============================================================================
-- 5. LICENSEES TABLE - License buyers/users
-- ==============================================================================

CREATE TABLE IF NOT EXISTS licensees (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id VARCHAR(50) NOT NULL,
    
    -- Basic Information
    name VARCHAR(255) NOT NULL,
    legal_name VARCHAR(255),
    registration_number VARCHAR(100),
    tax_id VARCHAR(50),
    
    -- Contact Information
    primary_contact_name VARCHAR(255),
    primary_contact_email VARCHAR(255),
    primary_contact_phone VARCHAR(50),
    website_url VARCHAR(500),
    
    -- Address Information
    address_line1 VARCHAR(255),
    address_line2 VARCHAR(255),
    city VARCHAR(100),
    state_province VARCHAR(100),
    postal_code VARCHAR(20),
    country VARCHAR(100),
    
    -- Business Details
    business_type VARCHAR(50), -- 'INDIVIDUAL', 'CORPORATION', 'LLC', 'PARTNERSHIP', 'NON_PROFIT'
    industry VARCHAR(100),
    company_size VARCHAR(20), -- 'SMALL', 'MEDIUM', 'LARGE', 'ENTERPRISE'
    annual_revenue DECIMAL(15,2),
    revenue_currency VARCHAR(3),
    
    -- Licensing Specific
    preferred_license_types TEXT[], -- Types of licenses this licensee typically needs
    credit_rating VARCHAR(10), -- 'EXCELLENT', 'GOOD', 'FAIR', 'POOR'
    payment_terms_days INTEGER DEFAULT 30,
    
    -- Metadata
    notes TEXT,
    tags TEXT[],
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE', -- 'ACTIVE', 'INACTIVE', 'SUSPENDED'
    
    -- Audit Fields
    created_by_user_id UUID,
    updated_by_user_id UUID,
    created_at TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP(6),
    
    -- Constraints
    CONSTRAINT fk_licensees_tenant FOREIGN KEY (tenant_id) REFERENCES tenants(tenant_id),
    CONSTRAINT fk_licensees_created_by FOREIGN KEY (created_by_user_id) REFERENCES users(id),
    CONSTRAINT fk_licensees_updated_by FOREIGN KEY (updated_by_user_id) REFERENCES users(id),
    CONSTRAINT chk_licensee_status CHECK (status IN ('ACTIVE', 'INACTIVE', 'SUSPENDED')),
    CONSTRAINT chk_licensee_business_type CHECK (business_type IN ('INDIVIDUAL', 'CORPORATION', 'LLC', 'PARTNERSHIP', 'NON_PROFIT')),
    CONSTRAINT chk_licensee_company_size CHECK (company_size IN ('SMALL', 'MEDIUM', 'LARGE', 'ENTERPRISE')),
    CONSTRAINT chk_licensee_credit_rating CHECK (credit_rating IN ('EXCELLENT', 'GOOD', 'FAIR', 'POOR')),
    CONSTRAINT chk_licensee_annual_revenue CHECK (annual_revenue IS NULL OR annual_revenue >= 0),
    CONSTRAINT chk_licensee_payment_terms CHECK (payment_terms_days > 0),
    CONSTRAINT unique_licensee_name_per_tenant UNIQUE (tenant_id, name)
);

-- ==============================================================================
-- 6. BRANDS TABLE - Intellectual property being licensed
-- ==============================================================================

CREATE TABLE IF NOT EXISTS brands (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id VARCHAR(50) NOT NULL,
    licensor_id UUID,
    
    -- Basic Information
    name VARCHAR(255) NOT NULL,
    legal_name VARCHAR(255),
    brand_code VARCHAR(50), -- Internal reference code
    description TEXT,
    
    -- Brand Classification
    brand_type VARCHAR(50), -- 'TRADEMARK', 'COPYRIGHT', 'PATENT', 'TRADE_SECRET', 'CHARACTER', 'LOGO'
    industry_category VARCHAR(100),
    target_market VARCHAR(100),
    
    -- Legal Information
    trademark_number VARCHAR(100),
    copyright_number VARCHAR(100),
    patent_number VARCHAR(100),
    registration_date DATE,
    expiration_date DATE,
    registration_country VARCHAR(100),
    
    -- Licensing Details
    licensing_territories TEXT[], -- Geographic regions where licensing is allowed
    excluded_territories TEXT[], -- Geographic regions where licensing is restricted
    license_categories TEXT[], -- Product/service categories this brand can license to
    
    -- Financial Information
    estimated_value DECIMAL(15,2),
    value_currency VARCHAR(3),
    royalty_rate_min DECIMAL(5,4), -- Minimum royalty rate as decimal (e.g., 0.05 for 5%)
    royalty_rate_max DECIMAL(5,4), -- Maximum royalty rate as decimal
    minimum_guarantee DECIMAL(15,2), -- Minimum guarantee amount
    
    -- Status and Metadata
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE', -- 'ACTIVE', 'INACTIVE', 'PENDING', 'EXPIRED'
    notes TEXT,
    tags TEXT[],
    
    -- Audit Fields
    created_by_user_id UUID,
    updated_by_user_id UUID,
    created_at TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP(6),
    
    -- Constraints
    CONSTRAINT fk_brands_tenant FOREIGN KEY (tenant_id) REFERENCES tenants(tenant_id),
    CONSTRAINT fk_brands_licensor FOREIGN KEY (licensor_id) REFERENCES licensors(id),
    CONSTRAINT fk_brands_created_by FOREIGN KEY (created_by_user_id) REFERENCES users(id),
    CONSTRAINT fk_brands_updated_by FOREIGN KEY (updated_by_user_id) REFERENCES users(id),
    CONSTRAINT chk_brand_status CHECK (status IN ('ACTIVE', 'INACTIVE', 'PENDING', 'EXPIRED')),
    CONSTRAINT chk_brand_type CHECK (brand_type IN ('TRADEMARK', 'COPYRIGHT', 'PATENT', 'TRADE_SECRET', 'CHARACTER', 'LOGO')),
    CONSTRAINT chk_brand_dates CHECK (expiration_date IS NULL OR registration_date IS NULL OR expiration_date >= registration_date),
    CONSTRAINT chk_brand_estimated_value CHECK (estimated_value IS NULL OR estimated_value >= 0),
    CONSTRAINT chk_brand_royalty_rates CHECK (
        (royalty_rate_min IS NULL OR royalty_rate_min >= 0) AND
        (royalty_rate_max IS NULL OR royalty_rate_max >= 0) AND
        (royalty_rate_min IS NULL OR royalty_rate_max IS NULL OR royalty_rate_max >= royalty_rate_min)
    ),
    CONSTRAINT chk_brand_minimum_guarantee CHECK (minimum_guarantee IS NULL OR minimum_guarantee >= 0),
    CONSTRAINT unique_brand_name_per_tenant UNIQUE (tenant_id, name),
    CONSTRAINT unique_brand_code_per_tenant UNIQUE (tenant_id, brand_code)
);

-- ==============================================================================
-- 7. UPLOAD SESSIONS TABLE - Batch file upload tracking
-- ==============================================================================

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
    CONSTRAINT fk_upload_sessions_initiated_by FOREIGN KEY (initiated_by_user_id) REFERENCES users(id),
    CONSTRAINT chk_upload_session_status CHECK (status IN ('PENDING', 'IN_PROGRESS', 'COMPLETED', 'FAILED', 'CANCELLED')),
    CONSTRAINT chk_upload_session_files CHECK (completed_files >= 0 AND failed_files >= 0 AND total_files >= 0),
    CONSTRAINT chk_upload_session_size CHECK (total_size_bytes >= 0 AND processed_size_bytes >= 0)
);

-- ==============================================================================
-- 8. BUSINESS CONTRACTS TABLE - Core contract entities
-- ==============================================================================

CREATE TABLE IF NOT EXISTS business_contracts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id VARCHAR(50) NOT NULL,
    
    -- Related Entities
    licensor_id UUID NOT NULL,
    licensee_id UUID NOT NULL,
    brand_id UUID,
    
    -- Contract Identification
    contract_number VARCHAR(100),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    contract_type VARCHAR(50) NOT NULL, -- 'EXCLUSIVE', 'NON_EXCLUSIVE', 'SOLE', 'MASTER', 'AMENDMENT'
    
    -- Contract Terms
    license_scope TEXT, -- Description of what is being licensed
    licensed_territories TEXT[], -- Geographic scope
    licensed_categories TEXT[], -- Product/service categories
    exclusivity_type VARCHAR(20), -- 'EXCLUSIVE', 'NON_EXCLUSIVE', 'SOLE'
    
    -- Financial Terms
    total_value DECIMAL(15,2),
    currency VARCHAR(3),
    royalty_rate DECIMAL(5,4), -- Royalty rate as decimal (e.g., 0.05 for 5%)
    minimum_guarantee DECIMAL(15,2),
    advance_payment DECIMAL(15,2),
    payment_schedule VARCHAR(50), -- 'MONTHLY', 'QUARTERLY', 'ANNUALLY', 'LUMP_SUM'
    payment_terms_days INTEGER DEFAULT 30,
    
    -- Contract Dates
    execution_date DATE,
    effective_date DATE NOT NULL,
    expiration_date DATE NOT NULL,
    notice_period_days INTEGER, -- Days required for termination notice
    
    -- Renewal Information
    auto_renewal BOOLEAN DEFAULT FALSE,
    renewal_period_months INTEGER,
    renewal_terms TEXT,
    parent_contract_id UUID, -- For amendments and renewals
    
    -- Status and Lifecycle
    status VARCHAR(20) NOT NULL DEFAULT 'DRAFT', -- 'DRAFT', 'PENDING', 'ACTIVE', 'EXPIRED', 'TERMINATED', 'RENEWED'
    approval_status VARCHAR(20) DEFAULT 'PENDING', -- 'PENDING', 'APPROVED', 'REJECTED'
    execution_status VARCHAR(20) DEFAULT 'PENDING', -- 'PENDING', 'EXECUTED', 'PARTIALLY_EXECUTED'
    
    -- Performance Tracking
    total_royalties_paid DECIMAL(15,2) DEFAULT 0,
    last_royalty_payment_date DATE,
    next_payment_due_date DATE,
    compliance_status VARCHAR(20) DEFAULT 'COMPLIANT', -- 'COMPLIANT', 'NON_COMPLIANT', 'UNDER_REVIEW'
    
    -- Metadata and Administration
    assigned_agent_id UUID, -- User responsible for managing this contract
    notes TEXT,
    tags TEXT[],
    custom_fields JSONB, -- Flexible field storage
    
    -- Audit Fields
    created_by_user_id UUID,
    updated_by_user_id UUID,
    created_at TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP(6),
    
    -- Constraints
    CONSTRAINT fk_business_contracts_tenant FOREIGN KEY (tenant_id) REFERENCES tenants(tenant_id),
    CONSTRAINT fk_business_contracts_licensor FOREIGN KEY (licensor_id) REFERENCES licensors(id),
    CONSTRAINT fk_business_contracts_licensee FOREIGN KEY (licensee_id) REFERENCES licensees(id),
    CONSTRAINT fk_business_contracts_brand FOREIGN KEY (brand_id) REFERENCES brands(id),
    CONSTRAINT fk_business_contracts_parent FOREIGN KEY (parent_contract_id) REFERENCES business_contracts(id),
    CONSTRAINT fk_business_contracts_assigned_agent FOREIGN KEY (assigned_agent_id) REFERENCES users(id),
    CONSTRAINT fk_business_contracts_created_by FOREIGN KEY (created_by_user_id) REFERENCES users(id),
    CONSTRAINT fk_business_contracts_updated_by FOREIGN KEY (updated_by_user_id) REFERENCES users(id),
    CONSTRAINT chk_contract_type CHECK (contract_type IN ('EXCLUSIVE', 'NON_EXCLUSIVE', 'SOLE', 'MASTER', 'AMENDMENT')),
    CONSTRAINT chk_exclusivity_type CHECK (exclusivity_type IN ('EXCLUSIVE', 'NON_EXCLUSIVE', 'SOLE')),
    CONSTRAINT chk_contract_status CHECK (status IN ('DRAFT', 'PENDING', 'ACTIVE', 'EXPIRED', 'TERMINATED', 'RENEWED')),
    CONSTRAINT chk_approval_status CHECK (approval_status IN ('PENDING', 'APPROVED', 'REJECTED')),
    CONSTRAINT chk_execution_status CHECK (execution_status IN ('PENDING', 'EXECUTED', 'PARTIALLY_EXECUTED')),
    CONSTRAINT chk_compliance_status CHECK (compliance_status IN ('COMPLIANT', 'NON_COMPLIANT', 'UNDER_REVIEW')),
    CONSTRAINT chk_payment_schedule CHECK (payment_schedule IN ('MONTHLY', 'QUARTERLY', 'ANNUALLY', 'LUMP_SUM')),
    CONSTRAINT chk_contract_dates CHECK (expiration_date > effective_date),
    CONSTRAINT chk_execution_date CHECK (execution_date IS NULL OR execution_date <= effective_date),
    CONSTRAINT chk_contract_financial_values CHECK (
        (total_value IS NULL OR total_value >= 0) AND
        (royalty_rate IS NULL OR royalty_rate >= 0) AND
        (minimum_guarantee IS NULL OR minimum_guarantee >= 0) AND
        (advance_payment IS NULL OR advance_payment >= 0) AND
        (total_royalties_paid >= 0)
    ),
    CONSTRAINT chk_notice_period CHECK (notice_period_days IS NULL OR notice_period_days > 0),
    CONSTRAINT chk_renewal_period CHECK (renewal_period_months IS NULL OR renewal_period_months > 0),
    CONSTRAINT chk_payment_terms CHECK (payment_terms_days > 0),
    CONSTRAINT unique_contract_number_per_tenant UNIQUE (tenant_id, contract_number),
    CONSTRAINT unique_contract_title_per_tenant UNIQUE (tenant_id, title)
);

-- ==============================================================================
-- 9. CONTRACT FILES TABLE - File attachments for contracts
-- ==============================================================================

CREATE TABLE IF NOT EXISTS contract_files (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id VARCHAR(50) NOT NULL,
    business_contract_id UUID NOT NULL,
    
    -- File Identification
    filename VARCHAR(255) NOT NULL,
    original_filename VARCHAR(255) NOT NULL,
    display_name VARCHAR(255),
    file_type VARCHAR(50) NOT NULL, -- 'MAIN_CONTRACT', 'AMENDMENT', 'EXHIBIT', 'SIGNATURE_PAGE', 'OTHER'
    
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
    file_description TEXT,
    file_tags TEXT[],
    version_number INTEGER DEFAULT 1,
    is_primary BOOLEAN DEFAULT FALSE,
    
    -- Technical Metadata
    content_length BIGINT,
    content_encoding VARCHAR(50),
    last_accessed_at TIMESTAMP(6),
    access_count INTEGER NOT NULL DEFAULT 0,
    
    -- Audit Fields
    created_by_user_id UUID,
    updated_by_user_id UUID,
    created_at TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP(6),
    
    -- Constraints
    CONSTRAINT fk_contract_files_tenant FOREIGN KEY (tenant_id) REFERENCES tenants(tenant_id),
    CONSTRAINT fk_contract_files_business_contract FOREIGN KEY (business_contract_id) REFERENCES business_contracts(id) ON DELETE CASCADE,
    CONSTRAINT fk_contract_files_upload_session FOREIGN KEY (upload_session_id) REFERENCES upload_sessions(id),
    CONSTRAINT fk_contract_files_created_by FOREIGN KEY (created_by_user_id) REFERENCES users(id),
    CONSTRAINT fk_contract_files_updated_by FOREIGN KEY (updated_by_user_id) REFERENCES users(id),
    CONSTRAINT chk_contract_file_type CHECK (file_type IN ('MAIN_CONTRACT', 'AMENDMENT', 'EXHIBIT', 'SIGNATURE_PAGE', 'OTHER')),
    CONSTRAINT chk_contract_file_status CHECK (status IN ('UPLOADING', 'UPLOADED', 'PROCESSING', 'READY', 'ERROR', 'DELETED')),
    CONSTRAINT chk_contract_file_processing_status CHECK (processing_status IN ('PENDING', 'IN_PROGRESS', 'COMPLETED', 'FAILED')),
    CONSTRAINT chk_contract_file_virus_scan_status CHECK (virus_scan_status IN ('PENDING', 'SCANNING', 'CLEAN', 'INFECTED', 'ERROR')),
    CONSTRAINT chk_contract_file_size CHECK (file_size > 0),
    CONSTRAINT unique_s3_key_per_tenant_contract_files UNIQUE (tenant_id, s3_key),
    CONSTRAINT unique_checksum_per_tenant_contract_files UNIQUE (tenant_id, checksum, file_size)
);

-- ==============================================================================
-- 10. CONTRACT VERSIONS TABLE - Version history for contract files
-- ==============================================================================

CREATE TABLE IF NOT EXISTS contract_versions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    contract_file_id UUID NOT NULL,
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
    CONSTRAINT fk_contract_versions_contract_file FOREIGN KEY (contract_file_id) REFERENCES contract_files(id) ON DELETE CASCADE,
    CONSTRAINT fk_contract_versions_created_by FOREIGN KEY (created_by_user_id) REFERENCES users(id),
    CONSTRAINT chk_version_number CHECK (version_number > 0),
    CONSTRAINT chk_version_file_size CHECK (file_size > 0),
    CONSTRAINT unique_contract_file_version UNIQUE (contract_file_id, version_number)
);

-- ==============================================================================
-- 11. CONTRACT ACCESS LOG TABLE - Audit trail for file access
-- ==============================================================================

CREATE TABLE IF NOT EXISTS contract_access_log (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    contract_file_id UUID NOT NULL,
    user_id UUID,
    access_type VARCHAR(20) NOT NULL,
    ip_address INET,
    user_agent TEXT,
    access_timestamp TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    bytes_transferred BIGINT,
    success BOOLEAN NOT NULL DEFAULT true,
    error_message TEXT,
    
    -- Constraints
    CONSTRAINT fk_contract_access_contract_file FOREIGN KEY (contract_file_id) REFERENCES contract_files(id) ON DELETE CASCADE,
    CONSTRAINT fk_contract_access_user FOREIGN KEY (user_id) REFERENCES users(id),
    CONSTRAINT chk_access_type CHECK (access_type IN ('VIEW', 'DOWNLOAD', 'PREVIEW', 'METADATA')),
    CONSTRAINT chk_bytes_transferred CHECK (bytes_transferred IS NULL OR bytes_transferred >= 0)
);

-- ==============================================================================
-- 12. SECURITY AUDIT LOG TABLE - Security events
-- ==============================================================================

CREATE TABLE IF NOT EXISTS security_audit_log (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id VARCHAR(50) NOT NULL,
    
    -- Event Information
    event_type VARCHAR(50) NOT NULL, -- 'LOGIN', 'LOGOUT', 'DATA_ACCESS', 'DATA_MODIFICATION', 'PERMISSION_CHANGE'
    event_category VARCHAR(50) NOT NULL, -- 'AUTHENTICATION', 'AUTHORIZATION', 'DATA_ACCESS', 'SYSTEM'
    severity VARCHAR(20) NOT NULL DEFAULT 'INFO', -- 'LOW', 'MEDIUM', 'HIGH', 'CRITICAL'
    
    -- User and Session Information
    user_id UUID,
    username VARCHAR(255),
    session_id VARCHAR(255),
    
    -- Request Information
    ip_address INET,
    user_agent TEXT,
    request_method VARCHAR(10),
    request_path TEXT,
    
    -- Resource Information
    resource_type VARCHAR(50), -- 'CONTRACT', 'LICENSEE', 'LICENSOR', 'BRAND'
    resource_id UUID,
    resource_description TEXT,
    
    -- Action Details
    action_performed VARCHAR(100), -- 'CREATE', 'READ', 'UPDATE', 'DELETE', 'DOWNLOAD', 'UPLOAD'
    old_values JSONB,
    new_values JSONB,
    
    -- Result Information
    success BOOLEAN NOT NULL DEFAULT true,
    error_message TEXT,
    response_status_code INTEGER,
    
    -- Additional Context
    metadata JSONB,
    risk_score INTEGER, -- 0-100 risk assessment
    
    -- Timestamp
    event_timestamp TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraints
    CONSTRAINT fk_security_audit_log_tenant FOREIGN KEY (tenant_id) REFERENCES tenants(tenant_id),
    CONSTRAINT fk_security_audit_log_user FOREIGN KEY (user_id) REFERENCES users(id),
    CONSTRAINT chk_audit_event_type CHECK (event_type IN ('LOGIN', 'LOGOUT', 'DATA_ACCESS', 'DATA_MODIFICATION', 'PERMISSION_CHANGE', 'FILE_UPLOAD', 'FILE_DOWNLOAD', 'FAILED_ACCESS')),
    CONSTRAINT chk_audit_event_category CHECK (event_category IN ('AUTHENTICATION', 'AUTHORIZATION', 'DATA_ACCESS', 'SYSTEM', 'FILE_OPERATION')),
    CONSTRAINT chk_audit_severity CHECK (severity IN ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL')),
    CONSTRAINT chk_audit_action CHECK (action_performed IN ('CREATE', 'READ', 'UPDATE', 'DELETE', 'DOWNLOAD', 'UPLOAD', 'LOGIN', 'LOGOUT', 'ACCESS_DENIED')),
    CONSTRAINT chk_audit_risk_score CHECK (risk_score IS NULL OR (risk_score >= 0 AND risk_score <= 100))
);

-- ==============================================================================
-- 13. INDEXES FOR PERFORMANCE
-- ==============================================================================

-- Event Publication indexes
CREATE INDEX IF NOT EXISTS idx_event_publication_completion_date ON event_publication (completion_date);
CREATE INDEX IF NOT EXISTS idx_event_publication_publication_date ON event_publication (publication_date);

-- Users indexes
CREATE INDEX IF NOT EXISTS idx_users_tenant_id ON users (tenant_id);
CREATE INDEX IF NOT EXISTS idx_users_email ON users (email);
CREATE INDEX IF NOT EXISTS idx_users_active ON users (active);

-- Licensors indexes
CREATE INDEX IF NOT EXISTS idx_licensors_tenant_id ON licensors (tenant_id);
CREATE INDEX IF NOT EXISTS idx_licensors_status ON licensors (status);
CREATE INDEX IF NOT EXISTS idx_licensors_name ON licensors (name);
CREATE INDEX IF NOT EXISTS idx_licensors_tenant_status ON licensors (tenant_id, status);
CREATE INDEX IF NOT EXISTS idx_licensors_business_type ON licensors (business_type);
CREATE INDEX IF NOT EXISTS idx_licensors_deleted_at ON licensors (deleted_at) WHERE deleted_at IS NULL;

-- Licensees indexes
CREATE INDEX IF NOT EXISTS idx_licensees_tenant_id ON licensees (tenant_id);
CREATE INDEX IF NOT EXISTS idx_licensees_status ON licensees (status);
CREATE INDEX IF NOT EXISTS idx_licensees_name ON licensees (name);
CREATE INDEX IF NOT EXISTS idx_licensees_tenant_status ON licensees (tenant_id, status);
CREATE INDEX IF NOT EXISTS idx_licensees_business_type ON licensees (business_type);
CREATE INDEX IF NOT EXISTS idx_licensees_credit_rating ON licensees (credit_rating);
CREATE INDEX IF NOT EXISTS idx_licensees_deleted_at ON licensees (deleted_at) WHERE deleted_at IS NULL;

-- Brands indexes
CREATE INDEX IF NOT EXISTS idx_brands_tenant_id ON brands (tenant_id);
CREATE INDEX IF NOT EXISTS idx_brands_licensor_id ON brands (licensor_id);
CREATE INDEX IF NOT EXISTS idx_brands_status ON brands (status);
CREATE INDEX IF NOT EXISTS idx_brands_name ON brands (name);
CREATE INDEX IF NOT EXISTS idx_brands_brand_type ON brands (brand_type);
CREATE INDEX IF NOT EXISTS idx_brands_tenant_status ON brands (tenant_id, status);
CREATE INDEX IF NOT EXISTS idx_brands_expiration_date ON brands (expiration_date);
CREATE INDEX IF NOT EXISTS idx_brands_deleted_at ON brands (deleted_at) WHERE deleted_at IS NULL;

-- Upload Sessions indexes
CREATE INDEX IF NOT EXISTS idx_upload_sessions_tenant_id ON upload_sessions (tenant_id);
CREATE INDEX IF NOT EXISTS idx_upload_sessions_status ON upload_sessions (status);
CREATE INDEX IF NOT EXISTS idx_upload_sessions_created_at ON upload_sessions (created_at);
CREATE INDEX IF NOT EXISTS idx_upload_sessions_tenant_status ON upload_sessions (tenant_id, status);

-- Business Contracts indexes
CREATE INDEX IF NOT EXISTS idx_business_contracts_tenant_id ON business_contracts (tenant_id);
CREATE INDEX IF NOT EXISTS idx_business_contracts_licensor_id ON business_contracts (licensor_id);
CREATE INDEX IF NOT EXISTS idx_business_contracts_licensee_id ON business_contracts (licensee_id);
CREATE INDEX IF NOT EXISTS idx_business_contracts_brand_id ON business_contracts (brand_id);
CREATE INDEX IF NOT EXISTS idx_business_contracts_status ON business_contracts (status);
CREATE INDEX IF NOT EXISTS idx_business_contracts_contract_type ON business_contracts (contract_type);
CREATE INDEX IF NOT EXISTS idx_business_contracts_effective_date ON business_contracts (effective_date);
CREATE INDEX IF NOT EXISTS idx_business_contracts_expiration_date ON business_contracts (expiration_date);
CREATE INDEX IF NOT EXISTS idx_business_contracts_tenant_status ON business_contracts (tenant_id, status);
CREATE INDEX IF NOT EXISTS idx_business_contracts_tenant_expiration ON business_contracts (tenant_id, expiration_date);
CREATE INDEX IF NOT EXISTS idx_business_contracts_assigned_agent ON business_contracts (assigned_agent_id);
CREATE INDEX IF NOT EXISTS idx_business_contracts_parent_contract ON business_contracts (parent_contract_id);
CREATE INDEX IF NOT EXISTS idx_business_contracts_auto_renewal ON business_contracts (auto_renewal, expiration_date) WHERE auto_renewal = TRUE;
CREATE INDEX IF NOT EXISTS idx_business_contracts_deleted_at ON business_contracts (deleted_at) WHERE deleted_at IS NULL;

-- Contract Files indexes
CREATE INDEX IF NOT EXISTS idx_contract_files_tenant_id ON contract_files (tenant_id);
CREATE INDEX IF NOT EXISTS idx_contract_files_business_contract_id ON contract_files (business_contract_id);
CREATE INDEX IF NOT EXISTS idx_contract_files_status ON contract_files (status);
CREATE INDEX IF NOT EXISTS idx_contract_files_file_type ON contract_files (file_type);
CREATE INDEX IF NOT EXISTS idx_contract_files_upload_session_id ON contract_files (upload_session_id);
CREATE INDEX IF NOT EXISTS idx_contract_files_s3_bucket_key ON contract_files (s3_bucket, s3_key);
CREATE INDEX IF NOT EXISTS idx_contract_files_checksum ON contract_files (checksum);
CREATE INDEX IF NOT EXISTS idx_contract_files_deleted_at ON contract_files (deleted_at) WHERE deleted_at IS NULL;

-- Contract Versions indexes
CREATE INDEX IF NOT EXISTS idx_contract_versions_contract_file_id ON contract_versions (contract_file_id);
CREATE INDEX IF NOT EXISTS idx_contract_versions_created_at ON contract_versions (created_at);
CREATE INDEX IF NOT EXISTS idx_contract_versions_contract_version ON contract_versions (contract_file_id, version_number DESC);

-- Contract Access Log indexes
CREATE INDEX IF NOT EXISTS idx_contract_access_contract_file_id ON contract_access_log (contract_file_id);
CREATE INDEX IF NOT EXISTS idx_contract_access_user_id ON contract_access_log (user_id);
CREATE INDEX IF NOT EXISTS idx_contract_access_timestamp ON contract_access_log (access_timestamp);
CREATE INDEX IF NOT EXISTS idx_contract_access_type ON contract_access_log (access_type);
CREATE INDEX IF NOT EXISTS idx_contract_access_contract_timestamp ON contract_access_log (contract_file_id, access_timestamp DESC);

-- Security Audit Log indexes
CREATE INDEX IF NOT EXISTS idx_security_audit_log_tenant_timestamp ON security_audit_log (tenant_id, event_timestamp DESC);
CREATE INDEX IF NOT EXISTS idx_security_audit_log_user_timestamp ON security_audit_log (user_id, event_timestamp DESC);
CREATE INDEX IF NOT EXISTS idx_security_audit_log_event_type ON security_audit_log (event_type, event_timestamp DESC);
CREATE INDEX IF NOT EXISTS idx_security_audit_log_resource ON security_audit_log (resource_type, resource_id);
CREATE INDEX IF NOT EXISTS idx_security_audit_log_severity ON security_audit_log (severity, event_timestamp DESC);

-- ==============================================================================
-- 14. TRIGGERS FOR UPDATED_AT AUTOMATION
-- ==============================================================================

CREATE TRIGGER update_tenants_updated_at BEFORE UPDATE ON tenants 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_licensors_updated_at BEFORE UPDATE ON licensors 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_licensees_updated_at BEFORE UPDATE ON licensees 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_brands_updated_at BEFORE UPDATE ON brands 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_upload_sessions_updated_at BEFORE UPDATE ON upload_sessions 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_business_contracts_updated_at BEFORE UPDATE ON business_contracts 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_contract_files_updated_at BEFORE UPDATE ON contract_files 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ==============================================================================
-- 15. TENANT SCHEMA INITIALIZATION
-- ==============================================================================

-- Insert default tenant
INSERT INTO tenants (tenant_id, tenant_name, schema_name) 
VALUES ('default', 'Default Tenant', 'tenant_default')
ON CONFLICT (tenant_id) DO NOTHING;

-- Create schema for default tenant
CREATE SCHEMA IF NOT EXISTS tenant_default;

-- Grant permissions on default tenant schema
GRANT ALL ON SCHEMA tenant_default TO postgres;

-- Create tables in default tenant schema for immediate use
-- Note: In production, these would be created dynamically for each new tenant

-- Licensors for default tenant
CREATE TABLE IF NOT EXISTS tenant_default.licensors ( LIKE licensors INCLUDING ALL );

-- Licensees for default tenant
CREATE TABLE IF NOT EXISTS tenant_default.licensees ( LIKE licensees INCLUDING ALL );

-- Brands for default tenant
CREATE TABLE IF NOT EXISTS tenant_default.brands ( LIKE brands INCLUDING ALL );

-- Upload Sessions for default tenant
CREATE TABLE IF NOT EXISTS tenant_default.upload_sessions ( LIKE upload_sessions INCLUDING ALL );

-- Business Contracts for default tenant
CREATE TABLE IF NOT EXISTS tenant_default.business_contracts ( LIKE business_contracts INCLUDING ALL );

-- Contract Files for default tenant
CREATE TABLE IF NOT EXISTS tenant_default.contract_files ( LIKE contract_files INCLUDING ALL );

-- Contract Versions for default tenant
CREATE TABLE IF NOT EXISTS tenant_default.contract_versions ( LIKE contract_versions INCLUDING ALL );

-- Contract Access Log for default tenant
CREATE TABLE IF NOT EXISTS tenant_default.contract_access_log ( LIKE contract_access_log INCLUDING ALL );

-- Add foreign key constraints for tenant schema tables
DO $$
BEGIN
    -- Licensors constraints
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.table_constraints 
        WHERE constraint_name = 'fk_licensors_tenant' AND table_schema = 'tenant_default'
    ) THEN
        ALTER TABLE tenant_default.licensors 
            ADD CONSTRAINT fk_licensors_tenant 
            FOREIGN KEY (tenant_id) REFERENCES public.tenants(tenant_id);
        ALTER TABLE tenant_default.licensors 
            ADD CONSTRAINT fk_licensors_created_by 
            FOREIGN KEY (created_by_user_id) REFERENCES public.users(id);
        ALTER TABLE tenant_default.licensors 
            ADD CONSTRAINT fk_licensors_updated_by 
            FOREIGN KEY (updated_by_user_id) REFERENCES public.users(id);
    END IF;

    -- Licensees constraints
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.table_constraints 
        WHERE constraint_name = 'fk_licensees_tenant' AND table_schema = 'tenant_default'
    ) THEN
        ALTER TABLE tenant_default.licensees 
            ADD CONSTRAINT fk_licensees_tenant 
            FOREIGN KEY (tenant_id) REFERENCES public.tenants(tenant_id);
        ALTER TABLE tenant_default.licensees 
            ADD CONSTRAINT fk_licensees_created_by 
            FOREIGN KEY (created_by_user_id) REFERENCES public.users(id);
        ALTER TABLE tenant_default.licensees 
            ADD CONSTRAINT fk_licensees_updated_by 
            FOREIGN KEY (updated_by_user_id) REFERENCES public.users(id);
    END IF;

    -- Brands constraints
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.table_constraints 
        WHERE constraint_name = 'fk_brands_tenant' AND table_schema = 'tenant_default'
    ) THEN
        ALTER TABLE tenant_default.brands 
            ADD CONSTRAINT fk_brands_tenant 
            FOREIGN KEY (tenant_id) REFERENCES public.tenants(tenant_id);
        ALTER TABLE tenant_default.brands 
            ADD CONSTRAINT fk_brands_licensor 
            FOREIGN KEY (licensor_id) REFERENCES tenant_default.licensors(id);
        ALTER TABLE tenant_default.brands 
            ADD CONSTRAINT fk_brands_created_by 
            FOREIGN KEY (created_by_user_id) REFERENCES public.users(id);
        ALTER TABLE tenant_default.brands 
            ADD CONSTRAINT fk_brands_updated_by 
            FOREIGN KEY (updated_by_user_id) REFERENCES public.users(id);
    END IF;

    -- Upload Sessions constraints
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.table_constraints 
        WHERE constraint_name = 'fk_upload_sessions_tenant' AND table_schema = 'tenant_default'
    ) THEN
        ALTER TABLE tenant_default.upload_sessions 
            ADD CONSTRAINT fk_upload_sessions_tenant 
            FOREIGN KEY (tenant_id) REFERENCES public.tenants(tenant_id);
        ALTER TABLE tenant_default.upload_sessions 
            ADD CONSTRAINT fk_upload_sessions_initiated_by 
            FOREIGN KEY (initiated_by_user_id) REFERENCES public.users(id);
    END IF;

    -- Business Contracts constraints
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.table_constraints 
        WHERE constraint_name = 'fk_business_contracts_tenant' AND table_schema = 'tenant_default'
    ) THEN
        ALTER TABLE tenant_default.business_contracts 
            ADD CONSTRAINT fk_business_contracts_tenant 
            FOREIGN KEY (tenant_id) REFERENCES public.tenants(tenant_id);
        ALTER TABLE tenant_default.business_contracts 
            ADD CONSTRAINT fk_business_contracts_licensor 
            FOREIGN KEY (licensor_id) REFERENCES tenant_default.licensors(id);
        ALTER TABLE tenant_default.business_contracts 
            ADD CONSTRAINT fk_business_contracts_licensee 
            FOREIGN KEY (licensee_id) REFERENCES tenant_default.licensees(id);
        ALTER TABLE tenant_default.business_contracts 
            ADD CONSTRAINT fk_business_contracts_brand 
            FOREIGN KEY (brand_id) REFERENCES tenant_default.brands(id);
        ALTER TABLE tenant_default.business_contracts 
            ADD CONSTRAINT fk_business_contracts_parent 
            FOREIGN KEY (parent_contract_id) REFERENCES tenant_default.business_contracts(id);
        ALTER TABLE tenant_default.business_contracts 
            ADD CONSTRAINT fk_business_contracts_assigned_agent 
            FOREIGN KEY (assigned_agent_id) REFERENCES public.users(id);
        ALTER TABLE tenant_default.business_contracts 
            ADD CONSTRAINT fk_business_contracts_created_by 
            FOREIGN KEY (created_by_user_id) REFERENCES public.users(id);
        ALTER TABLE tenant_default.business_contracts 
            ADD CONSTRAINT fk_business_contracts_updated_by 
            FOREIGN KEY (updated_by_user_id) REFERENCES public.users(id);
    END IF;

    -- Contract Files constraints
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.table_constraints 
        WHERE constraint_name = 'fk_contract_files_tenant' AND table_schema = 'tenant_default'
    ) THEN
        ALTER TABLE tenant_default.contract_files 
            ADD CONSTRAINT fk_contract_files_tenant 
            FOREIGN KEY (tenant_id) REFERENCES public.tenants(tenant_id);
        ALTER TABLE tenant_default.contract_files 
            ADD CONSTRAINT fk_contract_files_business_contract 
            FOREIGN KEY (business_contract_id) REFERENCES tenant_default.business_contracts(id) ON DELETE CASCADE;
        ALTER TABLE tenant_default.contract_files 
            ADD CONSTRAINT fk_contract_files_upload_session 
            FOREIGN KEY (upload_session_id) REFERENCES tenant_default.upload_sessions(id);
        ALTER TABLE tenant_default.contract_files 
            ADD CONSTRAINT fk_contract_files_created_by 
            FOREIGN KEY (created_by_user_id) REFERENCES public.users(id);
        ALTER TABLE tenant_default.contract_files 
            ADD CONSTRAINT fk_contract_files_updated_by 
            FOREIGN KEY (updated_by_user_id) REFERENCES public.users(id);
    END IF;

    -- Contract Versions constraints
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.table_constraints 
        WHERE constraint_name = 'fk_contract_versions_contract_file' AND table_schema = 'tenant_default'
    ) THEN
        ALTER TABLE tenant_default.contract_versions 
            ADD CONSTRAINT fk_contract_versions_contract_file 
            FOREIGN KEY (contract_file_id) REFERENCES tenant_default.contract_files(id) ON DELETE CASCADE;
        ALTER TABLE tenant_default.contract_versions 
            ADD CONSTRAINT fk_contract_versions_created_by 
            FOREIGN KEY (created_by_user_id) REFERENCES public.users(id);
    END IF;

    -- Contract Access Log constraints
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.table_constraints 
        WHERE constraint_name = 'fk_contract_access_contract_file' AND table_schema = 'tenant_default'
    ) THEN
        ALTER TABLE tenant_default.contract_access_log 
            ADD CONSTRAINT fk_contract_access_contract_file 
            FOREIGN KEY (contract_file_id) REFERENCES tenant_default.contract_files(id) ON DELETE CASCADE;
        ALTER TABLE tenant_default.contract_access_log 
            ADD CONSTRAINT fk_contract_access_user 
            FOREIGN KEY (user_id) REFERENCES public.users(id);
    END IF;
END $$;

-- Grant permissions on default tenant schema tables
GRANT ALL ON tenant_default.licensors TO postgres;
GRANT ALL ON tenant_default.licensees TO postgres;
GRANT ALL ON tenant_default.brands TO postgres;
GRANT ALL ON tenant_default.upload_sessions TO postgres;
GRANT ALL ON tenant_default.business_contracts TO postgres;
GRANT ALL ON tenant_default.contract_files TO postgres;
GRANT ALL ON tenant_default.contract_versions TO postgres;
GRANT ALL ON tenant_default.contract_access_log TO postgres;

-- ==============================================================================
-- 16. SAMPLE DATA FOR DEVELOPMENT
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
    'Initial Setup - Clean Schema',
    'COMPLETED',
    0,
    0,
    0,
    '{"description": "Clean schema deployment - ready for data"}'::jsonb
) ON CONFLICT DO NOTHING;

-- ==============================================================================
-- 17. SCHEMA VALIDATION
-- ==============================================================================

-- Verify table creation and structure
DO $$
DECLARE
    table_count INTEGER;
    constraint_count INTEGER;
BEGIN
    -- Count main tables
    SELECT COUNT(*) INTO table_count
    FROM information_schema.tables 
    WHERE table_schema = 'public' 
    AND table_name IN (
        'tenants', 'users', 'event_publication', 'licensors', 'licensees', 
        'brands', 'upload_sessions', 'business_contracts', 'contract_files', 
        'contract_versions', 'contract_access_log', 'security_audit_log'
    );
    
    -- Count foreign key constraints
    SELECT COUNT(*) INTO constraint_count
    FROM information_schema.table_constraints 
    WHERE constraint_type = 'FOREIGN KEY'
    AND table_schema IN ('public', 'tenant_default');
    
    RAISE NOTICE '========================================';
    RAISE NOTICE 'Clean Licensing Platform Schema V1 Deployment';
    RAISE NOTICE '========================================';
    RAISE NOTICE 'Main tables created: %', table_count;
    RAISE NOTICE 'Foreign key constraints: %', constraint_count;
    RAISE NOTICE 'Schema features:';
    RAISE NOTICE '- Multi-tenant isolation with schema-per-tenant';
    RAISE NOTICE '- Consistent UUID types throughout all ID fields';
    RAISE NOTICE '- Comprehensive audit trails and security logging';
    RAISE NOTICE '- File management with S3 integration';
    RAISE NOTICE '- Contract lifecycle management';
    RAISE NOTICE '- Licensing relationship management';
    RAISE NOTICE '- Spring Modulith event publication support';
    RAISE NOTICE '========================================';
    
    IF table_count >= 12 THEN
        RAISE NOTICE 'Schema deployment SUCCESSFUL - All core tables created';
    ELSE
        RAISE WARNING 'Schema deployment INCOMPLETE - Expected 12+ tables, found %', table_count;
    END IF;
    
    RAISE NOTICE '========================================';
END $$;