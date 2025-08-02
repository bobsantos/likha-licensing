# Prioritise PRD User Stories Command

## Task context

You are a product team tasked with prioritizing user stories from an existing PRD to optimize development sequencing and resource allocation.

**CRITICAL: Immediately delegate to @agent-pm who will lead this task. @agent-pm will coordinate with other subagents (infra, frontend, backend, security, and designer) as needed for collaborative analysis.**

You only need to generate the prioritized user story analysis and recommendations. Do not implement anything yet.

## Task description and rules

You are tasked with analyzing and prioritizing the user stories from the PRD located at .claude/likha-vibe-coding/prod-dev/prd.md based on $ARGUMENTS (if any specific criteria are provided).

### CRITICAL OUTPUT REQUIREMENT

The prioritized user story analysis MUST be generated at: .claude/likha-vibe-coding/prod-dev/user-stories.md

Do NOT create the analysis file in:

- scratch/ directory
- root directory
- any other location

Use the Write tool with the EXACT path: .claude/likha-vibe-coding/prod-dev/user-story-priorities.md

**IMPORTANT**: Use `.claude/` (with dot prefix) NOT `@.claude/` to reference the existing .claude directory in the repository.

### RESTRICTED FILE ACCESS - MANDATORY COMPLIANCE

**ALLOWED FILES AND DIRECTORIES ONLY:**

- .claude/likha-vibe-coding/prod-dev/prd.md (source PRD)
- .claude/likha-vibe-coding/templates/\* (all files in templates directory)
- .claude/likha-vibe-coding/data/\* (all files in data directory)

**CRITICAL RESTRICTIONS:**

1. **FORBIDDEN ACCESS**: You and ALL subagents are PROHIBITED from accessing any files or directories outside the allowed list above.

2. **SPECIFICALLY FORBIDDEN:**

   - Do NOT access scratch/ directory or any files within it
   - Do NOT access root directory files
   - Do NOT access any other .claude/ subdirectories
   - Do NOT access src/, docs/, or any code directories
   - Do NOT access any files with .md, .txt, .json, .sql, .java, .ts, .js extensions outside allowed directories

3. **SUBAGENT COMPLIANCE**: ALL subagents (pm, backend, frontend, infra, designer) MUST be explicitly instructed to only access the allowed files above. Any subagent that attempts to access forbidden files should be immediately stopped.

   **SUBAGENT INSTRUCTION TEMPLATE**: Each subagent prompt MUST include this exact text:

   ```
   CRITICAL FILE ACCESS RESTRICTIONS - MANDATORY COMPLIANCE:
   - ONLY access: .claude/likha-vibe-coding/prod-dev/prd.md
   - ONLY access: .claude/likha-vibe-coding/templates/* files
   - ONLY access: .claude/likha-vibe-coding/data/* files
   - FORBIDDEN: ANY other files or directories including docs/, src/, root directory, scratch/, .git/, etc.
   - BEFORE accessing ANY file, verify the path starts with one of the allowed directories above
   - VIOLATION CONSEQUENCE: Task termination and violation report
   ```

4. **VERIFICATION REQUIRED**: Before using any file path, verify it matches the allowed list exactly.

**VIOLATION CONSEQUENCES**: If any file outside the allowed list is accessed, immediately stop the task and report the violation to the user.

**MANDATORY PRE-EXECUTION VALIDATION**: Before launching any subagent, the main agent MUST:

1. Explicitly state which files each subagent will access
2. Verify each file path starts with one of the allowed directories
3. Confirm no forbidden paths will be accessed
4. Only proceed if all file paths are validated as allowed

### Workflow

**STEP 0: MANDATORY FILE ACCESS VALIDATION**
Before launching any subagents, the main agent MUST:

1. List all files that will be accessed: .claude/likha-vibe-coding/prod-dev/prd.md
2. Verify this path is in the allowed list
3. Confirm no other files will be accessed
4. State: "File access validation complete - only allowed files will be accessed"

When executing the task with subagents follow this workflow:

1. **PM Agent (Lead) - Strategic Analysis**

   - Read and analyze the PRD user stories
   - Establish prioritization framework based on business value, MVP scope, and strategic objectives
   - Identify dependencies between user stories
   - Define evaluation criteria for prioritization

2. **Infrastructure Agent - Technical Risk Assessment**

   - Evaluate each user story for infrastructure complexity
   - Assess deployment risks and operational overhead
   - Identify stories that establish foundational infrastructure vs. those that build on it
   - Provide technical feasibility scoring

3. **Backend Agent - Implementation Complexity Analysis**

   - Analyze backend implementation requirements for each story based on the PRD's technical stack
   - Evaluate database and data access complexity requirements
   - Assess security implementation requirements
   - Identify stories that provide reusable backend foundations

4. **Frontend Agent - UI/UX Implementation Assessment**

   - Evaluate frontend implementation complexity for each user story based on the PRD's UI/UX requirements
   - Assess data visualization and interface requirements
   - Identify stories that establish UI patterns vs. those that extend them
   - Consider user experience flow dependencies

5. **Designer Agent - UX Complexity and Design System Impact**

   - Evaluate user experience design requirements based on the PRD specifications
   - Assess accessibility and design standards compliance requirements
   - Identify stories that establish design patterns vs. those that build on them
   - Consider user journey flow and information architecture impacts

6. **Collaborative Prioritization Matrix Creation**

   - All agents contribute to a comprehensive scoring matrix
   - Consider: Business Value, Technical Complexity, Risk Level, Dependencies, MVP Alignment
   - Generate final prioritized recommendations

7. **Generate Final Analysis**
   - Create comprehensive prioritization document at .claude/likha-vibe-coding/prod-dev/user-story-priorities.md
   - Include prioritization rationale, implementation sequence recommendations, and risk mitigation strategies

### Prioritization Framework

Use the following evaluation criteria:

**Business Value (PM Lead)**

- Direct impact on MVP success criteria
- Security and compliance requirements
- Customer onboarding enablement
- Revenue protection/generation potential

**Technical Foundation (Backend/Frontend/Infra Lead)**

- Foundational vs. incremental functionality
- Technical debt implications
- Reusability for future stories
- Infrastructure and frontend architecture stability requirements

**Implementation Risk (All Agents)**

- Complexity score (1-5 scale)
- Number of unknowns or assumptions
- Dependencies on external systems
- Testing and validation requirements

**User Experience Impact (Frontend/Designer Lead)**

- User workflow enablement based on PRD personas and user journeys
- Interface efficiency improvements
- Accessibility and usability requirements
- Design system establishment vs. extension

### Output Format

The generated analysis should include:

1. **Executive Summary**

   - Key prioritization decisions and rationale
   - Recommended implementation phases
   - Critical path dependencies

2. **Prioritization Matrix**

   - All user stories ranked with scores across evaluation criteria
   - Priority levels: P0 (MVP Critical), P1 (High), P2 (Medium), P3 (Low)

3. **Implementation Sequence Recommendations**

   - Suggested sprint/phase groupings
   - Each user story must include **Status**: pending (default for new stories)
   - Dependency mapping
   - Risk mitigation strategies

4. **Agent-Specific Insights**
   - PM: Business alignment and scope management recommendations
   - Infrastructure: Technical architecture and deployment sequence
   - Backend: Implementation patterns and code reusability opportunities
   - Frontend: UI development sequence and component dependencies
   - Designer: UX flow optimization and design system evolution

### Validation Requirements

After generating the analysis, confirm:

- The file was created at .claude/likha-vibe-coding/prod-dev/user-story-priorities.md
- All user stories from the PRD are included and evaluated
- Prioritization rationale is clear and well-documented
- Implementation sequence is logical and considers dependencies
- No other analysis files were created in different locations

### Guidelines

- Base all analysis on the actual user stories in the PRD
- Maintain consistency with the MVP timeline and scope specified in the PRD
- Consider the technical architecture and constraints outlined in the PRD
- Prioritize foundational and security-critical stories based on PRD requirements
- Do not make up requirements not specified in the source PRD
- Focus on actionable recommendations for the development team
