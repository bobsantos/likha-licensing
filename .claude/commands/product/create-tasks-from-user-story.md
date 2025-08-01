# Create Tasks From User Story Command

## Task context

You are a product team tasked with creating focused development tasks from a specific user story in the prioritized user stories document.

You should use the pm (as lead), infra, frontend, backend, and designer subagents to accomplish this task through collaborative analysis.

You only need to generate the focused task breakdown and nothing else. Do not implement anything yet.

**CRITICAL**: Focus on TASK DELIVERABLES, not implementation details. Tasks should specify what needs to be delivered, not how to implement it.

**MVP DELIVERY FOCUS**: Prioritize delivery speed over perfection. Use best practices selectively - implement only essential patterns needed for the user story success criteria. Defer comprehensive implementations of best practices to future iterations.

**DEVELOPER EXPERIENCE PRIORITY**: Always include foundational development infrastructure that enables team velocity. Even if it requires upfront investment, prioritize development workflow improvements that accelerate all subsequent work (containerization, dev environments, tooling setup, etc.).

## Task description and rules

You are tasked with creating focused development tasks for the next available user story from the prioritized user stories located at .claude/likha-vibe-coding/prod-dev/user-story-priorities.md.

The system will automatically identify the next user story to work on by checking the Implementation Sequence Recommendations section and finding the first story with status "pending" (skipping any stories marked as "done", "cancelled", "closed", or "in_progress").

### CRITICAL OUTPUT REQUIREMENT

The focused task breakdown MUST be generated at: .claude/likha-vibe-coding/prod-dev/user-story-[NEXT_STORY_ID]-tasks.md

Where [NEXT_STORY_ID] is the automatically identified next story ID (e.g., US-001, US-002, etc.)

Do NOT create the tasks file in:

- scratch/ directory
- root directory
- any other location

Use the Write tool with the EXACT path: .claude/likha-vibe-coding/prod-dev/user-story-[NEXT_STORY_ID]-tasks.md

**IMPORTANT**: Use `.claude/` (with dot prefix) NOT `@.claude/` to reference the existing .claude directory in the repository.

### RESTRICTED FILE ACCESS - MANDATORY COMPLIANCE

**ALLOWED FILES AND DIRECTORIES ONLY:**

- .claude/likha-vibe-coding/prod-dev/user-story-priorities.md (source prioritized user stories)
- .claude/likha-vibe-coding/templates/\* (all files in templates directory)
- .claude/likha-vibe-coding/data/\* (all files in data directory)

**CRITICAL RESTRICTIONS:**

1. **FORBIDDEN ACCESS**: You and ALL subagents are PROHIBITED from accessing any files or directories outside the allowed list above.

2. **SPECIFICALLY FORBIDDEN:**

   - Do NOT access scratch/ directory or any files within it
   - Do NOT access root directory files
   - Do NOT access any other .claude/ subdirectories
   - Do NOT access src/, docs/, or any code directories
   - Do NOT access any files with .md, .txt, .json, .sql, .java, .ts, .js extensions outside allowed directories

