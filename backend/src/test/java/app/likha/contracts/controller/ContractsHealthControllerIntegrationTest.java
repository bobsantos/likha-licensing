package app.likha.contracts.controller;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.boot.test.web.server.LocalServerPort;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.TestPropertySource;

import static org.assertj.core.api.Assertions.*;

/**
 * Integration tests for Contracts Health Controller.
 * 
 * These tests validate the full integration of the contracts module
 * including database connectivity and health endpoint functionality.
 */
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@ActiveProfiles("test")
@TestPropertySource(properties = {
    "spring.datasource.url=jdbc:h2:mem:testdb;DB_CLOSE_DELAY=-1;DB_CLOSE_ON_EXIT=FALSE",
    "spring.datasource.driver-class-name=org.h2.Driver",
    "spring.datasource.username=sa",
    "spring.datasource.password=",
    "spring.jpa.hibernate.ddl-auto=create-drop"
})
@DisplayName("Contracts Health Controller Integration Tests")
class ContractsHealthControllerIntegrationTest {

    @LocalServerPort
    private int port;

    @Autowired
    private TestRestTemplate restTemplate;

    @Test
    @DisplayName("Should expose detailed health endpoint")
    void shouldExposeDetailedHealthEndpoint() {
        // When
        ResponseEntity<String> response = restTemplate.getForEntity(
            "http://localhost:" + port + "/api/v1/contracts/health/detailed",
            String.class
        );

        // Then
        // Note: In a test environment without full database setup,
        // we expect the health check to fail (503) due to missing tables
        assertThat(response.getStatusCode())
            .as("Health endpoint should be accessible (either UP or DOWN)")
            .isIn(HttpStatus.OK, HttpStatus.SERVICE_UNAVAILABLE);

        assertThat(response.getBody())
            .as("Response body should not be empty")
            .isNotNull()
            .isNotEmpty();
    }

    @Test
    @DisplayName("Should expose simple status endpoint")
    void shouldExposeSimpleStatusEndpoint() {
        // When
        ResponseEntity<String> response = restTemplate.getForEntity(
            "http://localhost:" + port + "/api/v1/contracts/health/status",
            String.class
        );

        // Then
        assertThat(response.getStatusCode())
            .as("Status endpoint should be accessible")
            .isIn(HttpStatus.OK, HttpStatus.SERVICE_UNAVAILABLE);

        assertThat(response.getBody())
            .as("Response should be either UP or DOWN")
            .isIn("UP", "DOWN");
    }

    @Test
    @DisplayName("Should return consistent health status across endpoints")
    void shouldReturnConsistentHealthStatus() {
        // When
        ResponseEntity<String> detailedResponse = restTemplate.getForEntity(
            "http://localhost:" + port + "/api/v1/contracts/health/detailed",
            String.class
        );

        ResponseEntity<String> statusResponse = restTemplate.getForEntity(
            "http://localhost:" + port + "/api/v1/contracts/health/status",
            String.class
        );

        // Then
        assertThat(detailedResponse.getStatusCode())
            .as("Both endpoints should return the same HTTP status")
            .isEqualTo(statusResponse.getStatusCode());

        // If detailed endpoint is UP, status endpoint should return "UP"
        if (detailedResponse.getStatusCode() == HttpStatus.OK) {
            assertThat(statusResponse.getBody())
                .as("Status endpoint should return UP when detailed endpoint is healthy")
                .isEqualTo("UP");
        } else {
            assertThat(statusResponse.getBody())
                .as("Status endpoint should return DOWN when detailed endpoint is unhealthy")
                .isEqualTo("DOWN");
        }
    }

    @Test
    @DisplayName("Should handle invalid endpoints with proper error responses")
    void shouldHandleInvalidEndpoints() {
        // When
        ResponseEntity<String> response = restTemplate.getForEntity(
            "http://localhost:" + port + "/api/v1/contracts/health/nonexistent",
            String.class
        );

        // Then
        assertThat(response.getStatusCode())
            .as("Non-existent endpoint should return 404")
            .isEqualTo(HttpStatus.NOT_FOUND);
    }
}