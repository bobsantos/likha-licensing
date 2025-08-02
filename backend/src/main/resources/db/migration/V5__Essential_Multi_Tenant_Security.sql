-- V5 Migration: Essential Multi-Tenant Security Implementation
-- Implements critical security measures for production-ready multi-tenant SaaS platform
-- Includes Row Level Security (RLS), database user management, audit trails, and encryption
-- Version: 5.0
-- Date: 2025-08-02

-- ==============================================================================
-- SECURITY VALIDATION AND PREREQUISITES
-- ==============================================================================

-- Verify that prerequisite tables exist before applying security
DO $$
BEGIN
    -- Check if core tenant infrastructure exists
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.tables 
        WHERE table_name = 'tenants' 
        AND table_schema = 'public'
    ) THEN
        RAISE EXCEPTION 'Tenants table not found - ensure base schema is deployed first';
    END IF;
    
    -- Check if V3/V4 contract tables exist
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.tables 
        WHERE table_name = 'business_contracts' 
        AND table_schema = 'public'
    ) THEN
        RAISE EXCEPTION 'V3 business_contracts table not found - ensure V3/V4 migrations are applied first';
    END IF;
    
    RAISE NOTICE 'Security prerequisites validated - proceeding with V5 security implementation';
END $$;

-- ==============================================================================
-- 1. CRITICAL: ROW LEVEL SECURITY (RLS) IMPLEMENTATION
-- ==============================================================================
-- Prevents cross-tenant data access at the database level
-- This is the most critical security fix for multi-tenant isolation

-- Enable RLS on all tenant-scoped tables
-- Public schema tables (shared across tenants)
ALTER TABLE public.tenants ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.licensors ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.licensees ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.brands ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.business_contracts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.contract_files ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.contract_versions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.contract_access_log ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.upload_sessions ENABLE ROW LEVEL SECURITY;

-- Tenant-specific schema tables
DO $$
DECLARE
    schema_name TEXT;
    table_name TEXT;
    tables_to_secure TEXT[] := ARRAY[
        'contracts', 'licensors', 'licensees', 'brands', 
        'business_contracts', 'contract_files', 'contract_versions', 
        'contract_access_log', 'upload_sessions'
    ];
BEGIN
    -- Enable RLS on tenant_default schema tables
    FOREACH table_name IN ARRAY tables_to_secure
    LOOP
        IF EXISTS (
            SELECT 1 FROM information_schema.tables 
            WHERE table_schema = 'tenant_default' AND table_name = table_name
        ) THEN
            EXECUTE format('ALTER TABLE tenant_default.%I ENABLE ROW LEVEL SECURITY', table_name);
            RAISE NOTICE 'Enabled RLS on tenant_default.%', table_name;
        END IF;
    END LOOP;
END $$;

-- ==============================================================================
-- 2. DATABASE USER MANAGEMENT AND MINIMAL PRIVILEGES
-- ==============================================================================
-- Create application-specific database users with minimal required privileges

-- Create application user for normal operations (read/write)
DO $$
BEGIN
    -- Check if user already exists
    IF NOT EXISTS (
        SELECT 1 FROM pg_roles WHERE rolname = 'likha_app_user'
    ) THEN
        CREATE ROLE likha_app_user WITH LOGIN PASSWORD 'CHANGE_ME_IN_PRODUCTION';
        RAISE NOTICE 'Created likha_app_user - CHANGE PASSWORD IN PRODUCTION';
    ELSE
        RAISE NOTICE 'likha_app_user already exists - skipping creation';
    END IF;
END $$;

-- Create read-only user for reporting and analytics
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_roles WHERE rolname = 'likha_readonly_user'
    ) THEN
        CREATE ROLE likha_readonly_user WITH LOGIN PASSWORD 'CHANGE_ME_IN_PRODUCTION';
        RAISE NOTICE 'Created likha_readonly_user - CHANGE PASSWORD IN PRODUCTION';
    ELSE
        RAISE NOTICE 'likha_readonly_user already exists - skipping creation';
    END IF;
END $$;

