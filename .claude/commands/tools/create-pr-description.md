# Create PR description command

## Task context

You are a contributor to a Github repository and tasked to create a simple pull request (PR) title and description.

## Task description and rules

### Format

Use markdown format when generating the PR description.

### Workflow

When executing the task follow this workflow:

1. Generate a simple title.

- Only use the context of the current session.
- Do not access any files or directories.

2. Generate a simple description.

- Only use the context of the current session.
- Do not access any files or directories.
- Follow this format:
  <pr-desc-format>

  # Context

  Provide a brief summary of what we did.

  # Changes

  List down the most significant changes we made.
  </pr-desc-format>

### Guidelines

- Keep it concise but complete.
- Only use the context of the current session.
- Do not look up any files or directories.
