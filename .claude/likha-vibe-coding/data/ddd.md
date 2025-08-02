# Domain Driven Design Guide

## Core Principles

### Ubiquitous Language
A shared vocabulary between developers and domain experts that permeates all aspects of the project. This language should be used consistently in code, documentation, conversations, and user interfaces. When the business talks about a "Contract", the code should use the same term - not "Agreement" or "Deal".

### Bounded Context
A logical boundary within which a domain model is defined and applicable. Each bounded context has its own ubiquitous language and model. For example, "Customer" might mean different things in Sales context vs Support context. Bounded contexts help manage complexity by dividing large domains into smaller, more manageable parts.

### Domain Model
The conceptual model of the domain that incorporates both behavior and data. It represents the business rules, policies, and logic - not just data structures. The domain model should be isolated from technical concerns like databases or web frameworks.

## Architecture Patterns

### Aggregate Roots
An aggregate is a cluster of domain objects that can be treated as a single unit. The aggregate root is the only entry point to the aggregate - all external access must go through it. This ensures consistency and enforces invariants. For example, an Order aggregate might contain OrderItems, but you can only add items through the Order, not directly.

### Value Objects
Immutable objects that are defined by their attributes rather than identity. Two value objects with the same values are considered equal. Examples include Money, Address, or DateRange. They encapsulate validation and behavior related to their values.

### Domain Services
Stateless operations that don't naturally fit within an entity or value object. They encapsulate domain logic that involves multiple entities or complex calculations. For example, a PricingService might calculate discounts based on multiple factors.

### Repository Pattern
Provides an abstraction over data storage, allowing the domain layer to remain ignorant of persistence details. Repositories typically provide methods like `findById()`, `save()`, and domain-specific queries like `findActiveContracts()`.

## Code Organization

### Layered Architecture
- **Domain Layer**: Contains entities, value objects, domain services, and domain events
- **Application Layer**: Orchestrates domain objects to perform use cases
- **Infrastructure Layer**: Implements technical capabilities (database, messaging, etc.)
- **Presentation Layer**: Handles user interface and API concerns

### Dependency Direction
Dependencies should point inward toward the domain layer. The domain should not depend on infrastructure, application, or presentation layers. This is often achieved through dependency inversion - the domain defines interfaces that other layers implement.

### Domain Purity
The domain layer should be free of framework dependencies, database concerns, or other infrastructure details. This makes the domain model easier to test, understand, and maintain.

### Interface Segregation
Define small, focused interfaces rather than large, general-purpose ones. This allows different parts of the system to depend only on the methods they actually use.

## Implementation Guidelines

### Rich Domain Models
Entities should encapsulate both data and behavior. Avoid anemic domain models that are just data containers with getters and setters. For example, an Order should have methods like `addItem()`, `cancel()`, and `ship()` rather than just exposing its properties.

### Validation
Business rules and invariants should be enforced within domain objects. An entity should never be in an invalid state. Validation happens in constructors, factory methods, and state-changing methods.

### Domain Events
Events that capture something significant that happened in the domain. They enable loose coupling between bounded contexts and support event sourcing. Examples: OrderPlaced, PaymentReceived, ContractSigned.

### Anti-Corruption Layer
A layer that translates between different bounded contexts or external systems, preventing external models from corrupting your domain model. It acts as a buffer that maintains the integrity of your ubiquitous language.

## Testing Strategy

### Domain Unit Tests
Focus on testing business logic within entities, value objects, and domain services. These tests should be independent of infrastructure concerns and run quickly.

### Integration Tests
Verify that different parts of the system work together correctly, especially interactions between bounded contexts or with external systems.

### Acceptance Tests
End-to-end tests that validate complete business scenarios from the user's perspective. These ensure the system delivers the expected business value.

## Documentation

### Domain Model Diagrams
Visual representations showing relationships between entities, value objects, and aggregates. These help communicate the structure of the domain model to team members.

### Context Maps
Diagrams showing how different bounded contexts relate to each other. They document integration points, translation layers, and team boundaries.

### Business Rules Documentation
Clear documentation of domain constraints, invariants, and business logic. This serves as a reference for both developers and domain experts, ensuring shared understanding of the business rules.