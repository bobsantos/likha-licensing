# Plan Task Deliverables Command

## Task context

You are a product team tasked with creating delivery plans for tasks. This command will:
- Re-evaluate the current plan if there's an in_progress task (only one task should be in_progress at a time)
- Create a plan for the next pending task if no task is currently in_progress (using Implementation Timeline)

You should use the appropriate subagents to accomplish this task through collaborative analysis. The lead agent should be determined by the task owner (Backend/Frontend/Infrastructure/Design/PM), with other agents as collaborators.

You only need to generate the delivery plan and nothing else. Do not implement anything yet.

**CRITICAL**: Focus on DELIVERABLE PLANNING, not implementation details. Plans should specify what needs to be delivered and in what sequence, not how to implement it.

## Task description and rules

You are tasked with creating a comprehensive delivery plan by:

1. **Reading the task file** at `.claude/likha-vibe-coding/prod-dev/tasks.md`
2. **Checking for in_progress tasks** - there should only be ONE task in_progress at any time
3. **If in_progress task exists**: Re-evaluate the current plan
4. **If NO in_progress task**: Use the Implementation Timeline section to determine the next task
5. **Creating a delivery plan** based on the findings

### CRITICAL OUTPUT REQUIREMENT

The delivery plan MUST be generated at: `.claude/likha-vibe-coding/prod-dev/plan.md`

Do NOT create the plan file in:
- scratch/ directory
- root directory  
- any other location

Use the Write tool with the EXACT path: `.claude/likha-vibe-coding/prod-dev/plan.md`

**IMPORTANT**: Use `.claude/` (with dot prefix) NOT `@.claude/` to reference the existing .claude directory in the repository.

### RESTRICTED FILE ACCESS - MANDATORY COMPLIANCE

**ALLOWED FILES AND DIRECTORIES ONLY:**

- `.claude/likha-vibe-coding/prod-dev/tasks.md` (current task file with timeline)
- `.claude/likha-vibe-coding/templates/*` (all files in templates directory)
- `.claude/likha-vibe-coding/data/*` (all files in data directory)

**CRITICAL RESTRICTIONS:**

1. **FORBIDDEN ACCESS**: You and ALL subagents are PROHIBITED from accessing any files or directories outside the allowed list above.

2. **SPECIFICALLY FORBIDDEN:**
   - Do NOT access scratch/ directory or any files within it
   - Do NOT access root directory files
   - Do NOT access any other .claude/ subdirectories
   - Do NOT access src/, docs/, or any code directories
   - Do NOT access any files with .md, .txt, .json, .sql, .java, .ts, .js extensions outside allowed directories

3. **SUBAGENT COMPLIANCE**: ALL subagents (pm, backend, frontend, infra, designer) MUST be explicitly instructed to only access the allowed files above.

   **SUBAGENT INSTRUCTION TEMPLATE**: Each subagent prompt MUST include this exact text:

   ```
   CRITICAL FILE ACCESS RESTRICTIONS - MANDATORY COMPLIANCE:
   - ONLY access: .claude/likha-vibe-coding/prod-dev/tasks.md
   - ONLY access: .claude/likha-vibe-coding/templates/* files
   - ONLY access: .claude/likha-vibe-coding/data/* files
   - FORBIDDEN: ANY other files or directories including docs/, src/, root directory, scratch/, .git/, etc.
   - BEFORE accessing ANY file, verify the path starts with one of the allowed directories above
   - VIOLATION CONSEQUENCE: Task termination and violation report

   CRITICAL TASK FOCUS - DELIVERY PLANNING:
   - Focus ONLY on identifying WHAT needs to be delivered and WHEN
   - Do NOT specify HOW to implement (no implementation details)
   - Do NOT attempt to write code or create actual implementations
   - Create delivery specifications, not implementation solutions
   - Define delivery milestones and success criteria

   MVP DELIVERY APPROACH:
   - Prioritize delivery speed over comprehensive best practice implementation
   - Use best practices selectively - only essential patterns for task success
   - Defer advanced patterns to future iterations unless critical for MVP
   - Focus on "good enough" solutions that meet acceptance criteria
   - Choose simple, proven approaches over complex implementations
   ```

### Workflow

**STEP 0: MANDATORY FILE ACCESS VALIDATION**
Before launching any subagents, the main agent MUST:
1. List all files that will be accessed
2. Verify each path is in the allowed list
3. Confirm no other files will be accessed
4. State: "File access validation complete - only allowed files will be accessed"

**STEP 1: TASK STATUS ASSESSMENT**
- Read `.claude/likha-vibe-coding/prod-dev/tasks.md`
- Scan all tasks in the "Task Breakdown by Team" sections
- Look for any task with **Status**: in_progress (there should be only ONE)
- If in_progress task found: Note the task ID, owner, and details for re-evaluation
- If NO in_progress task: Proceed to analyze the "Implementation Timeline" section
- **CRITICAL**: Identify task owners to determine which agent should lead the planning

**STEP 2: DELIVERY PLANNING**

