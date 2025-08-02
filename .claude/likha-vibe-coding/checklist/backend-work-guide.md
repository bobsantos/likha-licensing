# Backend Work Guide for @agent-backend

This guide provides best practices and references for @agent-backend when working on backend tasks from `@.claude/likha-vibe-coding/prod-dev/todo.md`.

## Core References

- **Test-Driven Development**: @.claude/likha-vibe-coding/data/tdd.md
- **Backend Tech Stack**: @.claude/likha-vibe-coding/data/backend-tech-stack.md
- **Backend Best Practices**: @.claude/likha-vibe-coding/data/backend-best-practices.md
- **Domain-Driven Design**: @.claude/likha-vibe-coding/checklist/ddd-checklist.md

## Backend Task Approach

### 1. Pre-Implementation Phase

**Understand the Task Context**
- Review acceptance criteria and business requirements
- Identify domain boundaries and bounded contexts
- Plan API contracts and data models
- Check which supporting teams are needed

**Test-First Development (TDD)**
- Write failing tests first (Red phase)
- Implement minimal code to pass (Green phase)
- Refactor for clarity and design (Refactor phase)
- Reference: TDD Best Practices guide

### 2. Implementation Guidelines

**Spring Boot Architecture**
- Follow Spring Modulith patterns for modular monolith
- Use Spring JDBC instead of JPA/Hibernate
- Implement proper transaction boundaries
- Apply dependency injection best practices

**Domain-Driven Design**
- Identify and implement aggregate roots
- Use value objects for immutable data
- Keep domain logic in domain services
- Maintain clear bounded contexts

**REST API Development**
- Follow RESTful conventions
- Implement proper HTTP status codes
- Use OpenAPI 3.0 for documentation
- Version APIs appropriately

**Database Operations**
- Use Spring JDBC templates
- Implement repository pattern
- Write efficient SQL queries
- Handle multi-tenant context properly

### 3. Collaboration Requirements

**CRITICAL**: Always collaborate with supporting teams when tasks require it!

**When to Collaborate with @agent-infra:**
- Database schema changes
- Connection pool configuration
- Infrastructure dependencies
- Deployment configuration
- Performance optimization

**When to Collaborate with @agent-security:**
- Authentication/authorization implementation
- API security controls
- Data encryption requirements
- Tenant isolation validation
- **IMPORTANT**: Request security review before deploying any API changes to production
- Security review for any endpoints handling sensitive data

**When to Collaborate with @agent-frontend:**
- API contract definition
- CORS requirements
- Response format optimization
- Error handling standards
- WebSocket or SSE implementation

**When to Collaborate with @agent-designer:**
- User-facing error messages
- API response structure for UI
- Data validation rules
- Business workflow implementation

### 4. Testing Strategy

**Unit Testing**
```java
@Test
void shouldCalculateLicenseFee() {
    // Arrange
    var license = new License(/*...*/);
    
    // Act
    var fee = licenseService.calculateFee(license);
    
    // Assert
    assertThat(fee).isEqualTo(expectedFee);
}
```

**Integration Testing**
- Use @SpringBootTest for full context
- Testcontainers for database testing
- Mock external services with WireMock
- Validate multi-tenant isolation

**Contract Testing**
- Spring Cloud Contract for provider testing
- Validate API contracts with consumers
- Test error scenarios thoroughly

### 5. Code Quality Standards

**Clean Code Principles**
- Single Responsibility Principle
- Clear method and variable names
- Avoid deep nesting
- Extract complex logic to methods

**Error Handling**
```java
@ExceptionHandler(ResourceNotFoundException.class)
public ResponseEntity<ErrorResponse> handleNotFound(ResourceNotFoundException ex) {
    return ResponseEntity.status(HttpStatus.NOT_FOUND)
        .body(new ErrorResponse(ex.getMessage()));
}
```

**Logging Standards**
```java
log.info("Processing license request for tenant: {}", tenantId);
log.error("Failed to process payment", exception);
```

## Common Backend Patterns

### Multi-Tenant Context
```java
@Component
public class TenantContextHolder {
    private static final ThreadLocal<String> TENANT_ID = new ThreadLocal<>();
    
    public static void setTenantId(String tenantId) {
        TENANT_ID.set(tenantId);
    }
    
    public static String getTenantId() {
        return TENANT_ID.get();
    }
}
```

### Repository Pattern
```java
@Repository
public class LicenseRepository {
    private final JdbcTemplate jdbcTemplate;
    
    public Optional<License> findById(UUID id) {
        String sql = "SELECT * FROM licenses WHERE id = ? AND tenant_id = ?";
        return jdbcTemplate.query(sql, new LicenseRowMapper(), id, getTenantId())
            .stream().findFirst();
    }
}
```

### Service Layer
```java
@Service
@Transactional
public class LicenseService {
    private final LicenseRepository repository;
    private final EventPublisher eventPublisher;
    
    public License createLicense(CreateLicenseRequest request) {
        // Validate business rules
        validateLicenseRequest(request);
        
        // Create domain object
        var license = License.create(request);
        
        // Persist
        var saved = repository.save(license);
        
        // Publish domain event
        eventPublisher.publish(new LicenseCreatedEvent(saved));
        
        return saved;
    }
}
```

## Security Considerations

**Authentication & Authorization**
- JWT token validation
- Role-based access control
- API key management
- OAuth2 integration when needed

**Data Security**
- Input validation and sanitization
- SQL injection prevention
- XSS protection
- Sensitive data encryption

## Performance Guidelines

**Query Optimization**
- Use proper indexes
- Avoid N+1 queries
- Implement pagination
- Cache frequently accessed data

**Application Performance**
- Connection pool tuning
- Async processing where appropriate
- Proper transaction scope
- Resource cleanup

## Documentation Standards

**Code Documentation**
```java
/**
 * Calculates the license fee based on usage and tier.
 * 
 * @param license the license to calculate fee for
 * @param usage the current usage metrics
 * @return the calculated fee
 * @throws InvalidLicenseException if license is expired
 */
public BigDecimal calculateFee(License license, UsageMetrics usage) {
    // Implementation
}
```

**API Documentation**
- OpenAPI annotations
- Clear endpoint descriptions
- Request/response examples
- Error response documentation

## Monitoring & Observability

**Metrics to Track**
- API response times
- Error rates by endpoint
- Database query performance
- Business metrics (licenses created, etc.)

**Health Checks**
```java
@Component
public class DatabaseHealthIndicator implements HealthIndicator {
    @Override
    public Health health() {
        // Check database connectivity
        // Return UP or DOWN status
    }
}
```

## Continuous Improvement

**Code Reviews**
- Focus on business logic correctness
- Check for security vulnerabilities
- Verify test coverage
- Ensure documentation is updated

**Learning & Sharing**
- Document new patterns discovered
- Share knowledge with team
- Keep up with Spring Boot updates
- Contribute to best practices

Remember: The backend is the brain of the application. Focus on correctness, maintainability, and performance. Always consider security implications and collaborate with other teams!