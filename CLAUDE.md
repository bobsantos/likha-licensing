# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## NOT ALLOWED FILES AND DIRECTORIES

DO NOT access these files and directories when performing any tasks:

- @scratch/\*

## Product discovery

When doing product discovery or planning by creating project brief, PRD, and other relevant documents, always aim for an MVP which we can deliver in 2-4 weeks.

## Product delivery

When implementing features or stories, always aim for an MVP in at most 2 weeks.

## Task Delegation

**DELEGATION PRIORITY**: Try delegating to specialized agents first, but if delegation fails or creates loops, proceed with direct implementation.

**Delegate to specialized agents when possible:**

**MAIN REFERENCE**: @.claude/likha-vibe-coding/checklist/agent-delegation.md

- **@agent-infra** - Infrastructure, Docker, DevOps, deployment, monitoring, database administration
- **@agent-backend** - Spring Boot, Spring Modulith, Java, Spring JDBC, API development
- **@agent-frontend** - React, TypeScript, Vite, Chakra UI, TanStack Table, component development
- **@agent-designer** - UI/UX design, wireframes, user flows, design systems, accessibility

**When to delegate:**

- Complex code implementation requiring specialized knowledge
- Multi-component architecture decisions
- Advanced technical problem solving
- Setup and troubleshooting issues requiring domain expertise

**When to implement directly (do NOT delegate):**

- Simple file reads or searches
- Project planning and task organization
- User communication and coordination
- Single file creation (SQL scripts, config files, simple classes)
- Trivial edits (1-2 lines of text/config)
- When agents create delegation loops without producing results
- Time-sensitive tasks that need immediate completion

**FALLBACK RULE**: If delegation doesn't produce concrete results within 1-2 attempts, proceed with direct implementation to ensure user requests are completed efficiently.

## Before Implementation - Always Check for Existing Code

Use Glob/Grep tools to search for similar functionality before creating new files.
NEVER create duplicate configurations, services, or components.

**MANDATORY STEPS:**

1. Search for existing similar classes/components using Glob patterns
2. Check for related functionality using Grep searches
3. Leverage existing implementations rather than creating new ones
4. Only create new files when genuinely necessary and no existing solution exists

## Imports

@.claude/likha-vibe-coding/checklist/agent-planning.md