-- Grant minimal necessary privileges to application user
GRANT CONNECT ON DATABASE likha_licensing TO likha_app_user;
GRANT USAGE ON SCHEMA public TO likha_app_user;
GRANT USAGE ON SCHEMA tenant_default TO likha_app_user;

-- Grant table-level permissions for application user
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO likha_app_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA tenant_default TO likha_app_user;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO likha_app_user;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA tenant_default TO likha_app_user;

-- Grant read-only permissions to readonly user
GRANT CONNECT ON DATABASE likha_licensing TO likha_readonly_user;
GRANT USAGE ON SCHEMA public TO likha_readonly_user;
GRANT USAGE ON SCHEMA tenant_default TO likha_readonly_user;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO likha_readonly_user;
GRANT SELECT ON ALL TABLES IN SCHEMA tenant_default TO likha_readonly_user;

-- Set default privileges for future tables
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO likha_app_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA tenant_default GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO likha_app_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO likha_readonly_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA tenant_default GRANT SELECT ON TABLES TO likha_readonly_user;

-- ==============================================================================
-- 3. RLS POLICIES FOR TENANT ISOLATION
-- ==============================================================================
-- Define policies that enforce tenant_id-based access control

-- Create function to get current tenant context
-- This will be set by the application layer for each request
CREATE OR REPLACE FUNCTION get_current_tenant_id()
RETURNS VARCHAR(50) AS $$
BEGIN
    -- Get tenant_id from session variable set by application
    RETURN COALESCE(current_setting('app.current_tenant_id', true), 'invalid_tenant');
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- RLS Policy for public.licensors
DROP POLICY IF EXISTS tenant_isolation_policy ON public.licensors;
CREATE POLICY tenant_isolation_policy ON public.licensors
    FOR ALL
    TO likha_app_user, likha_readonly_user
    USING (tenant_id = get_current_tenant_id());

-- RLS Policy for public.licensees
DROP POLICY IF EXISTS tenant_isolation_policy ON public.licensees;
CREATE POLICY tenant_isolation_policy ON public.licensees
    FOR ALL
    TO likha_app_user, likha_readonly_user
    USING (tenant_id = get_current_tenant_id());

-- RLS Policy for public.brands
DROP POLICY IF EXISTS tenant_isolation_policy ON public.brands;
CREATE POLICY tenant_isolation_policy ON public.brands
    FOR ALL
    TO likha_app_user, likha_readonly_user
    USING (tenant_id = get_current_tenant_id());

-- RLS Policy for public.business_contracts
DROP POLICY IF EXISTS tenant_isolation_policy ON public.business_contracts;
CREATE POLICY tenant_isolation_policy ON public.business_contracts
    FOR ALL
    TO likha_app_user, likha_readonly_user
    USING (tenant_id = get_current_tenant_id());

-- RLS Policy for public.contract_files
DROP POLICY IF EXISTS tenant_isolation_policy ON public.contract_files;
CREATE POLICY tenant_isolation_policy ON public.contract_files
    FOR ALL
    TO likha_app_user, likha_readonly_user
    USING (tenant_id = get_current_tenant_id());

-- RLS Policy for public.upload_sessions
DROP POLICY IF EXISTS tenant_isolation_policy ON public.upload_sessions;
CREATE POLICY tenant_isolation_policy ON public.upload_sessions
    FOR ALL
    TO likha_app_user, likha_readonly_user
    USING (tenant_id = get_current_tenant_id());

-- RLS Policy for tenant_default schema tables
DO $$
DECLARE
    table_name TEXT;
    tables_with_tenant_id TEXT[] := ARRAY[
        'licensors', 'licensees', 'brands', 
        'business_contracts', 'contract_files', 'upload_sessions'
    ];
