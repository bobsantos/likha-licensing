# Event Storming Session: Contract Management MVP

**Session Details:**
- **Date:** August 2, 2025 14:31:26
- **Product:** Contract Management MVP
- **Facilitator:** Claude Code (Event Storming Leader)
- **Participants:** Product Management, Designer, Infrastructure, Frontend, Security specialists
- **Duration:** Comprehensive domain analysis session
- **Input Source:** `.claude/likha-vibe-coding/prod-dev/prd.md`

## Executive Summary

This event storming session analyzed the Contract Management MVP to identify domain events, aggregates, and bounded contexts for implementing a licensing contract management platform. The session revealed a clear domain structure centered around contract lifecycle management with strong multi-tenant isolation requirements.

**Key Findings:**
- **4 Primary Bounded Contexts** supporting modular Spring Boot architecture
- **3 Core Aggregates** with clear business boundaries
- **8 Critical Domain Events** driving business workflows
- **Multi-tenant security model** with schema-per-tenant isolation
- **Event-driven architecture** supporting Spring Modulith design patterns

**Business Impact:**
- Clear architectural foundation for 4-week MVP development timeline
- Modular design enabling incremental feature delivery
- Scalable multi-tenant architecture supporting 500+ contracts per tenant
- Security-first design meeting enterprise licensing agency requirements

## Business Context

### Product Vision
Contract Management MVP for small-to-medium licensing agencies (50-500 contracts) struggling with manual contract organization and missed renewal opportunities. The platform delivers 10x faster contract retrieval and zero missed renewals through automated tracking and alerts.

### Target Users
- **Primary:** Licensing Agency Administrators (operations managers, agency owners)
- **Secondary:** Licensing Agents (client-facing account managers)
- **Scale:** 5+ concurrent users per tenant, 500+ contracts per tenant

### Core Value Proposition
"Licensing agencies can organize, search, and track their contracts 10x faster than current manual methods, with zero missed renewals and instant team access to contract information."

## Domain Events

### Core Business Events

**1. Contract Uploaded**
- **Trigger:** User uploads PDF/DOC contract file
- **Data:** File metadata, tenant context, user identity
- **Business Impact:** Contract becomes available for management
- **Downstream Effects:** Triggers metadata extraction, virus scanning

**2. Contract Metadata Added**
- **Trigger:** User completes contract metadata form
- **Data:** Licensee, territory, dates, contract type, value
- **Business Impact:** Contract becomes searchable and trackable
- **Downstream Effects:** Enables search indexing, expiration tracking

**3. Contract Expiration Alert Triggered**
- **Trigger:** System timer reaches configured alert threshold
- **Data:** Contract details, days until expiration, alert type
- **Business Impact:** Prevents missed renewal opportunities
- **Downstream Effects:** Email notifications, dashboard updates

**4. Contract Search Performed**
- **Trigger:** User executes search query or filter
- **Data:** Search criteria, user context, result metrics
- **Business Impact:** Enables instant contract retrieval
- **Downstream Effects:** Updates user activity logs, search analytics

**5. Contract Status Changed**
- **Trigger:** System or user updates contract lifecycle status
- **Data:** Previous status, new status, reason, timestamp
- **Business Impact:** Reflects current contract validity
- **Downstream Effects:** Dashboard updates, reporting changes

**6. User Registered**
- **Trigger:** Administrator creates new team member account
- **Data:** User details, role assignment, tenant association
- **Business Impact:** Enables team collaboration
- **Downstream Effects:** Access control setup, audit trail initialization

**7. Contract Downloaded**
- **Trigger:** User accesses contract file for viewing/sharing
- **Data:** Contract ID, user identity, access purpose
- **Business Impact:** Enables client service and collaboration
- **Downstream Effects:** Audit logging, usage tracking

**8. Contract Renewed**
- **Trigger:** User marks contract as renewed with replacement
- **Data:** Original contract ID, new contract details, renewal terms
- **Business Impact:** Maintains continuous licensing coverage
- **Downstream Effects:** Status updates, new expiration tracking

### Supporting Events

**User Authentication Events:**
- User Logged In
- User Session Expired
- Password Reset Requested

**System Events:**
- Tenant Created
- File Storage Quota Exceeded
- System Backup Completed

## Commands and Actors

### User Commands

**Licensing Administrator Commands:**
- **Upload Contract** → Triggers "Contract Uploaded"
- **Add Contract Metadata** → Triggers "Contract Metadata Added"
- **Edit Contract Metadata** → Triggers "Contract Metadata Updated"
- **Create User Account** → Triggers "User Registered"
- **Configure Alert Settings** → Triggers "Alert Configuration Changed"
- **Mark Contract Renewed** → Triggers "Contract Renewed"

