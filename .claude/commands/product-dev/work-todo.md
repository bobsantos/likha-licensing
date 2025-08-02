# work-todo

Work on the next uncompleted todo item from the product development todo list.

## Usage

```
/work-todo
```

## Description

This command will:
1. Read the todo list from `@.claude/likha-vibe-coding/prod-dev/todo.md`
2. Find the next uncompleted todo item (marked with `- [ ]`)
3. Identify the lead agent and supporting agents from the task metadata
4. Delegate the task to the appropriate lead agent
5. Update the todo status upon completion

## Workflow

### 1. Read Todo List
- Load the current todo list from `@.claude/likha-vibe-coding/prod-dev/todo.md`
- Parse the structure to identify:
  - Task owner (lead agent)
  - Supporting teams
  - Task priorities (HIGH, MEDIUM, LOW)
  - Acceptance criteria

### 2. Find Next Task
- Look for the first uncompleted task `- [ ]` in priority order:
  - First check HIGH priority tasks
  - Then MEDIUM priority tasks
  - Finally LOW priority tasks
- Extract the complete task description and any sub-tasks

### 3. Delegate to Lead Agent
- Identify the **Task Owner** from the todo metadata (e.g., @agent-infra, @agent-backend, etc.)
- Provide the complete task context:
  - Task description and requirements
  - Acceptance criteria from the header
  - Supporting team collaboration needs
  - Any technical implementation notes
  - Reference to the appropriate work guide (see Work Guide section below)

### 4. Task Execution
- Lead agent implements the task
- Coordinates with supporting agents as specified
- Validates implementation against acceptance criteria

### 5. Update Status
- Once task is completed:
  - Mark the todo item as completed `- [x]`
  - Update the todo file with completion status
  - Report completion back to user
  - **STOP** - Do not proceed to the next todo item

## Example Flow

```
1. User runs: /work-todo
2. Command reads @.claude/likha-vibe-coding/prod-dev/todo.md
3. Finds next HIGH priority task: "todo-1: Design contract management database schema"
4. Identifies metadata:
   - Task Owner: @agent-infra (Lead)
   - Supporting: @agent-backend, @agent-security
5. Delegates task to @agent-infra with full context
6. @agent-infra completes task
7. Updates todo-1 from [ ] to [x] in the file
8. Reports completion to user
```

## Work Guide

Each agent should follow their specific work guide when executing tasks:

- **@agent-infra**: Follow `@.claude/likha-vibe-coding/checklist/infra-work-guide.md`
  - Infrastructure best practices
  - Docker and AWS configuration
  - Security collaboration requirements
  
- **@agent-backend**: Follow `@.claude/likha-vibe-coding/checklist/backend-work-guide.md`
  - Spring Boot and Domain-Driven Design
  - API development standards
  - Testing strategies
  
- **@agent-frontend**: Follow `@.claude/likha-vibe-coding/checklist/frontend-work-guide.md`
  - React and TypeScript patterns
  - Accessibility requirements
  - UI/UX collaboration

All work guides emphasize:
- Test-Driven Development (TDD) approach
- Collaboration with supporting teams
- Security review requirements before production deployment
- Documentation and knowledge sharing

## Notes

- Always work on tasks in priority order (HIGH → MEDIUM → LOW)
- Lead agents coordinate with supporting teams as needed
- Task completion requires meeting the acceptance criteria
- If blocked, the lead agent should report the blocker instead of marking incomplete
- Follow the appropriate work guide for consistent implementation
- **IMPORTANT**: Complete only ONE todo item per command execution - do not automatically proceed to the next todo