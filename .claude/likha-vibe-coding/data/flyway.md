# Flyway Migration Best Practices

This document outlines best practices for working with Flyway database migrations in the Likha Licensing Platform.

## Core Principles

### 1. NEVER Modify Existing Migrations
- **CRITICAL**: Never update existing migration files (V1__, V2__, V3__, etc.)
- Existing migrations may have already been applied to production databases
- Modifying existing migrations can cause checksum failures and deployment issues
- Once committed to the repository, migrations are immutable

### 2. Always Create New Migrations
- For any schema changes, create a NEW migration file with the next sequential version
- Use proper versioning: V6__, V7__, V8__, etc.
- Include descriptive names: `V6__Add_Contract_Status_Column.sql`

### 3. Write Additive Changes
- Design migrations to work with existing data
- Use `ALTER TABLE ADD COLUMN IF NOT EXISTS` when possible
- Handle data migration carefully with proper rollback considerations

## Migration Naming Convention

```
V{version}__{description}.sql

Examples:
- V1__Initial_Schema.sql
- V2__Contract_Management_Schema.sql
- V6__Add_User_Permissions.sql
- V7__Update_Contract_Status_Enum.sql
```

## Common Migration Patterns

### Adding New Tables
```sql
-- V6__Add_New_Feature_Tables.sql
CREATE TABLE IF NOT EXISTS new_feature (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Adding Columns
```sql
-- V7__Add_Status_Column.sql
ALTER TABLE contracts 
ADD COLUMN IF NOT EXISTS status VARCHAR(50) DEFAULT 'ACTIVE';
```

### Data Migrations
```sql
-- V8__Migrate_Legacy_Data.sql
-- Always include rollback considerations
UPDATE contracts 
SET status = 'ACTIVE' 
WHERE status IS NULL;
```

### Multi-tenant Considerations
```sql
-- Apply changes to all tenant schemas
DO $$
DECLARE
    tenant_schema TEXT;
BEGIN
    FOR tenant_schema IN 
        SELECT schema_name FROM information_schema.schemata 
        WHERE schema_name LIKE 'tenant_%'
    LOOP
        EXECUTE format('ALTER TABLE %I.contracts ADD COLUMN IF NOT EXISTS new_field VARCHAR(100)', tenant_schema);
    END LOOP;
END $$;
```

## Testing Migrations

### 1. Local Testing
- Test migrations on a copy of production data
- Verify forward migration works
- Test rollback procedures where applicable

### 2. Staging Validation
- Apply migrations to staging environment first
- Validate application functionality after migration
- Monitor performance impact

### 3. Integration Tests
- Include migration testing in automated test suites
- Use Testcontainers to validate migration sequences
- Test with realistic data volumes

## Error Handling

### Checksum Failures
If you encounter checksum failures:
1. Never modify the existing migration
2. Create a repair migration if needed
3. Use `flyway repair` command only in development

### Failed Migrations
- Review the migration SQL for syntax errors
- Check for missing dependencies or constraints
- Create a new migration to fix issues, don't modify the failed one

## Rollback Strategy

### Forward-Only Approach
- Design migrations to be forward-compatible
- Avoid destructive operations when possible
- Plan for gradual feature rollouts

### Emergency Rollbacks
- Keep backups before major migrations
- Document rollback procedures
- Test rollback scenarios in staging

## Production Deployment

### Pre-deployment Checklist
- [ ] Migration tested locally
- [ ] Migration tested in staging
- [ ] Backup procedures verified
- [ ] Rollback plan documented
- [ ] Performance impact assessed

### Deployment Process
1. Create database backup
2. Apply migrations in maintenance window
3. Verify application startup
4. Monitor for issues
5. Document any problems and solutions

## Common Mistakes to Avoid

1. **Modifying existing migrations** - Creates checksum mismatches
2. **Non-idempotent operations** - Migrations should be repeatable
3. **Large data migrations in single transaction** - Can cause timeouts
4. **Missing IF NOT EXISTS clauses** - Causes failures on re-runs
5. **Forgetting multi-tenant schemas** - Breaks tenant isolation

## Tools and Commands

### Useful Flyway Commands
```bash
# Check migration status
mvn flyway:info

# Validate migrations
mvn flyway:validate

# Apply migrations
mvn flyway:migrate

# Repair checksums (development only)
mvn flyway:repair
```

### Development Workflow
1. Create new migration file
2. Test locally with `mvn flyway:migrate`
3. Verify application works
4. Commit migration file
5. Deploy to staging for validation

## Integration with Spring Boot

### Configuration
```properties
# application.properties
spring.flyway.enabled=true
spring.flyway.locations=classpath:db/migration
spring.flyway.baseline-on-migrate=true
spring.flyway.validate-on-migrate=true
```

### Testing Configuration
```java
// Use existing TestDatabaseConfiguration
@TestConfiguration
@Profile("test")
public class TestDatabaseConfiguration {
    // Flyway automatically runs migrations in tests
}
```

## When Schema Changes Are Needed

1. **Identify the change requirement**
2. **Create new migration file** with next version number
3. **Write backward-compatible SQL** when possible
4. **Test thoroughly** in development and staging
5. **Document the change** and rationale
6. **Deploy with proper backup procedures**

Remember: Migrations are permanent records. Think of them as immutable database history.