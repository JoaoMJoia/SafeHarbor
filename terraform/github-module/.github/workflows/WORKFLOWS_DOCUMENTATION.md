# GitHub Actions Workflows Documentation

> **📚 Related Documentation:**
> - **[Module Documentation](../../TERRAFORM_GITHUB_MODULE.md)** - Complete guide on the Terraform module structure and features
> - **[Architecture Guide](../../../TERRAFORM_GITHUB_ARCHITECTURE.md)** - Guide on using these modules in production Terraform configurations

## Overview

This document explains the GitHub Actions workflows that support and complement the Terraform GitHub module. These workflows provide automated quality assurance, testing, documentation generation, release management, and infrastructure validation for the module itself.

All workflows documented here are located in `terraform-module-github/.github/workflows/` and are specifically designed to maintain the quality, compatibility, and documentation of the Terraform module.

## Workflow Architecture

```
terraform-module-github/
└── .github/workflows/                    # Module-specific workflows
    ├── ci-lint.yaml                      # Code quality and linting
    ├── ci-terraform.yaml                 # Terraform validation and docs
    ├── ci-terraform-compatibilities.yml  # Multi-version compatibility testing
    ├── github-release.yml                # Automated releases
    ├── tag-retention-policy.yaml         # Tag cleanup and maintenance
    └── WORKFLOWS_DOCUMENTATION.md         # This file
```

## Module-Specific Workflows

These workflows are located in `terraform-module-github/.github/workflows/` and are specifically designed to maintain the quality, compatibility, and documentation of the Terraform module.

### 1. CI - Lint (`ci-lint.yaml`)

**Purpose:** Ensures code quality and consistency across all files in the module.

**What it does:**
- Validates Terraform files (formatting and `tflint`)
- Lints YAML, JSON, Shell, and Bash files
- Performs security checks using Checkov
- Automatically fixes formatting issues where possible

**How it complements the module:**
- **Quality Assurance:** Catches syntax errors, formatting issues, and security vulnerabilities before they reach production
- **Consistency:** Ensures all module code follows the same standards, making it easier to maintain and understand
- **Security:** Checkov scans for security misconfigurations in Terraform code, critical for infrastructure modules

**Triggers:**
- Pull requests targeting any branch
- Pushes to `main` branch (lint job only runs on PRs)

**Key Features:**
- Uses Super Linter with custom configuration from `.github/linters/`
- Automatically fixes Terraform formatting issues
- Validates against custom YAML linting rules
- Security scanning with Checkov

---

### 2. CI - Terraform (`ci-terraform.yaml`)

**Purpose:** Validates Terraform module functionality and automatically generates documentation.

**What it does:**
- Runs `terraform init`, `validate`, and `plan` on the example configuration
- Posts validation status and plan output as PR comments
- Automatically updates README.md files in `repository/` and `organization/` folders using `terraform-docs`
- Posts module usage examples on PRs

**How it complements the module:**
- **Validation:** Ensures the module works correctly with the example configuration before changes are merged
- **Documentation:** Automatically keeps module documentation in sync with code changes
- **Developer Experience:** Provides immediate feedback on PRs showing what the module will do
- **Example Verification:** Validates that the example configuration is always working

**Triggers:**
- Pull requests (ignores changes to `.github/**`, `CODEOWNERS`, `README.md`)
- Manual trigger via `workflow_dispatch` with customizable parameters

**Key Features:**
- AWS OIDC authentication for testing with real AWS resources
- Posts comprehensive PR comments with validation results and plan output
- Auto-commits documentation updates to PR branches
- Supports custom Terraform versions and example folder paths

**Workflow Jobs:**
1. **plan:** Validates and plans Terraform changes, posts summary to PR
2. **how-to-use:** Posts module usage examples as PR comment
3. **docs-repository:** Auto-updates `repository/README.md`
4. **docs-organization:** Auto-updates `organization/README.md`

---

### 3. CI - Terraform Compatibilities Check (`ci-terraform-compatibilities.yml`)

**Purpose:** Ensures the module works across multiple Terraform versions.

**What it does:**
- Tests the module against multiple Terraform versions (default: 1.9.7, 1.10.0, 1.12.1)
- Validates syntax, formatting, and provider compatibility for each version
- Uses matrix strategy to test all versions in parallel

