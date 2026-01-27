# Terraform GitHub Module

> **📚 Related Documentation:**
> - **[Architecture Guide](../TERRAFORM_GITHUB_ARCHITECTURE.md)** - Complete guide on using these modules in production Terraform configurations

## Overview

This is a comprehensive Terraform module for managing GitHub organizations and repositories as Infrastructure as Code (IaC). The module provides a declarative way to manage GitHub resources, ensuring consistency, security, and compliance across GitHub organizations.

> **Note:** This document focuses on the module internals. For information on how to use these modules in a complete Terraform setup with backend configuration, secrets management, and production best practices, see the [Architecture Guide](../TERRAFORM_GITHUB_ARCHITECTURE.md).

## Module Structure

The module is organized into two main sub-modules:

```
modules/github/
├── organization/     # Manages GitHub organization-level resources
├── repository/       # Manages GitHub repository-level resources
└── example/          # Example usage demonstrating both modules
```

## Architecture

### Organization Module

The organization module manages GitHub organization-wide settings and resources:

**Key Responsibilities:**
- Organization settings (permissions, security features, project settings)
- Organization membership management
- Team creation and management
- Team membership assignments
- Organization-level GitHub Actions variables and secrets
- AWS KMS key provisioning for SOPS (Secrets Operations) encryption

**Resources Managed:**
- `github_organization_settings` - Organization-wide configuration
- `github_membership` - Organization members with roles (admin/member)
- `github_team` - Teams within the organization
- `github_team_members` - Team membership assignments
- `github_actions_organization_variable` - Organization-level variables
- `github_actions_organization_secret` - Organization-level secrets
- `aws_kms_key` & `aws_kms_alias` - KMS keys for SOPS encryption

### Repository Module

The repository module manages individual GitHub repositories and their configurations:

**Key Responsibilities:**
- Repository creation and configuration
- Branch protection rules
- Collaborator and team access management
- Repository-level variables and secrets
- GitHub Actions environments
- Environment-specific variables and secrets
- Repository labels
- Dependabot security updates

**Resources Managed:**
- `github_repository` - Core repository resource
- `github_branch_protection` - Branch protection rules
- `github_repository_collaborators` - Team and user access
- `github_actions_variable` - Repository-level variables
- `github_actions_secret` - Repository-level secrets
- `github_repository_environment` - Deployment environments
- `github_actions_environment_variable` - Environment variables
- `github_actions_environment_secret` - Environment secrets
- `github_issue_label` - Repository labels
- `github_repository_dependabot_security_updates` - Security updates

## Key Features

### 1. Comprehensive Validation

The module implements extensive input validation to catch errors early:

- **Repository naming**: Enforces GitHub naming conventions (lowercase, alphanumeric, hyphens, underscores)
- **Team ID validation**: Validates against allowed team IDs
- **Email validation**: Ensures proper email format for billing
- **Variable/Secret naming**: Enforces uppercase naming conventions
- **Branch naming**: Validates branch names against GitHub rules
- **SOPS KMS key naming**: Enforces naming convention for KMS keys

**Example from `repository/variables.tf`:**
```hcl
validation {
  condition     = can(regex("^[a-z][a-z0-9_-]*$", var.name))
  error_message = "Repository name must be lowercase, start with a letter..."
}
```

### 2. Security-First Design

- **Branch Protection**: Comprehensive branch protection rules with configurable:
  - Force push restrictions
  - Pull request requirements
  - Required status checks
  - Signed commits
  - Linear history requirements
  - Bypass lists for specific teams/users

- **Secret Management**: 
  - Organization and repository-level secrets
  - Environment-specific secrets
  - Integration with SOPS for encrypted secret storage

- **Access Control**:
  - Granular team and user permissions
  - Role-based access (admin, maintainer, member, etc.)

### 3. Flexible Configuration

The module uses Terraform's dynamic blocks and `for_each` loops to support:
- Multiple branches with different protection rules
- Multiple teams with different permissions
- Multiple environments with environment-specific configurations
- Multiple labels, variables, and secrets

**Example from `repository/main.tf`:**
```hcl
resource "github_branch_protection" "branch_protection" {
  for_each = { for bp in var.branches : bp.branch => bp }
  # ... configuration
}
```

### 4. Environment Management

Supports GitHub Actions environments with:
- Deployment branch policies
- Wait timers for manual approvals
- Environment-specific variables and secrets
- Admin bypass capabilities

## Technical Highlights

### 1. Dynamic Resource Creation

Uses `for_each` extensively to create multiple resources from lists/maps:

```hcl
resource "github_issue_label" "repository_labels" {
  for_each    = { for label in var.labels : label.name => label }
  repository  = github_repository.repository.name
  name        = each.value.name
  color       = each.value.color
  description = each.value.description
}
```

