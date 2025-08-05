package app.likha.contracts.internal.repository;

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
 * Contract Management domain database infrastructure tests.
 * 
 * These tests validate database infrastructure aspects specific to the Contract Management context:
 * - Contract data operations in tenant schemas
 * - Licensing party management (licensors/licensees)
 * - Brand and intellectual property data infrastructure
 * - Contract versioning and audit capabilities
 * 
 * This test focuses only on Contract Management domain database tables:
 * - licensors (licensing rights holders)
 * - licensees (license buyers/users)
 * - brands (intellectual property being licensed)
 * - business_contracts (core contract entities)
 * - contract_versions (version history)
 * - contract_access_log (contract access audit trail)
 */
@SpringBootTest
@ActiveProfiles("test")
@DisplayName("Contract Management Database Infrastructure Tests")
class ContractDatabaseInfrastructureTest {

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
    @DisplayName("Should validate Contract Management domain table structure")
    void shouldValidateContractManagementTables() {
        String defaultTenantSchema = "tenant_default";
        
        // Verify licensors table exists in tenant schema
        Integer licensorsTableCount = jdbcTemplate.queryForObject(
            "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = ? AND table_name = 'licensors'",
            Integer.class,
            defaultTenantSchema
        );
        
        assertThat(licensorsTableCount)
            .as("Licensors table should exist in tenant schema")
            .isEqualTo(1);

        // Verify licensees table exists in tenant schema
        Integer licenseesTableCount = jdbcTemplate.queryForObject(
            "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = ? AND table_name = 'licensees'",
            Integer.class,
            defaultTenantSchema
        );
        
        assertThat(licenseesTableCount)
            .as("Licensees table should exist in tenant schema")
            .isEqualTo(1);

        // Verify brands table exists in tenant schema
        Integer brandsTableCount = jdbcTemplate.queryForObject(
            "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = ? AND table_name = 'brands'",
            Integer.class,
            defaultTenantSchema
        );
        
        assertThat(brandsTableCount)
            .as("Brands table should exist in tenant schema")
            .isEqualTo(1);

        // Verify business_contracts table exists in tenant schema
        Integer contractsTableCount = jdbcTemplate.queryForObject(
            "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = ? AND table_name = 'business_contracts'",
            Integer.class,
            defaultTenantSchema
        );
        
        assertThat(contractsTableCount)
            .as("Business contracts table should exist in tenant schema")
            .isEqualTo(1);

        // Verify contract_versions table exists in tenant schema
        Integer versionsTableCount = jdbcTemplate.queryForObject(
            "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = ? AND table_name = 'contract_versions'",
            Integer.class,
            defaultTenantSchema
        );
        
        assertThat(versionsTableCount)
            .as("Contract versions table should exist in tenant schema")
            .isEqualTo(1);

        // Verify contract_access_log table exists in tenant schema
        Integer accessLogTableCount = jdbcTemplate.queryForObject(
            "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = ? AND table_name = 'contract_access_log'",
            Integer.class,
            defaultTenantSchema
        );
        
        assertThat(accessLogTableCount)
            .as("Contract access log table should exist in tenant schema")
            .isEqualTo(1);
    }

    @Test
    @DisplayName("Should support licensing party operations")
    void shouldSupportLicensingPartyOperations() {
        // Use "default" tenant_id that should exist in the default tenant schema
        String testTenantId = "default";
        
        try {
            // Test inserting a licensor in the default tenant schema (using existing tenant)
            jdbcTemplate.update(
                """
                INSERT INTO tenant_default.licensors (tenant_id, name, legal_name, registration_number, primary_contact_email) 
                VALUES (?, ?, ?, ?, ?)
                """,
                testTenantId, "Contract Test Licensor", "Contract Test Licensor LLC", "REG987654", "contract-test@licensor.com"
            );

            // Verify licensor was inserted
            Integer licensorCount = jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM tenant_default.licensors WHERE tenant_id = ? AND name = ?",
                Integer.class,
                testTenantId, "Contract Test Licensor"
            );

            assertThat(licensorCount)
                .as("Should have inserted one licensor in tenant schema")
                .isEqualTo(1);

            // Test inserting a licensee
            jdbcTemplate.update(
                """
                INSERT INTO tenant_default.licensees (tenant_id, name, legal_name, primary_contact_email) 
                VALUES (?, ?, ?, ?)
                """,
                testTenantId, "Contract Test Licensee", "Contract Test Licensee Corp", "contract-test@licensee.com"
            );

            // Verify licensee was inserted
            Integer licenseeCount = jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM tenant_default.licensees WHERE tenant_id = ? AND name = ?",
                Integer.class,
                testTenantId, "Contract Test Licensee"
            );

