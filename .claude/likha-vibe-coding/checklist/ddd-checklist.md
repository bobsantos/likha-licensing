# Domain Driven Design Checklist

## Core Principles

- [ ] **Ubiquitous Language**: Use domain terminology consistently across code, documentation, and communication
- [ ] **Bounded Context**: Identify clear boundaries between different domains/subdomains
- [ ] **Domain Model**: Focus on business logic, not technical concerns

## Architecture Patterns

- [ ] **Aggregate Roots**: Ensure entities are accessed only through aggregate roots
- [ ] **Value Objects**: Use immutable value objects for data without identity
- [ ] **Domain Services**: Place business logic that doesn't belong to entities in domain services
- [ ] **Repository Pattern**: Abstract data access behind repository interfaces

## Code Organization

- [ ] **Layered Architecture**: Separate domain, application, infrastructure, and presentation layers
- [ ] **Dependency Direction**: Dependencies point inward toward the domain layer
- [ ] **Domain Purity**: Keep domain layer free of infrastructure concerns
- [ ] **Interface Segregation**: Define focused interfaces for different concerns

## Implementation Guidelines

- [ ] **Rich Domain Models**: Prefer behavior-rich entities over anemic data containers
- [ ] **Validation**: Implement business rules and validation in domain objects
- [ ] **Event Sourcing**: Consider domain events for important business state changes
- [ ] **Anti-Corruption Layer**: Protect domain model from external systems

## Testing Strategy

- [ ] **Domain Unit Tests**: Test business logic in isolation
- [ ] **Integration Tests**: Verify interactions between bounded contexts
- [ ] **Acceptance Tests**: Validate end-to-end business scenarios

## Documentation

- [ ] **Domain Model Diagrams**: Visualize entities, value objects, and relationships
- [ ] **Context Maps**: Document relationships between bounded contexts
- [ ] **Business Rules**: Clearly document domain constraints and invariants