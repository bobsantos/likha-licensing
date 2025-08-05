/**
 * Contract Management Module for the Likha Licensing Platform.
 * 
 * This module encapsulates all contract management functionality following
 * Spring Modulith modular monolith architecture principles.
 * 
 * <h2>Module Structure</h2>
 * <ul>
 *   <li><strong>Public API:</strong> Controllers and DTOs exposed to other modules</li>
 *   <li><strong>Controllers:</strong> REST endpoints in {@code controller/} package</li>
 *   <li><strong>DTOs:</strong> Request/Response data transfer objects in {@code dto/} package</li>
 *   <li><strong>Internal Services:</strong> Business logic in {@code internal.service/} package</li>
 *   <li><strong>Internal Repositories:</strong> Data access in {@code internal.repository/} package</li>
 *   <li><strong>Internal Models:</strong> Domain entities in {@code internal.model/} package</li>
 * </ul>
 * 
 * <h2>Bounded Context</h2>
 * This module manages:
 * <ul>
 *   <li>Contract lifecycle management</li>
 *   <li>Contract health monitoring and validation</li>
 *   <li>Multi-tenant contract data isolation</li>
 *   <li>Contract-related infrastructure health checks</li>
 * </ul>
 * 
 * <h2>Spring Modulith Compliance</h2>
 * - Only controllers and DTOs in root package are exposed as public API
 * - All business logic is encapsulated in {@code internal.*} subpackages
 * - Other modules can only access public controllers and DTOs
 * - Inter-module communication happens through public APIs or domain events
 * - Internal services, repositories, and models are private to this module
 * 
 * @author Likha Development Team
 * @version 1.0
 * @since 1.0
 */
package app.likha.contracts;