**If IN_PROGRESS task found (only one allowed):**
1. **Identify Lead Agent Based on Current Task Owner**
   - Find the current in_progress task(s) in tasks.md
   - Identify the owner(s) of in_progress tasks
   - The agent matching the task owner becomes the lead (e.g., if owner is "Backend", backend agent leads)
   - If multiple owners, prioritize based on critical path

2. **Lead Agent - Plan Re-evaluation**
   - Analyze tasks for the in_progress story from tasks.md
   - Identify which tasks are completed vs. pending
   - Identify optimization opportunities and potential blockers in their domain
   - Update delivery timeline and milestone projections
   - Reassess priorities and resource allocation

3. **Collaborating Agents - Domain Re-evaluation**
   - All other agents (pm, backend, frontend, infra, designer) provide input
   - Review task progress in their respective domains
   - Identify any delivery risks or blockers
   - Suggest plan adjustments or alternative approaches
   - Update delivery specifications as needed

**If NO IN_PROGRESS tasks (all pending):**
1. **Use Implementation Timeline to Identify Next Task**
   - Navigate to the "Implementation Timeline" section in tasks.md
   - Review the timeline phases (e.g., Days 1-2, Days 2-3, etc.)
   - Identify which tasks should be started next based on:
     - Current completed tasks
     - Dependencies satisfied
     - Timeline sequence
   - Note parallel execution opportunities vs. sequential requirements
   - **IMPORTANT**: If multiple task candidates exist for the same timeline phase:
     - All agents who own candidate tasks should collaborate
     - Lead and collaborating agents must jointly decide task prioritization
     - Consider factors: critical path, team availability, dependency chains, business value
     - Document the prioritization rationale in the delivery plan

2. **Lead Agent Selection and Prioritization**
   - If single task owner: That agent becomes the lead
   - If multiple task owners in same phase:
     - Agent with most critical path tasks leads
     - All task owners participate in prioritization discussion
     - Collaborative decision on which tasks to start first
     - Consider parallel execution capacity across teams

3. **Lead Agent - Delivery Strategy Planning**
   - Define delivery milestones and key checkpoints for their domain
   - Identify critical path and potential blockers
   - Plan resource allocation and timeline
   - Coordinate with other domains for dependencies
   - Document task prioritization decisions and rationale

4. **Collaborating Agents - Domain-Specific Planning**
   - All other agents analyze their domain-specific tasks from tasks.md
   - Define what needs to be delivered in their area
   - Identify dependencies and integration points
   - Specify delivery sequence and handoff requirements
   - Provide input on task prioritization when multiple candidates exist

### Output Format

The generated delivery plan should include:

1. **Executive Summary**
   - Current status (re-evaluation or new planning)
   - Target user story ID and title
   - Key deliverables overview
   - Timeline summary

2. **Current Status Assessment**
   - User story: [ID - Title]
   - Story status: [in_progress or pending]
   - Total tasks: [number]
   - Completed tasks: [number]
   - Pending tasks: [number]
   - Any identified blockers or risks

3. **Delivery Roadmap**
   - **Phase 1: [Name]** (Days X-Y)
     - Key deliverables
     - Critical tasks to complete
     - Dependencies
   - **Phase 2: [Name]** (Days X-Y)
     - Key deliverables
     - Critical tasks to complete
     - Dependencies
   - Continue for all phases...

4. **Task Prioritization**
   - **Critical Path Tasks** (must complete first)
     - Task IDs and brief descriptions
   - **Parallel Development Opportunities**
     - Tasks that can be done simultaneously
   - **Deferred Tasks** (if any)
     - Tasks that can wait for later phases

5. **Team Focus Areas**
   - **Backend Team**
     - Primary deliverables this phase
     - Key tasks to focus on
   - **Frontend Team**
     - Primary deliverables this phase
     - Key tasks to focus on
   - **Infrastructure Team**
     - Primary deliverables this phase
     - Key tasks to focus on
   - **Design Team**
     - Primary deliverables this phase
     - Key tasks to focus on

6. **Success Metrics & Milestones**
   - **Week 1 Goals**
     - Specific deliverables to complete
   - **Week 2 Goals**
     - Specific deliverables to complete
   - **Definition of Done**
     - Checklist for story completion

7. **Risk Mitigation**
   - Identified risks
   - Mitigation strategies
   - Contingency plans

### Validation Requirements

After generating the delivery plan, confirm:
- The file was created at `.claude/likha-vibe-coding/prod-dev/plan.md`
- The correct planning mode was used based on story status
- All tasks from tasks.md are accounted for in the plan
- Timeline and dependencies are realistic and actionable
- Plan provides clear guidance for all teams

### Guidelines

- Base all planning on actual tasks from tasks.md
- Create actionable delivery plans with clear milestones
- Focus on practical delivery guidance for the development team
- Consider technical dependencies and integration requirements
- Ensure plans align with business value and success metrics
- Create delivery milestones that are measurable and time-bound
- Provide specific task IDs when referencing tasks from tasks.md