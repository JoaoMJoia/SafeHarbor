# AWS Amplify Architecture Documentation

This document explains the AWS Amplify infrastructure configuration and its integration with GitHub Actions workflows for automated preview deployments.

## Overview

The AWS Amplify setup provides a fully managed hosting service for the Next.js frontend application. It integrates with GitHub Actions to automatically create preview environments for pull requests, enabling developers to test changes before merging.

## Components

### 1. Terraform Configuration (`amplify.tf`)

The Terraform configuration defines the AWS Amplify application with the following key features:

#### Application Configuration

- **Name**: `frontend`
- **Platform**: `WEB_COMPUTE` - Enables Next.js Server-Side Rendering (SSR) support
- **Repository**: Connected to GitHub repository for source code
- **Auto Branch Creation**: **Disabled** - Branches must be created manually via GitHub Actions
- **Auto Branch Deletion**: **Enabled** - Branches are automatically deleted when removed from GitHub
- **Auto Build**: **Disabled** - Builds must be triggered manually

#### Build Specification

The build process follows these phases:

1. **Pre-Build Phase**:
   - Installs dependencies using `npm ci --prefer-offline` for faster, consistent builds

2. **Build Phase**:
   - Compiles the Next.js application using `npm run build`

3. **Artifacts**:
   - Deploys all files from the `.next` directory (Next.js build output)

4. **Cache**:
   - Caches `node_modules/**` to speed up dependency installation
   - Caches `.next/cache/**/*` to optimize incremental Next.js builds

#### Environment Variables

- `ENV`: Environment identifier (e.g., "dev")
- `NEXT_DISABLE_SSR`: Disables SSR when set to "1"
- `_BUILD_TIMEOUT`: Build timeout in minutes (15 minutes)
- `EXAMPLE_VARIABLE`: Example configuration variable

#### Custom Rules

- **SPA Routing Support**: Custom rule redirects 404 errors to `index.html` with a 200 status code, enabling client-side routing for single-page applications

#### IAM Service Role

The Amplify app uses a service role ARN for logging and monitoring SSR applications:
```
arn:aws:iam::************:role/service-role/AmplifySSRLoggingRole-************
```

---

## 2. GitHub Actions Workflows

### Workflow 1: Manual Branch Management (`amplify-preview-url.yaml`)

This workflow provides manual control over Amplify branches and deployments.

#### Trigger

- **Type**: Manual (`workflow_dispatch`)
- **Inputs**:
  - `branch_name`: The branch name to operate on (required)
  - `operation`: Either `create` or `delete` (required)

#### Operations

##### Create Operation

When `operation: create` is selected:

1. **PR Validation**: Finds the associated open Pull Request for the specified branch
2. **Branch Check**: Verifies if the branch already exists in Amplify
3. **Branch Creation**: Creates a new Amplify branch if it doesn't exist (with auto-build enabled)
4. **Job Management**:
   - Checks for running deployment jobs
   - Starts a new `RELEASE` job if no job is running
5. **Deployment Monitoring**: Polls the deployment job status every 30 seconds until completion
6. **PR Comments**: Posts comments on the PR with:
   - Deployment start notification with Job ID
   - Success notification with preview URL
   - Failure notification with workflow run link

##### Delete Operation

When `operation: delete` is selected:

1. **Branch Check**: Verifies if the branch exists in Amplify
2. **Branch Deletion**: Deletes the branch from AWS Amplify
3. **Notification**: Sends a Microsoft Teams notification about the deletion

#### AWS Authentication

- Uses OIDC (OpenID Connect) for secure AWS authentication
- Assumes IAM role: `arn:aws:iam::${{ secrets.AWS_ORG_ACCOUNT }}:role/github-actions-role`
- Region: Configured via `vars.AWS_REGION`

#### Environment Variables

- `AMPLIFY_APP_ID`: The AWS Amplify application ID
- `AWS_REGION`: AWS region for Amplify operations
- `ROLE-TO-ASSUME`: IAM role ARN for AWS authentication

---

### Workflow 2: CI Monitoring (`ci-amplify-preview-url.yaml`)

This workflow automatically monitors Amplify deployments for pull requests.

#### Trigger

- **Type**: Pull Request
- **Branches**: PRs targeting the `dev` branch

#### Workflow Steps