### 2. Conditional Resource Creation

Uses dynamic blocks for optional configurations:

```hcl
dynamic "required_pull_request_reviews" {
  for_each = each.value.required_pull_request_reviews == null ? [] : [each.value.required_pull_request_reviews]
  content {
    # ... configuration
  }
}
```

### 3. Complex Data Structures

Handles nested data structures for environment variables/secrets:

```hcl
resource "github_actions_environment_variable" "env_var" {
  for_each = merge([
    for env, variables in var.environment_variables : {
      for variable in variables : "${env}:${variable.variable_name}" => {
        environment   = env
        variable_name = variable.variable_name
        value         = variable.value
      }
    }
  ]...)
  # ... resource configuration
}
```

### 4. Cross-Resource Dependencies

Properly manages dependencies between resources:

```hcl
resource "github_team_members" "team_members" {
  for_each = var.team_members
  team_id  = github_team.teams[each.key].id  # Depends on team creation
  # ...
}
```

## Usage Example

### Organization Setup

```hcl
module "organization-example" {
  source = "../organization"

  organization_name = "Example"
  billing_email     = "user@example.com"

  members = {
    "ExampleAdmin"  = "admin"
    "ExampleMember" = "member"
  }
  
  teams = {
    "admins"  = "Example administrators"
    "example" = "Example team"
  }
  
  team_members = {
    "admins" = [
      { username = "ExampleAdmin", role = "maintainer" },
    ]
  }
  
  organization_variables = {
    "EXAMPLE_VARIABLE" = "example"
  }
  
  sops_kms_key_name = "sops-kms-key-example"
}
```

### Repository Setup

```hcl
module "repository-example" {
  source = "../repository"

  name        = "example"
  description = "Example repository"
  
  branches = [
    {
      branch = "main"
      force_push_bypassers = [
        "example-org/admins",
      ]
      required_pull_request_reviews = {
        required_approving_review_count = 1
        require_code_owner_reviews      = true
        pull_request_bypassers          = ["example-org/admins"]
      }
    }
  ]
  
  teams = [
    {
      permission = "admin"
      team_id    = "developer"
    }
  ]
  
  repository_environments = [
    {
      environment = "production"
      wait_timer  = 5
      deployment_branch_policy = {
        protected_branches     = true
        custom_branch_policies = false
      }
    }
  ]
}
```

## Design Decisions

### 1. Separation of Concerns

- **Organization module**: Manages org-wide settings and resources
- **Repository module**: Manages repository-specific configurations
- This separation allows for independent management and reusability

### 2. Validation Strategy

- Input validation at the variable level catches errors before Terraform execution
- Comprehensive validation rules ensure data integrity
- Clear error messages guide users to correct configurations

### 3. Default Values

- Sensible defaults for common configurations (e.g., `delete_branch_on_merge = true`)
- Optional parameters for advanced use cases
- Balance between ease of use and flexibility

### 4. Resource Naming

- Consistent naming conventions across resources
- Use of `for_each` keys for resource identification
- Clear resource relationships through naming

## Best Practices Implemented

1. **Idempotency**: All resources are managed declaratively, ensuring consistent state
2. **Version Pinning**: Provider versions are pinned for reproducibility
3. **Documentation**: Comprehensive README files with examples
4. **Validation**: Extensive input validation prevents common errors
5. **Security**: Security-first approach with branch protection and secret management
6. **Modularity**: Separate modules for organization and repository management
7. **Flexibility**: Supports a wide range of GitHub features and configurations

## Testing & Quality Assurance

The module includes:
- Input validation to catch configuration errors early
- Example configurations demonstrating proper usage
- Comprehensive variable documentation
- Type safety through Terraform type constraints

## Integration Points

- **GitHub Provider**: Uses the official GitHub Terraform provider
- **AWS Provider**: Provisions KMS keys for SOPS integration
- **SOPS**: Supports encrypted secret management via AWS KMS
- **CI/CD**: Can be integrated into CI/CD pipelines for automated infrastructure management

## Interview Talking Points

When discussing this module, you can highlight:

1. **Infrastructure as Code**: Demonstrates understanding of IaC principles and Terraform best practices
2. **Security**: Shows awareness of security best practices (branch protection, secret management)
3. **Validation**: Demonstrates defensive programming and input validation
4. **Modularity**: Shows ability to design reusable, maintainable modules
5. **Complexity Management**: Handles complex nested data structures and conditional logic
6. **Documentation**: Shows commitment to clear, comprehensive documentation
7. **Real-world Application**: Practical module that solves actual infrastructure management needs

## Conclusion

This module represents a production-ready solution for managing GitHub infrastructure as code. It demonstrates proficiency in Terraform, understanding of GitHub's API and features, and best practices in infrastructure management, security, and code organization.
