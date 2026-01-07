# GitHub Infrastructure as Code Example
#
# This file demonstrates how to use the terraform-module-github modules
# to manage GitHub organization settings, repositories, teams, and secrets.
#
# Prerequisites:
#   - GitHub Personal Access Token (PAT) set as TF_MANAGE_GITHUB_TOKEN
#   - SOPS configured with KMS key for secret encryption
#   - Encrypted secrets files in sops_secrets/ directory

# ============================================================================
# Backend Configuration
# ============================================================================
# Store Terraform state in a remote S3 bucket with state locking via DynamoDB
#
# Note: This should typically be in a separate backend.tf file, but is shown
# here for completeness. Uncomment and configure for your environment.
#
terraform {
  backend "s3" {
    bucket         = "my-org-tfstate-github"
    key            = "github/terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "terraform-state-locks-github"
    encrypt        = true
  }
}

# ============================================================================
# Provider Configuration
# ============================================================================
# Configure the GitHub and SOPS providers
#
# Note: This should typically be in a separate providers.tf file, but is shown
# here for completeness. Uncomment and configure for your environment.
#
provider "github" {
  owner = "my-organization"
}

provider "sops" {}

# ============================================================================
# Organization Configuration
# ============================================================================

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
  # Roles: "admin" or "member"
  members = {
    "admin-user"      = "admin"
    "developer-1"     = "member"
    "developer-2"     = "member"
    "service-account" = "admin"
  }

  # Teams definition
  # Teams are used for grouping members and managing repository access
  teams = {
    "admins"           = "GitHub administrators"
    "project-a-admins" = "Admins for Project A repositories"
    "project-b-admins" = "Admins for Project B repositories"
    "core-team"        = "Core development team"
    "devops"           = "DevOps and infrastructure team"
  }

  # Team membership
  # Role: "maintainer" or "member"
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
    "devops" = [
      { username = "admin-user", role = "maintainer" },
      { username = "developer-1", role = "member" },
    ]
  }

  # Organization-wide variables (available to all repositories)
  # These are non-sensitive configuration values
  organization_variables = {
    "AWS_REGION"              = "eu-west-1"
    "DEFAULT_ENVIRONMENT"     = "production"
    "MONITORING_WEBHOOK_URL"  = "https://hooks.example.com/webhook"
    "SLACK_WEBHOOK_URL"       = "https://hooks.slack.com/services/example"
  }

  # Organization-wide secrets (available to all repositories)
  # These are sensitive values encrypted with SOPS
  organization_secrets = {
    "AWS_ORG_ACCOUNT"           = data.sops_file.organization.data["AWS_ORG_ACCOUNT"]
    "SHARED_API_KEY"            = data.sops_file.organization.data["SHARED_API_KEY"]
    "SERVICE_ACCOUNT_TOKEN"     = data.sops_file.organization.data["SERVICE_ACCOUNT_TOKEN"]
    "GITHUB_PAT"                = data.sops_file.organization.data["GITHUB_PAT"]
  }

  # KMS key name for SOPS encryption
  sops_kms_key_name = "sops-kms-key-tf-github"
}

# ============================================================================
# Repository Configuration Examples
# ============================================================================

# Example 1: Main Application Repository
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
  # Define protection rules for different branches
  branches = [
    {
      branch = "main"
      # Teams or users that can bypass branch protection
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

  # Team access to repository
  # Permissions: "admin", "push", "pull", "triage", "maintain"
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
  # Labels can trigger workflows or categorize issues/PRs
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
    },
    {
      name        = "priority/high"
      color       = "d73a4a"
      description = "High priority issue"
    }
  ]

  # Repository-level variables (non-sensitive)
  repository_variables = {
    "DB_USER" = "postgres"
    "CI"      = "true"
    "NODE_ENV" = "production"
  }

  # Repository-level secrets (sensitive, encrypted with SOPS)
  repository_secrets = {
    "DB_NAME"         = data.sops_file.my-application.data["DB_NAME"]
    "DB_PORT"         = data.sops_file.my-application.data["DB_PORT"]
  }

  # Deployment environments
  # Environments can have branch policies and environment-specific secrets
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
      },
      {
        variable_name = "LOG_LEVEL"
        value         = "debug"
      }
    ],
    production = [
      {
        variable_name = "API_BASE_URL"
        value         = "https://api.myapp.com"
      },
      {
        variable_name = "LOG_LEVEL"
        value         = "info"
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

  # Enable Dependabot security updates
  dependabot_security_updates = true
}

# Example 2: Infrastructure Repository
module "infrastructure" {
  source = "./terraform-module-github/repository"

  name                        = "infrastructure"
  description                 = "Infrastructure as Code repository"
  default_branch              = "main"
  allow_update_branch         = true
  has_issues                  = true
  has_wiki                    = false
  squash_merge_commit_message = "BLANK"
  squash_merge_commit_title   = "PR_TITLE"

  branches = [
    {
      branch = "main"
      force_push_bypassers = [
        "my-org/admins",
        "my-org/devops"
      ]
      required_pull_request_reviews = {
        required_approving_review_count = 2
        require_code_owner_reviews      = true
        dismiss_stale_reviews           = true
      }
      required_status_checks = {
        strict = true
      }
    }
  ]

  teams = [
    {
      permission = "admin"
      team_id    = "admins"
    },
    {
      permission = "push"
      team_id    = "devops"
    }
  ]

  labels = [
    {
      name        = "terraform"
      color       = "7c3aed"
      description = "Terraform related changes"
    },
    {
      name        = "aws"
      color       = "ff9900"
      description = "AWS infrastructure changes"
    }
  ]

  repository_variables = {
    "TF_VERSION" = "1.5.0"
    "AWS_REGION" = "eu-west-1"
  }

  repository_secrets = {
    "AWS_ACCESS_KEY_ID"     = data.sops_file.infrastructure.data["AWS_ACCESS_KEY_ID"]
    "AWS_SECRET_ACCESS_KEY" = data.sops_file.infrastructure.data["AWS_SECRET_ACCESS_KEY"]
  }

  repository_environments = [
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

  dependabot_security_updates = true
}

# ============================================================================
# SOPS Secrets Data Sources
# ============================================================================
# These data sources reference encrypted secrets files that should be
# created using SOPS before running Terraform.
#
# To create encrypted secrets:
#   sops -e -i sops_secrets/organization.enc.yaml
#   sops -e -i sops_secrets/my-application.enc.yaml
#   sops -e -i sops_secrets/infrastructure.enc.yaml

# Organization-level secrets
data "sops_file" "organization" {
  source_file = "${path.module}/sops_secrets/organization.enc.yaml"
}

# Repository-specific secrets
data "sops_file" "my-application" {
  source_file = "${path.module}/sops_secrets/my-application.enc.yaml"
}

data "sops_file" "infrastructure" {
  source_file = "${path.module}/sops_secrets/infrastructure.enc.yaml"
}

# Environment-specific secrets (optional)
# data "sops_file" "dev-backend" {
#   source_file = "${path.module}/sops_secrets/environment_secrets/dev/backend.enc.yaml"
# }
