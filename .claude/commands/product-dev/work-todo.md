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

### 2. Find Next Task and Lead Agent

- Look for the first uncompleted task `- [ ]` in priority order:
  - First check HIGH priority tasks
  - Then MEDIUM priority tasks
  - Finally LOW priority tasks
- Identify the **Task Owner** (lead agent) from the task metadata
- **No further analysis required** - proceed immediately to delegation

### 3. Delegate to Lead Agent

- Identify the **Task Owner** from the todo metadata (e.g., @agent-infra, @agent-backend, etc.)
- Use the following delegation template for ALL agents:

```
Work on {todo_id} from @.claude/likha-vibe-coding/prod-dev/todo.md

MANDATORY SEQUENCE - DO NOT SKIP ANY STEPS:
1. Read the full task context from the todo file
2. Check for existing files/functionality before implementing:
   - Search for similar classes, configurations, or components
   - Use existing implementations where possible
   - Avoid creating duplicate functionality
3. Create a detailed todo list using TodoWrite tool with your implementation plan
4. Share your plan with the user BEFORE writing any code
5. Write failing tests first (TDD approach - Red phase)
   - Backend: Write acceptance/integration tests
   - Frontend: Write component/unit tests
   - Infra: Write validation/smoke tests
   - Skip only if genuinely not applicable
6. Wait for user confirmation or 30 seconds
7. Only then implement code to make tests pass (Green phase)
8. Refactor if needed (Refactor phase)
9. Run all tests to ensure nothing breaks from your changes

CRITICAL: If you start coding without completing steps 1-4, the user will interrupt you.

Follow your work guide at {work_guide_path}
```

### 4. Task Execution

- Lead agent implements the task
- Coordinates with supporting agents as specified
- Validates implementation against acceptance criteria

### 5. Validation & Update Status

- Before marking task as completed:
  - Run all tests to ensure nothing breaks from the changes
  - Verify the implementation meets acceptance criteria
- Once validation passes:
  - Mark the todo item as completed `- [x]`
  - Update the todo file with completion status
  - Report completion back to user
  - **STOP** - Do not proceed to the next todo item

## Example Flow

```
1. User runs: /work-todo
2. Command reads @.claude/likha-vibe-coding/prod-dev/todo.md
3. Finds next HIGH priority task: "todo-1: Design contract management database schema"
4. Identifies Task Owner: @agent-infra (Lead)
5. Delegates to @agent-infra with: "Work on todo-1 from @.claude/likha-vibe-coding/prod-dev/todo.md"
6. @agent-infra reads the todo file and gathers all context
7. @agent-infra completes task
8. Updates todo-1 from [ ] to [x] in the file
9. Reports completion to user
```

## Notes

- Always work on tasks in priority order (HIGH → MEDIUM → LOW)
- Lead agents coordinate with supporting teams as needed
- Task completion requires meeting the acceptance criteria
- If blocked, the lead agent should report the blocker instead of marking incomplete
- Follow the appropriate work guide for consistent implementation
- **IMPORTANT**: Complete only ONE todo item per command execution - do not automatically proceed to the next todo
