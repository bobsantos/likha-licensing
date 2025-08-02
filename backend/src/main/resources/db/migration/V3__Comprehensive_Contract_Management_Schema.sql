-- Comprehensive Contract Management Database Schema
-- Implements full Contract Management bounded context with all domain aggregates
-- Includes Contract, Licensee, Licensor, Brand aggregates with proper relationships
-- Multi-tenant isolation using schema-per-tenant approach
-- Version: 3.0
-- Date: 2025-08-02

-- ==============================================================================
-- LICENSORS TABLE
-- ==============================================================================
-- Represents the party granting licenses (rights holders)
-- Core aggregate in Contract Management bounded context
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
-- LICENSEES TABLE
-- ==============================================================================
-- Represents the party receiving licenses (license buyers/users)
-- Core aggregate in Contract Management bounded context
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
-- BRANDS TABLE
-- ==============================================================================
-- Represents intellectual property brands/properties being licensed
-- Core aggregate in Contract Management bounded context
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
-- CONTRACTS TABLE (ENHANCED)
-- ==============================================================================
-- Represents the business contract entity (not just files)
-- Root aggregate in Contract Management bounded context
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
-- CONTRACT_FILES TABLE (ENHANCED)
-- ==============================================================================
-- Links business contracts to their associated files
-- Replaces the previous "contracts" table which was actually file-focused
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
-- CONTRACT_AMENDMENTS TABLE
-- ==============================================================================
-- Tracks amendments and modifications to existing contracts
CREATE TABLE IF NOT EXISTS contract_amendments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id VARCHAR(50) NOT NULL,
    parent_contract_id UUID NOT NULL,
    amendment_contract_id UUID NOT NULL,
    
    -- Amendment Details
    amendment_number VARCHAR(50) NOT NULL,
    amendment_type VARCHAR(50) NOT NULL, -- 'EXTENSION', 'MODIFICATION', 'TERMINATION', 'RENEWAL'
    summary TEXT NOT NULL,
    
    -- Changed Terms
    previous_terms JSONB, -- Snapshot of terms before amendment
    new_terms JSONB, -- New terms after amendment
    effective_date DATE NOT NULL,
    
    -- Audit Fields
    created_by_user_id UUID,
    created_at TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraints
    CONSTRAINT fk_contract_amendments_tenant FOREIGN KEY (tenant_id) REFERENCES tenants(tenant_id),
    CONSTRAINT fk_contract_amendments_parent FOREIGN KEY (parent_contract_id) REFERENCES business_contracts(id),
    CONSTRAINT fk_contract_amendments_amendment FOREIGN KEY (amendment_contract_id) REFERENCES business_contracts(id),
    CONSTRAINT fk_contract_amendments_created_by FOREIGN KEY (created_by_user_id) REFERENCES users(id),
    CONSTRAINT chk_amendment_type CHECK (amendment_type IN ('EXTENSION', 'MODIFICATION', 'TERMINATION', 'RENEWAL')),
    CONSTRAINT unique_amendment_number_per_contract UNIQUE (parent_contract_id, amendment_number)
);

-- ==============================================================================
-- CONTRACT_RENEWAL_HISTORY TABLE
-- ==============================================================================
-- Tracks the renewal chain of contracts
CREATE TABLE IF NOT EXISTS contract_renewal_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id VARCHAR(50) NOT NULL,
    original_contract_id UUID NOT NULL,
    renewed_contract_id UUID NOT NULL,
    
    -- Renewal Details
    renewal_date DATE NOT NULL,
    renewal_type VARCHAR(50) NOT NULL, -- 'AUTOMATIC', 'MANUAL', 'RENEGOTIATED'
    renewal_terms_changed BOOLEAN DEFAULT FALSE,
    notes TEXT,
    
    -- Audit Fields
    created_by_user_id UUID,
    created_at TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraints
    CONSTRAINT fk_contract_renewal_tenant FOREIGN KEY (tenant_id) REFERENCES tenants(tenant_id),
    CONSTRAINT fk_contract_renewal_original FOREIGN KEY (original_contract_id) REFERENCES business_contracts(id),
    CONSTRAINT fk_contract_renewal_renewed FOREIGN KEY (renewed_contract_id) REFERENCES business_contracts(id),
    CONSTRAINT fk_contract_renewal_created_by FOREIGN KEY (created_by_user_id) REFERENCES users(id),
    CONSTRAINT chk_renewal_type CHECK (renewal_type IN ('AUTOMATIC', 'MANUAL', 'RENEGOTIATED'))
);

