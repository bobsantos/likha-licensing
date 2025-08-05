# CLAUDE.md

This file provides guidance to Claude Code how to do product discovery and product development in this project.

## Product

We're building a comprehensive brand licensing management platform that serves as the central hub for managing complex intellectual property licensing relationships between licensors, licensees, and licensing agents.

The ultimate goal is to create a "single pane of glass" that enhances efficiency, mitigates risks, ensures brand integrity, and drives greater value for all parties while supporting the industry's shift toward comprehensive IP lifecycle management and proactive brand protection.

## Product team

We have specialised agents in .claude/agents who should work on anything related to the product:

- pm
  - The product manager (pm) agent leads all product discovery work.
  - Guides the rest of the agents on what to work on, why, and prioritisation.
- design
  - The design agent leads all work related to UI and UX.
- backend
  - The backend agent leads all work in terms of the backend service, database schema, and build pipeline using Github actions.
  - Works together with frontend agent to define available API's for consumption.
  - Works together with infra agent with tasks relevant to infrastructure configuration, CI/CD, and DevOps.
- frontend
  - The frontend agent leads all work relevant to the frontend application.
  - Works together with the backend agent to understand the API's available for consumption.
  - Works together with the designnt agebt to know what and how to build the user interfaces in the frontend application.
- infra
  - Collaborates with other agents when it comes to infrastructure, cloud, DevOps, and CI/CD.
- security
  - Collaborates with other agents by providing guidance on security and compliance to protect the data of customers and the overall security of the platform.

### Relevant directories for each team member

Here's a guide of which directories each agent should be working with mostly:

- pm
  - docs/vision.md
  - docs/roadmap.md
  - docs/research/
  - docs/domain/
  - .claude/commands/product/
  - .claude/likha-vibe-coding/prod-dev/
  - .claude/likha-vibe-coding/template/
- design
  - docs/vision.md
  - docs/roadmap.md
  - docs/research/
  - docs/domain/
  - .claude/commands/product/
  - .claude/likha-vibe-coding/prod-dev/
  - .claude/likha-vibe-coding/template/
- backend
  - docs/vision.md
  - docs/roadmap.md
  - docs/research/
  - docs/domain/
  - .claude/commands/product-dev/
  - .claude/likha-vibe-coding/prod-dev/
  - pom.xml
  - Dockerfile
  - Dockerfile.dev
  - .env
  - .github/
  - backend/
  - scripts
- frontend
  - docs/vision.md
  - docs/roadmap.md
  - docs/research/
  - docs/domain/
  - .claude/commands/product-dev/
  - .claude/likha-vibe-coding/prod-dev/
  - .env
  - .github/
  - frontend/
  - scripts
- infra
  - docs/vision.md
  - docs/roadmap.md
  - docs/research/
  - docs/domain/
  - .env
  - .github/
  - Dockerfile
  - Dockerfile.dev
  - scripts
- security

A more comprehensive description of where things should be is in .claude/likha-vibe-coding/data/project-directory-structure.

**CRITICAL:** The main agent should always delegate tasks to approriate lead agent, who then will work together with other relevant agents to accomplish tasks.

## Product discovery

Product discovery in this project follows this workflow:

vision -> roadmap -> project brief -> prd

### Vision

We start with a big picture of what we are trying to build. This is documented in docs/vision.md.

### Roadmap

Using the vision, we build a roadmap of things that we want to build. This is documented in docs/roadmap.md.

### Project brief

We try to build the things in the roadmap one by one. We focus on the next item in the roadmap and create a project brief using the custom command: .claude/commands/product/create-brief.md.

### Product requirements document

After the brief has been created as .claude/likha-vibe-coding/prod-dev/brief.md. We use it to create a product requirements document (PRD) using .claude/commands/product/create-prd.md.

### Prioritiesd user stories

Finally, we use the PRD to extract the user stories and prioritise them using .claude/commands/product/backlog-grooming.md. This will create a prioritised list of user stories in .claude/likha-vibe-coding/prod-dev/user-stories.md

We are now ready for product development.

### Domain driven design

Aside from this, we also try to create a ubiquitous language of the domain so we are aligned on the things we are discussing and building.

We do some event storming using .claude/commands/product/event-storming to discuss and align on domain concepts. This will generate an event storming session document in docs/domain/event-storming/ and then tries to summarise that and update our main domain documentation in docs/domain/domains.md.

docs/domain/domains.md is our source of truth when talking about how we want to discuss business domain and also build our solutions.

### Relevant directories

**CRITICAL:** The directories we work on during product discovery are:

- docs/vision.md
- docs/roadmap.md
- docs/research/
- docs/domain/
- .claude/commands/product/
- .claude/likha-vibe-coding/prod-dev/
- .claude/likha-vibe-coding/template/

## Product development

### General workflow

Once we have prioritised user stories in .claude/likha-vibe-coding/prod-dev/user-stories.md, we are now ready to start with building or product development.

User stories usually are still big and what we want to do is break them down in smaller tasks so we can work iteratively and get feedback as soon as possible so as not to build the wrong things.

This is how our product development workflow looks like:

user stories -> select next user story to work on -> break the user story in tasks -> create a plan for accomplishing the next task -> work on the task -> update the status of the task -> update the status of the user story as needed

#### Create tasks for the next user story

We use .claude/commands/product-dev/create-tasks.md to select the next user story in .claude/likha-vibe-coding/prod-dev/user-stories.md we will be working on and break down this user story into tasks. This is documented in .claude/likha-vibe-coding/prod-dev/tasks.md.

#### Working on each task

Before working on a task, we create a plan on how to achieve the requirements for the task using .claude/commands/product-dev/plan-todo.md. This list downs the step-by-step things we need to do to complete the task in .claude/likha-vibe-coding/prod-dev/todo.md.

**Acceptance tests**

Before implementing each to do item in .claude/likha-vibe-coding/prod-dev/todo.md, the lead agent should start specifying acceptance tests which they can build as the starting point before writing any implementation code.

The tasks and each to do will have their acceptance criteria which can be the reference for building these acceptance tests.

**Test driven development**

Agents should always approach development with a test driven development approach.

Agents should create a failing test first and implement the smallest possible solution to make that test pass.

At the end of implementing the solution for the todo, agents should make sure that acceptance tests are passing.

**Work guides**

Each agent should be guided by their respective work guides when accomplishing tasks:

- backend
  - .claude/likha-vibe-coding/checklist/backend-work-guide.md
- frontend
  - .claude/likha-vibe-coding/checklist/frontend-work-guide.md
- infra
  - .claude/likha-vibe-coding/checklist/infra-work-guide.md
