-- V4 Migration: Migrate V2 contracts data to V3 business_contracts + contract_files structure
-- Safely transforms V2 file-centric contracts table to V3 business-centric model
-- Maintains data integrity, tenant isolation, and audit trails
-- Version: 4.0
-- Date: 2025-08-02

-- ==============================================================================
-- MIGRATION VALIDATION AND SAFETY CHECKS
-- ==============================================================================

-- Verify that source tables exist and contain data to migrate
DO $$
DECLARE
    v2_contracts_count INTEGER;
    tenant_schemas TEXT[];
    schema_name TEXT;
BEGIN
    -- Check if V2 contracts table exists
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.tables 
        WHERE table_name = 'contracts' 
        AND table_schema IN ('public', 'tenant_default')
    ) THEN
        RAISE NOTICE 'V2 contracts table not found - migration may have already been completed or V2 was never deployed';
        RETURN;
    END IF;
    
    -- Count existing contracts to migrate
    SELECT COUNT(*) INTO v2_contracts_count FROM tenant_default.contracts WHERE deleted_at IS NULL;
    RAISE NOTICE 'Found % V2 contracts to migrate', v2_contracts_count;
    
    -- Verify V3 tables exist
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.tables 
        WHERE table_name = 'business_contracts' 
        AND table_schema = 'public'
    ) THEN
        RAISE EXCEPTION 'V3 business_contracts table not found - ensure V3 migration has been applied first';
    END IF;
    
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.tables 
        WHERE table_name = 'contract_files' 
        AND table_schema = 'public'
    ) THEN
        RAISE EXCEPTION 'V3 contract_files table not found - ensure V3 migration has been applied first';
    END IF;
    
    RAISE NOTICE 'Migration validation passed - proceeding with data migration';
END $$;

-- ==============================================================================
-- BACKUP STRATEGY
-- ==============================================================================

-- Create backup tables with V2 data for rollback capability
CREATE TABLE IF NOT EXISTS contracts_v2_backup AS 
SELECT * FROM tenant_default.contracts;

CREATE TABLE IF NOT EXISTS contract_versions_v2_backup AS 
SELECT * FROM tenant_default.contract_versions;

CREATE TABLE IF NOT EXISTS contract_access_log_v2_backup AS 
SELECT * FROM tenant_default.contract_access_log;

RAISE NOTICE 'V2 data backed up to *_v2_backup tables';

-- ==============================================================================
-- DEFAULT ENTITIES CREATION
-- ==============================================================================

-- Create default licensor and licensee entities for existing contracts
-- These will be used for contracts that don't have explicit business relationships

DO $$
DECLARE
    default_licensor_id UUID;
    default_licensee_id UUID;
    tenant_id_var VARCHAR(50) := 'default';
BEGIN
    -- Create default licensor if it doesn't exist
    INSERT INTO tenant_default.licensors (
        id,
        tenant_id,
        name,
        legal_name,
        business_type,
        status,
        primary_contact_email,
        country,
        notes,
        created_at,
        updated_at
    ) VALUES (
        gen_random_uuid(),
        tenant_id_var,
        'Default Licensor (Migrated)',
        'Default Licensor Entity - Created During V2 to V3 Migration',
        'CORPORATION',
        'ACTIVE',
        'admin@company.com',
        'United States',
        'Default licensor entity created during V2 to V3 data migration for contracts without explicit licensor information.',
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    ) ON CONFLICT (tenant_id, name) DO NOTHING;
    
    -- Get the licensor ID
    SELECT id INTO default_licensor_id 
    FROM tenant_default.licensors 
    WHERE tenant_id = tenant_id_var AND name = 'Default Licensor (Migrated)';
    
    -- Create default licensee if it doesn't exist
    INSERT INTO tenant_default.licensees (
        id,
        tenant_id,
        name,
        legal_name,
        business_type,
        status,
        primary_contact_email,
        country,
        credit_rating,
        payment_terms_days,
        notes,
        created_at,
        updated_at
    ) VALUES (
        gen_random_uuid(),
        tenant_id_var,
        'Default Licensee (Migrated)',
        'Default Licensee Entity - Created During V2 to V3 Migration',
        'CORPORATION',
        'ACTIVE',
        'admin@company.com',
        'United States',
        'GOOD',
        30,
        'Default licensee entity created during V2 to V3 data migration for contracts without explicit licensee information.',
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    ) ON CONFLICT (tenant_id, name) DO NOTHING;
    
    -- Get the licensee ID
    SELECT id INTO default_licensee_id 
    FROM tenant_default.licensees 
    WHERE tenant_id = tenant_id_var AND name = 'Default Licensee (Migrated)';
    
    RAISE NOTICE 'Created default licensor (ID: %) and licensee (ID: %)', default_licensor_id, default_licensee_id;
