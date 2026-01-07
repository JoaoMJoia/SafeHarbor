# GitHub Infrastructure as Code Architecture

This document explains the architecture and structure of the Terraform configuration for managing GitHub organization settings, repositories, teams, and secrets.

## Overview

This Terraform configuration provides a centralized, version-controlled approach to managing GitHub resources. It uses reusable modules from `terraform-module-github/` to define organization settings, repositories, teams, branch protection rules, and secrets management.

The modules (`organization/` and `repository/`) encapsulate complex GitHub resource management logic, providing a clean, declarative interface for managing GitHub infrastructure as code.

## Directory Structure

```
terraform/
├── terraform-module-github/      # Reusable Terraform modules
│   ├── organization/             # Organization management module
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── README.md
│   ├── repository/               # Repository management module
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── README.md
│   └── example/                  # Example usage
│       └── main.tf
├── backend.tf                    # Terraform state backend configuration
├── providers.tf                  # Provider configurations (GitHub, SOPS)
├── versions.tf                   # Terraform and provider version constraints
├── organization-settings.tf      # Organization-level configuration
├── data_sops_secrets_files.tf    # SOPS encrypted secrets data sources
├── <repository-name>.tf          # Individual repository configurations
├── sops_secrets/                 # Encrypted secrets directory
│   ├── organization.enc.yaml
│   ├── <repo-name>.enc.yaml
│   └── environment_secrets/
│       └── <env>/
│           └── <service>.enc.yaml
└── <project-group>/               # Subdirectories for project groups
    ├── backend.tf
    ├── providers.tf
    └── <resource>.tf
```

> **Note:** The `terraform-module-github/` directory contains the reusable modules that are referenced in the configuration files below. These modules can be used locally (as shown in examples) or published to a module registry for team-wide use.

## Module Architecture

This architecture leverages two reusable Terraform modules located in `terraform-module-github/`:

1. **Organization Module** (`terraform-module-github/organization/`)
   - Manages GitHub organization-wide settings and resources
   - Handles organization members, teams, and team memberships
   - Provisions AWS KMS keys for SOPS encryption
   - Manages organization-level GitHub Actions variables and secrets

2. **Repository Module** (`terraform-module-github/repository/`)
   - Manages individual GitHub repositories
   - Configures branch protection rules
   - Manages repository access (teams and users)
   - Handles repository and environment-level variables/secrets
   - Creates repository labels and enables Dependabot

**Module Benefits:**
- **Reusability**: Write once, use across multiple repositories
- **Consistency**: Standardized configurations across the organization
- **Validation**: Built-in input validation prevents common errors
- **Maintainability**: Centralized logic for easier updates
- **Security**: Security best practices built into the modules

## Core Components

### 1. Backend Configuration (`backend.tf`)

The backend configuration stores Terraform state in a remote S3 bucket with state locking via DynamoDB:

```hcl
terraform {
  backend "s3" {
    bucket         = "my-org-tfstate-github"
    key            = "github/terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "terraform-state-locks-github"
    encrypt        = true
  }
}
```

### 2. Provider Configuration (`providers.tf`)

Configures the GitHub provider with the organization owner and SOPS provider for secret decryption:

```hcl
provider "github" {
  owner = "my-organization"
}

provider "sops" {}
```

**Note:** The GitHub provider requires a Personal Access Token (PAT) with appropriate permissions. Store it as an environment variable or secret named `TF_MANAGE_GITHUB_TOKEN`.

### 3. Organization Settings (`organization-settings.tf`)

Manages organization-level configuration using the reusable organization module from `terraform-module-github/`:

