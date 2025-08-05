# Backend Work Guide for @agent-backend

This guide provides best practices and references for @agent-backend when working on backend tasks from `@.claude/likha-vibe-coding/prod-dev/todo.md`.

## Core References

- **Test-Driven Development**: .claude/likha-vibe-coding/data/tdd.md
- **Backend Tech Stack**: .claude/likha-vibe-coding/data/backend-tech-stack.md
- **Backend Best Practices**: .claude/likha-vibe-coding/data/backend-best-practices.md
- **Domain-Driven Design**: .claude/likha-vibe-coding/data/ddd.md
- **Flyway Migration Best Practices**: .claude/likha-vibe-coding/data/flyway.md

## Backend Task Approach

### MANDATORY Pre-Implementation Checklist

Before writing ANY implementation code, you MUST complete these steps IN ORDER:

- [ ] Read and understand the full task requirements from todo.md
- [ ] **Search for existing functionality** - Use Glob and Grep tools to find:
  - [ ] Similar classes, services, or configurations
  - [ ] Existing database configurations or test setups
  - [ ] Related Spring components or beans
  - [ ] Any duplicate functionality that already exists
- [ ] **Leverage existing code** - Extend or use existing implementations rather than creating new ones
- [ ] Create a detailed todo list using TodoWrite tool with your implementation plan
- [ ] Share your implementation plan with the user
- [ ] Write failing tests first (TDD approach - Red phase)
  - Write Spring Boot integration tests for APIs
  - Write repository tests for database operations
  - Write unit tests for business logic
- [ ] Get user confirmation or wait 30 seconds for implicit approval
- [ ] Only then proceed with implementation to make tests pass
- [ ] **MANDATORY**: Run `mvn clean verify` after implementation to ensure all tests pass
- [ ] **MANDATORY**: Fix any test failures before claiming task completion

**CRITICAL**: If you skip any of these steps, the user will interrupt you and you'll need to start over.

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
- **MANDATORY**: Run `mvn clean verify` to ensure all tests pass
- **MANDATORY**: Fix any test failures before proceeding
- Reference: TDD Best Practices guide

### 2. Implementation Verification

**CRITICAL VERIFICATION STEP - NEVER SKIP THIS**

After ANY implementation work, you MUST:

1. **Run Full Test Suite**: Execute `mvn clean verify` to run all tests
2. **Check Test Results**: Ensure ALL tests pass (0 failures, 0 errors)
3. **Fix Any Failures**: Address any test failures immediately
4. **Re-run Tests**: Verify fixes by running `mvn clean verify` again
5. **Only Then**: Mark task as complete

**Why This Matters:**
- Prevents broken code from being committed
- Ensures all existing functionality still works
- Validates new implementation doesn't break tests
- Maintains code quality and system stability

**Command to Run:**
```bash
mvn clean verify
```

This command will:
- Clean previous builds (`clean`)
- Compile code
- Run unit tests
- Run integration tests
- Run any verification checks
- Report all failures clearly

**DO NOT** claim task completion if this step fails or is skipped.

### 3. Implementation Guidelines

**Spring Boot Architecture**

- Follow Spring Modulith patterns for modular monolith
- Use Spring JDBC instead of JPA/Hibernate
- Implement proper transaction boundaries
- Apply dependency injection best practices

**Spring Boot Layered Architecture within Modules**

Each Spring Modulith module follows a consistent layered architecture pattern with clear separation of concerns:

**Package Structure Pattern for Modules (Spring Boot Modulith Compliant):**
```
app.likha.{module}/                    # Root module package (public API only)
├── package-info.java                  # Module documentation and boundaries
├── controller/                        # REST controllers (public API layer)
│   └── {Module}Controller.java
├── dto/                              # Request/Response DTOs (public API)
│   ├── Create{Module}Request.java
│   └── {Module}Response.java
└── internal/                         # Internal implementations (encapsulated)
    ├── service/                      # Internal business logic services
    │   └── {Module}Service.java
    ├── repository/                   # Internal data access layer
    │   └── {Module}Repository.java
    ├── model/                        # Internal domain models
    │   └── {Module}.java
    ├── config/                       # Internal module-specific configuration
    │   └── {Module}Configuration.java
    └── event/                        # Internal domain events and handlers
        ├── {Module}CreatedEvent.java
        └── {Module}EventHandler.java
```