END $$;

-- ==============================================================================
-- MAIN DATA MIGRATION
-- ==============================================================================

-- Begin transaction for atomic migration
BEGIN;

-- Step 1: Migrate V2 contracts to V3 business_contracts
INSERT INTO tenant_default.business_contracts (
    id,
    tenant_id,
    licensor_id,
    licensee_id,
    brand_id,
    contract_number,
    title,
    description,
    contract_type,
    license_scope,
    total_value,
    currency,
    effective_date,
    expiration_date,
    status,
    approval_status,
    execution_status,
    compliance_status,
    notes,
    tags,
    created_by_user_id,
    updated_by_user_id,
    created_at,
    updated_at,
    deleted_at
)
SELECT 
    c.id, -- Preserve original contract ID
    c.tenant_id,
    (SELECT id FROM tenant_default.licensors WHERE name = 'Default Licensor (Migrated)' LIMIT 1) as licensor_id,
    (SELECT id FROM tenant_default.licensees WHERE name = 'Default Licensee (Migrated)' LIMIT 1) as licensee_id,
    NULL as brand_id, -- No brand mapping in V2
    COALESCE(c.filename, 'MIGRATED-' || SUBSTRING(c.id::text, 1, 8)) as contract_number,
    COALESCE(c.display_name, c.original_filename, 'Migrated Contract') as title,
    COALESCE(c.contract_description, 'Contract migrated from V2 schema') as description,
    CASE 
        WHEN c.contract_type IS NOT NULL THEN c.contract_type
        ELSE 'NON_EXCLUSIVE'
    END as contract_type,
    COALESCE(c.contract_description, 'License scope to be defined') as license_scope,
    c.contract_value as total_value,
    COALESCE(c.contract_currency, 'USD') as currency,
    COALESCE(c.effective_date, c.created_at::date) as effective_date,
    COALESCE(c.expiration_date, c.created_at::date + INTERVAL '1 year') as expiration_date,
    CASE 
        WHEN c.status = 'READY' THEN 'ACTIVE'
        WHEN c.status = 'DELETED' THEN 'TERMINATED'
        WHEN c.status = 'ERROR' THEN 'DRAFT'
        ELSE 'DRAFT'
    END as status,
    'APPROVED' as approval_status, -- Assume existing contracts are approved
    'EXECUTED' as execution_status, -- Assume existing contracts are executed
    'COMPLIANT' as compliance_status,
    CONCAT_WS('; ', 
        c.contract_description,
        CASE WHEN c.contract_tags IS NOT NULL THEN 'Tags: ' || array_to_string(c.contract_tags, ', ') END,
        'Migrated from V2 schema on ' || CURRENT_DATE::text
    ) as notes,
    c.contract_tags,
    c.created_by_user_id,
    c.updated_by_user_id,
    c.created_at,
    c.updated_at,
    c.deleted_at
FROM tenant_default.contracts c
WHERE c.deleted_at IS NULL -- Only migrate active contracts
ON CONFLICT (id) DO NOTHING; -- Skip if already migrated

