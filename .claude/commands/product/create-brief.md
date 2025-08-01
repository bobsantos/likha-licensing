# Create Brief command

## Task context

You are a product team for a brand licensing platform trying to create a product brief.

You should use the pm, infra, and backend subagents if available to help you accomplish this task.

You only need to generate the project brief and nothing else. Do not implement anything yet.

## Task description and rules

You are tasked with creating a comprehensive product brief for $ARGUMENTS.

### CRITICAL OUTPUT REQUIREMENT

The PRD MUST be generated at: .claude/likha-vibe-coding/prod-dev/brief.md

Do NOT create the brief file in:

- scratch/ directory
- root directory
- any other location

Use the Write tool with the EXACT path: .claude/likha-vibe-coding/prod-dev/brief.md

**IMPORTANT**: Use `.claude/` (with dot prefix) NOT `@.claude/` to reference the existing .claude directory in the repository.

### Generating the project brief

When generating the project brief document, use the template .claude/likha-vibe-coding/templates/brief-tmpl.md and generate the final brief at: **OUTPUT FILE: .claude/likha-vibe-coding/prod-dev/brief.md.**

IMPORTANT: The PRD MUST be created at this exact path, not in any other location.

### RESTRICTED FILE ACCESS - MANDATORY COMPLIANCE

**ALLOWED FILES AND DIRECTORIES ONLY:**

- .claude/likha-vibe-coding/templates/brief-tmpl.md
- .claude/likha-vibe-coding/data/\* (all files in this directory)

**CRITICAL RESTRICTIONS:**

1. **FORBIDDEN ACCESS**: You and ALL subagents are PROHIBITED from accessing any files or directories outside the allowed list above.

2. **SPECIFICALLY FORBIDDEN:**

   - Do NOT access scratch/ directory or any files within it
   - Do NOT access root directory files
   - Do NOT access any other .claude/ subdirectories
   - Do NOT access src/, docs/, or any code directories
   - Do NOT access any files with .md, .txt, .json, .sql, .java, .ts, .js extensions outside allowed directories

3. **SUBAGENT COMPLIANCE**: ALL subagents (pm, backend, frontend, infra, designer) MUST be explicitly instructed to only access the allowed files above. Any subagent that attempts to access forbidden files should be immediately stopped.

4. **VERIFICATION REQUIRED**: Before using any file path, verify it matches the allowed list exactly.

**VIOLATION CONSEQUENCES**: If any file outside the allowed list is accessed, immediately stop the task and report the violation to the user.

### Workflow

When executing the task with subagents follow this workflow:

1. Create these sections: Executive Summary, Problem Statement, Target Audience, Competitive Analysis

- Use the pm subagent for this step.

2. Create these sections: Constraints and Requirements, Success Criteria.

- Use the pm (lead), backend, frontend, infra subagents.
- Collaborative effort for comprehensive constraints and requirements, and success criteria.

3. Generate the final brief file at .claude/likha-vibe-coding/prod-dev/brief.md

CRITICAL: Use the Write tool to create the brief file at the EXACT path: .claude/likha-vibe-coding/prod-dev/brief.md
Do NOT create the file in any other location (not in scratch/ or any other directory).

4. Validate brief file creation

After generating the brief, confirm:

- The file was created at .claude/likha-vibe-coding/prod-dev/brief.md
- The file contains all required sections
- No other brief files were created in different locations

5. Use the pm subagent to review the generated project brief.

### Guidelines

- Keep it concise but complete
- Do not make up numbers without any supporting document or URL
- Do not look up any other files except the ones listed here
