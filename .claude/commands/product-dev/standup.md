# Standup Command

## Task context

You are a product manager tasked with running a standup to check the current delivery status and identify what tasks need to be worked on next. This command will analyze the current state of tasks and delivery plan to provide actionable guidance.

The pm agent will lead this standup and collaborate with other agents (backend, frontend, infrastructure, designer) to get a holistic view of the delivery status.

## Task description and rules

You are tasked with running a standup by:

1. **Reading the task breakdown** at `.claude/likha-vibe-coding/prod-dev/tasks.md`
2. **Reading the delivery plan** at `.claude/likha-vibe-coding/prod-dev/plan.md`
3. **Analyzing current progress** based on task statuses
4. **Collaborating with other agents** to understand domain-specific blockers and progress
5. **Identifying next tasks** based on the delivery roadmap and dependencies
6. **Presenting a clear standup report** with recommendations

### RESTRICTED FILE ACCESS - MANDATORY COMPLIANCE

**ALLOWED FILES AND DIRECTORIES ONLY:**

- `.claude/likha-vibe-coding/prod-dev/tasks.md` (task breakdown and statuses)
- `.claude/likha-vibe-coding/prod-dev/plan.md` (delivery plan and roadmap)

**CRITICAL RESTRICTIONS:**

1. **FORBIDDEN ACCESS**: The pm agent and ALL collaborating agents are PROHIBITED from accessing any files or directories outside the allowed list above.

2. **SPECIFICALLY FORBIDDEN:**
   - Do NOT access scratch/ directory or any files within it
   - Do NOT access root directory files
   - Do NOT access any other .claude/ subdirectories
   - Do NOT access src/, docs/, or any code directories
   - Do NOT access any files outside the prod-dev directory

3. **AGENT COMPLIANCE**: ALL agents MUST be explicitly instructed to only access the allowed files above.

   **AGENT INSTRUCTION TEMPLATE**: Each agent prompt MUST include this exact text:

   ```
   CRITICAL FILE ACCESS RESTRICTIONS - MANDATORY COMPLIANCE:
   - ONLY access: .claude/likha-vibe-coding/prod-dev/tasks.md
   - ONLY access: .claude/likha-vibe-coding/prod-dev/plan.md
   - FORBIDDEN: ANY other files or directories
   - BEFORE accessing ANY file, verify the path is one of the allowed files above
   - VIOLATION CONSEQUENCE: Task termination and violation report
   ```

### Workflow

**STEP 1: LAUNCH PM AGENT AS STANDUP LEAD**
- Launch the pm agent as the standup facilitator
- Include the file access restrictions in the prompt
- Instruct the pm agent to coordinate with other agents for domain-specific insights

**STEP 2: PM AGENT STANDUP FACILITATION**
The pm agent should:

1. **Initial Analysis**
   - Read tasks.md to understand overall task breakdown and statuses
   - Read plan.md to understand delivery phases and priorities
   - Identify which teams have tasks in current phase

2. **Collaborate with Domain Agents**
   - Backend agent: Review backend task progress, identify technical blockers
   - Frontend agent: Check frontend task status, UI/UX dependencies
   - Infrastructure agent: Assess infrastructure readiness, deployment blockers
   - Designer agent: Verify design deliverables, handoff status

3. **Synthesize Standup Report**
   - Compile insights from all agents
   - Cross-reference with delivery plan
   - Identify cross-team dependencies
   - Determine critical path and next actions

### Output Format

The pm agent should provide a standup report including:

1. **Standup Header**
   ```
   DAILY STANDUP - [User Story ID]: [Title]
   Date: [Current Date] | Day [X] of [Y]
   Phase: [Current Phase Name]
   Health: 🟢 On Track / 🟡 At Risk / 🔴 Blocked
   ```

2. **Progress Since Last Standup**
   ```
   YESTERDAY'S PROGRESS:
   ✅ Completed:
   - [Task ID]: [Task Title] ([Team])
   - [Task ID]: [Task Title] ([Team])
   
   🔄 In Progress:
   - [Task ID]: [Task Title] ([Team]) - [% complete]
   - [Task ID]: [Task Title] ([Team]) - [% complete]
   ```

3. **Today's Priorities**
   ```
   TODAY'S FOCUS:
   🎯 Critical Path Items:
   1. [Task ID]: [Task Title] ([Team])
      - Why: [Reason this is critical]
      - Blocks: [What this unblocks]
   
   📋 Parallel Work:
   - [Task ID]: [Task Title] ([Team])
   - [Task ID]: [Task Title] ([Team])
   ```

4. **Blockers & Dependencies**
   ```
   🚨 IMMEDIATE ATTENTION NEEDED:
   - [Blocker description]
     Impact: [What's affected]
     Action: [Required resolution]
     Owner: [Who needs to act]
   ```

5. **Metrics Update**
   ```
   BURNDOWN STATUS:
   - Tasks Remaining: [n]
   - Days Remaining: [n]
   - Velocity: [On Track/Behind/Ahead]
   ```

6. **Domain-Specific Insights**
   - **Backend Status**: Technical progress, API readiness, blockers
   - **Frontend Status**: UI implementation, integration status
   - **Infrastructure Status**: Environment setup, deployment readiness
   - **Design Status**: Design handoffs, pending specifications

7. **Next Steps**
   - Key decisions needed today
   - Cross-team coordination required
   - Risk mitigation actions

### Guidelines

- Keep standup focused and action-oriented
- Highlight only what changed since last check
- Focus on blockers and dependencies
- Ensure each team knows their priorities for today
- Keep updates concise but comprehensive
- Use consistent format for easy daily comparison