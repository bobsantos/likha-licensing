package app.likha;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableAsync;
import org.springframework.transaction.annotation.EnableTransactionManagement;

/**
 * Main application class for the Likha Licensing Platform.
 * 
 * This is a monolithic Spring Boot application that serves both:
 * - Backend REST APIs for licensing management
 * - Frontend React application (built assets served as static resources)
 */
@SpringBootApplication
@EnableAsync
@EnableTransactionManagement
public class LicensingPlatformApplication {

    public static void main(String[] args) {
        SpringApplication.run(LicensingPlatformApplication.class, args);
    }
}