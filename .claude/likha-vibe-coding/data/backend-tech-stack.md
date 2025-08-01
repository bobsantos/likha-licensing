# Technology Stack

## Backend/API Layer

- **Java 21** with Spring Boot 3.2+
- **Maven** for build management
- **Lombok** for annotations
- **Spring Modulith** for modular monolith architecture
- **Spring JDBC** for database operations (instead of Hibernate/JPA)
- **Spring Security** for authentication and authorization
- **Spring WebMVC** for REST API endpoints
- **Spring Boot Test** for testing Spring Boot
- **AssertJ** to use for test assertions

## Testing Strategy & Methodologies

### Unit Testing
- **JUnit 5** as primary testing framework
- **Mockito** for mocking dependencies and external services
- **AssertJ** for fluent assertions and readable test code
- **Spring Boot Test slices** (@WebMvcTest, @DataJdbcTest, @JsonTest)

### Test-Driven Development (TDD)
- **Red-Green-Refactor cycle** for service and repository development
- **Test-first approach** for business logic implementation
- **Mockito argument captors** for interaction verification

### Behavior-Driven Development (BDD)
- **Cucumber-Spring** integration for acceptance testing
- **Gherkin scenarios** for business requirement validation
- **Step definitions** mapped to Spring Boot test contexts

### Integration Testing
- **@SpringBootTest** for full application context testing
- **Testcontainers** for real PostgreSQL database integration
- **WireMock** for external API mocking and stubbing
- **Spring Boot Test slices** for focused integration testing

### Contract Testing
- **Spring Cloud Contract** for provider-side contract testing
- **Pact JVM** for consumer-driven contract testing
- **OpenAPI 3.0 validation** with springdoc-openapi-ui
- **JSON Schema validation** for request/response contracts

### Multi-Tenant Testing
- **Schema isolation testing** with Testcontainers PostgreSQL
- **Tenant context switching** validation in integration tests
- **Cross-tenant security testing** to prevent data leakage
- **Concurrent tenant operations** testing for race conditions

### Security Testing
- **Spring Security Test** for authentication and authorization testing
- **@WithMockUser** and custom security context testing
- **OWASP dependency check** for vulnerability scanning
- **JWT token validation** and security filter chain testing

### Database Testing
- **@DataJdbcTest** for repository layer testing
- **Flyway test migrations** with schema-per-tenant validation
- **Database transaction testing** with @Transactional
- **Connection pool testing** with HikariCP configuration

### Performance Testing
- **JMH (Java Microbenchmark Harness)** for micro-benchmarks
- **Spring Boot Actuator** metrics validation
- **Load testing** with JMeter integration tests
- **Database query performance** testing with query analysis

### End-to-End Testing
- **REST Assured** for API endpoint testing
- **TestRestTemplate** for full Spring Boot integration
- **Database state validation** after API operations
- **Multi-step business workflow** testing

### Smoke Testing
- **Spring Boot health checks** validation
- **Database connectivity** verification
- **External service availability** checks
- **Critical API endpoint** basic functionality validation

## Frontend

- **React 18+** with TypeScript
- **Vite** as build tool and development server
- **Chakra UI** for component library
- **TanStack Table** for advanced data grid functionality
- **Axios** for HTTP client
- **React Router** for client-side routing

## Database & Storage

- **PostgreSQL 15+** as primary database
- **Schema-per-tenant** multi-tenancy approach
- **AWS S3** for document and file storage
- **Redis** for caching and session management (future)

## Infrastructure & Deployment

- **Docker** for containerization
- **AWS Fargate** for serverless container deployment
- **Application Load Balancer (ALB)** for load balancing
- **AWS RDS** for managed PostgreSQL
- **AWS S3** for object storage

## Development & Operations

- **Docker Compose** for local development environment
- **GitHub Actions** for CI/CD pipeline
- **AWS CloudWatch** for monitoring and logging