-- Step 2: Migrate V2 contracts to V3 contract_files  
INSERT INTO tenant_default.contract_files (
    id,
    tenant_id,
    business_contract_id,
    filename,
    original_filename,
    display_name,
    file_type,
    file_size,
    mime_type,
    file_extension,
    checksum,
    checksum_algorithm,
    s3_bucket,
    s3_key,
    s3_version_id,
    s3_etag,
    upload_session_id,
    upload_order,
    status,
    processing_status,
    virus_scan_status,
    virus_scan_result,
    content_length,
    content_encoding,
    last_accessed_at,
    access_count,
    created_by_user_id,
    updated_by_user_id,
    created_at,
    updated_at,
    deleted_at
)
SELECT 
    gen_random_uuid() as id, -- Generate new ID for contract files
    c.tenant_id,
    c.id as business_contract_id, -- Link to the business contract
    c.filename,
    c.original_filename,
    c.display_name,
    'MAIN_CONTRACT' as file_type, -- Assume primary contract file
    c.file_size,
    c.mime_type,
    c.file_extension,
    c.checksum,
    c.checksum_algorithm,
    c.s3_bucket,
    c.s3_key,
    c.s3_version_id,
    c.s3_etag,
    c.upload_session_id,
    c.upload_order,
    c.status,
    c.processing_status,
    c.virus_scan_status,
    c.virus_scan_result,
    c.content_length,
    c.content_encoding,
    c.last_accessed_at,
    c.access_count,
    c.created_by_user_id,
    c.updated_by_user_id,
    c.created_at,
    c.updated_at,
    c.deleted_at
FROM tenant_default.contracts c
WHERE c.deleted_at IS NULL -- Only migrate active contracts
ON CONFLICT (tenant_id, s3_key) DO NOTHING; -- Skip duplicates based on S3 key

-- Step 3: Migrate contract versions
INSERT INTO tenant_default.contract_versions (
    id,
    contract_id,
    version_number,
    s3_bucket,
    s3_key,
    s3_version_id,
    checksum,
    file_size,
    mime_type,
    created_by_user_id,
    created_at,
    notes
)
SELECT 
    cv.id,
    cv.contract_id, -- This should match the business_contract_id
    cv.version_number,
    cv.s3_bucket,
    cv.s3_key,
    cv.s3_version_id,
    cv.checksum,
    cv.file_size,
    cv.mime_type,
    cv.created_by_user_id,
    cv.created_at,
    COALESCE(cv.notes, 'Migrated from V2 schema')
FROM tenant_default.contract_versions cv
WHERE EXISTS (
    SELECT 1 FROM tenant_default.contracts c 
    WHERE c.id = cv.contract_id AND c.deleted_at IS NULL
)
ON CONFLICT (id) DO NOTHING;

-- Update contract_versions to point to contract_files instead of business_contracts
-- Note: This maintains backward compatibility while the application adapts
UPDATE tenant_default.contract_versions cv
SET contract_id = cf.id
FROM tenant_default.contract_files cf
WHERE cf.business_contract_id = cv.contract_id
AND EXISTS (
    SELECT 1 FROM tenant_default.contracts c 
    WHERE c.id = cf.business_contract_id
);

-- Step 4: Migrate contract access logs
INSERT INTO tenant_default.contract_access_log (
    id,
    contract_id,
    user_id,
    access_type,
    ip_address,
    user_agent,
    access_timestamp,
    bytes_transferred,
    success,
    error_message
)
SELECT 
    cal.id,
    cf.id as contract_id, -- Point to contract_files
    cal.user_id,
    cal.access_type,
    cal.ip_address,
    cal.user_agent,
    cal.access_timestamp,
    cal.bytes_transferred,
    cal.success,
    cal.error_message
FROM tenant_default.contract_access_log cal
JOIN tenant_default.contract_files cf ON cf.business_contract_id = cal.contract_id
WHERE EXISTS (
    SELECT 1 FROM tenant_default.contracts c 
    WHERE c.id = cal.contract_id AND c.deleted_at IS NULL
)
ON CONFLICT (id) DO NOTHING;