**Example: Contracts Module Structure (Spring Boot Modulith Compliant):**
```
app.likha.contracts/                   # Public API package only
├── package-info.java                  # Module boundaries and documentation
├── controller/                        # Public REST endpoints (exposed)
│   └── ContractsHealthController.java
├── dto/                              # Public DTOs (exposed)
│   ├── CreateContractRequest.java     # Future DTOs go here
│   └── ContractResponse.java
└── internal/                         # Private implementations (encapsulated)
    ├── service/                      # Internal business services
    │   └── ContractManagementHealthService.java
    ├── repository/                   # Internal data access
    │   └── ContractRepository.java
    ├── model/                        # Internal domain models
    │   └── Contract.java
    └── event/                        # Internal domain events
        └── ContractCreatedEvent.java
```

**Layer Responsibilities:**

1. **Controller Layer** (`controller/`)
   - REST API endpoints and HTTP request handling
   - Input validation and transformation
   - HTTP response mapping
   - Exception handling at API boundary
   - OpenAPI documentation annotations

2. **Service Layer** (`service/`)
   - Business logic implementation
   - Transaction boundary management
   - Domain event publishing
   - Cross-cutting concerns (validation, authorization)
   - Orchestration of repository operations

3. **Repository Layer** (`repository/`)
   - Data access abstraction
   - Spring JDBC template operations
   - Multi-tenant query handling
   - Database transaction management
   - SQL query implementation

4. **Model Layer** (`model/`)
   - Domain entities and value objects
   - Data transfer objects (DTOs)
   - Request/response models
   - Validation annotations
   - Business rules and constraints

**Spring Modulith Integration Guidelines:**

- **Public API**: Only controllers and DTOs in root package are accessible to other modules
- **Encapsulation**: All business logic, data access, and domain models are in `internal.*` packages
- **Module Boundaries**: Enforced by Spring Boot Modulith - other modules cannot access internal packages
- **Inter-Module Communication**: Via public API endpoints or domain events only
- **Package-Info Documentation**: Required for each module with clear boundary definitions
- **Dependency Direction**: Controllers can depend on internal services, but not vice versa

**Domain-Driven Design**

- **Reference**: @docs/domain/domains.md for bounded contexts, domain events, and architecture patterns
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

### 4. Collaboration Requirements

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

### 5. Testing Strategy

**Layer-Specific Testing Patterns**

**1. Controller Layer Testing:**

```java
@WebMvcTest(LicenseController.class)
class LicenseControllerTest {
    
    @Autowired
    private MockMvc mockMvc;
    
    @MockBean
    private LicenseService licenseService;
    
    @Test
    void shouldCreateLicense() throws Exception {
        // Given
        var request = new CreateLicenseRequest("Test License", License.LicenseType.EXCLUSIVE, null);
        var license = License.builder().id(UUID.randomUUID()).name("Test License").build();
        
        when(licenseService.createLicense(any())).thenReturn(license);
        
        // When & Then
        mockMvc.perform(post("/api/v1/licenses")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.name").value("Test License"));
    }
    
    @Test
    void shouldValidateCreateLicenseRequest() throws Exception {
        // Given invalid request
        var invalidRequest = new CreateLicenseRequest("", null, null);
        
        // When & Then
        mockMvc.perform(post("/api/v1/licenses")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(invalidRequest)))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.violations").isArray());
    }
}
```

**2. Service Layer Testing:**

```java
@ExtendWith(MockitoExtension.class)
class LicenseServiceTest {
    
    @Mock
    private LicenseRepository licenseRepository;
    
    @Mock
    private ApplicationEventPublisher eventPublisher;
    
    @InjectMocks
    private LicenseService licenseService;
    
    @Test
    void shouldCreateLicense() {
        // Given
        var request = new CreateLicenseRequest("Test License", License.LicenseType.EXCLUSIVE, null);
        var savedLicense = License.builder()
                .id(UUID.randomUUID())
                .name("Test License")
                .type(License.LicenseType.EXCLUSIVE)
                .status(License.LicenseStatus.DRAFT)
                .build();
        
        when(licenseRepository.existsByNameAndTenantId(anyString(), anyString())).thenReturn(false);
        when(licenseRepository.save(any(License.class))).thenReturn(savedLicense);
        
        // When
        var result = licenseService.createLicense(request);
        
        // Then
        assertThat(result).isNotNull();
        assertThat(result.getName()).isEqualTo("Test License");
        assertThat(result.getStatus()).isEqualTo(License.LicenseStatus.DRAFT);
        
        verify(eventPublisher).publishEvent(any(LicenseCreatedEvent.class));
    }
    
    @Test
    void shouldThrowExceptionWhenDuplicateLicense() {
        // Given
        var request = new CreateLicenseRequest("Existing License", License.LicenseType.EXCLUSIVE, null);
        when(licenseRepository.existsByNameAndTenantId("Existing License", anyString())).thenReturn(true);
        
        // When & Then
        assertThatThrownBy(() -> licenseService.createLicense(request))
                .isInstanceOf(DuplicateLicenseException.class)
                .hasMessage("License with name already exists");
    }
}
```

