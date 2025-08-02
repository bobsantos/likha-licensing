# Infrastructure Work Guide for @agent-infra

This guide provides best practices and references for @agent-infra when working on infrastructure tasks from `@.claude/likha-vibe-coding/prod-dev/todo.md`.

## Core References

- **Test-Driven Development**: @.claude/likha-vibe-coding/data/tdd.md
- **DevOps Best Practices**: @.claude/likha-vibe-coding/data/devops-best-practices.md
- **Backend Tech Stack**: @.claude/likha-vibe-coding/data/backend-tech-stack.md
- **Frontend Tech Stack**: @.claude/likha-vibe-coding/data/frontend-tech-stack.md
- **Domain-Driven Design**: @.claude/likha-vibe-coding/data/ddd.md
- **Domain Model Reference**: @docs/domain/domains.md

## Infrastructure Task Approach

### 1. Pre-Implementation Phase

**Understand the Task Context**
- Review the task's acceptance criteria thoroughly
- Identify all dependencies and integration points
- Check which supporting teams are needed (@agent-backend, @agent-security, etc.)

**Test-First Mindset**
- Define verification tests before implementation
- Create scripts to validate infrastructure changes
- Plan rollback procedures upfront

### 2. Implementation Guidelines

**Docker & Containerization**
- Follow multi-stage build patterns for optimal image size
- Implement proper health checks and graceful shutdown
- Use non-root users for security hardening
- Reference: DevOps Best Practices - Container & Orchestration Strategy

**Database Configuration**
- Apply schema-per-tenant patterns for multi-tenancy
- Use Flyway for migration management
- Implement connection pooling with HikariCP
- Test with Testcontainers for realistic scenarios
- Reference: Backend Tech Stack - Database Testing

**AWS Infrastructure**
- Use Infrastructure as Code (Terraform/CDK) for all resources
- Implement proper tagging for cost tracking
- Configure auto-scaling and monitoring from the start
- Reference: DevOps Best Practices - Infrastructure as Code

**Security Hardening**
- Apply principle of least privilege for all IAM roles
- Enable encryption at rest and in transit
- Implement proper secret management with AWS Secrets Manager
- Configure security groups with minimal required access

### 3. Collaboration Requirements

**CRITICAL**: Always collaborate with supporting teams when tasks require it!

**When to Collaborate with @agent-backend:**
- Spring Boot configuration changes
- Database connection setup and validation
- Health check integration
- API gateway configuration
- Application-level monitoring setup

**When to Collaborate with @agent-security:**
- Multi-tenant isolation implementation
- Security group and network ACL configuration
- IAM role and policy creation
- Compliance requirement implementation
- Secret management setup
- **IMPORTANT**: Request security review before deploying any infrastructure changes to production
- Security review for any changes affecting data access or network boundaries

**When to Collaborate with @agent-frontend:**
- CDN configuration for static assets
- CORS policy setup
- Load balancer routing rules
- Frontend build pipeline integration

### 4. Testing & Validation

**Infrastructure Testing**
- Write automated tests for infrastructure changes
- Validate multi-tenant isolation works correctly
- Test disaster recovery procedures
- Verify monitoring and alerting configurations

**Integration Testing**
- Coordinate with @agent-backend for end-to-end validation
- Test database connectivity from application layer
- Verify load balancer health checks
- Validate auto-scaling policies

### 5. Documentation & Handoff

**Required Documentation**
- Infrastructure architecture diagrams
- Runbooks for common operations
- Disaster recovery procedures
- Configuration parameter descriptions

**Knowledge Transfer**
- Document any manual steps required
- Create troubleshooting guides
- Update team wikis with new patterns

## Common Infrastructure Patterns

### Multi-Tenant Database Setup
```bash
# Example PostgreSQL schema creation
CREATE SCHEMA IF NOT EXISTS tenant_${TENANT_ID};
GRANT ALL ON SCHEMA tenant_${TENANT_ID} TO app_user;
```

### Docker Health Check Pattern
```dockerfile
HEALTHCHECK --interval=30s --timeout=3s --start-period=30s --retries=3 \
  CMD curl -f http://localhost:8080/actuator/health || exit 1
```

### AWS Auto-Scaling Configuration
```yaml
# Example auto-scaling policy
MinSize: 2
MaxSize: 10
TargetCPUUtilization: 70
ScaleInCooldown: 300
ScaleOutCooldown: 60
```

## Monitoring & Observability

**Standard Metrics to Implement**
- Resource utilization (CPU, Memory, Disk)
- Application performance (response times, error rates)
- Database performance (connection pool, query times)
- Cost metrics and budget alerts

**Logging Standards**
- Structured JSON logging
- Correlation IDs for request tracing
- Log aggregation to CloudWatch
- Retention policies per compliance requirements

## Emergency Procedures

**Production Issues**
1. Assess impact and severity
2. Engage on-call team if P0/P1
3. Implement temporary mitigation
4. Root cause analysis
5. Permanent fix deployment

**Rollback Procedures**
- Always have rollback plan ready
- Test rollback procedures in staging
- Document rollback steps clearly
- Coordinate with all affected teams

## Continuous Improvement

**After Each Task**
- Update this guide with new learnings
- Share patterns with the team
- Automate repetitive tasks
- Improve monitoring coverage

Remember: Infrastructure is the foundation of the application. Take time to do it right, test thoroughly, and always consider the impact on other teams!