```hcl
module "my-org" {
  # Using local module (for development/testing)
  source = "./terraform-module-github/organization"
  
  # Or use from git repository (for production)
  # source = "git::https://github.com/my-org/terraform-module-github.git//organization?ref=v0.1.0"

  organization_name = "MyOrganization"
  location          = "United States"
  billing_email     = "billing@myorg.com"
  blog              = "https://www.myorg.com"
  twitter_username  = "myorg"

  # Organization members with roles
  members = {
    "admin-user"     = "admin"
    "developer-1"    = "member"
    "developer-2"    = "member"
    "service-account" = "admin"
  }

  # Teams definition
  teams = {
    "admins"           = "GitHub administrators"
    "project-a-admins" = "Admins for Project A repositories"
    "project-b-admins" = "Admins for Project B repositories"
    "core-team"        = "Core development team"
  }

  # Team membership
  team_members = {
    "admins" = [
      { username = "admin-user", role = "maintainer" },
      { username = "service-account", role = "maintainer" },
    ]
    "core-team" = [
      { username = "admin-user", role = "maintainer" },
      { username = "developer-1", role = "member" },
      { username = "developer-2", role = "member" },
    ]
  }

  # Organization-wide variables (available to all repositories)
  organization_variables = {
    "AWS_REGION"              = "eu-west-1"
    "DEFAULT_ENVIRONMENT"     = "production"
    "MONITORING_WEBHOOK_URL"  = "https://hooks.example.com/webhook"
  }

  # Organization-wide secrets (available to all repositories)
  organization_secrets = {
    "AWS_ORG_ACCOUNT"           = data.sops_file.organization.data["AWS_ORG_ACCOUNT"]
    "SHARED_API_KEY"            = data.sops_file.organization.data["SHARED_API_KEY"]
    "SERVICE_ACCOUNT_TOKEN"     = data.sops_file.service-account.data["TOKEN"]
  }

  sops_kms_key_name = "sops-kms-key-tf-github"
}
```

### 4. Repository Configuration

Each repository is managed through a dedicated `.tf` file using the reusable repository module from `terraform-module-github/`:

```hcl
module "my-application" {
  # Using local module (for development/testing)
  source = "./terraform-module-github/repository"
  
  # Or use from git repository (for production)
  # source = "git::https://github.com/my-org/terraform-module-github.git//repository?ref=v0.1.2"

  name                        = "my-application"
  description                 = "Main application repository"
  default_branch              = "main"
  allow_update_branch         = true
  has_issues                  = true
  has_wiki                    = false
  squash_merge_commit_message = "BLANK"
  squash_merge_commit_title   = "PR_TITLE"

  # Branch protection rules
  branches = [
    {
      branch = "main"
      force_push_bypassers = [
        "my-org/admins",
        "/developer-1",
        "/developer-2"
      ]
      required_pull_request_reviews = {
        required_approving_review_count = 1
        require_code_owner_reviews      = false
        dismiss_stale_reviews           = true
      }
      required_status_checks = {
        strict = false
      }
    },
    {
      branch = "develop"
      force_push_bypassers = [
        "my-org/admins",
      ]
      required_pull_request_reviews = {
        required_approving_review_count = 0
        require_code_owner_reviews      = false
      }
      required_status_checks = {
        strict = false
      }
    }
  ]

  # Team access
  teams = [
    {
      permission = "admin"
      team_id    = "admins"
    },
    {
      permission = "push"
      team_id    = "core-team"
    }
  ]

  # Repository labels for automation
  labels = [
    {
      name        = "infra-non-prod/eu-west-1"
      color       = "DBC840"
      description = "Apply terraform to non-production"
    },
    {
      name        = "infra-prod/eu-west-1"
      color       = "b60205"
      description = "Apply terraform to production"
    }
  ]

  # Repository-level variables
  repository_variables = {
    "DB_USER" = "postgres"
    "CI"      = "true"
  }

  # Repository-level secrets
  repository_secrets = {
    "SONARQUBE_TOKEN" = data.sops_file.my-application.data["SONARQUBE_TOKEN"]
    "DB_NAME"         = data.sops_file.my-application.data["DB_NAME"]
    "DB_PORT"         = data.sops_file.my-application.data["DB_PORT"]
  }

  # Deployment environments
  repository_environments = [
    {
      environment = "development"
    },
    {
      environment = "staging"
      deployment_branch_policy = {
        protected_branches     = false
        custom_branch_policies  = true
      }
    },
    {
      environment = "production"
      deployment_branch_policy = {
        protected_branches     = false
        custom_branch_policies = true
      }
    }
  ]

  # Environment-specific variables
  environment_variables = {
    development = [
      {
        variable_name = "API_BASE_URL"
        value         = "https://dev-api.myapp.com"
      }
    ],
    production = [
      {
        variable_name = "API_BASE_URL"
        value         = "https://api.myapp.com"
      }
    ]
  }

  # Environment-specific secrets
  environment_secrets = {
    development = [
      {
        secret_name = "DATABASE_PASSWORD"
        value       = data.sops_file.my-application.data["DATABASE_PASSWORD_DEV"]
      },
      {
        secret_name = "API_KEY"
        value       = data.sops_file.my-application.data["API_KEY_DEV"]
      }
    ],
    production = [
      {
        secret_name = "DATABASE_PASSWORD"
        value       = data.sops_file.my-application.data["DATABASE_PASSWORD_PROD"]
      },
      {
        secret_name = "API_KEY"
        value       = data.sops_file.my-application.data["API_KEY_PROD"]
      }
    ]
  }

  dependabot_security_updates = true
}
```