-- ==============================================================================
-- PERFORMANCE INDEXES
-- ==============================================================================

-- Licensors Indexes
CREATE INDEX IF NOT EXISTS idx_licensors_tenant_id ON licensors (tenant_id);
CREATE INDEX IF NOT EXISTS idx_licensors_status ON licensors (status);
CREATE INDEX IF NOT EXISTS idx_licensors_name ON licensors (name);
CREATE INDEX IF NOT EXISTS idx_licensors_tenant_status ON licensors (tenant_id, status);
CREATE INDEX IF NOT EXISTS idx_licensors_business_type ON licensors (business_type);
CREATE INDEX IF NOT EXISTS idx_licensors_deleted_at ON licensors (deleted_at) WHERE deleted_at IS NULL;

-- Licensees Indexes
CREATE INDEX IF NOT EXISTS idx_licensees_tenant_id ON licensees (tenant_id);
CREATE INDEX IF NOT EXISTS idx_licensees_status ON licensees (status);
CREATE INDEX IF NOT EXISTS idx_licensees_name ON licensees (name);
CREATE INDEX IF NOT EXISTS idx_licensees_tenant_status ON licensees (tenant_id, status);
CREATE INDEX IF NOT EXISTS idx_licensees_business_type ON licensees (business_type);
CREATE INDEX IF NOT EXISTS idx_licensees_credit_rating ON licensees (credit_rating);
CREATE INDEX IF NOT EXISTS idx_licensees_deleted_at ON licensees (deleted_at) WHERE deleted_at IS NULL;

-- Brands Indexes
CREATE INDEX IF NOT EXISTS idx_brands_tenant_id ON brands (tenant_id);
CREATE INDEX IF NOT EXISTS idx_brands_licensor_id ON brands (licensor_id);
CREATE INDEX IF NOT EXISTS idx_brands_status ON brands (status);
CREATE INDEX IF NOT EXISTS idx_brands_name ON brands (name);
CREATE INDEX IF NOT EXISTS idx_brands_brand_type ON brands (brand_type);
CREATE INDEX IF NOT EXISTS idx_brands_tenant_status ON brands (tenant_id, status);
CREATE INDEX IF NOT EXISTS idx_brands_expiration_date ON brands (expiration_date);
CREATE INDEX IF NOT EXISTS idx_brands_deleted_at ON brands (deleted_at) WHERE deleted_at IS NULL;

-- Business Contracts Indexes
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

-- Contract Files Indexes
CREATE INDEX IF NOT EXISTS idx_contract_files_tenant_id ON contract_files (tenant_id);
CREATE INDEX IF NOT EXISTS idx_contract_files_business_contract_id ON contract_files (business_contract_id);
CREATE INDEX IF NOT EXISTS idx_contract_files_status ON contract_files (status);
CREATE INDEX IF NOT EXISTS idx_contract_files_file_type ON contract_files (file_type);
CREATE INDEX IF NOT EXISTS idx_contract_files_upload_session_id ON contract_files (upload_session_id);
CREATE INDEX IF NOT EXISTS idx_contract_files_s3_bucket_key ON contract_files (s3_bucket, s3_key);
CREATE INDEX IF NOT EXISTS idx_contract_files_checksum ON contract_files (checksum);
CREATE INDEX IF NOT EXISTS idx_contract_files_deleted_at ON contract_files (deleted_at) WHERE deleted_at IS NULL;

