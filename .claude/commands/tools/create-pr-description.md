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

2. Generate a simple description.

- Only use the context of the current session.
- Do not access any files or directories.
- **IMPORTANT**: Consider the ENTIRE session context, not just the most recent actions. Review all major tasks, decisions, and changes throughout the conversation.
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
  - All files created, modified, or deleted
  - Agent collaborations and specialized tasks
  - Problem-solving and course corrections
  - Final outcomes and deliverables