3. **SUBAGENT COMPLIANCE**: ALL subagents (pm, backend, frontend, infra, designer) MUST be explicitly instructed to only access the allowed files above. Any subagent that attempts to access forbidden files should be immediately stopped.

   **SUBAGENT INSTRUCTION TEMPLATE**: Each subagent prompt MUST include this exact text:

   ```
   CRITICAL FILE ACCESS RESTRICTIONS - MANDATORY COMPLIANCE:
   - ONLY access: .claude/likha-vibe-coding/prod-dev/user-story-priorities.md
   - ONLY access: .claude/likha-vibe-coding/templates/* files
   - ONLY access: .claude/likha-vibe-coding/data/* files
   - FORBIDDEN: ANY other files or directories including docs/, src/, root directory, scratch/, .git/, etc.
   - BEFORE accessing ANY file, verify the path starts with one of the allowed directories above
   - VIOLATION CONSEQUENCE: Task termination and violation report

   CRITICAL TASK FOCUS - DO NOT IMPLEMENT:
   - Focus ONLY on identifying WHAT needs to be delivered (deliverables)
   - Do NOT specify HOW to implement (no implementation details)
   - Do NOT attempt to write code or create actual implementations
   - Create task specifications, not task solutions
   
   MVP DELIVERY APPROACH:
   - Prioritize delivery speed over comprehensive best practice implementation
   - Use best practices selectively - only essential patterns for user story success
   - Defer advanced patterns (complex caching, extensive monitoring, perfect accessibility) to future iterations
   - Focus on "good enough" solutions that meet acceptance criteria and can be improved later
   - Choose simple, proven approaches over cutting-edge or complex implementations
   
   DEVELOPER EXPERIENCE REQUIREMENTS:
   - ALWAYS include containerization (Docker) for environment reproducibility as foundational requirement
   - ALWAYS include development environment setup that enables consistent team workflows
   - ALWAYS consider tooling and infrastructure that accelerates development velocity
   - Treat development workflow improvements as critical path items, not optional enhancements
   - Prioritize foundational development infrastructure even if it requires upfront time investment
   ```

4. **VERIFICATION REQUIRED**: Before using any file path, verify it matches the allowed list exactly.

**VIOLATION CONSEQUENCES**: If any file outside the allowed list is accessed, immediately stop the task and report the violation to the user.

**MANDATORY PRE-EXECUTION VALIDATION**: Before launching any subagent, the main agent MUST:

1. Explicitly state which files each subagent will access
2. Verify each file path starts with one of the allowed directories
3. Confirm no forbidden paths will be accessed
4. Only proceed if all file paths are validated as allowed

### Workflow

**STEP 0: MANDATORY FILE ACCESS VALIDATION**
Before launching any subagents, the main agent MUST:

1. List all files that will be accessed: .claude/likha-vibe-coding/prod-dev/user-story-priorities.md
2. Verify this path is in the allowed list
3. Confirm no other files will be accessed
4. State: "File access validation complete - only allowed files will be accessed"

When executing the task with subagents follow this workflow:

1. **Auto-Identify Next User Story**

   - Read the Implementation Sequence Recommendations section in the prioritized user stories document
   - First, check if any story has **Status**: in_progress
   - If an in_progress story exists, STOP and report: "Cannot create new tasks - Story [ID] is currently in progress. Complete it first."
   - If no stories are in_progress, scan through all user stories in their documented sequence order
   - Find the first story with **Status**: pending (skip stories marked as "done", "cancelled", or "closed")
   - Extract all relevant details, priorities, and implementation notes for the identified story

2. **PM Agent (Lead) - Task Planning Strategy**

   - Analyze the user story requirements and success criteria
   - Break down into logical development phases (what deliverables are needed)
   - **CRITICAL**: Identify foundational development infrastructure needs (containerization, dev environments, tooling)
   - Define task dependencies and critical path with developer experience as foundational priority
   - Establish acceptance criteria for each task deliverable
   - Ensure development workflow improvements are prioritized even if they require upfront time investment

3. **Backend Agent - Backend Task Breakdown**

   - Identify what backend deliverables are needed (APIs, services, data models)
   - Define what endpoints and data structures need to be created
   - Specify what database changes need to be delivered
   - Identify what security and validation deliverables are required

4. **Frontend Agent - Frontend Task Breakdown**

   - Identify what UI/UX deliverables are needed (components, pages, flows)
   - Define what component deliverables and data integration points are required
   - Specify what user interaction deliverables need to be created
   - Identify what frontend integration deliverables are needed

5. **Infrastructure Agent - Infrastructure Task Breakdown**

   - **PRIORITY 1**: Identify development environment deliverables (Docker containers, dev database setup, local tooling)
   - **PRIORITY 2**: Identify what deployment and infrastructure deliverables are needed
   - Define what monitoring, logging, and observability deliverables are required
   - Specify what configuration and environment deliverables need to be created
   - Identify what scalability and performance deliverables are needed
   - **CRITICAL**: Always include containerization and environment reproducibility as foundational requirements