-- Contract Amendments Indexes
CREATE INDEX IF NOT EXISTS idx_contract_amendments_tenant_id ON contract_amendments (tenant_id);
CREATE INDEX IF NOT EXISTS idx_contract_amendments_parent_contract ON contract_amendments (parent_contract_id);
CREATE INDEX IF NOT EXISTS idx_contract_amendments_amendment_contract ON contract_amendments (amendment_contract_id);
CREATE INDEX IF NOT EXISTS idx_contract_amendments_effective_date ON contract_amendments (effective_date);
CREATE INDEX IF NOT EXISTS idx_contract_amendments_amendment_type ON contract_amendments (amendment_type);

-- Contract Renewal History Indexes
CREATE INDEX IF NOT EXISTS idx_contract_renewal_tenant_id ON contract_renewal_history (tenant_id);
CREATE INDEX IF NOT EXISTS idx_contract_renewal_original_contract ON contract_renewal_history (original_contract_id);
CREATE INDEX IF NOT EXISTS idx_contract_renewal_renewed_contract ON contract_renewal_history (renewed_contract_id);
CREATE INDEX IF NOT EXISTS idx_contract_renewal_date ON contract_renewal_history (renewal_date);
CREATE INDEX IF NOT EXISTS idx_contract_renewal_type ON contract_renewal_history (renewal_type);

-- ==============================================================================
-- TRIGGERS FOR UPDATED_AT AUTOMATION
-- ==============================================================================

-- Apply triggers to new tables
CREATE TRIGGER update_licensors_updated_at BEFORE UPDATE ON licensors 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_licensees_updated_at BEFORE UPDATE ON licensees 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_brands_updated_at BEFORE UPDATE ON brands 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_business_contracts_updated_at BEFORE UPDATE ON business_contracts 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_contract_files_updated_at BEFORE UPDATE ON contract_files 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ==============================================================================
-- TENANT SCHEMA INITIALIZATION
-- ==============================================================================

-- Create tables in default tenant schema for immediate use
-- Note: In production, these would be created dynamically for each new tenant

-- Licensors for default tenant
CREATE TABLE IF NOT EXISTS tenant_default.licensors (
    LIKE licensors INCLUDING ALL
);

-- Licensees for default tenant
CREATE TABLE IF NOT EXISTS tenant_default.licensees (
    LIKE licensees INCLUDING ALL
);

-- Brands for default tenant
CREATE TABLE IF NOT EXISTS tenant_default.brands (
    LIKE brands INCLUDING ALL
);

-- Business Contracts for default tenant
CREATE TABLE IF NOT EXISTS tenant_default.business_contracts (
    LIKE business_contracts INCLUDING ALL
);

-- Contract Files for default tenant
CREATE TABLE IF NOT EXISTS tenant_default.contract_files (
    LIKE contract_files INCLUDING ALL
);

-- Contract Amendments for default tenant
CREATE TABLE IF NOT EXISTS tenant_default.contract_amendments (
    LIKE contract_amendments INCLUDING ALL
);

-- Contract Renewal History for default tenant
CREATE TABLE IF NOT EXISTS tenant_default.contract_renewal_history (
    LIKE contract_renewal_history INCLUDING ALL
);

-- Add foreign key constraints for tenant schema tables
ALTER TABLE IF EXISTS tenant_default.licensors 
    ADD CONSTRAINT IF NOT EXISTS fk_licensors_tenant 
    FOREIGN KEY (tenant_id) REFERENCES public.tenants(tenant_id);

ALTER TABLE IF EXISTS tenant_default.licensees 
    ADD CONSTRAINT IF NOT EXISTS fk_licensees_tenant 
    FOREIGN KEY (tenant_id) REFERENCES public.tenants(tenant_id);

ALTER TABLE IF EXISTS tenant_default.brands 
    ADD CONSTRAINT IF NOT EXISTS fk_brands_tenant 
    FOREIGN KEY (tenant_id) REFERENCES public.tenants(tenant_id);

ALTER TABLE IF EXISTS tenant_default.brands 
    ADD CONSTRAINT IF NOT EXISTS fk_brands_licensor 
    FOREIGN KEY (licensor_id) REFERENCES tenant_default.licensors(id);