**Licensing Agent Commands:**
- **Search Contracts** → Triggers "Contract Search Performed"
- **Download Contract** → Triggers "Contract Downloaded"
- **View Contract Details** → Triggers "Contract Accessed"
- **Update Contract Notes** → Triggers "Contract Metadata Updated"

**System Commands:**
- **Check Expiration Dates** → Triggers "Contract Expiration Alert Triggered"
- **Update Contract Status** → Triggers "Contract Status Changed"
- **Generate Dashboard Data** → Triggers "Dashboard Refreshed"

### Actor Responsibilities

**Licensing Administrator:**
- Contract lifecycle management
- Team member management
- System configuration
- Compliance oversight

**Licensing Agent:**
- Daily contract lookup
- Client service support
- Contract information sharing

**System (Automated):**
- Expiration monitoring
- Status updates
- Alert generation
- Audit logging

## Aggregates and Boundaries

### Contract Aggregate

**Root Entity:** Contract
**Aggregate Boundaries:**
- Contract metadata and lifecycle
- File storage references
- Expiration tracking
- Search indexing data

**Business Rules:**
- End date must be after start date
- Contract title unique within tenant
- Status transitions follow defined lifecycle
- Metadata changes logged for audit

**Invariants:**
- Active contracts have future end dates
- Expired contracts cannot be marked active
- Required metadata must be complete
- File references must be valid

### Tenant Aggregate

**Root Entity:** Tenant
**Aggregate Boundaries:**
- Tenant configuration
- User management
- Data isolation policies
- Subscription settings

**Business Rules:**
- Schema-per-tenant data isolation
- User access scoped to single tenant
- Contract limits based on subscription
- Audit trails maintained per tenant

**Invariants:**
- Users belong to exactly one tenant
- Cross-tenant data access forbidden
- Tenant deletion cascades to all data
- Subscription status controls access

### User Aggregate

**Root Entity:** User
**Aggregate Boundaries:**
- Authentication credentials
- Role and permissions
- Session management
- Activity tracking

**Business Rules:**
- Email addresses unique across system
- Password complexity requirements
- Role-based access control
- Session timeout policies

**Invariants:**
- Active users must have valid roles
- Deactivated users cannot authenticate
- Admin role required for user management
- Audit trails track all user actions

## Bounded Contexts

### Contract Management Context

**Primary Responsibility:** Contract lifecycle and metadata management

**Domain Objects:**
- Contract (Root Aggregate)
- Licensee (Entity)
- Licensor (Entity)
- Brand (Entity)
- ContractMetadata (Value Object)
- ContractStatus (Enum)

**Key Operations:**
- Upload and store contract files
- Manage contract metadata
- Track contract lifecycle status
- Generate expiration alerts

**Data Ownership:**
- Contract files and metadata
- Licensee/licensor information
- Contract search indexes
- Expiration tracking data

**External Dependencies:**
- File Storage Context for document management
- User Management Context for access control
- Notification Context for alerts

### User Management Context

**Primary Responsibility:** Authentication, authorization, and multi-tenancy

**Domain Objects:**
- Tenant (Root Aggregate)
- User (Root Aggregate)
- Role (Value Object)
- Permission (Value Object)
- Session (Entity)

**Key Operations:**
- User authentication and authorization
- Tenant data isolation
- Role-based access control
- Session management

**Data Ownership:**
- User accounts and credentials
- Tenant configurations
- Role and permission definitions
- Authentication sessions

**External Dependencies:**
- All contexts require user authentication
- Tenant isolation enforced across contexts

### File Storage Context

**Primary Responsibility:** Document upload, storage, and retrieval

**Domain Objects:**
- StoredFile (Root Aggregate)
- FileMetadata (Value Object)
- StorageLocation (Value Object)
- UploadSession (Entity)

**Key Operations:**
- Secure file upload with validation
- Virus scanning and content verification
- File storage with tenant isolation
- Secure file download and streaming

**Data Ownership:**
- Physical file storage
- File metadata and indexes
- Upload progress tracking
- Storage quota management

**External Dependencies:**
- Contract Management Context for file associations
- User Management Context for access control

### Notification Context

**Primary Responsibility:** Alert generation and delivery

**Domain Objects:**
- NotificationRule (Root Aggregate)
- Alert (Entity)
- NotificationTemplate (Value Object)
- DeliveryChannel (Value Object)

**Key Operations:**
- Monitor contract expiration dates
- Generate and send alerts
- Manage notification preferences
- Track delivery status

**Data Ownership:**
- Notification rules and schedules
- Alert history and status
- Email templates and configuration
- Delivery tracking data

**External Dependencies:**
- Contract Management Context for expiration data
- User Management Context for recipient information

## Read Models and Policies

### Dashboard Read Model

**Purpose:** Contract overview and expiration alerts for daily workflow

