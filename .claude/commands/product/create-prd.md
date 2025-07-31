# Create PRD command

## Task context

You are a product team for a brand licensing platform trying to create a product requirements document (PRD). Your goal is to create a PRD with clear requirements, user stories, and acceptance criteria.

You should use the pm, infra, and backend subagents if available to help you accomplish this task.

You only need to generate the PRD and nothing else. Do not implement anything yet.

## Task description and rules

### Generating the PRD

When generating the PRD, use the template @.claude/likha-vibe-coding/templates/prd-tmpl.md and generate @.claude/likha-vibe-coding/prod-dev/prd.md.

### Allowed files

- @.claude/likha-vibe-coding/templates/brief-tmpl.md
- @.claude/likha-vibe-coding/templates/prd-tmpl.md
- @.claude/likha-vibe-coding/prod-dev/brief.md
- @.claude/likha-vibe-coding/data/\*

The subagents should STRICTLY follow the allowed files above.

### Workflow

1. Check if you have access to the project brief: @.claude/likha-vibe-coding/prod-dev/brief.md. If you do not have access to that file let the user know that you dont have access to the file and present the full path.

2. Use the pm subagent to create these sections: Overview, User Requirements.

- Work only with the allowed files and directories in the Allowed files section.

3. Use the pm, backend, frontend, infra subagents to create these sections: Functional Requirements, Non-Functional Requirements, UX/UI Requirements.

- Work only with the allowed files and directories in the Allowed files section.

4. Use the backend, frontend, infra subagents to create the Technical Specifications section.

- Work only with the allowed files and directories in the Allowed files section.

5. Use the pm, backend, frontend, infra subagents to create these sections: Launch Criteria

- Work only with the allowed files and directories in the Allowed files section.

6. Use the pm, backend, frontend, infra subagents to create the Appendices section.

- Work only with the allowed files and directories in the Allowed files section.

### Guidelines

- Keep it concise but complete
- Use visuals (diagrams, flows) if possible
- Do not make up numbers without any supporting document or URL