**How it complements the module:**
- **Backward Compatibility:** Ensures the module works for users on different Terraform versions
- **Future-Proofing:** Catches version-specific issues before they affect users
- **Quality Assurance:** Validates that module changes don't break compatibility with supported versions

**Triggers:**
- Pull requests when Terraform files (`**.tf`) or this workflow file changes
- Manual trigger with customizable Terraform version list

**Key Features:**
- Matrix strategy for parallel version testing
- AWS OIDC authentication for provider compatibility testing
- Validates module syntax and formatting across versions
- All versions must pass for workflow to succeed

---

### 4. GitHub Package Release (`github-release.yml`)

**Purpose:** Automates the release process for the Terraform module.

**What it does:**
- Bumps version and creates git tags based on conventional commits
- Generates/updates `CHANGELOG.md` with commit history
- Creates GitHub releases with changelog and auto-generated release notes
- Creates and auto-merges a PR with changelog updates
- Sends notifications to Microsoft Teams (if configured)

**How it complements the module:**
- **Version Management:** Automates semantic versioning based on commit messages
- **Release Documentation:** Maintains changelog automatically
- **Distribution:** Creates GitHub releases that can be referenced in module sources
- **Communication:** Notifies teams of new releases

**Triggers:**
- Called as a reusable workflow (`workflow_call`) from other workflows
- Typically triggered when code is merged to `main`

**Key Features:**
- Conventional commit-based version bumping
- Gitmoji support in changelog
- Excludes documentation-only commits from changelog
- Auto-creates and merges PR with changelog updates
- MS Teams integration for release notifications

**Release Process:**
1. Version bump based on conventional commits (feat → minor, fix → patch, BREAKING → major)
2. Generate changelog from commit history
3. Create git tag (format: `vX.X.X`)
4. Create GitHub release with changelog
5. Create PR with changelog updates
6. Auto-merge PR
7. Send MS Teams notification

---

### 5. Tag Retention Policy (`tag-retention-policy.yaml`)

**Purpose:** Automatically manages git tags to keep the repository clean.

**What it does:**
- Identifies the latest major version (e.g., `v3.0.0`)
- Applies retention rules:
  - Latest major version: Keeps ALL minor/patch versions
  - Previous 2 major versions: Keeps the last 2 versions of each
- Deletes tags that don't match retention criteria
- Sends MS Teams notifications with cleanup summary

**How it complements the module:**
- **Repository Maintenance:** Prevents tag clutter while preserving important versions
- **Version History:** Maintains a clean version history for module consumers
- **Storage Optimization:** Reduces repository size by removing old tags
- **User Experience:** Keeps the releases page focused on relevant versions

**Triggers:**
- Scheduled: 1st day of every month at 10:10 AM
- Manual trigger with optional dry-run mode

**Retention Rules Example:**
If you have tags: `v1.0.0`, `v1.1.0`, `v1.2.0`, `v2.0.0`, `v2.1.0`, `v2.2.0`, `v3.0.0`, `v3.1.0`
- **Keeps:** `v3.0.0`, `v3.1.0` (all of latest major v3)
- **Keeps:** `v2.1.0`, `v2.2.0` (last 2 of previous major v2)
- **Keeps:** `v1.1.0`, `v1.2.0` (last 2 of previous major v1)
- **Deletes:** `v1.0.0`, `v2.0.0`

---

## How Workflows Complement the Terraform Module

### 1. Quality Assurance Pipeline

The workflows create a comprehensive quality assurance pipeline:

```
PR Created
    ↓
[CI - Lint] → Validates code quality, formatting, security
    ↓
[CI - Terraform] → Validates module functionality, generates docs
    ↓
[CI - Terraform Compatibilities] → Tests multiple Terraform versions
    ↓
PR Merged → [GitHub Release] → Creates versioned release
```

### 2. Documentation Automation

- **Auto-Generated READMEs:** `ci-terraform.yaml` automatically updates module README files with `terraform-docs`
- **Changelog Management:** `github-release.yml` maintains `CHANGELOG.md` automatically
- **Usage Examples:** PR comments include module usage examples

### 3. Version Management

