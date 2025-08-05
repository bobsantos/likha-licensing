package app.likha.contracts.controller;

import app.likha.contracts.internal.service.ContractManagementHealthService;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.actuate.health.Health;
import org.springframework.boot.actuate.health.Status;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.web.servlet.MockMvc;

import java.util.Map;

import static org.assertj.core.api.Assertions.*;
import static org.mockito.Mockito.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest(ContractsHealthController.class)
@DisplayName("Contracts Health Controller Tests")
class ContractsHealthControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @MockBean
    private ContractManagementHealthService healthService;

    @Test
    @WithMockUser
    @DisplayName("GET /api/v1/contracts/health/detailed should return 200 when health is UP")
    void shouldReturn200WhenHealthIsUp() throws Exception {
        // Given
        Health upHealth = Health.up()
            .withDetail("tables_validated", 10)
            .withDetail("rls_validated", 10)
            .withDetail("tenant_function_validated", true)
            .withDetail("validation_time", 150L)
            .build();
        
        when(healthService.health()).thenReturn(upHealth);

        // When & Then
        String responseContent = mockMvc.perform(get("/api/v1/contracts/health/detailed"))
            .andExpect(status().isOk())
            .andExpect(content().contentType("application/json"))
            .andReturn()
            .getResponse()
            .getContentAsString();

        // Parse and validate response content
        Map<String, Object> response = objectMapper.readValue(responseContent, new TypeReference<Map<String, Object>>(){});
        
        assertThat(response)
            .as("Response should contain health status and details")
            .containsKeys("status", "details");

        assertThat(response.get("status"))
            .as("Status should be UP")
            .isEqualTo("UP");

        @SuppressWarnings("unchecked")
        Map<String, Object> details = (Map<String, Object>) response.get("details");
        assertThat(details)
            .as("Details should contain validation results")
            .containsKeys("tables_validated", "rls_validated", "tenant_function_validated", "validation_time");

        verify(healthService).health();
    }

    @Test
    @WithMockUser
    @DisplayName("GET /api/v1/contracts/health/detailed should return 503 when health is DOWN")
    void shouldReturn503WhenHealthIsDown() throws Exception {
        // Given
        Health downHealth = Health.down()
            .withDetail("error", "Contract management schema validation failed")
            .withDetail("missing_tables", java.util.List.of("tenants", "licensors"))
            .withDetail("validation_time", 75L)
            .build();
        
        when(healthService.health()).thenReturn(downHealth);

        // When & Then
        String responseContent = mockMvc.perform(get("/api/v1/contracts/health/detailed"))
            .andExpect(status().isServiceUnavailable())
            .andExpect(content().contentType("application/json"))
            .andReturn()
            .getResponse()
            .getContentAsString();

        // Parse and validate response content
        Map<String, Object> response = objectMapper.readValue(responseContent, new TypeReference<Map<String, Object>>(){});
        
        assertThat(response)
            .as("Response should contain health status and details")
            .containsKeys("status", "details");

        assertThat(response.get("status"))
            .as("Status should be DOWN")
            .isEqualTo("DOWN");

        @SuppressWarnings("unchecked")
        Map<String, Object> details = (Map<String, Object>) response.get("details");
        assertThat(details)
            .as("Details should contain error information")
            .containsKeys("error", "missing_tables", "validation_time");

        verify(healthService).health();
    }

    @Test
    @WithMockUser
    @DisplayName("GET /api/v1/contracts/health/status should return 200 with UP when health is good")
    void shouldReturnUpStatusWhenHealthIsGood() throws Exception {
        // Given
        Health upHealth = Health.up().build();
        when(healthService.health()).thenReturn(upHealth);

        // When & Then
        mockMvc.perform(get("/api/v1/contracts/health/status"))
            .andExpect(status().isOk())
            .andExpect(content().string("UP"));

        verify(healthService).health();
    }

    @Test
    @WithMockUser
    @DisplayName("GET /api/v1/contracts/health/status should return 503 with DOWN when health is bad")
    void shouldReturnDownStatusWhenHealthIsBad() throws Exception {
        // Given
        Health downHealth = Health.down()
            .withDetail("error", "Database connection failed")
            .build();
        when(healthService.health()).thenReturn(downHealth);

        // When & Then
        mockMvc.perform(get("/api/v1/contracts/health/status"))
            .andExpect(status().isServiceUnavailable())
            .andExpect(content().string("DOWN"));

        verify(healthService).health();
    }

    @Test
    @WithMockUser
    @DisplayName("Should handle unknown health status gracefully")
    void shouldHandleUnknownHealthStatusGracefully() throws Exception {
        // Given - health with UNKNOWN status
        Health unknownHealth = Health.status(Status.UNKNOWN)
            .withDetail("error", "Health status could not be determined")
            .build();
        when(healthService.health()).thenReturn(unknownHealth);

        // When & Then - UNKNOWN status should be treated as not UP (503)
        mockMvc.perform(get("/api/v1/contracts/health/detailed"))
            .andExpect(status().isServiceUnavailable());

        mockMvc.perform(get("/api/v1/contracts/health/status"))
            .andExpect(status().isServiceUnavailable())
            .andExpect(content().string("DOWN"));

        verify(healthService, times(2)).health();
    }

    @Test
    @WithMockUser
    @DisplayName("Should handle service exceptions gracefully")
    void shouldHandleServiceExceptionsGracefully() throws Exception {
        // Given - service throws exception
        when(healthService.health()).thenThrow(new RuntimeException("Service temporarily unavailable"));

        // When & Then - controller should handle exceptions appropriately
        mockMvc.perform(get("/api/v1/contracts/health/detailed"))
            .andExpect(status().isServiceUnavailable());

        mockMvc.perform(get("/api/v1/contracts/health/status"))
            .andExpect(status().isServiceUnavailable())
            .andExpect(content().string("DOWN"));

        verify(healthService, times(2)).health();
    }
}