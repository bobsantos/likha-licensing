package app.likha.users.internal.repository;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.beans.factory.annotation.Autowired;

import javax.sql.DataSource;
import java.sql.Connection;

import static org.assertj.core.api.Assertions.*;

/**
 * User Management domain database infrastructure tests.
 * 
 * These tests validate database infrastructure aspects specific to the User Management context:
 * - Tenant isolation and schema-per-tenant functionality
 * - User authentication infrastructure
 * - Security audit logging capabilities
 * - Multi-tenant data separation
 * 
 * This test focuses only on User Management domain database tables:
 * - tenants (tenant configuration and metadata)
 * - users (user accounts and authentication)
 * - security_audit_log (security events)
 */
@SpringBootTest
@ActiveProfiles("test")
@DisplayName("User Management Database Infrastructure Tests")
class TenantDatabaseInfrastructureTest {

    @Autowired
    private DataSource dataSource;

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @BeforeEach
    void setUp() throws Exception {
        // Verify database is running and accessible
        try (Connection connection = dataSource.getConnection()) {
            assertThat(connection.isValid(5))
                .as("Database connection should be valid")
                .isTrue();
        }
    }

    @Test
    @DisplayName("Should support tenant context and schema-per-tenant isolation")
    void shouldSupportTenantContextAndIsolation() {
        // Test that tenant schemas exist - our current approach uses schema-per-tenant
        String defaultTenantSchema = "tenant_default";
        
        Integer schemaCount = jdbcTemplate.queryForObject(
            "SELECT COUNT(*) FROM information_schema.schemata WHERE schema_name = ?",
            Integer.class,
            defaultTenantSchema
        );
        
        assertThat(schemaCount)
            .as("Default tenant schema should exist")
            .isEqualTo(1);
    }

    @Test
    @DisplayName("Should support tenant management operations")
    void shouldSupportTenantManagementOperations() {
        String testTenantId = "user-mgmt-test-tenant";
        String testSchemaName = "tenant_" + testTenantId.replace("-", "_");
        
        try {
            // Test inserting a tenant in public schema (User Management domain)
            jdbcTemplate.update(
                "INSERT INTO tenants (tenant_id, tenant_name, schema_name, active) VALUES (?, ?, ?, ?)",
                testTenantId, "User Management Test Tenant", testSchemaName, true
            );

            // Verify tenant was inserted
            Integer tenantCount = jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM tenants WHERE tenant_id = ?",
                Integer.class,
                testTenantId
            );

            assertThat(tenantCount)
                .as("Should have inserted one tenant")
                .isEqualTo(1);

            // Verify tenant metadata is correct
            String retrievedSchemaName = jdbcTemplate.queryForObject(
                "SELECT schema_name FROM tenants WHERE tenant_id = ?",
                String.class,
                testTenantId
            );

            assertThat(retrievedSchemaName)
                .as("Tenant schema name should match expected pattern")
                .isEqualTo(testSchemaName);

        } finally {
            // Cleanup - remove test data
            jdbcTemplate.update("DELETE FROM tenants WHERE tenant_id = ?", testTenantId);
        }
    }

    @Test
    @DisplayName("Should validate User Management domain table structure")
    void shouldValidateUserManagementTables() {
        // Verify tenants table exists and has required structure
        Integer tenantsTableCount = jdbcTemplate.queryForObject(
            "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'tenants'",
            Integer.class
        );
        
        assertThat(tenantsTableCount)
            .as("Tenants table should exist in public schema")
            .isEqualTo(1);

        // Verify users table exists and has required structure
        Integer usersTableCount = jdbcTemplate.queryForObject(
            "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'users'",
            Integer.class
        );
        
        assertThat(usersTableCount)
            .as("Users table should exist in public schema")
            .isEqualTo(1);

        // Verify security_audit_log table exists
        Integer auditLogTableCount = jdbcTemplate.queryForObject(
            "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'security_audit_log'",
            Integer.class
        );
        
        assertThat(auditLogTableCount)
            .as("Security audit log table should exist in public schema")
            .isEqualTo(1);
    }

    @Test
    @DisplayName("Should support tenant schema operations")
    void shouldSupportTenantSchemaOperations() {
        // Test creating and validating tenant schema (infrastructure capability)
        String testTenantId = "schema-test-tenant";
        String testSchemaName = "tenant_" + testTenantId.replace("-", "_");
        
        try {
            // Create tenant record
            jdbcTemplate.update(
                "INSERT INTO tenants (tenant_id, tenant_name, schema_name, active) VALUES (?, ?, ?, ?)",
                testTenantId, "Schema Test Tenant", testSchemaName, true
            );

            // Test schema creation (simulating tenant provisioning)
            jdbcTemplate.execute("CREATE SCHEMA IF NOT EXISTS " + testSchemaName);
            
            // Verify schema was created
            Integer schemaCount = jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM information_schema.schemata WHERE schema_name = ?",
                Integer.class,
                testSchemaName
            );
            
            assertThat(schemaCount)
                .as("Tenant schema should be created successfully")
                .isEqualTo(1);

            // Verify tenant record references correct schema
            String retrievedSchema = jdbcTemplate.queryForObject(
                "SELECT schema_name FROM tenants WHERE tenant_id = ?",
                String.class,
                testTenantId
            );
            
            assertThat(retrievedSchema)
                .as("Tenant should reference correct schema name")
                .isEqualTo(testSchemaName);

        } finally {
            // Cleanup - remove test schema and tenant
            jdbcTemplate.execute("DROP SCHEMA IF EXISTS " + testSchemaName + " CASCADE");
            jdbcTemplate.update("DELETE FROM tenants WHERE tenant_id = ?", testTenantId);
        }
    }

    @Test
    @DisplayName("Should validate tenant isolation constraints")
    void shouldValidateTenantIsolationConstraints() {
        // Verify tenant_id constraints exist on key tables
        Integer tenantConstraintCount = jdbcTemplate.queryForObject(
            """
            SELECT COUNT(*) FROM information_schema.table_constraints tc
            JOIN information_schema.constraint_column_usage ccu 
            ON tc.constraint_name = ccu.constraint_name
            WHERE tc.table_name = 'tenants' 
            AND tc.constraint_type = 'PRIMARY KEY'
            AND ccu.column_name = 'tenant_id'
            """,
            Integer.class
        );
        
        assertThat(tenantConstraintCount)
            .as("Tenants table should have tenant_id primary key constraint")
            .isEqualTo(1);

        // Verify schema_name uniqueness (important for tenant isolation)
        Integer schemaNameConstraintCount = jdbcTemplate.queryForObject(
            """
            SELECT COUNT(*) FROM information_schema.table_constraints tc
            JOIN information_schema.constraint_column_usage ccu 
            ON tc.constraint_name = ccu.constraint_name
            WHERE tc.table_name = 'tenants' 
            AND tc.constraint_type = 'UNIQUE'
            AND ccu.column_name = 'schema_name'
            """,
            Integer.class
        );
        
        assertThat(schemaNameConstraintCount)
            .as("Tenants table should have unique constraint on schema_name")
            .isGreaterThanOrEqualTo(1);
    }
}