6. **Designer Agent - Design Task Breakdown**

   - Identify what design deliverables are needed (wireframes, mockups, specifications)
   - Define what design artifacts and documentation need to be created
   - Specify what accessibility and usability deliverables are required
   - Identify what design system deliverables need to be produced

7. **Generate Focused Task List**
   - Compile all agent inputs into comprehensive task breakdown
   - Prioritize tasks within the user story scope
   - Define clear deliverables and acceptance criteria
   - Create implementation timeline and resource allocation

### Task Breakdown Framework

Use the following structure for each identified task:

**Task Structure:**

- **Task ID**: Unique identifier (e.g., US-001-T001)
- **Title**: Clear, actionable task description
- **Owner**: Primary responsible team (Backend/Frontend/Infrastructure/Design)
- **Status**: pending (default for new tasks)
- **Priority**: Critical/High/Medium/Low within user story scope
- **Estimated Effort**: Time estimate in hours/days
- **Dependencies**: List of prerequisite tasks
- **Acceptance Criteria**: Specific, measurable deliverable completion requirements
- **Deliverable Notes**: What needs to be delivered (not how to implement it)

**Task Categories:**

- **Setup Tasks**: Environment, tooling, and infrastructure preparation (**ALWAYS INCLUDE - FOUNDATIONAL PRIORITY**)
  - Docker containerization for development and production
  - Development environment reproducibility
  - Local database setup and tooling
  - Development workflow automation
- **Core Implementation**: Primary feature development
- **Integration Tasks**: API integration, data flow, component connections
- **Testing Tasks**: Unit tests, integration tests, user acceptance testing
- **Documentation Tasks**: Technical docs, user guides, API documentation
- **Deployment Tasks**: Production readiness, monitoring, rollout

### Output Format

The generated task breakdown should include:

1. **User Story Overview**

   - User story ID and title
   - Priority level and business value
   - Success criteria summary

2. **Task Breakdown by Team**

   - Backend Tasks (with deliverable specifications)
   - Frontend Tasks (with UI/UX deliverable requirements)
   - Infrastructure Tasks (with deployment deliverable needs)
   - Design Tasks (with design deliverable requirements)

3. **Implementation Timeline**

   - Task sequence and dependencies
   - Critical path identification
   - Resource allocation recommendations
   - Risk mitigation strategies

4. **Acceptance Criteria**

   - Story-level acceptance criteria
   - Task-level completion requirements
   - Definition of done checklist

5. **Deliverable Specifications**
   - API contract deliverables and data model deliverables
   - UI component deliverables and design specifications
   - Infrastructure deliverable requirements
   - Security and compliance deliverables

### Validation Requirements

After generating the task breakdown, confirm:

- The file was created at .claude/likha-vibe-coding/prod-dev/user-story-[NEXT_STORY_ID]-tasks.md
- The next available user story was correctly identified and analyzed
- All necessary implementation aspects are covered
- Tasks are specific, actionable, and measurable
- Dependencies and timeline are realistic
- No other task files were created in different locations

### Developer Experience Considerations

**Consider including these foundational development infrastructure tasks when they would accelerate team velocity:**

- **Docker development environment**: Container setup for local development consistency
- **Environment reproducibility**: Setup that works identically across all team members  
- **Development tooling**: Hot reload, debugging, and workflow automation where beneficial
- **Local database setup**: Containerized database when complex multi-tenant setup is needed
- **CI/CD foundation**: Basic pipeline supporting the development workflow

**Guideline**: Invest in developer experience improvements early if they prevent repeated setup friction or enable faster iteration cycles throughout the project.

### Guidelines

- Base all tasks on the specific user story requirements and context
- Maintain consistency with the overall prioritization and MVP timeline
- Create tasks that are implementable within 1-3 days each
- Focus on actionable deliverables with clear acceptance criteria
- Consider technical dependencies and integration requirements
- Ensure tasks align with the user story's business value and success metrics
- Do not create tasks for requirements not specified in the source user story
- Focus on practical implementation guidance for the development team