ALTER TABLE IF EXISTS tenant_default.business_contracts 
    ADD CONSTRAINT IF NOT EXISTS fk_business_contracts_tenant 
    FOREIGN KEY (tenant_id) REFERENCES public.tenants(tenant_id);

ALTER TABLE IF EXISTS tenant_default.business_contracts 
    ADD CONSTRAINT IF NOT EXISTS fk_business_contracts_licensor 
    FOREIGN KEY (licensor_id) REFERENCES tenant_default.licensors(id);

ALTER TABLE IF EXISTS tenant_default.business_contracts 
    ADD CONSTRAINT IF NOT EXISTS fk_business_contracts_licensee 
    FOREIGN KEY (licensee_id) REFERENCES tenant_default.licensees(id);

ALTER TABLE IF EXISTS tenant_default.business_contracts 
    ADD CONSTRAINT IF NOT EXISTS fk_business_contracts_brand 
    FOREIGN KEY (brand_id) REFERENCES tenant_default.brands(id);

ALTER TABLE IF EXISTS tenant_default.business_contracts 
    ADD CONSTRAINT IF NOT EXISTS fk_business_contracts_parent 
    FOREIGN KEY (parent_contract_id) REFERENCES tenant_default.business_contracts(id);

ALTER TABLE IF EXISTS tenant_default.contract_files 
    ADD CONSTRAINT IF NOT EXISTS fk_contract_files_tenant 
    FOREIGN KEY (tenant_id) REFERENCES public.tenants(tenant_id);

ALTER TABLE IF EXISTS tenant_default.contract_files 
    ADD CONSTRAINT IF NOT EXISTS fk_contract_files_business_contract 
    FOREIGN KEY (business_contract_id) REFERENCES tenant_default.business_contracts(id) ON DELETE CASCADE;

ALTER TABLE IF EXISTS tenant_default.contract_files 
    ADD CONSTRAINT IF NOT EXISTS fk_contract_files_upload_session 
    FOREIGN KEY (upload_session_id) REFERENCES tenant_default.upload_sessions(id);

ALTER TABLE IF EXISTS tenant_default.contract_amendments 
    ADD CONSTRAINT IF NOT EXISTS fk_contract_amendments_tenant 
    FOREIGN KEY (tenant_id) REFERENCES public.tenants(tenant_id);

ALTER TABLE IF EXISTS tenant_default.contract_amendments 
    ADD CONSTRAINT IF NOT EXISTS fk_contract_amendments_parent 
    FOREIGN KEY (parent_contract_id) REFERENCES tenant_default.business_contracts(id);

ALTER TABLE IF EXISTS tenant_default.contract_amendments 
    ADD CONSTRAINT IF NOT EXISTS fk_contract_amendments_amendment 
    FOREIGN KEY (amendment_contract_id) REFERENCES tenant_default.business_contracts(id);

ALTER TABLE IF EXISTS tenant_default.contract_renewal_history 
    ADD CONSTRAINT IF NOT EXISTS fk_contract_renewal_tenant 
    FOREIGN KEY (tenant_id) REFERENCES public.tenants(tenant_id);

ALTER TABLE IF EXISTS tenant_default.contract_renewal_history 
    ADD CONSTRAINT IF NOT EXISTS fk_contract_renewal_original 
    FOREIGN KEY (original_contract_id) REFERENCES tenant_default.business_contracts(id);

ALTER TABLE IF EXISTS tenant_default.contract_renewal_history 
    ADD CONSTRAINT IF NOT EXISTS fk_contract_renewal_renewed 
    FOREIGN KEY (renewed_contract_id) REFERENCES tenant_default.business_contracts(id);

-- ==============================================================================
-- GRANT PERMISSIONS
-- ==============================================================================

-- Grant permissions on default tenant schema tables
GRANT ALL ON tenant_default.licensors TO postgres;
GRANT ALL ON tenant_default.licensees TO postgres;
GRANT ALL ON tenant_default.brands TO postgres;
GRANT ALL ON tenant_default.business_contracts TO postgres;
GRANT ALL ON tenant_default.contract_files TO postgres;
GRANT ALL ON tenant_default.contract_amendments TO postgres;
GRANT ALL ON tenant_default.contract_renewal_history TO postgres;

