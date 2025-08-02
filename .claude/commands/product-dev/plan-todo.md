# Plan Todo Custom Command

This command creates a detailed todo list for the currently in_progress task from `@.claude/likha-vibe-coding/prod-dev/tasks.md`.

## Usage

```
plan-todo
```

## Process

1. **Check for existing todo.md** - If todo.md exists with uncompleted tasks, alert and stop
2. **Read the tasks.md file** to find the in_progress task
3. **Extract task details** including:
   - Task ID and name
   - Task owner (agent responsible)
   - Supporting teams
   - Status
   - Dependencies
   - Estimate
   - Acceptance criteria
4. **Generate todo list** with:
   - Team collaboration requirements
   - Prioritized task breakdown (HIGH, MEDIUM, LOW)
   - Completion criteria
   - Technical implementation notes

## Todo List Structure

The generated `todo.md` will include:

### Header Section
- Current task details (ID, owner, status, dependencies, estimate)
- Team collaboration requirements with specific support needs

### Task Sections by Priority
- **🎯 High Priority Tasks** - Critical path items to start immediately
- **🔧 Medium Priority Tasks** - Secondary tasks after core implementation
- **📚 Low Priority Tasks** - Documentation and polish

### Footer Sections
- **🏁 Completion Criteria** - Checklist for task completion
- **🔗 Unblocks** - Tasks that depend on this one
- **🛠 Technical Implementation Notes** - Key technical details

## Pre-flight Check

**IMPORTANT:** Before proceeding, check if `@.claude/likha-vibe-coding/prod-dev/todo.md` exists:

1. If todo.md exists:
   - Check if it contains any uncompleted tasks (unchecked checkboxes `- [ ]`)
   - If uncompleted tasks exist:
     - **ALERT:** "⚠️ Existing todo.md found with uncompleted tasks! Please complete or archive the current todo list before generating a new one."
     - **STOP** the workflow immediately
   - If all tasks are completed:
     - Archive the existing todo.md as `todo-[TASK-ID]-completed.md`
     - Proceed with generating new todo.md

2. If todo.md does not exist:
   - Proceed with normal workflow

## Implementation Steps

1. Execute pre-flight check for existing todo.md
2. Parse tasks.md to find task with `**Status**: in_progress` or `**Status**: pending` (next in line)
3. Extract all relevant task information
4. Generate structured todo items based on task description and acceptance criteria
5. Add collaboration requirements for supporting teams
6. Include technical notes relevant to the task type
7. Save as `todo.md` in the same directory

## Example Output Format

```markdown
# Current Todo List - [TASK-ID]: [Task Name]

**Task Owner:** @agent-[type] (Lead)  
**Supporting Teams:** @agent-[type1], @agent-[type2]  
**Status:** In Progress  
**Dependencies:** [Previous tasks]  
**Estimate:** X days  
**Acceptance Criteria:** [Brief summary]

## 🤝 Team Collaboration Requirements

**@agent-[type] support needed for:**
- [Specific support item 1]
- [Specific support item 2]

---

## 🎯 High Priority Tasks (Start Immediately)

### [Category]
- [ ] **todo-1:** [HIGH] [Task description]
  - [Sub-task details]
  - [Implementation notes]

---

## 🔧 Medium Priority Tasks (After Core Implementation)

### [Category]
- [ ] **todo-X:** [MEDIUM] [Task description]

---

## 📚 Low Priority Tasks (Documentation & Polish)

### [Category]
- [ ] **todo-Y:** [LOW] [Task description]

---

## 🏁 Completion Criteria

### ✅ Ready for Next Tasks When Complete:
- [ ] [Completion criterion 1]
- [ ] [Completion criterion 2]

### 🔗 Unblocks These Tasks:
- **[TASK-ID]:** [Task name]

---

## 🛠 Technical Implementation Notes

[Relevant technical details, code snippets, or architecture notes]

---

*Task [TASK-ID] planned and ready for implementation by @agent-[type]*  
*Last updated: [Date] - [Status]*
```

## Notes

- The command automatically numbers todos sequentially
- Includes collaboration indicators (🤝) where cross-team support is needed
- Uses priority levels (HIGH, MEDIUM, LOW) for task organization
- Maintains consistent formatting with checkboxes for tracking
- Adds technical context relevant to the specific task type