**3. Repository Layer Testing:**

```java
@DataJdbcTest
@Testcontainers
class LicenseRepositoryTest {
    
    @Container
    static PostgreSQLContainer<?> postgres = new PostgreSQLContainer<>("postgres:16")
            .withDatabaseName("testdb")
            .withUsername("test")
            .withPassword("test");
    
    @Autowired
    private JdbcTemplate jdbcTemplate;
    
    private LicenseRepository licenseRepository;
    
    @BeforeEach
    void setUp() {
        licenseRepository = new LicenseRepository(jdbcTemplate);
    }
    
    @Test
    void shouldSaveAndFindLicense() {
        // Given
        try (var ignored = TenantContext.setTenantId("tenant-1")) {
            var license = License.builder()
                    .name("Test License")
                    .type(License.LicenseType.EXCLUSIVE)
                    .status(License.LicenseStatus.DRAFT)
                    .build();
            
            // When
            var savedLicense = licenseRepository.save(license);
            var foundLicense = licenseRepository.findById(savedLicense.getId());
            
            // Then
            assertThat(savedLicense.getId()).isNotNull();
            assertThat(foundLicense).isPresent();
            assertThat(foundLicense.get().getName()).isEqualTo("Test License");
        }
    }
    
    @Test
    void shouldRespectTenantIsolation() {
        // Given
        var license1 = License.builder().name("License 1").build();
        var license2 = License.builder().name("License 2").build();
        
        UUID savedId1, savedId2;
        
        try (var ignored = TenantContext.setTenantId("tenant-1")) {
            savedId1 = licenseRepository.save(license1).getId();
        }
        
        try (var ignored = TenantContext.setTenantId("tenant-2")) {
            savedId2 = licenseRepository.save(license2).getId();
        }
        
        // When & Then - tenant-1 should only see license1
        try (var ignored = TenantContext.setTenantId("tenant-1")) {
            assertThat(licenseRepository.findById(savedId1)).isPresent();
            assertThat(licenseRepository.findById(savedId2)).isEmpty();
        }
        
        // When & Then - tenant-2 should only see license2
        try (var ignored = TenantContext.setTenantId("tenant-2")) {
            assertThat(licenseRepository.findById(savedId2)).isPresent();
            assertThat(licenseRepository.findById(savedId1)).isEmpty();
        }
    }
    
    @DynamicPropertySource
    static void configureProperties(DynamicPropertyRegistry registry) {
        registry.add("spring.datasource.url", postgres::getJdbcUrl);
        registry.add("spring.datasource.username", postgres::getUsername);
        registry.add("spring.datasource.password", postgres::getPassword);
    }
}
```

**4. Integration Testing:**

```java
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@Testcontainers
class LicenseIntegrationTest {
    
    @Container
    static PostgreSQLContainer<?> postgres = new PostgreSQLContainer<>("postgres:16");
    
    @Autowired
    private TestRestTemplate restTemplate;
    
    @Autowired
    private LicenseRepository licenseRepository;
    
    @Test
    void shouldCreateAndRetrieveLicense() {
        // Given
        var createRequest = new CreateLicenseRequest("Integration Test License", 
                License.LicenseType.EXCLUSIVE, null);
        
        // When - Create license
        var createResponse = restTemplate.postForEntity("/api/v1/licenses", 
                createRequest, LicenseResponse.class);
        
        // Then - Verify creation
        assertThat(createResponse.getStatusCode()).isEqualTo(HttpStatus.CREATED);
        assertThat(createResponse.getBody().name()).isEqualTo("Integration Test License");
        
        var licenseId = createResponse.getBody().id();
        
        // When - Retrieve license
        var getResponse = restTemplate.getForEntity("/api/v1/licenses/" + licenseId, 
                LicenseResponse.class);
        
        // Then - Verify retrieval
        assertThat(getResponse.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(getResponse.getBody().name()).isEqualTo("Integration Test License");
    }
    
    @DynamicPropertySource
    static void configureProperties(DynamicPropertyRegistry registry) {
        registry.add("spring.datasource.url", postgres::getJdbcUrl);
        registry.add("spring.datasource.username", postgres::getUsername);
        registry.add("spring.datasource.password", postgres::getPassword);
    }
}
```