**Data Sources:**
- Contract aggregate (expiration dates, status)
- User activity logs
- Notification history

**Projections:**
- Expiring contracts by timeframe (30/60/90 days)
- Recent user activity summary
- Contract portfolio statistics
- Alert status and history

**Update Triggers:**
- Contract status changes
- New contract uploads
- Expiration alert generation
- User activity events

### Contract Search Read Model

**Purpose:** Fast contract discovery and filtering

**Data Sources:**
- Contract metadata
- File content extraction
- User access permissions

**Projections:**
- Searchable contract index
- Filtered result sets
- Sort and pagination data
- Search suggestion data

**Update Triggers:**
- Contract metadata changes
- New contract uploads
- Search query execution
- Permission changes

### User Activity Read Model

**Purpose:** Audit trails and usage analytics

**Data Sources:**
- User action logs
- Contract access events
- System operation logs

**Projections:**
- User activity timelines
- Contract access history
- System usage metrics
- Compliance audit data

**Update Triggers:**
- Any user action
- Contract access events
- System operations
- Authentication events

### Business Policies

**Contract Expiration Policy:**
- Alert thresholds: 90, 60, 30, 7 days before expiration
- Alert frequency: Maximum weekly for same contract
- Status auto-update: Mark expired when end date passes
- Renewal tracking: Maintain history of renewals

**Multi-Tenant Isolation Policy:**
- All data access scoped by tenant ID
- Cross-tenant queries forbidden
- User authentication validates tenant membership
- File storage organized by tenant directories

**Audit Trail Policy:**
- Log all contract access and modifications
- Track user authentication events
- Maintain immutable audit records
- Retention policy based on compliance requirements

**Role-Based Access Policy:**
- Admin role: Full tenant access and user management
- Agent role: Contract access based on assignments
- System role: Automated operations only
- Permission inheritance and override rules

## Security Considerations

### Tenant Isolation Security

**Data Isolation:**
- Schema-per-tenant PostgreSQL architecture
- Tenant ID validation on all database queries
- File storage isolation via directory structure
- Cross-tenant contamination prevention

**Access Control:**
- JWT token-based authentication with tenant claims
- Role-based authorization at API endpoints
- Resource-level permission checking
- Session management with tenant binding

### File Security

**Upload Security:**
- File type validation (PDF, DOC, DOCX only)
- File size limits (25MB maximum)
- Virus scanning before storage
- Content validation and sanitization

**Storage Security:**
- Encryption at rest for sensitive files
- Secure file naming to prevent path traversal
- Access logging for all file operations
- Backup encryption and secure deletion

### API Security

**Endpoint Protection:**
- HTTPS/TLS 1.3 for all communications
- CSRF protection on state-changing operations
- Rate limiting on search and upload endpoints
- Input validation and sanitization

**Authentication Security:**
- Secure password requirements and hashing
- Account lockout on failed login attempts
- Session timeout and token rotation
- Password reset with secure tokens

### Audit and Compliance

**Audit Logging:**
- Immutable audit trail for all user actions
- Contract access tracking with timestamps
- File operation logging (upload, download, delete)
- Authentication and authorization events

**Privacy and Compliance:**
- GDPR-ready data export capabilities
- User data anonymization features
- Configurable data retention policies
- Consent management for data processing

## Integration Points

### External System Interfaces

**Email Service Integration:**
- SMTP configuration for expiration alerts
- Template-based notification system
- Delivery status tracking
- Bounce and error handling

**File System Integration:**
- Local file storage with cloud-ready abstraction
- Backup and restore capabilities
- Storage quota monitoring
- File cleanup and archival

**Database Integration:**
- PostgreSQL with schema-per-tenant
- Connection pooling and optimization
- Migration management
- Backup and recovery procedures

### Internal Context Communication

**Event-Driven Communication:**
- Domain events published via Spring Application Events
- Asynchronous processing for non-critical operations
- Event sourcing for audit trails
- Saga pattern for cross-context operations

**Synchronous Integration:**
- Direct service calls within same process
- Shared data through defined interfaces
- Transaction coordination where needed
- Circuit breaker patterns for resilience

## Technology Mapping

### Spring Modulith Architecture

**Module Organization:**
```
app.likha.licensing/
├── contracts/           # Contract Management Context
├── users/              # User Management Context  
├── files/              # File Storage Context
├── notifications/      # Notification Context
└── shared/             # Cross-cutting concerns
```

**Technology Alignment:**
- **Spring Boot 3.x:** Main application framework
- **Spring JDBC:** Database access without ORM complexity
- **Spring Security:** Authentication and authorization
- **Spring Modulith:** Module boundaries and event handling

### Database Schema Design

**Schema-per-Tenant Structure:**
```sql
-- Tenant schemas
tenant_123.contracts
tenant_123.users
tenant_123.files
tenant_123.notifications

-- Shared schemas
public.tenants
public.system_config
```

