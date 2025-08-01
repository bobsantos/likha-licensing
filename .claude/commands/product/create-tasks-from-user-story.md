# Create Tasks From User Story Command

## Task context

You are a product team tasked with creating focused development tasks from a specific user story in the prioritized user stories document.

You should use the pm (as lead), infra, frontend, backend, and designer subagents to accomplish this task through collaborative analysis.

You only need to generate the focused task breakdown and nothing else. Do not implement anything yet.

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
- .claude/likha-vibe-coding/templates/* (all files in templates directory)
- .claude/likha-vibe-coding/data/* (all files in data directory)

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
   - Break down into logical development phases
   - Define task dependencies and critical path
   - Establish acceptance criteria for each task

3. **Backend Agent - Backend Task Breakdown**
   - Identify specific backend implementation tasks
   - Define API endpoints, data models, and service layer requirements
   - Specify database schema changes or additions
   - Identify security and validation requirements

4. **Frontend Agent - Frontend Task Breakdown**
   - Identify specific UI/UX implementation tasks
   - Define component requirements and data flow
   - Specify user interaction patterns and state management
   - Identify integration points with backend APIs

5. **Infrastructure Agent - Infrastructure Task Breakdown**
   - Identify deployment and infrastructure requirements
   - Define monitoring, logging, and observability tasks
   - Specify configuration and environment setup needs
   - Identify scalability and performance considerations

6. **Designer Agent - Design Task Breakdown**
   - Identify user experience design requirements
   - Define wireframes, mockups, and design specifications needed
   - Specify accessibility and usability testing requirements
   - Identify design system component needs

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
- **Priority**: Critical/High/Medium/Low within user story scope
- **Estimated Effort**: Time estimate in hours/days
- **Dependencies**: List of prerequisite tasks
- **Acceptance Criteria**: Specific, measurable completion requirements
- **Technical Notes**: Implementation-specific guidance

**Task Categories:**
- **Setup Tasks**: Environment, tooling, and infrastructure preparation
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
   - Backend Tasks (with technical specifications)
   - Frontend Tasks (with UI/UX requirements)
   - Infrastructure Tasks (with deployment needs)
   - Design Tasks (with user experience requirements)

3. **Implementation Timeline**
   - Task sequence and dependencies
   - Critical path identification
   - Resource allocation recommendations
   - Risk mitigation strategies

4. **Acceptance Criteria**
   - Story-level acceptance criteria
   - Task-level completion requirements
   - Definition of done checklist

5. **Technical Specifications**
   - API contracts and data models
   - UI component specifications
   - Infrastructure requirements
   - Security and compliance considerations

### Validation Requirements

After generating the task breakdown, confirm:
- The file was created at .claude/likha-vibe-coding/prod-dev/user-story-[NEXT_STORY_ID]-tasks.md
- The next available user story was correctly identified and analyzed
- All necessary implementation aspects are covered
- Tasks are specific, actionable, and measurable
- Dependencies and timeline are realistic
- No other task files were created in different locations

### Guidelines

- Base all tasks on the specific user story requirements and context
- Maintain consistency with the overall prioritization and MVP timeline
- Create tasks that are implementable within 1-3 days each
- Focus on actionable deliverables with clear acceptance criteria
- Consider technical dependencies and integration requirements
- Ensure tasks align with the user story's business value and success metrics
- Do not create tasks for requirements not specified in the source user story
- Focus on practical implementation guidance for the development team