**5. Module Boundary Testing:**

```java
@ModulithTest
class ModulithArchitectureTest {
    
    @Test
    void shouldRespectModuleBoundaries() {
        // This test verifies that Spring Modulith module boundaries are respected
        // Automatically validates package structure and dependencies
    }
    
    @Test
    void shouldHaveValidEventListeners() {
        // Validates that event listeners are properly configured
        // and event publishing/consumption follows module boundaries
    }
}
```

**Unit Testing Best Practices**

```java
@Test
void shouldCalculateLicenseFee() {
    // Arrange
    var license = License.builder()
            .type(License.LicenseType.EXCLUSIVE)
            .status(License.LicenseStatus.ACTIVE)
            .build();

    // Act
    var fee = licenseService.calculateFee(license);

    // Assert
    assertThat(fee).isEqualTo(expectedFee);
}
```

**Contract Testing**

- Spring Cloud Contract for provider testing
- Validate API contracts with consumers
- Test error scenarios thoroughly
- Use @MockMvcTest for isolated controller testing

### 6. Code Quality Standards

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

### Module Package Structure Implementation

**1. Package-Info Definition (Required for each module):**

```java
/**
 * {Module Name} Module for the Likha Licensing Platform.
 * 
 * This module encapsulates all {module functionality} following
 * Spring Modulith modular monolith architecture principles.
 * 
 * <h2>Module Structure</h2>
 * <ul>
 *   <li><strong>Public API:</strong> Controllers in this package (app.likha.{module})</li>
 *   <li><strong>Internal Services:</strong> Services in internal subpackages</li>
 *   <li><strong>Data Access:</strong> Repositories and data access objects</li>
 * </ul>
 * 
 * <h2>Bounded Context</h2>
 * This module manages:
 * <ul>
 *   <li>Primary business capability</li>
 *   <li>Secondary business capability</li>
 *   <li>Multi-tenant data isolation</li>
 *   <li>Module-specific infrastructure concerns</li>
 * </ul>
 * 
 * <h2>Spring Modulith Compliance</h2>
 * - Only classes in this root package are exposed as public API
 * - All internal implementations are in 'internal' subpackages
 * - Inter-module communication happens through public APIs or events
 * 
 * @author Likha Development Team
 * @version 1.0
 * @since 1.0
 */
package app.likha.{module};
```

**2. Controller Layer Pattern:**

```java
@RestController
@RequestMapping("/api/v1/licenses")
@Validated
@Tag(name = "License Management", description = "License CRUD operations")
public class LicenseController {
    
    private final LicenseService licenseService;
    
    public LicenseController(LicenseService licenseService) {
        this.licenseService = licenseService;
    }
    
    @PostMapping
    @Operation(summary = "Create new license")
    public ResponseEntity<LicenseResponse> createLicense(
            @Valid @RequestBody CreateLicenseRequest request) {
        
        var license = licenseService.createLicense(request);
        var response = LicenseResponse.from(license);
        
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }
    
    @GetMapping("/{licenseId}")
    @Operation(summary = "Get license by ID")
    public ResponseEntity<LicenseResponse> getLicense(
            @PathVariable UUID licenseId) {
        
        return licenseService.findById(licenseId)
                .map(LicenseResponse::from)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }
}
```

**3. Service Layer Pattern:**

```java
@Service
@Transactional
public class LicenseService {
    
    private final LicenseRepository licenseRepository;
    private final ApplicationEventPublisher eventPublisher;
    
    public LicenseService(LicenseRepository licenseRepository, 
                         ApplicationEventPublisher eventPublisher) {
        this.licenseRepository = licenseRepository;
        this.eventPublisher = eventPublisher;
    }
    
    public License createLicense(CreateLicenseRequest request) {
        // Business validation
        validateLicenseRequest(request);
        
        // Create domain entity
        var license = License.builder()
                .name(request.name())
                .type(request.type())
                .tenantId(TenantContextHolder.getTenantId())
                .status(LicenseStatus.DRAFT)
                .build();
        
        // Persist
        var savedLicense = licenseRepository.save(license);
        
        // Publish domain event
        eventPublisher.publishEvent(new LicenseCreatedEvent(savedLicense.getId()));
        
        return savedLicense;
    }
    
    @Transactional(readOnly = true)
    public Optional<License> findById(UUID licenseId) {
        return licenseRepository.findById(licenseId);
    }
    
    private void validateLicenseRequest(CreateLicenseRequest request) {
        if (licenseRepository.existsByNameAndTenantId(request.name(), 
                TenantContextHolder.getTenantId())) {
            throw new DuplicateLicenseException("License with name already exists");
        }
    }
}
```

