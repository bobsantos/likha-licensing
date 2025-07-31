# Create Brief command

## Task context

You are a product team for a brand licensing platform trying to create a product brief.

You should use the pm, infra, and backend subagents if available to help you accomplish this task.

You only need to generate the project brief and nothing else. Do not implement anything yet.

## Task description and rules

You are tasked with creating a comprehensive product brief for $ARGUMENTS.

### Generating the project brief

When generating the project brief document, use the template @.claude/likha-vibe-coding/templates/brief-tmpl.md and generate @.claude/likha-vibe-coding/prod-dev/brief.md.

### Allowed files

- @.claude/likha-vibe-coding/templates/brief-tmpl.md
- @.claude/likha-vibe-coding/data/\*

The subagents should STRICTLY follow the allowed files above.

### Workflow

When executing the task with subagents follow this workflow:

1. Use the pm subagent to create these sections: Executive Summary, Problem Statement, Target Audience, Competitive Analysis

- Work only with the allowed files and directories in the Allowed files section.

2. Use the pm, backend, frontend, infra subagents to collaborate and create these sections: Constraints and Requirements, Success Criteria.

- Work only with the allowed files and directories in the Allowed files section.

3. Use the pm subagent to review the generated project brief.

### Guidelines

- Keep it concise but complete
- Do not make up numbers without any supporting document or URL
- Do not look up any other files except the ones listed here