-- ==============================================================================
-- SAMPLE DATA FOR DEVELOPMENT
-- ==============================================================================

-- Insert sample licensor
INSERT INTO tenant_default.licensors (
    tenant_id, 
    name,
    legal_name,
    business_type,
    status,
    primary_contact_email,
    country
) VALUES (
    'default',
    'Marvel Entertainment LLC',
    'Marvel Entertainment, LLC',
    'LLC',
    'ACTIVE',
    'licensing@marvel.com',
    'United States'
) ON CONFLICT DO NOTHING;

-- Insert sample licensee
INSERT INTO tenant_default.licensees (
    tenant_id, 
    name,
    legal_name,
    business_type,
    status,
    primary_contact_email,
    country,
    credit_rating
) VALUES (
    'default',
    'Acme Toy Company',
    'Acme Toy Company, Inc.',
    'CORPORATION',
    'ACTIVE',
    'licensing@acmetoys.com',
    'United States',
    'GOOD'
) ON CONFLICT DO NOTHING;

-- Insert sample brand
INSERT INTO tenant_default.brands (
    tenant_id, 
    licensor_id,
    name,
    brand_type,
    status,
    description,
    licensing_territories
) VALUES (
    'default',
    (SELECT id FROM tenant_default.licensors WHERE name = 'Marvel Entertainment LLC' LIMIT 1),
    'Spider-Man',
    'CHARACTER',
    'ACTIVE',
    'The amazing Spider-Man character and related intellectual property',
    ARRAY['North America', 'Europe', 'Asia-Pacific']
) ON CONFLICT DO NOTHING;

-- Insert sample business contract
INSERT INTO tenant_default.business_contracts (
    tenant_id,
    licensor_id,
    licensee_id,
    brand_id,
    title,
    contract_type,
    status,
    effective_date,
    expiration_date,
    total_value,
    currency,
    royalty_rate,
    license_scope,
    licensed_territories
) VALUES (
    'default',
    (SELECT id FROM tenant_default.licensors WHERE name = 'Marvel Entertainment LLC' LIMIT 1),
    (SELECT id FROM tenant_default.licensees WHERE name = 'Acme Toy Company' LIMIT 1),
    (SELECT id FROM tenant_default.brands WHERE name = 'Spider-Man' LIMIT 1),
    'Spider-Man Action Figure License Agreement',
    'EXCLUSIVE',
    'ACTIVE',
    '2025-01-01',
    '2027-12-31',
    1000000.00,
    'USD',
    0.08,
    'Action figures, collectibles, and related toy products featuring Spider-Man character',
    ARRAY['North America']
) ON CONFLICT DO NOTHING;

-- ==============================================================================
-- SCHEMA VALIDATION
-- ==============================================================================

-- Verify table creation and structure
DO $$
BEGIN
    -- Check if all required tables exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'licensors' AND table_schema = 'public') THEN
        RAISE EXCEPTION 'licensors table was not created successfully';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'licensees' AND table_schema = 'public') THEN
        RAISE EXCEPTION 'licensees table was not created successfully';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'brands' AND table_schema = 'public') THEN
        RAISE EXCEPTION 'brands table was not created successfully';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'business_contracts' AND table_schema = 'public') THEN
        RAISE EXCEPTION 'business_contracts table was not created successfully';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'contract_files' AND table_schema = 'public') THEN
        RAISE EXCEPTION 'contract_files table was not created successfully';
    END IF;
    
    -- Check tenant schema tables
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'business_contracts' AND table_schema = 'tenant_default') THEN
        RAISE EXCEPTION 'tenant_default.business_contracts table was not created successfully';
    END IF;
    
    RAISE NOTICE 'Comprehensive Contract Management Schema V3 successfully created and validated';
    RAISE NOTICE 'Schema includes: Licensors, Licensees, Brands, Business Contracts, Contract Files, Amendments, and Renewal History';
    RAISE NOTICE 'All tables support multi-tenant isolation and include proper audit trails';
END $$;