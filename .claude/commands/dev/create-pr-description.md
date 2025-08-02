# Create PR description command

## Task context

You are a contributor to a Github repository and tasked to create a simple pull request (PR) title and description.

## Task description and rules

### Format

**CRITICAL**: Use proper markdown format when generating the PR description. The output must be valid markdown with:
- `#` for the main title (PR title)
- `##` for section headers (Context, Changes)
- `-` for bullet points in lists
- `**text**` for bold emphasis
- `` `code` `` for inline code/file paths

**OUTPUT FORMAT**: Present the final PR description wrapped in markdown code blocks (```markdown) so the user can easily copy and paste it directly into GitHub PR descriptions.

### Workflow

When executing the task follow this workflow:

1. Generate a simple title.

- Only use the context of the current session.
- Do not access any files or directories.
- **FOCUS ON MAIN TASK**: The title should reflect the PRIMARY work done, not minor adjustments or side tasks

2. Generate a comprehensive description.

- Only use the context of the current session.
- Do not access any files or directories.
- **IMPORTANT**: Consider the ENTIRE session context, not just the most recent actions. Review all major tasks, decisions, and changes throughout the conversation.
- **COMPLETENESS CHECK**: Before writing the PR description, perform a systematic session review:
  1. **Initial User Request**: What was the primary goal or task requested?
  2. **Main Task Focus**: Identify the PRIMARY work done (e.g., if working on todos, what specific todo was completed?)
  3. **Major Deliverables**: List all new files created, existing files modified, or commands built
  4. **Supporting Work**: What enhancements, research, or improvements were made to support the main deliverable?
  5. **Problem Resolution**: Any issues discovered and resolved during implementation
  6. **Collaborative Work**: Agent consultations or specialized analysis performed
- **QUALITY CONTROL**: Ensure the Changes section captures ALL substantial work, not just final fixes. Prioritize by impact:
  - **Primary deliverables** (new features, commands, major implementations) should be listed first
  - **Supporting enhancements** (documentation updates, tech stack improvements) second  
  - **Process improvements** (fixes, optimizations) last
- **MAIN TASK EMPHASIS**: When using work-todo or similar task management commands:
  - The PR title should reflect the specific todo completed (e.g., "Complete database schema design for contract management")
  - The primary change should be about the todo task itself, not the command modifications
  - Command updates should be listed as supporting changes, not the main focus
- Follow this exact markdown format:
  <pr-desc-format>

  # [PR Title - one line describing the main outcome]

  ## Context

  Provide a brief summary of what we did throughout the entire session.

  ## Changes

  - **Major change 1**: Description of significant change
  - **Major change 2**: Description of significant change  
  - **Major change 3**: Description of significant change
  </pr-desc-format>

### Guidelines

- Keep it concise but complete.
- Only use the context of the current session.
- Do not look up any files or directories.
- **Format Compliance**: Ensure the output is valid markdown that renders properly in GitHub PR descriptions.
- **Session Scope**: When reviewing session context, consider:
  - Initial user requests and goals
  - Multi-step processes and workflows executed
  - All files created, modified, or deleted (including those initially created in wrong locations)
  - Agent collaborations and specialized tasks
  - Problem-solving and course corrections (like fixing path reference bugs)
  - Final outcomes and deliverables
- **Chronological Review**: Before finalizing the PR description, perform a mental walkthrough of the session from start to finish to ensure comprehensive coverage of all work performed