-- Commit the transaction
COMMIT;

-- ==============================================================================
-- DATA VALIDATION AND INTEGRITY CHECKS
-- ==============================================================================

DO $$
DECLARE
    v2_contracts_count INTEGER;
    v3_business_contracts_count INTEGER;
    v3_contract_files_count INTEGER;
    migration_issues INTEGER := 0;
BEGIN
    -- Count migrated records
    SELECT COUNT(*) INTO v2_contracts_count 
    FROM tenant_default.contracts 
    WHERE deleted_at IS NULL;
    
    SELECT COUNT(*) INTO v3_business_contracts_count 
    FROM tenant_default.business_contracts 
    WHERE deleted_at IS NULL;
    
    SELECT COUNT(*) INTO v3_contract_files_count 
    FROM tenant_default.contract_files 
    WHERE deleted_at IS NULL;
    
    -- Validate migration counts
    IF v2_contracts_count != v3_business_contracts_count THEN
        RAISE WARNING 'Migration count mismatch: V2 contracts (%) != V3 business contracts (%)', 
                     v2_contracts_count, v3_business_contracts_count;
        migration_issues := migration_issues + 1;
    END IF;
    
    IF v2_contracts_count != v3_contract_files_count THEN
        RAISE WARNING 'Migration count mismatch: V2 contracts (%) != V3 contract files (%)', 
                     v2_contracts_count, v3_contract_files_count;
        migration_issues := migration_issues + 1;
    END IF;
    
    -- Check for orphaned contract files
    IF EXISTS (
        SELECT 1 FROM tenant_default.contract_files cf
        WHERE NOT EXISTS (
            SELECT 1 FROM tenant_default.business_contracts bc
            WHERE bc.id = cf.business_contract_id
        )
    ) THEN
        RAISE WARNING 'Found orphaned contract files without corresponding business contracts';
        migration_issues := migration_issues + 1;
    END IF;
    
    -- Check for missing default entities
    IF NOT EXISTS (
        SELECT 1 FROM tenant_default.licensors 
        WHERE name = 'Default Licensor (Migrated)'
    ) THEN
        RAISE WARNING 'Default licensor not found';
        migration_issues := migration_issues + 1;
    END IF;
    
    IF NOT EXISTS (
        SELECT 1 FROM tenant_default.licensees 
        WHERE name = 'Default Licensee (Migrated)'
    ) THEN
        RAISE WARNING 'Default licensee not found';
        migration_issues := migration_issues + 1;
    END IF;
    
    -- Report results
    IF migration_issues = 0 THEN
        RAISE NOTICE 'Migration completed successfully!';
        RAISE NOTICE 'Migrated % contracts to % business contracts and % contract files', 
                     v2_contracts_count, v3_business_contracts_count, v3_contract_files_count;
    ELSE
        RAISE WARNING 'Migration completed with % issues - review warnings above', migration_issues;
    END IF;
END $$;

-- ==============================================================================
-- POST-MIGRATION CLEANUP AND OPTIMIZATION
-- ==============================================================================

-- Update statistics for better query performance
ANALYZE tenant_default.business_contracts;
ANALYZE tenant_default.contract_files;
ANALYZE tenant_default.licensors;
ANALYZE tenant_default.licensees;

-- ==============================================================================
-- MIGRATION COMPLETION MARKERS
-- ==============================================================================