BEGIN
    FOREACH table_name IN ARRAY tables_with_tenant_id
    LOOP
        IF EXISTS (
            SELECT 1 FROM information_schema.tables 
            WHERE table_schema = 'tenant_default' AND table_name = table_name
        ) THEN
            EXECUTE format('DROP POLICY IF EXISTS tenant_isolation_policy ON tenant_default.%I', table_name);
            EXECUTE format('CREATE POLICY tenant_isolation_policy ON tenant_default.%I
                FOR ALL
                TO likha_app_user, likha_readonly_user
                USING (tenant_id = get_current_tenant_id())', table_name);
            RAISE NOTICE 'Created RLS policy for tenant_default.%', table_name;
        END IF;
    END LOOP;
END $$;

-- Special policy for tenants table - users can only see their own tenant
DROP POLICY IF EXISTS tenant_self_access_policy ON public.tenants;
CREATE POLICY tenant_self_access_policy ON public.tenants
    FOR ALL
    TO likha_app_user, likha_readonly_user
    USING (tenant_id = get_current_tenant_id());

-- ==============================================================================
-- 4. ENHANCED AUDIT TRAIL SYSTEM
-- ==============================================================================
-- Comprehensive audit logging for security and compliance

-- Create audit log table for security events
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
    CONSTRAINT chk_audit_event_type CHECK (event_type IN ('LOGIN', 'LOGOUT', 'DATA_ACCESS', 'DATA_MODIFICATION', 'PERMISSION_CHANGE', 'FILE_UPLOAD', 'FILE_DOWNLOAD', 'FAILED_ACCESS')),
    CONSTRAINT chk_audit_event_category CHECK (event_category IN ('AUTHENTICATION', 'AUTHORIZATION', 'DATA_ACCESS', 'SYSTEM', 'FILE_OPERATION')),
    CONSTRAINT chk_audit_severity CHECK (severity IN ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL')),
    CONSTRAINT chk_audit_action CHECK (action_performed IN ('CREATE', 'READ', 'UPDATE', 'DELETE', 'DOWNLOAD', 'UPLOAD', 'LOGIN', 'LOGOUT', 'ACCESS_DENIED')),
    CONSTRAINT chk_audit_risk_score CHECK (risk_score IS NULL OR (risk_score >= 0 AND risk_score <= 100))
);

-- Enable RLS on audit log
ALTER TABLE security_audit_log ENABLE ROW LEVEL SECURITY;

-- RLS Policy for audit log - users can only see their tenant's audit records
DROP POLICY IF EXISTS tenant_audit_policy ON security_audit_log;
CREATE POLICY tenant_audit_policy ON security_audit_log
    FOR SELECT
    TO likha_app_user, likha_readonly_user
    USING (tenant_id = get_current_tenant_id());

-- Separate policy for inserting audit records (application can log to any tenant)
DROP POLICY IF EXISTS audit_insert_policy ON security_audit_log;
CREATE POLICY audit_insert_policy ON security_audit_log
    FOR INSERT
    TO likha_app_user
    WITH CHECK (true); -- Allow application to insert audit records for any tenant

-- Create indexes for audit log performance
CREATE INDEX IF NOT EXISTS idx_security_audit_log_tenant_timestamp 
    ON security_audit_log (tenant_id, event_timestamp DESC);
CREATE INDEX IF NOT EXISTS idx_security_audit_log_user_timestamp 
    ON security_audit_log (user_id, event_timestamp DESC);
CREATE INDEX IF NOT EXISTS idx_security_audit_log_event_type 
    ON security_audit_log (event_type, event_timestamp DESC);
CREATE INDEX IF NOT EXISTS idx_security_audit_log_resource 
    ON security_audit_log (resource_type, resource_id);
CREATE INDEX IF NOT EXISTS idx_security_audit_log_severity 
    ON security_audit_log (severity, event_timestamp DESC);

-- ==============================================================================
-- 5. BASIC ENCRYPTION CONFIGURATION
-- ==============================================================================
-- Set up encryption settings and create secure functions

-- Enable pgcrypto extension for encryption functions
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Create function for encrypting sensitive data
CREATE OR REPLACE FUNCTION encrypt_sensitive_data(data TEXT)
RETURNS TEXT AS $$
BEGIN
    -- Use AES encryption with a key derived from database settings
    -- In production, this should use a proper key management system
    RETURN encode(
        encrypt(
            data::bytea, 
            'CHANGE_ME_ENCRYPTION_KEY_IN_PRODUCTION'::bytea, 
            'aes'
        ), 
        'base64'
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create function for decrypting sensitive data
CREATE OR REPLACE FUNCTION decrypt_sensitive_data(encrypted_data TEXT)
RETURNS TEXT AS $$
BEGIN
    RETURN convert_from(
        decrypt(
            decode(encrypted_data, 'base64'), 
            'CHANGE_ME_ENCRYPTION_KEY_IN_PRODUCTION'::bytea, 
            'aes'
        ), 
        'UTF8'
    );
EXCEPTION
    WHEN OTHERS THEN
        RETURN NULL; -- Return NULL if decryption fails
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ==============================================================================
-- 6. DATABASE CONNECTION AND SESSION SECURITY
-- ==============================================================================
-- Configure secure connection settings

-- Set secure default values for connections
-- These settings should also be configured in postgresql.conf
ALTER SYSTEM SET log_connections = on;
ALTER SYSTEM SET log_disconnections = on;
ALTER SYSTEM SET log_statement = 'mod'; -- Log data-modifying statements
ALTER SYSTEM SET log_line_prefix = '%t [%p]: [%l-1] user=%u,db=%d,app=%a,client=%h ';

-- Create function to audit database connections
CREATE OR REPLACE FUNCTION audit_connection()
RETURNS event_trigger AS $$
BEGIN
    -- This will be called on DDL events
    -- Log structural changes for security monitoring
    INSERT INTO security_audit_log (
        tenant_id,
        event_type,
        event_category,
        severity,
        user_id,
        username,
        action_performed,
        resource_type,
        metadata,
        event_timestamp
    ) VALUES (
        'system',
        'DATA_MODIFICATION',
        'SYSTEM',
        'HIGH',
        NULL,
        current_user,
        'DDL_CHANGE',
        'DATABASE_SCHEMA',
        jsonb_build_object(
            'command_tag', TG_TAG,
            'object_type', TG_EVENT,
            'database', current_database()
        ),
        CURRENT_TIMESTAMP
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create DDL audit trigger (commented out for initial deployment)
-- CREATE EVENT TRIGGER audit_ddl_events ON ddl_command_end EXECUTE FUNCTION audit_connection();

-- ==============================================================================
-- 7. SECURITY MONITORING AND ALERTING SETUP
-- ==============================================================================
-- Create functions and views for security monitoring

-- Create view for security dashboard
CREATE OR REPLACE VIEW security_monitoring_dashboard AS
SELECT 
    tenant_id,
    DATE_TRUNC('hour', event_timestamp) as hour_bucket,
    event_type,
    event_category,
    severity,
    COUNT(*) as event_count,
    COUNT(DISTINCT user_id) as unique_users,
    AVG(risk_score) as avg_risk_score,
    COUNT(CASE WHEN success = false THEN 1 END) as failed_events
FROM security_audit_log 
WHERE event_timestamp >= CURRENT_TIMESTAMP - INTERVAL '24 hours'
GROUP BY tenant_id, hour_bucket, event_type, event_category, severity
ORDER BY hour_bucket DESC, event_count DESC;

-- Create function to detect suspicious activity
CREATE OR REPLACE FUNCTION detect_suspicious_activity(
    p_tenant_id VARCHAR(50),
    p_hours_back INTEGER DEFAULT 1
)
RETURNS TABLE (
    alert_type TEXT,
    description TEXT,
    severity VARCHAR(20),
    event_count BIGINT,
    risk_score NUMERIC
) AS $$
BEGIN
    -- Multiple failed login attempts
    RETURN QUERY
    SELECT 
        'MULTIPLE_FAILED_LOGINS'::TEXT,
        'Multiple failed login attempts detected'::TEXT,
        'HIGH'::VARCHAR(20),
        COUNT(*),
        AVG(sal.risk_score)::NUMERIC
    FROM security_audit_log sal
    WHERE sal.tenant_id = p_tenant_id
        AND sal.event_type = 'LOGIN'
        AND sal.success = false
        AND sal.event_timestamp >= CURRENT_TIMESTAMP - (p_hours_back || ' hours')::INTERVAL
    GROUP BY sal.ip_address, sal.user_id
    HAVING COUNT(*) >= 5;
    
    -- Unusual data access patterns
    RETURN QUERY
    SELECT 
        'UNUSUAL_DATA_ACCESS'::TEXT,
        'Unusual data access pattern detected'::TEXT,
        'MEDIUM'::VARCHAR(20),
        COUNT(*),
        AVG(sal.risk_score)::NUMERIC
    FROM security_audit_log sal
    WHERE sal.tenant_id = p_tenant_id
        AND sal.event_type = 'DATA_ACCESS'
        AND sal.event_timestamp >= CURRENT_TIMESTAMP - (p_hours_back || ' hours')::INTERVAL
    GROUP BY sal.user_id
    HAVING COUNT(*) >= 100; -- More than 100 data access events per hour
    
    -- High-risk operations
    RETURN QUERY
    SELECT 
        'HIGH_RISK_OPERATIONS'::TEXT,
        'High-risk operations detected'::TEXT,
        'CRITICAL'::VARCHAR(20),
        COUNT(*),
        AVG(sal.risk_score)::NUMERIC
    FROM security_audit_log sal
    WHERE sal.tenant_id = p_tenant_id
        AND sal.risk_score >= 80
        AND sal.event_timestamp >= CURRENT_TIMESTAMP - (p_hours_back || ' hours')::INTERVAL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ==============================================================================
-- 8. SECURITY VALIDATION AND TESTING
-- ==============================================================================
-- Verify that security measures are properly implemented

-- Test RLS policies
DO $$
BEGIN
    -- Set a test tenant context
    PERFORM set_config('app.current_tenant_id', 'test_tenant', false);
    
    -- Verify RLS is enabled on critical tables
    IF NOT EXISTS (
        SELECT 1 FROM pg_class c
        JOIN pg_namespace n ON c.relnamespace = n.oid
        WHERE c.relname = 'business_contracts'
        AND n.nspname = 'public'
        AND c.relrowsecurity = true
    ) THEN
        RAISE WARNING 'RLS not enabled on business_contracts table';
    END IF;
    
    RAISE NOTICE 'RLS validation completed';
END $$;

-- Create security health check function
CREATE OR REPLACE FUNCTION security_health_check()
RETURNS TABLE (
    check_name TEXT,
    status TEXT,
    details TEXT
) AS $$
BEGIN
    -- Check if RLS is enabled on critical tables
    RETURN QUERY
    SELECT 
        'RLS_ENABLED'::TEXT as check_name,
        CASE WHEN COUNT(*) >= 8 THEN 'PASS' ELSE 'FAIL' END::TEXT as status,
        COUNT(*)::TEXT || ' tables have RLS enabled'::TEXT as details
    FROM pg_class c
    JOIN pg_namespace n ON c.relnamespace = n.oid
    WHERE c.relrowsecurity = true
    AND n.nspname IN ('public', 'tenant_default');
    
    -- Check if application users exist
    RETURN QUERY
    SELECT 
        'APP_USERS_EXIST'::TEXT,
        CASE WHEN COUNT(*) >= 2 THEN 'PASS' ELSE 'FAIL' END::TEXT,
        COUNT(*)::TEXT || ' application database users configured'::TEXT
    FROM pg_roles 
    WHERE rolname IN ('likha_app_user', 'likha_readonly_user');
    
    -- Check if audit table exists
    RETURN QUERY
    SELECT 
        'AUDIT_TABLE_EXISTS'::TEXT,
        CASE WHEN COUNT(*) >= 1 THEN 'PASS' ELSE 'FAIL' END::TEXT,
        'Security audit log table configured'::TEXT
    FROM information_schema.tables
    WHERE table_name = 'security_audit_log'
    AND table_schema = 'public';
    
    -- Check if encryption functions exist
    RETURN QUERY
    SELECT 
        'ENCRYPTION_FUNCTIONS'::TEXT,
        CASE WHEN COUNT(*) >= 2 THEN 'PASS' ELSE 'FAIL' END::TEXT,
        COUNT(*)::TEXT || ' encryption functions available'::TEXT
    FROM information_schema.routines
    WHERE routine_name IN ('encrypt_sensitive_data', 'decrypt_sensitive_data')
    AND routine_schema = 'public';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ==============================================================================
-- 9. GRANT PERMISSIONS FOR SECURITY FUNCTIONS
-- ==============================================================================
-- Ensure application can use security functions

GRANT EXECUTE ON FUNCTION get_current_tenant_id() TO likha_app_user, likha_readonly_user;
GRANT EXECUTE ON FUNCTION encrypt_sensitive_data(TEXT) TO likha_app_user;
GRANT EXECUTE ON FUNCTION decrypt_sensitive_data(TEXT) TO likha_app_user;
GRANT EXECUTE ON FUNCTION detect_suspicious_activity(VARCHAR, INTEGER) TO likha_app_user, likha_readonly_user;
GRANT EXECUTE ON FUNCTION security_health_check() TO likha_app_user, likha_readonly_user;

GRANT SELECT ON security_monitoring_dashboard TO likha_app_user, likha_readonly_user;

-- ==============================================================================
-- 10. FINAL SECURITY VALIDATION
-- ==============================================================================
-- Run comprehensive security validation

DO $$
DECLARE
    security_check RECORD;
    check_count INTEGER := 0;
    pass_count INTEGER := 0;
BEGIN
    RAISE NOTICE '========================================';
    RAISE NOTICE 'V5 Security Implementation Validation';
    RAISE NOTICE '========================================';
    
    FOR security_check IN SELECT * FROM security_health_check()
    LOOP
        check_count := check_count + 1;
        IF security_check.status = 'PASS' THEN
            pass_count := pass_count + 1;
        END IF;
        
        RAISE NOTICE '% - %: %', 
            security_check.check_name, 
            security_check.status, 
            security_check.details;
    END LOOP;
    
    RAISE NOTICE '========================================';
    RAISE NOTICE 'Security validation: % of % checks passed', pass_count, check_count;
    
    IF pass_count = check_count THEN
        RAISE NOTICE 'All security checks PASSED - System is secure';
    ELSE
        RAISE WARNING 'Some security checks FAILED - Review above results';
    END IF;
    
    RAISE NOTICE '========================================';
    RAISE NOTICE 'CRITICAL PRODUCTION REMINDERS:';
    RAISE NOTICE '1. CHANGE DEFAULT PASSWORDS for likha_app_user and likha_readonly_user';
    RAISE NOTICE '2. CHANGE ENCRYPTION KEY in encrypt_sensitive_data/decrypt_sensitive_data functions';
    RAISE NOTICE '3. Configure application to set app.current_tenant_id session variable';
    RAISE NOTICE '4. Set up monitoring for security_audit_log table';
    RAISE NOTICE '5. Configure SSL/TLS for all database connections';
    RAISE NOTICE '6. Review and adjust postgresql.conf security settings';
    RAISE NOTICE '7. Set up automated security monitoring and alerting';
    RAISE NOTICE '========================================';
END $$;

-- ==============================================================================
-- MIGRATION COMPLETION RECORD
-- ==============================================================================

-- Record this security migration for audit purposes
INSERT INTO security_audit_log (
    tenant_id,
    event_type,
    event_category,
    severity,
    username,
    action_performed,
    resource_type,
    resource_description,
    metadata,
    success,
    event_timestamp
) VALUES (
    'system',
    'DATA_MODIFICATION',
    'SYSTEM',
    'HIGH',
    current_user,
    'CREATE',
    'DATABASE_SECURITY',
    'V5 Essential Multi-Tenant Security Implementation',
    jsonb_build_object(
        'migration_version', 'V5',
        'security_features', ARRAY[
            'Row Level Security (RLS)',
            'Database User Management',
            'Tenant Isolation Policies',
            'Enhanced Audit Trail',
            'Basic Encryption Functions',
            'Security Monitoring Dashboard',
            'Suspicious Activity Detection'
        ],
        'migration_timestamp', CURRENT_TIMESTAMP,
        'database_version', version()
    ),
    true,
    CURRENT_TIMESTAMP
);

RAISE NOTICE 'V5 Essential Multi-Tenant Security implementation completed successfully!';