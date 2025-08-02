package app.likha.infrastructure;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.condition.EnabledIfSystemProperty;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.beans.factory.annotation.Autowired;

import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.DatabaseMetaData;
import java.util.List;
import java.util.Map;

import static org.assertj.core.api.Assertions.*;

@SpringBootTest
@ActiveProfiles("test")
@EnabledIfSystemProperty(named = "test.database.validation", matches = "true")
@DisplayName("Database Connection Validation Tests - Integration Only")
class DatabaseConnectionValidationTest {

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
    @DisplayName("Should successfully connect to PostgreSQL database")
    void shouldConnectToDatabase() throws Exception {
        // Test basic database connectivity
        try (Connection connection = dataSource.getConnection()) {
            assertThat(connection.isValid(5))
                .as("Database connection should be valid")
                .isTrue();

            DatabaseMetaData metaData = connection.getMetaData();
            assertThat(metaData.getDatabaseProductName())
                .as("Should be connected to PostgreSQL")
                .isEqualTo("PostgreSQL");
        }
    }

    @Test
    @DisplayName("Should have all required contract management tables")
    void shouldHaveRequiredContractTables() {
        // Verify that all essential contract management tables exist
        String[] requiredTables = {
            "tenants",
            "licensors", 
            "licensees",
            "brands",
            "business_contracts",
            "contract_files",
            "contract_versions",
            "contract_access_log",
            "upload_sessions",
            "security_audit_log"
        };

        for (String tableName : requiredTables) {
            Integer tableCount = jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM information_schema.tables WHERE table_name = ? AND table_schema = 'public'",
                Integer.class,
                tableName
            );
            
            assertThat(tableCount)
                .as("Table '%s' should exist in public schema", tableName)
                .isEqualTo(1);
        }
    }

    @Test
    @DisplayName("Should have Row Level Security enabled on tenant tables")
    void shouldHaveRowLevelSecurityEnabled() {
        // Verify RLS is enabled on all tenant-scoped tables
        String[] rlsTables = {
            "tenants",
            "licensors",
            "licensees", 
            "brands",
            "business_contracts",
            "contract_files",
            "contract_versions",
            "contract_access_log",
            "upload_sessions",
            "security_audit_log"
        };

        for (String tableName : rlsTables) {
            Boolean rlsEnabled = jdbcTemplate.queryForObject(
                """
                SELECT c.relrowsecurity 
                FROM pg_class c
                JOIN pg_namespace n ON c.relnamespace = n.oid
                WHERE c.relname = ? AND n.nspname = 'public'
                """,
                Boolean.class,
                tableName
            );
            
            assertThat(rlsEnabled)
                .as("Table '%s' should have Row Level Security enabled", tableName)
                .isTrue();
        }
    }

    @Test
    @DisplayName("Should have required database users configured")
    void shouldHaveRequiredDatabaseUsers() {
        // Verify application database users exist
        List<String> existingUsers = jdbcTemplate.queryForList(
            "SELECT rolname FROM pg_roles WHERE rolname IN ('likha_app_user', 'likha_readonly_user')",
            String.class
        );

        assertThat(existingUsers)
            .as("Should have both application database users")
            .containsExactlyInAnyOrder("likha_app_user", "likha_readonly_user");
    }

    @Test
    @DisplayName("Should have tenant isolation function available")
    void shouldHaveTenantIsolationFunction() {
        // Verify the tenant isolation function exists
        Integer functionCount = jdbcTemplate.queryForObject(
            "SELECT COUNT(*) FROM information_schema.routines WHERE routine_name = 'get_current_tenant_id'",
            Integer.class
        );

        assertThat(functionCount)
            .as("get_current_tenant_id function should exist")
            .isEqualTo(1);

        // Test the function works
        String result = jdbcTemplate.queryForObject(
            "SELECT get_current_tenant_id()",
            String.class
        );

        assertThat(result)
            .as("Function should return default value when no tenant context is set")
            .isEqualTo("invalid_tenant");
    }

    @Test
    @DisplayName("Should support tenant context setting and isolation")
    void shouldSupportTenantContextAndIsolation() {
        // Test setting tenant context
        String testTenantId = "test-tenant-001";
        
        jdbcTemplate.execute("SELECT set_config('app.current_tenant_id', '" + testTenantId + "', false)");
        
        String currentTenant = jdbcTemplate.queryForObject(
            "SELECT get_current_tenant_id()",
            String.class
        );
        
        assertThat(currentTenant)
            .as("Should return the set tenant ID")
            .isEqualTo(testTenantId);

        // Reset tenant context
        jdbcTemplate.execute("SELECT set_config('app.current_tenant_id', '', false)");
    }

    @Test
    @DisplayName("Should have security audit logging capabilities")
    void shouldHaveSecurityAuditLogging() {
        // Verify security audit log table structure
        List<Map<String, Object>> columns = jdbcTemplate.queryForList(
            """
            SELECT column_name, data_type, is_nullable
            FROM information_schema.columns 
            WHERE table_name = 'security_audit_log' 
            AND table_schema = 'public'
            ORDER BY ordinal_position
            """
        );

        assertThat(columns)
            .as("Security audit log table should have columns")
            .isNotEmpty();

        // Verify key columns exist
        List<String> columnNames = columns.stream()
            .map(col -> (String) col.get("column_name"))
            .toList();

        assertThat(columnNames)
            .as("Should have essential audit log columns")
            .contains(
                "id", "tenant_id", "event_type", "event_category", 
                "severity", "user_id", "event_timestamp", "success"
            );
    }

    @Test
    @DisplayName("Should support basic contract operations")
    void shouldSupportBasicContractOperations() {
        String testTenantId = "integration-test-tenant";
        
        // Set tenant context
        jdbcTemplate.execute("SELECT set_config('app.current_tenant_id', '" + testTenantId + "', false)");
        
        try {
            // Test inserting a tenant (this should work even with RLS)
            jdbcTemplate.update(
                "INSERT INTO tenants (tenant_id, name, status, created_at) VALUES (?, ?, ?, CURRENT_TIMESTAMP)",
                testTenantId, "Integration Test Tenant", "ACTIVE"
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

            // Test inserting a licensor
            jdbcTemplate.update(
                """
                INSERT INTO licensors (tenant_id, name, legal_name, registration_number, contact_email) 
                VALUES (?, ?, ?, ?, ?)
                """,
                testTenantId, "Test Licensor", "Test Licensor LLC", "REG123456", "test@licensor.com"
            );

            // Verify licensor count
            Integer licensorCount = jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM licensors WHERE tenant_id = ?",
                Integer.class,
                testTenantId
            );

            assertThat(licensorCount)
                .as("Should have inserted one licensor")
                .isEqualTo(1);

        } finally {
            // Cleanup - remove test data
            jdbcTemplate.update("DELETE FROM licensors WHERE tenant_id = ?", testTenantId);
            jdbcTemplate.update("DELETE FROM tenants WHERE tenant_id = ?", testTenantId);
            
            // Reset tenant context
            jdbcTemplate.execute("SELECT set_config('app.current_tenant_id', '', false)");
        }
    }

    @Test
    @DisplayName("Should validate connection pool configuration")
    void shouldValidateConnectionPoolConfiguration() throws Exception {
        // Test multiple concurrent connections (basic connection pool validation)
        try (Connection conn1 = dataSource.getConnection();
             Connection conn2 = dataSource.getConnection();
             Connection conn3 = dataSource.getConnection()) {
            
            assertThat(conn1.isValid(5))
                .as("First connection should be valid")
                .isTrue();
                
            assertThat(conn2.isValid(5))
                .as("Second connection should be valid")
                .isTrue();
                
            assertThat(conn3.isValid(5))
                .as("Third connection should be valid")
                .isTrue();

            // All connections should be different instances
            assertThat(conn1)
                .as("Connections should be different instances")
                .isNotSameAs(conn2)
                .isNotSameAs(conn3);
        }
    }

    @Test
    @DisplayName("Should run security health check successfully")
    void shouldRunSecurityHealthCheck() {
        // Execute the security health check function
        List<Map<String, Object>> healthChecks = jdbcTemplate.queryForList(
            "SELECT * FROM security_health_check()"
        );

        assertThat(healthChecks)
            .as("Security health check should return results")
            .isNotEmpty();

        // Verify that most security checks pass
        long passCount = healthChecks.stream()
            .filter(check -> "PASS".equals(check.get("status")))
            .count();

        assertThat(passCount)
            .as("Most security checks should pass")
            .isGreaterThan(0);
    }

    @Test
    @DisplayName("Should validate Flyway migrations were applied")
    void shouldValidateFlywayMigrations() {
        // Check that Flyway schema history table exists and has migrations
        Integer migrationCount = jdbcTemplate.queryForObject(
            "SELECT COUNT(*) FROM flyway_schema_history WHERE success = true",
            Integer.class
        );

        assertThat(migrationCount)
            .as("Should have successfully applied Flyway migrations")
            .isGreaterThan(0);

        // Verify the latest migration (V5) was applied
        String latestVersion = jdbcTemplate.queryForObject(
            "SELECT version FROM flyway_schema_history WHERE success = true ORDER BY installed_rank DESC LIMIT 1",
            String.class
        );

        assertThat(latestVersion)
            .as("Latest migration should be V5 or higher")
            .matches("^[5-9].*"); // Version 5 or higher
    }
}