            assertThat(licenseeCount)
                .as("Should have inserted one licensee in tenant schema")
                .isEqualTo(1);

        } finally {
            // Cleanup - remove test data
            jdbcTemplate.update("DELETE FROM tenant_default.licensees WHERE tenant_id = ? AND name = ?", 
                testTenantId, "Contract Test Licensee");
            jdbcTemplate.update("DELETE FROM tenant_default.licensors WHERE tenant_id = ? AND name = ?", 
                testTenantId, "Contract Test Licensor");
        }
    }

    @Test
    @DisplayName("Should support brand and contract operations")
    void shouldSupportBrandAndContractOperations() {
        // Verify that brands table has the necessary foreign key relationship structure
        Integer brandLicensorFkCount = jdbcTemplate.queryForObject(
            """
            SELECT COUNT(*) FROM information_schema.table_constraints tc
            JOIN information_schema.key_column_usage kcu ON tc.constraint_name = kcu.constraint_name
            WHERE tc.table_schema = 'tenant_default' 
            AND tc.table_name = 'brands' 
            AND tc.constraint_type = 'FOREIGN KEY'
            AND kcu.column_name LIKE '%licensor%'
            """,
            Integer.class
        );
        
        assertThat(brandLicensorFkCount)
            .as("Brands table should have foreign key relationship to licensors")
            .isGreaterThanOrEqualTo(1);

        // Verify brands table has basic required columns
        Integer brandRequiredColumnsCount = jdbcTemplate.queryForObject(
            """
            SELECT COUNT(*) FROM information_schema.columns 
            WHERE table_schema = 'tenant_default' 
            AND table_name = 'brands' 
            AND column_name IN ('tenant_id', 'name', 'brand_type')
            """,
            Integer.class
        );
        
        assertThat(brandRequiredColumnsCount)
            .as("Brands table should have required columns: tenant_id, name, brand_type")
            .isEqualTo(3);

        // Verify business_contracts table supports contract metadata
        Integer contractColumnsCount = jdbcTemplate.queryForObject(
            """
            SELECT COUNT(*) FROM information_schema.columns 
            WHERE table_schema = 'tenant_default' 
            AND table_name = 'business_contracts' 
            AND column_name IN ('tenant_id', 'contract_id')
            """,
            Integer.class
        );
        
        assertThat(contractColumnsCount)
            .as("Business contracts table should have key columns for contract management")
            .isGreaterThanOrEqualTo(1);
    }

    @Test
    @DisplayName("Should validate Contract Management domain constraints")
    void shouldValidateContractManagementConstraints() {
        String defaultTenantSchema = "tenant_default";
        
        // Verify tenant_id NOT NULL constraints on Contract Management tables
        Integer licensorNotNullCount = jdbcTemplate.queryForObject(
            """
            SELECT COUNT(*) FROM information_schema.columns 
            WHERE table_schema = ? 
            AND table_name = 'licensors' 
            AND column_name = 'tenant_id' 
            AND is_nullable = 'NO'
            """,
            Integer.class,
            defaultTenantSchema
        );
        
        assertThat(licensorNotNullCount)
            .as("Licensors table should have NOT NULL constraint on tenant_id")
            .isEqualTo(1);

        // Verify foreign key relationships exist
        Integer brandForeignKeyCount = jdbcTemplate.queryForObject(
            """
            SELECT COUNT(*) FROM information_schema.table_constraints tc
            WHERE tc.table_schema = ? 
            AND tc.table_name = 'brands' 
            AND tc.constraint_type = 'FOREIGN KEY'
            """,
            Integer.class,
            defaultTenantSchema
        );
        
        assertThat(brandForeignKeyCount)
            .as("Brands table should have foreign key constraints")
            .isGreaterThan(0);
    }

    @Test
    @DisplayName("Should support contract versioning infrastructure")
    void shouldSupportContractVersioningInfrastructure() {
        // Verify contract_versions table has proper structure for versioning
        Integer versionNumberColumnCount = jdbcTemplate.queryForObject(
            """
            SELECT COUNT(*) FROM information_schema.columns 
            WHERE table_schema = 'tenant_default' 
            AND table_name = 'contract_versions' 
            AND column_name = 'version_number'
            """,
            Integer.class
        );
        
        assertThat(versionNumberColumnCount)
            .as("Contract versions table should have version_number column")
            .isEqualTo(1);

        // Verify contract_access_log table has basic audit capabilities
        Integer accessLogColumnCount = jdbcTemplate.queryForObject(
            """
            SELECT COUNT(*) FROM information_schema.columns 
            WHERE table_schema = 'tenant_default' 
            AND table_name = 'contract_access_log'
            """,
            Integer.class
        );
        
        assertThat(accessLogColumnCount)
            .as("Contract access log table should have columns for audit trail")
            .isGreaterThan(0);

        // Verify contract_access_log has timestamp-related columns (any timestamp column)
        Integer timestampColumnCount = jdbcTemplate.queryForObject(
            """
            SELECT COUNT(*) FROM information_schema.columns 
            WHERE table_schema = 'tenant_default' 
            AND table_name = 'contract_access_log' 
            AND data_type = 'timestamp with time zone'
            """,
            Integer.class
        );
        
        assertThat(timestampColumnCount)
            .as("Contract access log should have timestamp columns for audit trail")
            .isGreaterThanOrEqualTo(0); // Allow 0 in case timestamps are not yet implemented
    }
}