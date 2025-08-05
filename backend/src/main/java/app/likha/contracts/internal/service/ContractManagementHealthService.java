package app.likha.contracts.internal.service;

import org.springframework.boot.actuate.health.Health;
import org.springframework.boot.actuate.health.HealthIndicator;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.dao.DataAccessException;

import java.util.ArrayList;
import java.util.List;

/**
 * Internal service for Contract Management health validation.
 * 
 * Validates that all required contract management tables exist and are accessible,
 * including proper multi-tenant configuration with Row Level Security.
 * 
 * This service ensures the contract management bounded context is ready
 * for operation and all database infrastructure is properly configured.
 * 
 * Following Spring Modulith principles, this service is internal to the contracts module
 * and should only be accessed through the public API (controller layer).
 */
@Service
public class ContractManagementHealthService implements HealthIndicator {

    private final JdbcTemplate jdbcTemplate;

    // Required contract management tables that must exist and be accessible
    private static final String[] REQUIRED_TABLES = {
        "licensors", "licensees", "brands", "business_contracts", "contract_versions", "contract_access_log"
    };

    // Tables that must have Row Level Security enabled
    private static final String[] RLS_REQUIRED_TABLES = {
        "licensors", "licensees", "brands", "business_contracts", "contract_versions", "contract_access_log"
    };

    public ContractManagementHealthService(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @Override
    public Health health() {
        long startTime = System.currentTimeMillis();
        
        try {
            // Validate table existence
            List<String> missingTables = validateTableExistence();
            if (!missingTables.isEmpty()) {
                return Health.down()
                    .withDetail("error", "Contract management schema validation failed")
                    .withDetail("missing_tables", missingTables)
                    .withDetail("validation_time", System.currentTimeMillis() - startTime)
                    .build();
            }

            // Validate Row Level Security
            List<String> rlsFailures = validateRowLevelSecurity();
            if (!rlsFailures.isEmpty()) {
                return Health.down()
                    .withDetail("error", "Row Level Security validation failed")
                    .withDetail("rls_validation_failed", rlsFailures)
                    .withDetail("validation_time", System.currentTimeMillis() - startTime)
                    .build();
            }

            // Validate tenant isolation function
            boolean tenantFunctionAvailable = validateTenantIsolationFunction();
            if (!tenantFunctionAvailable) {
                return Health.down()
                    .withDetail("error", "Tenant isolation function validation failed")
                    .withDetail("tenant_function_validated", false)
                    .withDetail("validation_time", System.currentTimeMillis() - startTime)
                    .build();
            }

            // All validations passed
            return Health.up()
                .withDetail("tables_validated", REQUIRED_TABLES.length)
                .withDetail("rls_validated", RLS_REQUIRED_TABLES.length)
                .withDetail("tenant_function_validated", true)
                .withDetail("validation_time", System.currentTimeMillis() - startTime)
                .build();

        } catch (DataAccessException e) {
            return Health.down()
                .withDetail("error", "Database access failed during contract schema validation")
                .withDetail("exception", e.getMessage())
                .withDetail("validation_time", System.currentTimeMillis() - startTime)
                .build();
        } catch (Exception e) {
            return Health.down()
                .withDetail("error", "Unexpected error during contract schema validation")
                .withDetail("exception", e.getMessage())
                .withDetail("validation_time", System.currentTimeMillis() - startTime)
                .build();
        }
    }

    /**
     * Validates that all required contract management tables exist.
     * 
     * @return List of missing table names, empty if all tables exist
     */
    private List<String> validateTableExistence() {
        List<String> missingTables = new ArrayList<>();
        
        for (String tableName : REQUIRED_TABLES) {
            Integer tableCount = jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM information_schema.tables WHERE table_name = ? AND table_schema = 'public'",
                Integer.class,
                tableName
            );
            
            if (tableCount == null || tableCount == 0) {
                missingTables.add(tableName);
            }
        }
        
        return missingTables;
    }

    /**
     * Validates that Row Level Security is enabled on all tenant-scoped tables.
     * 
     * @return List of tables where RLS validation failed, empty if all pass
     */
    private List<String> validateRowLevelSecurity() {
        List<String> rlsFailures = new ArrayList<>();
        
        for (String tableName : RLS_REQUIRED_TABLES) {
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
            
            if (rlsEnabled == null || !rlsEnabled) {
                rlsFailures.add(tableName);
            }
        }
        
        return rlsFailures;
    }

    /**
     * Validates that the tenant isolation function is available and working.
     * 
     * @return true if the tenant function is available and working, false otherwise
     */
    private boolean validateTenantIsolationFunction() {
        try {
            // Check if the function exists
            Integer functionCount = jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM information_schema.routines WHERE routine_name = 'get_current_tenant_id'",
                Integer.class
            );
            
            if (functionCount == null || functionCount == 0) {
                return false;
            }

            // Test the function works
            String result = jdbcTemplate.queryForObject(
                "SELECT get_current_tenant_id()",
                String.class
            );
            
            // Function should return "invalid_tenant" when no tenant context is set
            return "invalid_tenant".equals(result);
            
        } catch (DataAccessException e) {
            return false;
        }
    }
}