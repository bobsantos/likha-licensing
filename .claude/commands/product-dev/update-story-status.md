# Update Story Status Command

## Task context

You are tasked with updating the status of a specific user story in the user-stories.md file.

## Task description and rules

### Input format

The user will provide input in the format: `userstoryID:status`

- `userstoryID`: The user story identifier (e.g., US-001, US-002)
- `status`: One of: pending, in_progress, blocked, cancelled, closed, done

### RESTRICTED FILE ACCESS - MANDATORY COMPLIANCE

**ALLOWED FILES AND DIRECTORIES ONLY:**

- `.claude/likha-vibe-coding/prod-dev/user-stories.md` (user story priorities file)

**CRITICAL RESTRICTIONS:**

1. **FORBIDDEN ACCESS**: You are PROHIBITED from accessing any files or directories outside the allowed list above.

2. **SPECIFICALLY FORBIDDEN:**

   - Do NOT access scratch/ directory or any files within it
   - Do NOT access root directory files
   - Do NOT access any other .claude/ subdirectories
   - Do NOT access src/, docs/, or any code directories
   - Do NOT access any files outside the prod-dev directory

3. **COMPLIANCE CHECK**: BEFORE accessing ANY file, verify the path is the allowed file above.

### Workflow

1. **Parse the input** to extract userstoryID and status

   - Validate format is `userstoryID:status`
   - Validate status is one of: pending, in_progress, blocked, cancelled, closed, done

2. **Read the user story file** at `.claude/likha-vibe-coding/prod-dev/user-stories.md`

   - ONLY access this specific file path
   - Do NOT access any other files

3. **Find the user story** by searching for the userstoryID in the file

   - Look for user story sections like `#### 1. US-001: Tenant Schema Provisioning (P0 - CRITICAL)`
   - Locate the corresponding status line

4. **Update the status** by replacing the current status line with the new status

   - Find line matching pattern: `**Status**: [current_status]`
   - Replace with: `**Status**: [new_status]`

5. **Save the changes** to the file
   - Use Edit or MultiEdit tool to update the file
   - Preserve all other content and formatting

### Guidelines

- **Status line format**: Look for lines like `**Status**: [current_status]` and update to `**Status**: [new_status]`
- **Valid statuses**: Only accept: pending, in_progress, blocked, cancelled, closed, done
- **Error handling**:
  - If userstoryID is not found, inform the user that the user story was not found
  - If status is invalid, inform the user of valid status options
- **Preserve formatting**: Maintain the exact formatting and structure of the file
- **No additional changes**: Only update the status field, do not modify any other content

### Example

Input: `US-001:in_progress`

- Find user story US-001 in the file
- Locate the line `**Status**: pending`
- Change it to `**Status**: in_progress`
- Save the file

### Output

After successfully updating the status, confirm:

- User Story ID that was updated
- Previous status
- New status
- Example: "✅ Updated US-001 from 'pending' to 'in_progress'"

If error occurred, report:

- What went wrong (user story not found, invalid status, etc.)
- Guidance on correct usage