### 5. Secrets Management (`data_sops_secrets_files.tf`)

Secrets are encrypted using SOPS (Secrets Operations) and referenced as data sources:

```hcl
# Organization-level secrets
data "sops_file" "organization" {
  source_file = "${path.module}/sops_secrets/organization.enc.yaml"
}

# Repository-specific secrets
data "sops_file" "my-application" {
  source_file = "${path.module}/sops_secrets/my-application.enc.yaml"
}

# Environment-specific secrets
data "sops_file" "dev-backend" {
  source_file = "${path.module}/sops_secrets/environment_secrets/dev/backend.enc.yaml"
}
```

**Secrets Structure:**
- Organization secrets: `sops_secrets/organization.enc.yaml`
- Repository secrets: `sops_secrets/<repo-name>.enc.yaml`
- Environment secrets: `sops_secrets/environment_secrets/<env>/<service>.enc.yaml`

### 6. Project Group Subdirectories

For managing multiple related repositories, create subdirectories:

```
project-group/
├── backend.tf              # Separate state for this group
├── providers.tf
├── versions.tf
├── repository-1.tf
├── repository-2.tf
└── sops_secrets/
    └── ...
```

This allows:
- Isolated state management per project group
- Easier organization of related repositories
- Independent deployment workflows

## Key Design Patterns

### 1. Module Reusability

The configuration uses reusable modules from `terraform-module-github/` that encapsulate:
- **Organization Module** (`terraform-module-github/organization/`):
  - Organization management logic
  - Team creation and membership
  - Organization-level variables and secrets
  - AWS KMS key provisioning for SOPS
  
- **Repository Module** (`terraform-module-github/repository/`):
  - Repository creation and configuration
  - Branch protection rules
  - Repository-level access control
  - Environment management
  - Repository variables, secrets, and labels

### 2. Secrets as Code

All secrets are:
- Encrypted with SOPS before committing to version control
- Referenced through data sources in Terraform
- Stored in a structured directory hierarchy
- Decrypted at runtime by the SOPS provider

### 3. Environment Separation

Environments are managed through:
- Repository environments (development, staging, production)
- Environment-specific variables and secrets
- Branch-based deployment policies

### 4. Team-Based Access Control

Access is managed through:
- Organization teams
- Team-to-repository permissions
- Individual member roles
- Branch protection bypassers

## Workflow

1. **Initial Setup:**
   - Configure backend (S3 bucket, DynamoDB table)
   - Set up SOPS encryption keys
   - Create GitHub PAT with required permissions

