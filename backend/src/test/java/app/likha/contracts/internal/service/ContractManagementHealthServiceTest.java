package app.likha.contracts.internal.service;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.springframework.boot.actuate.health.Health;
import org.springframework.boot.actuate.health.Status;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.dao.DataAccessException;

import static org.assertj.core.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

@DisplayName("Contract Management Health Service Tests")
class ContractManagementHealthServiceTest {

    @Mock
    private JdbcTemplate jdbcTemplate;

    private ContractManagementHealthService healthService;

    @BeforeEach
    void setUp() {
        MockitoAnnotations.openMocks(this);
        healthService = new ContractManagementHealthService(jdbcTemplate);
    }

    @Test
    @DisplayName("Should return UP status when all contract tables are accessible")
    void shouldReturnUpWhenAllTablesAccessible() {
        // Given - all table existence queries return successfully
        when(jdbcTemplate.queryForObject(contains("information_schema.tables"), eq(Integer.class), anyString()))
            .thenReturn(1); // Each table exists
        
        // And RLS validation succeeds
        when(jdbcTemplate.queryForObject(contains("pg_class"), eq(Boolean.class), anyString()))
            .thenReturn(true);
        
        // And tenant function exists
        when(jdbcTemplate.queryForObject(contains("information_schema.routines"), eq(Integer.class)))
            .thenReturn(1);
        when(jdbcTemplate.queryForObject(eq("SELECT get_current_tenant_id()"), eq(String.class)))
            .thenReturn("invalid_tenant");

        // When
        Health health = healthService.health();

        // Then
        assertThat(health.getStatus())
            .as("Health status should be UP when all tables are accessible")
            .isEqualTo(Status.UP);

        assertThat(health.getDetails())
            .as("Should contain table validation details")
            .containsKeys("tables_validated", "rls_validated", "tenant_function_validated", "validation_time");

        assertThat(health.getDetails().get("tables_validated"))
            .as("Should validate expected number of tables")
            .isEqualTo(10); // Expected contract management tables

        // Verify all expected tables were checked
        verify(jdbcTemplate, times(10)).queryForObject(contains("information_schema.tables"), eq(Integer.class), anyString());
    }

    @Test
    @DisplayName("Should return DOWN status when contract tables are missing")
    void shouldReturnDownWhenTablesMissing() {
        // Given - some tables don't exist
        when(jdbcTemplate.queryForObject(contains("information_schema.tables"), eq(Integer.class), anyString()))
            .thenReturn(0); // Tables don't exist

        // When
        Health health = healthService.health();

        // Then
        assertThat(health.getStatus())
            .as("Health status should be DOWN when tables are missing")
            .isEqualTo(Status.DOWN);

        assertThat(health.getDetails())
            .as("Should contain error information")
            .containsKeys("error", "missing_tables", "validation_time");

        assertThat(health.getDetails().get("error"))
            .as("Should indicate missing tables")
            .isEqualTo("Contract management schema validation failed");
    }

    @Test
    @DisplayName("Should return DOWN status when database connection fails")
    void shouldReturnDownWhenDatabaseConnectionFails() {
        // Given - database connection fails
        when(jdbcTemplate.queryForObject(contains("information_schema.tables"), eq(Integer.class), anyString()))
            .thenThrow(new DataAccessException("Connection failed") {});

        // When
        Health health = healthService.health();

        // Then
        assertThat(health.getStatus())
            .as("Health status should be DOWN when database connection fails")
            .isEqualTo(Status.DOWN);

        assertThat(health.getDetails())
            .as("Should contain error information")
            .containsKeys("error", "exception", "validation_time");

        assertThat(health.getDetails().get("error"))
            .as("Should indicate database access failure")
            .isEqualTo("Database access failed during contract schema validation");

        assertThat(health.getDetails().get("exception"))
            .as("Should contain exception message")
            .isEqualTo("Connection failed");
    }

    @Test
    @DisplayName("Should validate all required contract management tables")
    void shouldValidateAllRequiredTables() {
        // Given - table existence queries succeed
        when(jdbcTemplate.queryForObject(contains("information_schema.tables"), eq(Integer.class), anyString()))
            .thenReturn(1);
        // And RLS validation succeeds
        when(jdbcTemplate.queryForObject(contains("pg_class"), eq(Boolean.class), anyString()))
            .thenReturn(true);
        // And tenant function exists and works
        when(jdbcTemplate.queryForObject(contains("information_schema.routines"), eq(Integer.class)))
            .thenReturn(1);
        when(jdbcTemplate.queryForObject(eq("SELECT get_current_tenant_id()"), eq(String.class)))
            .thenReturn("invalid_tenant");

        // When
        Health health = healthService.health();

        // Then - verify specific tables are being checked
        String[] expectedTables = {
            "tenants", "licensors", "licensees", "brands", "business_contracts",
            "contract_files", "contract_versions", "contract_access_log", 
            "upload_sessions", "security_audit_log"
        };

        for (String tableName : expectedTables) {
            verify(jdbcTemplate).queryForObject(
                contains("information_schema.tables"), 
                eq(Integer.class),
                eq(tableName)
            );
        }

        assertThat(health.getStatus())
            .as("Should be UP when all required tables are validated")
            .isEqualTo(Status.UP);
    }

