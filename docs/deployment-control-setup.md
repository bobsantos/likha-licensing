# Deployment Control Setup Guide

This guide explains how to configure deployment control using GitHub repository variables for the Likha Licensing Platform.

## Overview

The deployment workflow (`deploy.yml`) uses repository variables to control when deployments should run:

- **Enabled**: When `DEPLOY_ENABLED` variable is set to `'true'`
- **Disabled**: When `DEPLOY_ENABLED` is `'false'`, unset, or any other value
- **Manual Override**: Workflow can always be triggered manually via workflow dispatch, regardless of the variable setting

## Setup Instructions

### Step 1: Access Repository Settings

1. Navigate to your GitHub repository
2. Click on **Settings** tab (requires admin/write access)
3. In the left sidebar, click **Secrets and variables**
4. Click **Actions** from the submenu

### Step 2: Configure Repository Variable

1. Click on the **Variables** tab (next to Secrets tab)
2. Click **New repository variable**
3. Set the following:
   - **Name**: `DEPLOY_ENABLED`
   - **Value**: `true` (to enable) or `false` (to disable)
4. Click **Add variable**

### Step 3: Verify Configuration

After setting the variable, you can verify the configuration by:

1. Go to **Actions** tab in your repository
2. Look for the **Deploy Pipeline** workflow
3. Check recent runs to see the deployment status check

## Deployment Behavior

### When DEPLOY_ENABLED = 'true'

- ✅ Deployments run automatically on:
  - Push to `main` branch → Staging deployment
  - Version tags (`v*`) → Production deployment
- ✅ Manual workflow dispatch works
- ✅ All deployment jobs execute normally

### When DEPLOY_ENABLED ≠ 'true' (disabled)

- ❌ Automatic deployments are skipped
- ✅ Manual workflow dispatch still works (override)
- ℹ️ A clear message explains why deployment was skipped
- ℹ️ Instructions provided for enabling deployments

### Manual Override (Always Available)

1. Go to **Actions** > **Deploy Pipeline**
2. Click **Run workflow**
3. Select target environment:
   - `staging` - Deploy to staging environment
   - `production` - Deploy to production environment
4. Click **Run workflow**

This works regardless of the `DEPLOY_ENABLED` variable setting.

## Workflow Status Messages

### Deployment Enabled
```
✅ Deployment is enabled via DEPLOY_ENABLED repository variable
```

### Manual Trigger
```
✅ Deployment enabled via manual workflow_dispatch trigger
```

### Deployment Disabled
```
⚠️ Deployment is disabled. Set DEPLOY_ENABLED repository variable to 'true' or trigger manually to enable.
📖 See repository Settings > Secrets and variables > Actions > Variables tab
```

## Troubleshooting

### Deployments Not Running

1. **Check Variable Value**: Ensure `DEPLOY_ENABLED` is exactly `'true'` (case-sensitive)
2. **Check Variable Scope**: Must be a repository variable, not environment or organization variable
3. **Check Permissions**: Ensure the GitHub token has appropriate permissions

### Variable Not Working

1. **Refresh the page** after setting the variable
2. **Trigger a new workflow run** to test the setting
3. **Check workflow logs** for the deployment status check step

### Manual Triggers Not Working

1. **Check repository permissions**: Need write access to trigger workflows
2. **Check branch protection**: Ensure branch protection rules allow workflow runs
3. **Check workflow file**: Ensure `workflow_dispatch` trigger is configured

## Security Considerations

### Repository Variables vs Secrets

- **Repository Variables**: Used for non-sensitive configuration (like feature flags)
- **Repository Secrets**: Used for sensitive data (like API keys, passwords)

The `DEPLOY_ENABLED` flag is a configuration setting, not sensitive data, so it's appropriate to use a repository variable.

### Access Control

- Repository variables are visible to anyone with read access to the repository
- Use appropriate repository access controls to limit who can modify deployment settings
- Consider using environment-specific variables for different deployment targets

## Best Practices

### Development Workflow

1. **Development Phase**: Keep `DEPLOY_ENABLED` = `false` or unset
2. **Testing Phase**: Use manual triggers to test deployment workflows
3. **Production Ready**: Set `DEPLOY_ENABLED` = `true` to enable automatic deployments

### Team Coordination

1. **Document Changes**: Update team when enabling/disabling deployments
2. **Use PR Reviews**: Consider requiring reviews for deployment configuration changes
3. **Monitor Deployments**: Set up notifications for deployment successes/failures

### Environment Management

1. **Staging First**: Enable staging deployments before production
2. **Gradual Rollout**: Test with staging before enabling production deployments
3. **Rollback Plan**: Ensure rollback procedures are tested and documented

## Related Documentation

- [GitHub Actions Workflow Documentation](README.md)
- [Deployment Strategy Overview](../docs/deployment-strategy.md)
- [Infrastructure Setup Guide](../docs/infrastructure-setup.md)

## Support

If you encounter issues with deployment control setup:

1. Check the workflow logs for detailed error messages
2. Verify all prerequisites are met (secrets, variables, permissions)
3. Consult the troubleshooting section above
4. Create an issue in the repository for additional support