**Data Access Patterns:**
- Repository pattern with tenant scoping
- Query optimization for contract search
- Connection pooling per tenant
- Schema migration management

### Event Processing Architecture

**Event Store Design:**
- Domain events stored for audit and replay
- Event versioning for schema evolution
- Projection rebuilding capabilities
- Event filtering and routing

**Processing Patterns:**
- Immediate consistency within aggregates
- Eventual consistency between contexts
- Compensating actions for failures
- Dead letter queue for error handling

## Implementation Priorities

### Phase 1: Core Domain (Weeks 1-2)

**Contract Management Context:**
- Contract upload and storage
- Basic metadata management
- Simple search functionality
- File download capabilities

**User Management Context:**
- User authentication
- Basic tenant isolation
- Role-based access control
- Session management

### Phase 2: Enhanced Features (Weeks 3-4)

**File Storage Context:**
- Advanced upload features
- File content extraction
- Storage optimization
- Backup procedures

**Notification Context:**
- Expiration monitoring
- Alert generation
- Email notifications
- Dashboard integration

### Phase 3: Production Readiness (Post-MVP)

**Advanced Security:**
- Enhanced audit logging
- Advanced threat protection
- Compliance reporting
- Security monitoring

**Performance Optimization:**
- Search performance tuning
- Caching strategies
- Database optimization
- Scaling preparation

## Risk Assessment and Mitigation

### Technical Risks

**Multi-Tenant Complexity:**
- **Risk:** Schema-per-tenant implementation complexity
- **Mitigation:** Early architecture validation and testing
- **Contingency:** Simplified single-tenant fallback

**File Storage Scaling:**
- **Risk:** Local file system limitations
- **Mitigation:** Cloud-ready abstraction layer
- **Contingency:** Early cloud storage integration

**Search Performance:**
- **Risk:** Slow search with large contract volumes
- **Mitigation:** Database indexing and query optimization
- **Contingency:** External search engine integration

### Business Risks

**User Adoption:**
- **Risk:** Resistance to new system adoption
- **Mitigation:** Intuitive UI design and user training
- **Contingency:** Extended trial periods and support

**Feature Scope Creep:**
- **Risk:** Additional features requested during development
- **Mitigation:** Clear MVP scope definition and change control
- **Contingency:** Phase 2 feature parking lot

## Success Metrics

### Technical Metrics

**Performance Targets:**
- Contract search response time: < 2 seconds
- File upload success rate: > 99.5%
- System uptime: > 99% during demos
- Multi-user support: 5+ concurrent users

**Quality Metrics:**
- Code coverage: > 80% for business logic
- Security scan: Zero critical vulnerabilities
- Load testing: 500+ contracts per tenant
- Cross-browser compatibility: Chrome, Firefox, Safari, Edge

### Business Metrics

**Customer Validation:**
- Successful customer demos: 2-3 prospects
- Trial engagement: 50+ contracts uploaded
- Task completion rate: > 90% during testing
- Customer commitment: $500-1000/month agreements

**User Experience:**
- Onboarding completion: No documentation required
- Feature discovery: > 80% of core features used
- User satisfaction: Positive feedback on value proposition
- Error recovery: Clear guidance for all error states

## Next Steps

### Immediate Actions (Week 1)

1. **Architecture Setup:**
   - Configure Spring Modulith project structure
   - Set up schema-per-tenant database design
   - Implement basic event handling framework
   - Create Docker development environment

2. **Core Domain Implementation:**
   - Implement Contract aggregate with basic operations
   - Set up User aggregate with authentication
   - Create file upload and storage capabilities
   - Establish tenant isolation patterns

### Development Milestones (Weeks 2-4)

1. **Week 2: Contract Management Core**
   - Complete contract CRUD operations
   - Implement basic search functionality
   - Add metadata management features
   - Set up file download capabilities

2. **Week 3: User Experience Enhancement**
   - Build React frontend with contract dashboard
   - Implement advanced search and filtering
   - Add expiration tracking and alerts
   - Create user management interface

3. **Week 4: Production Readiness**
   - Complete security implementation
   - Add comprehensive audit logging
   - Implement email notification system
   - Conduct customer demo preparation

### Future Phases

1. **Phase 2: Advanced Features**
   - Contract content extraction and indexing
   - Advanced reporting and analytics
   - Enhanced collaboration features
   - Mobile optimization

2. **Phase 3: Scale and Integration**
   - Cloud deployment preparation
   - External system integrations
   - Advanced workflow automation
   - Enterprise security features

---

**Event Storming Session Complete**  
**Documentation Generated:** August 2, 2025 14:31:26  
**Next Review:** Weekly during development sprints  
**Stakeholder Approval Required:** Architecture team, Product team, Security team