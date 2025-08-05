/**
 * User Management bounded context.
 * 
 * Responsible for managing user accounts, tenant management, and security audit logs
 * within the multi-tenant licensing platform.
 * 
 * This module handles:
 * - User account lifecycle (creation, authentication, management)
 * - Tenant management and isolation
 * - Security audit logging for compliance and monitoring
 * 
 * Database tables:
 * - tenants: Multi-tenant organization data
 * - users: User account information and authentication
 * - security_audit_log: Security events and audit trail
 * 
 * Following Spring Modulith architecture patterns:
 * - Internal services are package-private and not exposed to other modules
 * - Public API is exposed through controller layer when needed
 * - Proper bounded context separation with clear responsibilities
 */
@org.springframework.modulith.ApplicationModule
package app.likha.users;