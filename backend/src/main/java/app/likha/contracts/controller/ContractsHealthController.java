package app.likha.contracts.controller;

import app.likha.contracts.internal.service.ContractManagementHealthService;
import org.springframework.boot.actuate.health.Health;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * Public API controller for contract management health endpoints.
 * 
 * Following Spring Modulith architecture principles, this controller serves as the
 * public interface for the contracts module. Internal services should not be 
 * accessed directly from outside the module boundary.
 * 
 * This controller provides health check endpoints specifically for contract
 * management infrastructure validation.
 */
@RestController
@RequestMapping("/api/v1/contracts/health")
public class ContractsHealthController {

    private final ContractManagementHealthService healthService;

    public ContractsHealthController(ContractManagementHealthService healthService) {
        this.healthService = healthService;
    }

    /**
     * Get detailed health status for contract management infrastructure.
     * 
     * Validates database schema, table existence, Row Level Security configuration,
     * and tenant isolation functions specific to contract management.
     * 
     * @return ResponseEntity with health status and detailed validation results
     */
    @GetMapping("/detailed")
    public ResponseEntity<Health> getDetailedHealth() {
        try {
            Health health = healthService.health();
            
            // Return appropriate HTTP status based on health
            if (health.getStatus().getCode().equals("UP")) {
                return ResponseEntity.ok(health);
            } else {
                return ResponseEntity.status(503).body(health); // Service Unavailable
            }
        } catch (Exception e) {
            // Handle unexpected errors gracefully
            Health errorHealth = Health.down()
                .withDetail("error", "Health check service error")
                .withDetail("exception", e.getMessage())
                .build();
            return ResponseEntity.status(503).body(errorHealth);
        }
    }

    /**
     * Simple health check endpoint for contract management.
     * 
     * Returns minimal health information suitable for load balancer checks.
     * 
     * @return ResponseEntity with basic health status
     */
    @GetMapping("/status")
    public ResponseEntity<String> getHealthStatus() {
        try {
            Health health = healthService.health();
            
            if (health.getStatus().getCode().equals("UP")) {
                return ResponseEntity.ok("UP");
            } else {
                return ResponseEntity.status(503).body("DOWN");
            }
        } catch (Exception e) {
            // Handle unexpected errors gracefully
            return ResponseEntity.status(503).body("DOWN");
        }
    }
}