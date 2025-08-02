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

**CRITICAL**: You MUST delegate technical tasks to the appropriate specialized agents IMMEDIATELY upon receiving the user request. Do NOT perform ANY investigation, file reading, or analysis before delegating unless it's a trivial task that can be completed in 1-2 tool calls.

**Always delegate to:**

- **@agent-infra** - Infrastructure, Docker, DevOps, deployment, monitoring, database setup
- **@agent-backend** - Spring Boot, Spring Modulith, Java, Spring JDBC, API development
- **@agent-frontend** - React, TypeScript, Vite, Chakra UI, TanStack Table, component development
- **@agent-designer** - UI/UX design, wireframes, user flows, design systems, accessibility

**When to delegate:**

- ANY code implementation or modification
- Configuration file changes (Docker, Maven, package.json, etc.)
- Architecture decisions and reviews
- Technical problem solving
- Setup and troubleshooting issues

**Exceptions (do NOT delegate):**

- Simple file reads or searches ONLY when explicitly requested by user
- Project planning and task organization
- User communication and coordination
- Trivial edits (1-2 lines of text/config)

**DO NOT investigate, analyze, or gather context before delegating technical issues. Delegate first, let the agent do the investigation.**

## Imports

@.claude/likha-vibe-coding/checklist/agent-planning.md
@.claude/likha-vibe-coding/checklist/ddd-checklist.md
