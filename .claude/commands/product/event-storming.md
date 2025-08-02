# Event Storming Command

## Task context

You are conducting an event storming session to identify domain events, aggregates, and bounded contexts based on the product requirements documented in the PRD. Your goal is to create comprehensive domain modeling documentation that will inform the system architecture and implementation.

**CRITICAL: IMMEDIATE DELEGATION REQUIRED**

You MUST delegate this entire task to the backend agent immediately upon receiving this command. Do NOT perform any investigation, file reading, or analysis yourself. The backend agent will lead the event storming session and collaborate with pm, frontend, infra, designer, and security agents as needed.

Delegate with: "Lead an event storming session using the current PRD as the basis. You will facilitate the session and collaborate with pm, frontend, infra, designer, and security agents to identify domain events, aggregates, and bounded contexts. Create comprehensive documentation following the workflow specified in this command."

**IMPORTANT**: Event storming is a collaborative Domain-Driven Design technique that identifies:

- Domain Events (things that happen in the business)
- Commands (actions that trigger events)
- Aggregates (business entities that enforce consistency)
- Bounded Contexts (logical boundaries in the domain)
- Read Models (data projections for queries)
- Policies (business rules that react to events)

## Task description and rules

### CRITICAL OUTPUT REQUIREMENT

The event storming documentation MUST be generated at: docs/domain/event-storming/{timestamp}-{product-name}-event-storming.md

Where:
- {timestamp} = Current timestamp in format YYYYMMDDHHMMSS
- {product-name} = Derived from the PRD title/product name, converted to kebab-case

Do NOT create the documentation in:

- scratch/ directory
- root directory
- .claude/ directory
- any other location

Use the Write tool with the generated path following the naming convention above.

### REQUIRED INPUT

The event storming session MUST be based on the existing PRD located at:

**INPUT FILE: .claude/likha-vibe-coding/prod-dev/prd.md**

This PRD contains the business requirements, user stories, and functional specifications that will inform the domain modeling.

### RESTRICTED FILE ACCESS - MANDATORY COMPLIANCE

**ALLOWED FILES AND DIRECTORIES ONLY:**

- .claude/likha-vibe-coding/prod-dev/prd.md (required input)
- docs/domain/event-storming/ (event storming output directory)
- docs/domain/domains.md (main domain documentation to be updated)

**CRITICAL RESTRICTIONS:**

1. **FORBIDDEN ACCESS**: You and ALL subagents are PROHIBITED from accessing any files or directories outside the allowed list above.

2. **SPECIFICALLY FORBIDDEN:**
   - Do NOT access scratch/ directory or any files within it
   - Do NOT access src/, test/, or any code directories
   - Do NOT access any other .claude/ subdirectories beyond the PRD
   - Do NOT access any database schema files or implementation code

3. **SUBAGENT COMPLIANCE**: ALL subagents (backend, pm, frontend, infra, designer, security) MUST be explicitly instructed to only access the allowed files above.

4. **VERIFICATION REQUIRED**: Before using any file path, verify it matches the allowed list exactly.

### Workflow

When conducting the event storming session use this workflow step-by-step:

1. **Read and Analyze the PRD**
   - Read the PRD at .claude/likha-vibe-coding/prod-dev/prd.md
   - Extract business processes, user stories, and functional requirements
   - Identify key business capabilities and workflows

2. **Identify Domain Events**
   - Use backend agent (lead) with pm agent for business process understanding
   - Extract events from user stories and business processes described in the PRD
   - Focus on business-meaningful events, not technical implementation details

3. **Map Commands and Actors**
   - Use pm agent (lead) with backend agent for command identification
   - Identify commands that trigger events based on user actions and system processes
   - Map actors (users/systems) that issue commands

4. **Define Aggregates and Boundaries**
   - Use backend agent (lead) with designer agent for consistency boundaries
   - Group related events around business entities
   - Identify aggregate roots and consistency boundaries

5. **Establish Bounded Contexts**
   - Use backend agent (lead) with infra agent for system boundaries
   - Define logical boundaries between different business capabilities
   - Consider team structure and data ownership

6. **Design Read Models and Policies**
   - Use frontend agent (lead) with backend agent for query optimization
   - Design read models for search and reporting requirements
   - Identify business policies that react to domain events

7. **Security and Compliance Considerations**
   - Use security agent to review multi-tenant requirements
   - Ensure audit events and compliance tracking are included
   - Validate access control boundaries align with domain boundaries

8. **Create Event Storming Documentation**
   - Ensure docs/domain/event-storming/ directory exists
   - Generate appropriate filename using timestamp and product name from PRD
   - Use comprehensive documentation format specified below

9. **Update Main Domain Documentation**
   - Read the current docs/domain/domains.md file
   - Update it with key findings from the event storming session
   - Include bounded contexts, main aggregates, and domain overview
   - Maintain existing content while incorporating new insights

### Documentation Structure

The event storming documentation MUST include these sections:

1. **Executive Summary**
   - High-level domain overview
   - Key bounded contexts identified
   - Primary business processes modeled

2. **Event Storming Session Details**
   - Participants (agents involved)
   - Session methodology
   - Key insights discovered

3. **Domain Events**
   - Complete list of domain events
   - Event descriptions and business meaning
   - Event data/payload definitions

4. **Commands and Actors**
   - Commands that trigger events
   - User types and system actors
   - Command-to-event mappings

5. **Aggregates and Entities**
   - Business aggregates identified
   - Aggregate responsibilities
   - Consistency boundaries

6. **Bounded Contexts**
   - Context boundaries and responsibilities
   - Context relationships and dependencies
   - Data flow between contexts

7. **Read Models and Projections**
   - Query patterns from the PRD
   - Optimized read models for UI requirements
   - Reporting and analytics projections

8. **Business Policies and Rules**
   - Event-driven policies
   - Business rule enforcement
   - Cross-context coordination

9. **Implementation Recommendations**
   - Architecture patterns suggested
   - Technology alignment with current stack
   - Migration considerations

10. **Next Steps**
    - Recommended follow-up activities
    - Technical design priorities
    - Implementation roadmap suggestions

### Main Domain Documentation Update

After creating the event storming documentation, you MUST update the main domain documentation file at docs/domain/domains.md to include:

1. **Domain Overview Summary**
   - High-level summary of the business domain
   - Key business capabilities identified
   - Primary value streams

2. **Bounded Contexts Directory**
   - List of all bounded contexts identified
   - Brief description of each context's responsibility
   - Context relationships and dependencies

3. **Core Aggregates**
   - Main business aggregates across all contexts
   - Aggregate responsibilities and key behaviors
   - Cross-aggregate coordination patterns


**IMPORTANT**: Preserve any existing content in domains.md and integrate the new information harmoniously. If the file doesn't exist, create it with a comprehensive structure.

### Guidelines

- Focus on business events, not technical implementation
- Use ubiquitous language from the PRD
- Consider any multi-tenant or scaling requirements mentioned in the PRD
- Align with the technology stack specified in the PRD
- Consider the MVP scope and priorities from the PRD
- Keep documentation actionable for development teams

**CRITICAL**: The backend agent MUST lead this session as Domain-Driven Design and event storming require deep understanding of business logic, aggregate design, and domain modeling - core backend architecture responsibilities.