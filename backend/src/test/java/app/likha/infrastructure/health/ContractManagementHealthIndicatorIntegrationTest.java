package app.likha.infrastructure.health;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.condition.EnabledIfSystemProperty;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.actuate.health.Health;
import org.springframework.boot.actuate.health.Status;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;

import static org.assertj.core.api.Assertions.*;

/**
 * Integration tests for ContractManagementHealthIndicator with real database.
 * 
 * These tests verify that the health indicator works correctly with the actual
 * Spring Boot application context and database infrastructure.
 */
@SpringBootTest
@ActiveProfiles("test")
@EnabledIfSystemProperty(named = "test.database.validation", matches = "true")
@DisplayName("Contract Management Health Indicator Integration Tests")
class ContractManagementHealthIndicatorIntegrationTest {

    @Autowired
    private ContractManagementHealthIndicator healthIndicator;

    @Test
    @DisplayName("Should return UP status when contract management schema is properly configured")
    void shouldReturnUpWhenSchemaIsProperlyConfigured() {
        // When
        Health health = healthIndicator.health();

        // Then
        assertThat(health.getStatus())
            .as("Health status should be UP when contract schema is properly configured")
            .isEqualTo(Status.UP);

        assertThat(health.getDetails())
            .as("Should contain validation details")
            .containsKeys("tables_validated", "rls_validated", "tenant_function_validated", "validation_time");

        assertThat(health.getDetails().get("tables_validated"))
            .as("Should validate expected number of contract tables")
            .isEqualTo(10);

        assertThat(health.getDetails().get("rls_validated"))
            .as("Should validate RLS on expected number of tables")
            .isEqualTo(10);

        assertThat(health.getDetails().get("tenant_function_validated"))
            .as("Should validate tenant isolation function")
            .isEqualTo(true);

        Object validationTime = health.getDetails().get("validation_time");
        assertThat(validationTime)
            .as("Should include validation timing")
            .isInstanceOf(Number.class);

        assertThat(((Number) validationTime).longValue())
            .as("Validation time should be positive")
            .isPositive();
    }

    @Test
    @DisplayName("Should have health indicator registered in Spring context")
    void shouldHaveHealthIndicatorRegisteredInSpringContext() {
        // Then
        assertThat(healthIndicator)
            .as("Health indicator should be properly injected by Spring")
            .isNotNull()
            .isInstanceOf(ContractManagementHealthIndicator.class);
    }

    @Test
    @DisplayName("Should validate health indicator performs reasonable validation time")
    void shouldValidateReasonableValidationTime() {
        // When
        long startTime = System.currentTimeMillis();
        Health health = healthIndicator.health();
        long totalTime = System.currentTimeMillis() - startTime;

        // Then
        assertThat(totalTime)
            .as("Health check should complete within reasonable time (under 5 seconds)")
            .isLessThan(5000);

        Object validationTime = health.getDetails().get("validation_time");
        assertThat(((Number) validationTime).longValue())
            .as("Reported validation time should be close to actual time")
            .isLessThanOrEqualTo(totalTime);
    }
}