1. **AWS Authentication**: Authenticates with AWS using OIDC
2. **Branch Validation**: Extracts the PR branch name from `github.head_ref`
3. **Branch Existence Check**: Verifies if the branch exists in AWS Amplify
4. **Job Status Check**: Retrieves the latest deployment job status and ID
5. **Initial PR Comment**: Posts a comment indicating:
   - Deployment is running (if job exists)
   - No active deployment found (if no job exists)
6. **Deployment Monitoring**: 
   - Polls job status every 30 seconds
   - Continues until job reaches `SUCCEED`, `FAILED`, or other terminal state
7. **Preview URL Extraction**: Retrieves the preview URL from branch details
8. **Final PR Comment**: Updates the PR with:
   - Success message and preview URL (if deployment succeeded)
   - Failure message with workflow run link (if deployment failed)

#### Key Differences from Manual Workflow

- **Automatic Trigger**: Runs automatically on PR creation/updates
- **No Branch Creation**: Only monitors existing branches (doesn't create them)
- **Read-Only Operations**: Only checks status, doesn't create branches or start jobs

---

## Workflow Integration

### Typical Development Flow

1. **Developer creates a feature branch** and opens a Pull Request targeting `dev`

2. **Manual Branch Creation** (via `amplify-preview-url.yaml`):
   - Developer or maintainer manually triggers the workflow with `operation: create`
   - Workflow creates the Amplify branch and starts deployment
   - Preview URL is posted to the PR

3. **Automatic Monitoring** (via `ci-amplify-preview-url.yaml`):
   - CI workflow automatically monitors the deployment status
   - Updates PR comments with deployment progress and final status

4. **Branch Cleanup** (via `amplify-preview-url.yaml`):
   - When PR is merged or closed, manually trigger workflow with `operation: delete`
   - Branch is deleted from Amplify
   - Teams notification is sent

### Why Manual Branch Creation?

The Terraform configuration has `enable_auto_branch_creation = false` because:

- **Cost Control**: Prevents automatic creation of branches for every PR
- **Selective Deployments**: Only important PRs get preview environments
- **Resource Management**: Avoids unnecessary AWS resources for draft/WIP PRs

---

## Preview URL Format

Preview URLs follow this pattern:
```
https://{branch-display-name}.{amplify-app-id}.amplifyapp.com
```

The `branch-display-name` is automatically generated by AWS Amplify based on the branch name.

---

## Configuration Requirements

### GitHub Repository Variables

- `AWS_REGION`: AWS region where Amplify app is deployed
- `MS_TEAMS_WEBHOOK_URI`: Microsoft Teams webhook URI for notifications

### GitHub Repository Secrets

- `AWS_ORG_ACCOUNT`: AWS account ID for IAM role assumption

### AWS IAM Role

The workflows require an IAM role with the following permissions:
- `amplify:GetApp`
- `amplify:GetBranch`
- `amplify:ListBranches`
- `amplify:CreateBranch`
- `amplify:DeleteBranch`
- `amplify:ListJobs`
- `amplify:GetJob`
- `amplify:StartJob`

The role ARN format: `arn:aws:iam::{account-id}:role/github-actions-role`

---

## Troubleshooting

### Branch Not Found

If the CI workflow reports "Branch does not exist in Amplify":
- Manually trigger `amplify-preview-url.yaml` with `operation: create` first
- Ensure the branch name matches exactly (case-sensitive)

### Deployment Failures

Common causes:
- Build timeout (check `_BUILD_TIMEOUT` environment variable)
- Missing environment variables
- Build errors in the Next.js application
- Insufficient IAM permissions

### Preview URL Not Available

- Ensure deployment job status is `SUCCEED`
- Check that the branch was created with `enable-auto-build`
- Verify the Amplify app ID is correct in workflow environment variables

---

## Best Practices

1. **Branch Naming**: Use descriptive branch names that will appear in preview URLs
2. **Cleanup**: Always delete Amplify branches when PRs are closed to avoid resource waste
3. **Monitoring**: Use the CI workflow to track deployment status automatically
4. **Manual Control**: Use manual workflow for important PRs that need preview environments
5. **Environment Variables**: Keep sensitive values in AWS Amplify console, not in Terraform

---

## Related Documentation

- [AWS Amplify Documentation](https://docs.aws.amazon.com/amplify/)
- [Next.js Deployment Guide](https://nextjs.org/docs/deployment)
- [GitHub Actions OIDC Authentication](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services)
