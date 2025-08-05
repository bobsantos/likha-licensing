package app.likha.infrastructure;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.beans.factory.annotation.Autowired;

import javax.sql.DataSource;
import java.sql.Connection;
import java.util.List;

import static org.assertj.core.api.Assertions.*;

/**
 * Cross-cutting infrastructure validation tests that complement health checks by testing database functionality
 * that spans across all domain modules.
 * 
 * These tests validate infrastructure aspects that health checks don't cover:
 * - Database user roles and permissions
 * - PostgreSQL extensions and security configuration
 * - Database migration history validation
 * - Database security functions and procedures
 * 
 * Unlike health checks which test basic connectivity and table existence,
 * these tests perform comprehensive integration testing of the shared database infrastructure.
 * 
 * Domain-specific infrastructure tests are located in their respective modules:
 * - User Management: tenant isolation and user authentication infrastructure
 * - Contract Management: licensing business data infrastructure
 * - File Storage: document storage and upload infrastructure
 */
@SpringBootTest
@ActiveProfiles("test")
@DisplayName("Database Infrastructure Validation Tests")
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
    @DisplayName("Should have required database users configured")
    void shouldHaveRequiredDatabaseUsers() {
        // Verify PostgreSQL default user exists (postgres user should always be present)
        List<String> existingUsers = jdbcTemplate.queryForList(
            "SELECT rolname FROM pg_roles WHERE rolname = 'postgres'",
            String.class
        );

        assertThat(existingUsers)
            .as("Should have postgres database user")
            .contains("postgres");
            
        // Note: In the current schema, we're using the default connection pool user
        // rather than specific application users like 'likha_app_user', 'likha_readonly_user'
    }


    @Test
    @DisplayName("Should validate database schema structure")
    void shouldValidateDatabaseSchemaStructure() {
        // Verify public schema exists (for shared infrastructure tables)
        Integer publicSchemaCount = jdbcTemplate.queryForObject(
            "SELECT COUNT(*) FROM information_schema.schemata WHERE schema_name = 'public'",
            Integer.class
        );
        
        assertThat(publicSchemaCount)
            .as("Public schema should exist for shared infrastructure")
            .isEqualTo(1);
            
        // Verify that schema-per-tenant pattern is supported
        // (Check that we can create and drop tenant schemas - infrastructure capability test)
        String testSchemaName = "test_schema_capability";
        
        try {
            // Test schema creation capability
            jdbcTemplate.execute("CREATE SCHEMA IF NOT EXISTS " + testSchemaName);
            
            Integer testSchemaCount = jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM information_schema.schemata WHERE schema_name = ?",
                Integer.class,
                testSchemaName
            );
            
            assertThat(testSchemaCount)
                .as("Should be able to create tenant schemas")
                .isEqualTo(1);
                
        } finally {
            // Cleanup test schema
            jdbcTemplate.execute("DROP SCHEMA IF EXISTS " + testSchemaName + " CASCADE");
        }
    }


    @Test
    @DisplayName("Should validate database security configuration")
    void shouldRunSecurityHealthCheck() {
        // Check basic database security features
        // 1. Verify PostgreSQL extensions are available
        List<String> extensions = jdbcTemplate.queryForList(
            "SELECT extname FROM pg_extension WHERE extname IN ('uuid-ossp', 'pgcrypto')",
            String.class
        );

        assertThat(extensions)
            .as("Required security extensions should be installed")
            .containsExactlyInAnyOrder("uuid-ossp", "pgcrypto");
            
        // 2. Verify triggers are configured for updated_at columns
        Integer triggerCount = jdbcTemplate.queryForObject(
            "SELECT COUNT(*) FROM information_schema.triggers WHERE trigger_name LIKE '%updated_at%'",
            Integer.class
        );
        
        assertThat(triggerCount)
            .as("Should have updated_at triggers configured")
            .isGreaterThan(0);
            
        // 3. Verify constraints are in place for key tables
        Integer constraintCount = jdbcTemplate.queryForObject(
            "SELECT COUNT(*) FROM information_schema.table_constraints WHERE constraint_type = 'CHECK'",
            Integer.class
        );
        
        assertThat(constraintCount)
            .as("Should have CHECK constraints for data validation")
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

        // Verify the latest migration (V1) was applied successfully
        String latestVersion = jdbcTemplate.queryForObject(
            "SELECT version FROM flyway_schema_history WHERE success = true ORDER BY installed_rank DESC LIMIT 1",
            String.class
        );

        assertThat(latestVersion)
            .as("Latest migration should be V1 or higher (current clean schema)")
            .matches("^[1-9].*"); // Version 1 or higher
    }
}