    @Test
    @DisplayName("Should include Row Level Security validation")
    void shouldIncludeRowLevelSecurityValidation() {
        // Given - table existence queries succeed
        when(jdbcTemplate.queryForObject(contains("information_schema.tables"), eq(Integer.class), anyString()))
            .thenReturn(1);
        
        // And RLS validation succeeds
        when(jdbcTemplate.queryForObject(contains("pg_class"), eq(Boolean.class), anyString()))
            .thenReturn(true);
        
        // And tenant function exists and works
        when(jdbcTemplate.queryForObject(contains("information_schema.routines"), eq(Integer.class)))
            .thenReturn(1);
        when(jdbcTemplate.queryForObject(eq("SELECT get_current_tenant_id()"), eq(String.class)))
            .thenReturn("invalid_tenant");

        // When
        Health health = healthService.health();

        // Then
        assertThat(health.getStatus())
            .as("Health status should be UP when RLS is properly configured")
            .isEqualTo(Status.UP);

        assertThat(health.getDetails())
            .as("Should contain RLS validation details")
            .containsKey("rls_validated");

        // Verify RLS was checked for tenant tables
        verify(jdbcTemplate, atLeastOnce()).queryForObject(contains("pg_class"), eq(Boolean.class), anyString());
    }

    @Test
    @DisplayName("Should validate tenant isolation function availability")
    void shouldValidateTenantIsolationFunction() {
        // Given - table and RLS validations pass
        when(jdbcTemplate.queryForObject(contains("information_schema.tables"), eq(Integer.class), anyString()))
            .thenReturn(1);
        when(jdbcTemplate.queryForObject(contains("pg_class"), eq(Boolean.class), anyString()))
            .thenReturn(true);
        
        // And tenant function exists
        when(jdbcTemplate.queryForObject(contains("information_schema.routines"), eq(Integer.class)))
            .thenReturn(1);
        when(jdbcTemplate.queryForObject(eq("SELECT get_current_tenant_id()"), eq(String.class)))
            .thenReturn("invalid_tenant");

        // When
        Health health = healthService.health();

        // Then
        assertThat(health.getStatus())
            .as("Health status should be UP when tenant function is available")
            .isEqualTo(Status.UP);

        assertThat(health.getDetails())
            .as("Should contain tenant function validation")
            .containsKey("tenant_function_validated");

        // Verify tenant function was tested
        verify(jdbcTemplate).queryForObject(eq("SELECT get_current_tenant_id()"), eq(String.class));
    }

    @Test
    @DisplayName("Should handle partial validation failures gracefully")
    void shouldHandlePartialValidationFailures() {
        // Given - table validation succeeds but RLS validation fails
        when(jdbcTemplate.queryForObject(contains("information_schema.tables"), eq(Integer.class), anyString()))
            .thenReturn(1);
        when(jdbcTemplate.queryForObject(contains("pg_class"), eq(Boolean.class), anyString()))
            .thenReturn(false); // RLS not enabled

        // When
        Health health = healthService.health();

        // Then
        assertThat(health.getStatus())
            .as("Health status should be DOWN when RLS validation fails")
            .isEqualTo(Status.DOWN);

        assertThat(health.getDetails())
            .as("Should contain specific validation failure information")
            .containsKey("rls_validation_failed");
    }

    @Test
    @DisplayName("Should include validation timing in health details")
    void shouldIncludeValidationTiming() {
        // Given - table existence queries succeed
        when(jdbcTemplate.queryForObject(contains("information_schema.tables"), eq(Integer.class), anyString()))
            .thenReturn(1);
        // And RLS validation succeeds
        when(jdbcTemplate.queryForObject(contains("pg_class"), eq(Boolean.class), anyString()))
            .thenReturn(true);
        // And tenant function exists and works
        when(jdbcTemplate.queryForObject(contains("information_schema.routines"), eq(Integer.class)))
            .thenReturn(1);
        when(jdbcTemplate.queryForObject(eq("SELECT get_current_tenant_id()"), eq(String.class)))
            .thenReturn("invalid_tenant");

        // When
        Health health = healthService.health();

        // Then
        assertThat(health.getDetails())
            .as("Should include validation timing")
            .containsKey("validation_time");

        Object validationTime = health.getDetails().get("validation_time");
        assertThat(validationTime)
            .as("Validation time should be a number")
            .isInstanceOf(Number.class);

        assertThat(((Number) validationTime).longValue())
            .as("Validation time should be positive")
            .isPositive();
    }
}