/**
 * File Storage bounded context.
 * 
 * Responsible for managing file uploads, storage, and contract document handling
 * within the multi-tenant licensing platform.
 * 
 * This module handles:
 * - File upload session management
 * - Contract file storage and retrieval
 * - File metadata and access control
 * 
 * Database tables:
 * - upload_sessions: Temporary file upload tracking
 * - contract_files: Contract document storage and metadata
 * 
 * Following Spring Modulith architecture patterns:
 * - Internal services are package-private and not exposed to other modules
 * - Public API is exposed through controller layer when needed
 * - Proper bounded context separation with clear responsibilities
 */
@org.springframework.modulith.ApplicationModule
package app.likha.files;