2. **Adding a Repository:**
   - Create `<repository-name>.tf` file
   - Define repository configuration using the module
   - Create encrypted secrets file in `sops_secrets/`
   - Add data source in `data_sops_secrets_files.tf`
   - Run `terraform plan` and `terraform apply`

3. **Managing Secrets:**
   - Encrypt secrets using SOPS: `sops -e -i secrets/my-app.enc.yaml`
   - Reference in Terraform via data sources
   - Secrets are automatically decrypted by the SOPS provider

4. **Updating Configuration:**
   - Modify `.tf` files
   - Review changes with `terraform plan`
   - Apply with `terraform apply`

## Benefits

1. **Version Control:** All GitHub configuration is versioned and auditable
2. **Consistency:** Standardized repository settings across the organization
3. **Security:** Secrets encrypted at rest and managed through SOPS
4. **Scalability:** Easy to add new repositories and teams
5. **Automation:** Changes can be reviewed through pull requests
6. **Documentation:** Configuration serves as living documentation

## Best Practices

1. **Naming Conventions:**
   - Use descriptive repository names
   - Follow consistent team naming (e.g., `<project>-admins`, `<project>-developers`)
   - Use clear label names for automation

2. **Branch Protection:**
   - Always protect main/master branches
   - Require PR reviews for production branches
   - Allow force push only for specific teams/users

3. **Secrets Management:**
   - Never commit unencrypted secrets
   - Use separate secrets per environment
   - Rotate secrets regularly
   - Limit access to SOPS encryption keys

4. **State Management:**
   - Use remote state backends
   - Enable state locking
   - Regularly backup state files

5. **Module Versioning:**
   - Pin module versions explicitly when using git sources
   - Test module updates in non-production first
   - Document breaking changes
   - When using local modules, ensure consistent module code across environments

6. **Module Development:**
   - Test changes using the [example configuration](./terraform-module-github/example/)
   - Validate inputs using Terraform's validation blocks (already implemented in modules)

## Example: Complete Repository Setup

Here's a complete example of setting up a new repository:

1. **Create repository configuration file:**
   ```hcl
   # my-new-service.tf
   module "my-new-service" {
     # Using local module
     source = "./terraform-module-github/repository"
     
     # Or from git repository
     # source = "git::https://github.com/my-org/terraform-module-github.git//repository?ref=v0.1.2"
     
     name        = "my-new-service"
     description = "New microservice for user management"
     # ... (full configuration as shown above)
   }
   ```

2. **Create encrypted secrets:**
   ```bash
   sops -e -i sops_secrets/my-new-service.enc.yaml
   ```

3. **Add data source:**
   ```hcl
   # data_sops_secrets_files.tf
   data "sops_file" "my-new-service" {
     source_file = "${path.module}/sops_secrets/my-new-service.enc.yaml"
   }
   ```

4. **Apply configuration:**
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## Troubleshooting

**Issue:** Provider authentication errors
- **Solution:** Ensure `TF_MANAGE_GITHUB_TOKEN` environment variable is set with a valid PAT

**Issue:** SOPS decryption failures
- **Solution:** Verify SOPS key is accessible and KMS key permissions are correct

**Issue:** State locking errors
- **Solution:** Check DynamoDB table exists and has proper permissions

**Issue:** Module version conflicts
- **Solution:** Update module versions consistently across all repository configurations

**Issue:** Module source path errors
- **Solution:** Verify the path to `terraform-module-github/` is correct relative to your Terraform configuration files

## Summary

This architecture document describes how to use the reusable Terraform modules in `terraform-module-github/` to manage GitHub infrastructure as code. The modules provide:

- **Abstraction**: Complex GitHub resource management simplified through clean module interfaces
- **Validation**: Input validation ensures configurations are correct before Terraform execution
- **Consistency**: Standardized patterns for managing GitHub resources across the organization
- **Security**: Built-in security best practices for branch protection, secrets management, and access control

By using these modules, you can manage your entire GitHub organization and repositories declaratively, with version control, automated workflows, and consistent configurations.
