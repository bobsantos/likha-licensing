# Create PRD command

## Task context

You are a product team for a brand licensing platform trying to create a product requirements document (PRD). Your goal is to create a PRD with clear requirements, user stories, and acceptance criteria.

**CRITICAL: IMMEDIATE DELEGATION REQUIRED**

You MUST delegate this entire task to the pm agent immediately upon receiving this command. Do NOT perform any investigation, file reading, or analysis yourself. The pm agent will lead and collaborate with backend, frontend, infra, designer, and security agents as needed.

Delegate with: "Create a comprehensive PRD for the brand licensing platform following the workflow and requirements specified in this command. You will lead this effort and collaborate with backend, frontend, infra, designer, and security agents as needed."

You ONLY need to generate the PRD and nothing else.

DO NOT write specific implementations like code, sql, and configurations.

DO NOT implement anything yet.

IMPORTANT: A PRD defines WHAT needs to be built and WHY, not HOW to build it. Focus on:

- Business requirements and user needs
- Feature specifications and acceptance criteria
- Performance targets and quality standards
- High-level technology choices (e.g., "PostgreSQL 15+", "Spring Boot 3.2+")

AVOID implementation details such as:

- Code examples, class definitions, or method signatures
- SQL table schemas or specific database queries
- Configuration files (YAML, XML, JSON)
- Detailed API endpoint implementations
- Infrastructure-as-code specifications

The Technical Specifications section should describe architecture approaches and technology stack choices at a conceptual level, leaving implementation details for separate technical design documents.

## Task description and rules

### CRITICAL OUTPUT REQUIREMENT

The PRD MUST be generated at: .claude/likha-vibe-coding/prod-dev/prd.md

Do NOT create the PRD file in:

- scratch/ directory
- root directory
- any other location

Use the Write tool with the EXACT path: .claude/likha-vibe-coding/prod-dev/prd.md

**IMPORTANT**: Use `.claude/` (with dot prefix) NOT `@.claude/` to reference the existing .claude directory in the repository.

### Generating the PRD

When generating the PRD, use the template .claude/likha-vibe-coding/templates/prd-tmpl.md and generate the final PRD file at:

**OUTPUT FILE: .claude/likha-vibe-coding/prod-dev/prd.md**

IMPORTANT: The PRD MUST be created at this exact path, not in any other location.

While performing this task try to remind yourself and the subagents to prioritise delivery speed and aim for an MVP version. Think of implementing the must-haves and then put the nice-to-haves as recommendation in the appendices.

### RESTRICTED FILE ACCESS - MANDATORY COMPLIANCE

**ALLOWED FILES AND DIRECTORIES ONLY:**

- .claude/likha-vibe-coding/templates/brief-tmpl.md
- .claude/likha-vibe-coding/templates/prd-tmpl.md
- .claude/likha-vibe-coding/prod-dev/\* (all files in this directory)
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

When generating the PRD use this workflow step-by-step:

1. Check if you have access to the project brief: .claude/likha-vibe-coding/prod-dev/brief.md. If you do not have access to that file let the user know that you dont have access to the file and present the full path.

2. Create these sections: Overview, User Requirements.

- Use the pm subagent for this step (product strategy and user research expertise)

3. Create these sections: Functional Requirements, Non-Functional Requirements, UX/UI Requirements.

- Use pm (lead), backend, frontend, infra, security, and designer subagents for this step
- pm subagent coordinates overall requirements, others provide domain expertise

4. Create the Technical Specifications section.

- Use backend (lead), frontend, infra, security subagents for this step
- Focus on technical architecture and implementation details

5. Create these sections: Launch Criteria, Appendices.

- Use pm (lead), backend, frontend, infra, security, and designer subagents for this step
- Collaborative effort for comprehensive launch planning

6. Verify the output directory exists and confirm the target file path

- Check that the directory .claude/likha-vibe-coding/prod-dev/ exists
- Confirm you will write to: .claude/likha-vibe-coding/prod-dev/prd.md
- If the directory doesn't exist, create it first

7. Generate the final PRD file at .claude/likha-vibe-coding/prod-dev/prd.md

8. Let the pm agent review the final PRD as sanity check

CRITICAL: Use the Write tool to create the PRD file at the EXACT path: .claude/likha-vibe-coding/prod-dev/prd.md
Do NOT create the file in any other location (not in scratch/ or any other directory).

8. Validate PRD file creation

After generating the PRD, confirm:

- The file was created at .claude/likha-vibe-coding/prod-dev/prd.md
- The file contains all required sections
- No other PRD files were created in different locations

### Guidelines

- Keep it concise but complete
- Use visuals (diagrams, flows) if possible
- Do not make up numbers without any supporting document or URL