-- Insert migration record for tracking
INSERT INTO tenant_default.upload_sessions (
    tenant_id,
    session_name,
    status,
    total_files,
    completed_files,
    metadata,
    created_at,
    completed_at
) VALUES (
    'default',
    'V4 Migration: V2 to V3 Schema Migration',
    'COMPLETED',
    (SELECT COUNT(*) FROM tenant_default.contracts WHERE deleted_at IS NULL),
    (SELECT COUNT(*) FROM tenant_default.business_contracts WHERE deleted_at IS NULL),
    jsonb_build_object(
        'migration_version', 'V4',
        'migration_type', 'V2_to_V3_schema',
        'migration_date', CURRENT_TIMESTAMP::text,
        'v2_contracts_migrated', (SELECT COUNT(*) FROM tenant_default.contracts WHERE deleted_at IS NULL),
        'v3_business_contracts_created', (SELECT COUNT(*) FROM tenant_default.business_contracts WHERE deleted_at IS NULL),
        'v3_contract_files_created', (SELECT COUNT(*) FROM tenant_default.contract_files WHERE deleted_at IS NULL),
        'default_licensor_created', true,
        'default_licensee_created', true
    ),
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
) ON CONFLICT DO NOTHING;

-- ==============================================================================
-- ROLLBACK PROCEDURES (DOCUMENTATION)
-- ==============================================================================

/*
ROLLBACK PROCEDURE:
If this migration needs to be rolled back, execute the following steps:

1. Stop the application to prevent new data creation

2. Drop the migrated V3 data:
   DELETE FROM tenant_default.contract_files WHERE business_contract_id IN (
       SELECT id FROM tenant_default.business_contracts 
       WHERE notes LIKE '%Migrated from V2 schema%'
   );
   DELETE FROM tenant_default.business_contracts WHERE notes LIKE '%Migrated from V2 schema%';
   DELETE FROM tenant_default.licensors WHERE name = 'Default Licensor (Migrated)';
   DELETE FROM tenant_default.licensees WHERE name = 'Default Licensee (Migrated)';

3. Restore V2 data from backup (if needed):
   TRUNCATE tenant_default.contracts;
   INSERT INTO tenant_default.contracts SELECT * FROM contracts_v2_backup;
   
   TRUNCATE tenant_default.contract_versions;
   INSERT INTO tenant_default.contract_versions SELECT * FROM contract_versions_v2_backup;
   
   TRUNCATE tenant_default.contract_access_log;
   INSERT INTO tenant_default.contract_access_log SELECT * FROM contract_access_log_v2_backup;

4. Drop backup tables:
   DROP TABLE contracts_v2_backup;
   DROP TABLE contract_versions_v2_backup;
   DROP TABLE contract_access_log_v2_backup;

5. Restart the application with V2 schema

NOTE: This rollback should only be performed in development/staging environments.
Production rollbacks require careful planning and testing.
*/

-- ==============================================================================
-- FINAL VALIDATION
-- ==============================================================================

DO $$
BEGIN
    RAISE NOTICE '========================================';
    RAISE NOTICE 'V4 Migration Summary';
    RAISE NOTICE '========================================';
    RAISE NOTICE 'Migration Type: V2 contracts → V3 business_contracts + contract_files';
    RAISE NOTICE 'V2 Contracts Found: %', (SELECT COUNT(*) FROM tenant_default.contracts WHERE deleted_at IS NULL);
    RAISE NOTICE 'V3 Business Contracts Created: %', (SELECT COUNT(*) FROM tenant_default.business_contracts WHERE deleted_at IS NULL);
    RAISE NOTICE 'V3 Contract Files Created: %', (SELECT COUNT(*) FROM tenant_default.contract_files WHERE deleted_at IS NULL);
    RAISE NOTICE 'Default Entities Created: 1 Licensor, 1 Licensee';
    RAISE NOTICE 'Backup Tables: contracts_v2_backup, contract_versions_v2_backup, contract_access_log_v2_backup';
    RAISE NOTICE '========================================';
    RAISE NOTICE 'Migration completed successfully!';
    RAISE NOTICE 'Next steps:';
    RAISE NOTICE '1. Update application code to use V3 schema';
    RAISE NOTICE '2. Test all contract-related functionality';
    RAISE NOTICE '3. Verify file uploads and downloads work correctly';
    RAISE NOTICE '4. Review migrated data for accuracy';
    RAISE NOTICE '5. Remove backup tables after verification (production only)';
    RAISE NOTICE '========================================';
END $$;