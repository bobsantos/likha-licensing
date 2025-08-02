# Create Brief command

## Task context

You are a product team for a brand licensing platform trying to create a product brief.

**CRITICAL DELEGATION REQUIREMENT**: You MUST immediately delegate this task to the pm agent as the lead. DO NOT perform any analysis, file reading, or brief creation yourself.

**MANDATORY WORKFLOW**:

1. **IMMEDIATELY** use the Task tool to delegate to the pm agent
2. Provide the pm agent with all context from docs/roadmap.md and the brief template
3. The pm agent should coordinate with other agents (designer, backend, frontend, infra, security) as needed for specific sections

You only need to generate the project brief and nothing else. Do not implement anything yet.

## Task description and rules

You are tasked with creating a comprehensive product brief for the specified feature from the roadmap.

### Argument Format

Arguments should be provided in the format: `feature:research_folder`

- **feature**: The specific feature/section name from docs/roadmap.md (e.g., "Contract Management MVP", "Royalty Management MVP", "Product Approval Module")
- **research_folder**: Directory path containing relevant research files to use as information sources (e.g., "docs/research/contract-management", "docs/research/royalty-system")

Example usage: `Contract Management MVP:docs/research/contract-management`

### CRITICAL OUTPUT REQUIREMENT

The brief MUST be generated at: .claude/likha-vibe-coding/prod-dev/brief.md

Do NOT create the brief file in:

- scratch/ directory
- root directory
- any other location

Use the Write tool with the EXACT path: .claude/likha-vibe-coding/prod-dev/brief.md

**IMPORTANT**: Use `.claude/` (with dot prefix) NOT `@.claude/` to reference the existing .claude directory in the repository.

### Generating the project brief

When generating the project brief document, use the template .claude/likha-vibe-coding/templates/brief-tmpl.md and generate the final brief at: **OUTPUT FILE: .claude/likha-vibe-coding/prod-dev/brief.md.**

IMPORTANT: The brief MUST be created at this exact path, not in any other location.

### RESTRICTED FILE ACCESS - MANDATORY COMPLIANCE

**ALLOWED FILES AND DIRECTORIES ONLY:**

- .claude/likha-vibe-coding/templates/brief-tmpl.md
- .claude/likha-vibe-coding/data/\* (all files in this directory)
- docs/roadmap.md
- Research folder specified in arguments (e.g., docs/research/\* or the specific research folder provided)

**CRITICAL RESTRICTIONS:**

1. **FORBIDDEN ACCESS**: You and ALL subagents are PROHIBITED from accessing any files or directories outside the allowed list above.

2. **SPECIFICALLY FORBIDDEN:**

   - Do NOT access scratch/ directory or any files within it
   - Do NOT access root directory files
   - Do NOT access any other .claude/ subdirectories
   - Do NOT access src/, docs/, or any code directories
   - Do NOT access any files with .md, .txt, .json, .sql, .java, .ts, .js extensions outside allowed directories

3. **SUBAGENT COMPLIANCE**: ALL subagents (pm, backend, frontend, infra, designer, security) MUST be explicitly instructed to only access the allowed files above. Any subagent that attempts to access forbidden files should be immediately stopped.

4. **VERIFICATION REQUIRED**: Before using any file path, verify it matches the allowed list exactly. The research folder specified in arguments must be explicitly validated as accessible.

5. **RESEARCH FOLDER ACCESS**: The pm agent must be given explicit permission to access all files within the research folder specified in the arguments format `feature:research_folder`.

**VIOLATION CONSEQUENCES**: If any file outside the allowed list is accessed, immediately stop the task and report the violation to the user.

### Mandatory Delegation Workflow

**STEP 1: IMMEDIATE DELEGATION**

- Parse the arguments to extract the feature name and research folder path
- Use the Task tool to delegate to the pm agent with subagent_type: "pm"
- Include all context about the specified feature and file restrictions
- Provide the pm agent with roadmap context, brief template information, and research folder access

**STEP 2: PM AGENT RESPONSIBILITIES**
The pm agent should:

1. Parse the feature name and research folder from the arguments format `feature:research_folder`
2. Search docs/roadmap.md for the specified feature to understand the context, requirements, and timeline
3. Review all research files in the specified research folder to gather additional context, user insights, competitive analysis, and technical requirements
4. Create these sections based on roadmap and research information: Executive Summary, Problem Statement, Target Audience, Competitive Analysis
5. Create these sections: Constraints and Requirements, Success Criteria
6. Coordinate with other agents as needed:
   - designer agent: for user experience insights and target audience analysis
   - backend/frontend agents: for technical constraints and requirements
   - infra agent: for deployment and scalability considerations
   - security agent: for compliance requirements, risk assessment, and security constraints
7. Generate the final brief file at .claude/likha-vibe-coding/prod-dev/brief.md

**STEP 3: OUTPUT VALIDATION**
After the pm agent completes the task, confirm:

- The file was created at .claude/likha-vibe-coding/prod-dev/brief.md
- The file contains all required sections
- No other brief files were created in different locations

**CRITICAL**: Use the Write tool to create the brief file at the EXACT path: .claude/likha-vibe-coding/prod-dev/brief.md
Do NOT create the file in any other location (not in scratch/ or any other directory).

### Guidelines

- Keep it concise but complete
- Do not make up numbers without any supporting document or URL
- Do not look up any other files except the ones listed here