- **Semantic Versioning:** `github-release.yml` handles version bumping based on conventional commits
- **Tag Management:** `tag-retention-policy.yaml` keeps version history clean
- **Release Distribution:** GitHub releases enable module versioning via git tags

### 4. Developer Experience

- **Immediate Feedback:** PR comments show validation results, plan output, and usage examples
- **Error Prevention:** Linting and validation catch issues before merge
- **Documentation:** Always up-to-date documentation without manual effort

### 5. Module Reliability

- **Compatibility Testing:** Ensures module works across Terraform versions
- **Example Validation:** Example configuration is always tested and working
- **Security Scanning:** Checkov identifies security issues in infrastructure code

## Workflow Dependencies

```
┌─────────────────────────────────────────────────────────┐
│                    Pull Request                          │
└─────────────────────────────────────────────────────────┘
                        │
        ┌───────────────┼───────────────┐
        │               │               │
        ▼               ▼               ▼
  [CI - Lint]   [CI - Terraform]  [CI - Compatibilities]
        │               │               │
        └───────────────┼───────────────┘
                        │
                        ▼
                  PR Merged
                        │
                        ▼
              [GitHub Release]
                        │
                        ▼
              [Tag Retention]
```

## Configuration Requirements

### Required Secrets and Variables

**Module Workflows:**
- `AWS_ORG_ACCOUNT` (secret): AWS account ID for OIDC authentication
- `AWS_REGION` (variable): AWS region for operations
- `MS_TEAMS_WEBHOOK_URI` (variable, optional): MS Teams webhook for notifications

### AWS IAM Role

All workflows that interact with AWS use OIDC authentication with the role:
```
arn:aws:iam::<AWS_ORG_ACCOUNT>:role/github-actions-role
```

This role must have permissions for:
- AWS KMS (for SOPS key operations in Terraform workflows)

## Best Practices

### 1. Conventional Commits

Use conventional commit messages for automatic version bumping:
- `feat:` → Minor version bump
- `fix:` → Patch version bump
- `BREAKING CHANGE:` → Major version bump

### 2. PR Workflow

1. Create PR with module changes
2. Workflows automatically validate and test
3. Review PR comments for validation results
4. Merge when all checks pass
5. Release workflow automatically creates new version

### 3. Module Development

- Test changes using the `example/` folder
- Ensure example configuration always works
- Update documentation in code (terraform-docs will auto-generate README)
- Use conventional commits for proper versioning

### 4. Version Management

- Let the release workflow handle versioning
- Review changelog PR before merging
- Tag retention policy will clean up old versions automatically

## Troubleshooting

### Workflow Failures

**CI - Lint failures:**
- Check Super Linter output for specific errors
- Run `terraform fmt` locally to fix formatting
- Review Checkov security findings

**CI - Terraform failures:**
- Verify example configuration is valid
- Check AWS credentials and permissions
- Review Terraform plan output in PR comments

**CI - Compatibilities failures:**
- Check which Terraform version failed
- Review provider compatibility issues
- Ensure module syntax is compatible with all tested versions

**Release workflow failures:**
- Verify conventional commit format
- Check GitHub token permissions
- Ensure MS Teams webhook is configured (if using notifications)

### Common Issues

**Issue:** Documentation not updating
- **Solution:** Check that `terraform-docs` action has write permissions and can push to PR branch

**Issue:** Release not creating
- **Solution:** Verify workflow is called from another workflow or manually triggered on `main` branch

**Issue:** Tag retention deleting important tags
- **Solution:** Review retention policy logic, adjust if needed, or use dry-run mode first

## Summary

The GitHub Actions workflows provide a complete CI/CD pipeline for the Terraform GitHub module:

1. **Quality Assurance:** Linting, validation, and security scanning
2. **Testing:** Multi-version compatibility testing and example validation
3. **Documentation:** Auto-generated READMEs and changelogs
4. **Release Management:** Automated versioning and release creation
5. **Maintenance:** Tag cleanup and repository hygiene

Together, these workflows ensure the Terraform module is:
- ✅ High quality and secure
- ✅ Well-documented
- ✅ Compatible across Terraform versions
- ✅ Easy to use and maintain
- ✅ Properly versioned and distributed

This automation allows developers to focus on module functionality while the workflows handle quality assurance, documentation, and release management automatically.
