package app.likha.config;

import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.boot.autoconfigure.flyway.FlywayMigrationStrategy;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.annotation.Order;

/**
 * Database configuration to ensure proper initialization order.
 * 
 * This configuration ensures that:
 * 1. Flyway runs first to create database schema and tables
 * 2. JPA/Hibernate EntityManagerFactory is initialized after Flyway completes
 * 3. Spring Modulith event store can find the event_publication table
 */
@Configuration
@Order(1) // Ensure this configuration runs early
public class DatabaseConfiguration {

    /**
     * Custom Flyway migration strategy to ensure proper initialization order.
     * This bean is created early in the Spring Boot lifecycle.
     */
    @Bean
    @ConditionalOnProperty(name = "spring.flyway.enabled", havingValue = "true", matchIfMissing = true)
    public FlywayMigrationStrategy flywayMigrationStrategy() {
        return flyway -> {
            // Clean and migrate for development environments
            // In production, you might want to avoid clean()
            flyway.migrate();
        };
    }
}