**4. Repository Layer Pattern:**

```java
@Repository
public class LicenseRepository {
    
    private final JdbcTemplate jdbcTemplate;
    private final LicenseRowMapper licenseRowMapper;
    
    public LicenseRepository(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
        this.licenseRowMapper = new LicenseRowMapper();
    }
    
    public License save(License license) {
        if (license.getId() == null) {
            return insert(license);
        } else {
            return update(license);
        }
    }
    
    public Optional<License> findById(UUID id) {
        String sql = """
            SELECT id, name, type, tenant_id, status, created_at, updated_at
            FROM licenses 
            WHERE id = ? AND tenant_id = ?
            """;
        
        return jdbcTemplate.query(sql, licenseRowMapper, id, TenantContextHolder.getTenantId())
                .stream()
                .findFirst();
    }
    
    public boolean existsByNameAndTenantId(String name, String tenantId) {
        String sql = "SELECT COUNT(*) FROM licenses WHERE name = ? AND tenant_id = ?";
        Integer count = jdbcTemplate.queryForObject(sql, Integer.class, name, tenantId);
        return count != null && count > 0;
    }
    
    private License insert(License license) {
        String sql = """
            INSERT INTO licenses (id, name, type, tenant_id, status, created_at, updated_at)
            VALUES (?, ?, ?, ?, ?, ?, ?)
            """;
        
        var id = UUID.randomUUID();
        var now = Instant.now();
        
        jdbcTemplate.update(sql, 
            id, 
            license.getName(), 
            license.getType().name(),
            TenantContextHolder.getTenantId(),
            license.getStatus().name(),
            now,
            now
        );
        
        return license.toBuilder().id(id).createdAt(now).updatedAt(now).build();
    }
    
    private static class LicenseRowMapper implements RowMapper<License> {
        @Override
        public License mapRow(ResultSet rs, int rowNum) throws SQLException {
            return License.builder()
                    .id(UUID.fromString(rs.getString("id")))
                    .name(rs.getString("name"))
                    .type(LicenseType.valueOf(rs.getString("type")))
                    .tenantId(rs.getString("tenant_id"))
                    .status(LicenseStatus.valueOf(rs.getString("status")))
                    .createdAt(rs.getTimestamp("created_at").toInstant())
                    .updatedAt(rs.getTimestamp("updated_at").toInstant())
                    .build();
        }
    }
}
```

**5. Domain Model Pattern:**

```java
@Builder(toBuilder = true)
@Value
public class License {
    UUID id;
    String name;
    LicenseType type;
    String tenantId;
    LicenseStatus status;
    Instant createdAt;
    Instant updatedAt;
    
    public enum LicenseType {
        EXCLUSIVE, NON_EXCLUSIVE, SUBLICENSE
    }
    
    public enum LicenseStatus {
        DRAFT, ACTIVE, SUSPENDED, TERMINATED
    }
    
    public boolean isActive() {
        return status == LicenseStatus.ACTIVE;
    }
    
    public License activate() {
        if (status != LicenseStatus.DRAFT) {
            throw new InvalidLicenseStateException("Can only activate draft licenses");
        }
        return toBuilder().status(LicenseStatus.ACTIVE).build();
    }
}
```

**6. DTO Pattern:**

```java
// Request DTO
public record CreateLicenseRequest(
    @NotBlank(message = "License name is required")
    @Size(max = 255, message = "License name must not exceed 255 characters")
    String name,
    
    @NotNull(message = "License type is required")
    License.LicenseType type,
    
    @Valid
    @NotNull(message = "License terms are required")
    LicenseTermsRequest terms
) {}

// Response DTO
@Builder
public record LicenseResponse(
    UUID id,
    String name,
    License.LicenseType type,
    License.LicenseStatus status,
    Instant createdAt,
    Instant updatedAt
) {
    public static LicenseResponse from(License license) {
        return LicenseResponse.builder()
                .id(license.getId())
                .name(license.getName())
                .type(license.getType())
                .status(license.getStatus())
                .createdAt(license.getCreatedAt())
                .updatedAt(license.getUpdatedAt())
                .build();
    }
}
```

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
    
    public static void clear() {
        TENANT_ID.remove();
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
