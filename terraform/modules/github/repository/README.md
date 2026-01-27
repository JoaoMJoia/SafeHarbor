# Repository Terraform Module

## Description
This module manages GitHub repositories, including repository settings, branch protections, collaborators, teams, variables, secrets, environments, and labels. It is designed to provide a comprehensive and secure setup for GitHub repositories.

## Prerequisites
- Terraform >= 1.5.2
- GitHub provider >= 5.0
- Sufficient permissions to manage GitHub repositories and settings

## Usage
```hcl
module "repository-example" {
  source = "../repository"

  name        = "example"
  description = "Example repository"
  branches = [
    {
      branch = "example"
      force_push_bypassers = [
        "example-org/admins",
        "example-org/example-admins",
      ]
      required_pull_request_reviews = {
        required_approving_review_count = 0
        require_code_owner_reviews      = false
      }
    }
  ]
  teams = [
    {
      permission = "admin"
      team_id    = "developer"
    }
  ]
  repository_variables = {
    "EXAMPLE_VARIABLE" = "example"
  }
  repository_secrets = {
    "EXAMPLE_SECRET" = "example"
  }
  repository_environments = [
    {
      environment = "example"
      deployment_branch_policy = {
        protected_branches     = false
        custom_branch_policies = true
      }
    }
  ]
  environment_variables = {
    example = [
      {
        variable_name = "EXAMPLE_VARIABLE"
        value         = "example"
      }
    ]
  }
  environment_secrets = {
    example = [
      {
        secret_name = "EXAMPLE_SECRET"
        value       = "example"
      },
    ]
  }
  labels = [
    {
      name        = "example"
      color       = "DBC840"
      description = "Example label"
    }
  ]
}
```

## Features
- Create and manage GitHub repositories with customizable settings
- Configure branch protections and default branches
- Manage repository collaborators and teams with granular permissions
- Set up repository-level and environment-level variables and secrets
- Define repository environments and deployment branch policies
- Add custom labels to repositories
- Enable security features like Dependabot and vulnerability alerts

## Best Practices
- Use descriptive names and descriptions for repositories
- Apply branch protections to enforce code quality and security
- Use teams and user permissions to control access
- Store sensitive data in secrets and variables, not in code
- Regularly review and update repository settings and permissions
- Pin provider versions for reproducibility

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.2 |
| <a name="requirement_github"></a> [github](#requirement\_github) | >= 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_github"></a> [github](#provider\_github) | >= 5.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [github_actions_environment_secret.env_secret](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_environment_secret) | resource |
| [github_actions_environment_variable.env_var](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_environment_variable) | resource |
| [github_actions_secret.repository_secrets](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_secret) | resource |
| [github_actions_variable.repository_variables](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_variable) | resource |
| [github_branch.repo_branches](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/branch) | resource |
| [github_branch_default.branch_default](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/branch_default) | resource |
| [github_branch_protection.branch_protection](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/branch_protection) | resource |
| [github_issue_label.repository_labels](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/issue_label) | resource |
| [github_repository.repository](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository) | resource |
| [github_repository_collaborators.repository_collaborators](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository_collaborators) | resource |
| [github_repository_dependabot_security_updates.repository_dependabot_security_updates](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository_dependabot_security_updates) | resource |
| [github_repository_environment.repository_environment](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository_environment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allow_auto_merge"></a> [allow\_auto\_merge](#input\_allow\_auto\_merge) | Whether to allow auto-merge | `bool` | `false` | no |
| <a name="input_allow_merge_commit"></a> [allow\_merge\_commit](#input\_allow\_merge\_commit) | Whether to allow merge commit | `bool` | `true` | no |
| <a name="input_allow_rebase_merge"></a> [allow\_rebase\_merge](#input\_allow\_rebase\_merge) | Whether to allow rebase merge | `bool` | `true` | no |
| <a name="input_allow_squash_merge"></a> [allow\_squash\_merge](#input\_allow\_squash\_merge) | Whether to allow squash merge | `bool` | `true` | no |
| <a name="input_allow_update_branch"></a> [allow\_update\_branch](#input\_allow\_update\_branch) | Whether to allow branch update | `bool` | `false` | no |
| <a name="input_archived"></a> [archived](#input\_archived) | Whether the repository is archived | `bool` | `false` | no |
| <a name="input_auto_init"></a> [auto\_init](#input\_auto\_init) | Whether to auto initialize the repository | `bool` | `false` | no |
| <a name="input_branches"></a> [branches](#input\_branches) | List of branch protections to apply | <pre>list(object({<br>    branch                          = string<br>    allows_deletions                = optional(bool, false)<br>    allows_force_pushes             = optional(bool, false)<br>    enforce_admins                  = optional(bool, false)<br>    lock_branch                     = optional(bool, false)<br>    require_conversation_resolution = optional(bool, true)<br>    require_signed_commits          = optional(bool, false)<br>    required_linear_history         = optional(bool, false)<br>    force_push_bypassers            = optional(list(string), [])<br>    required_pull_request_reviews = optional(object({<br>      dismiss_stale_reviews           = optional(bool, false)<br>      dismissal_restrictions          = optional(list(string), [])<br>      require_code_owner_reviews      = bool<br>      require_last_push_approval      = optional(bool, false)<br>      required_approving_review_count = number<br>      restrict_dismissals             = optional(bool, false)<br>    }), null)<br>    required_status_checks = optional(object({<br>      contexts = optional(list(string), [])<br>      strict   = bool<br>    }), null)<br>  }))</pre> | `[]` | no |
| <a name="input_default_branch"></a> [default\_branch](#input\_default\_branch) | Default branch for the repository | `string` | `"main"` | no |
| <a name="input_delete_branch_on_merge"></a> [delete\_branch\_on\_merge](#input\_delete\_branch\_on\_merge) | Whether to delete branch on merge | `bool` | `true` | no |
| <a name="input_dependabot_security_updates"></a> [dependabot\_security\_updates](#input\_dependabot\_security\_updates) | Whether Dependabot security updates are enabled | `bool` | `false` | no |
| <a name="input_description"></a> [description](#input\_description) | Description of the GitHub repository | `string` | n/a | yes |
| <a name="input_environment_secrets"></a> [environment\_secrets](#input\_environment\_secrets) | Map of environment secrets where key is environment name and value is list of secrets | <pre>map(list(object({<br>    secret_name = string<br>    value       = string<br>  })))</pre> | `{}` | no |
| <a name="input_environment_variables"></a> [environment\_variables](#input\_environment\_variables) | Map of environment variables where key is environment name and value is list of variables | <pre>map(list(object({<br>    variable_name = string<br>    value         = string<br>  })))</pre> | `{}` | no |
| <a name="input_has_downloads"></a> [has\_downloads](#input\_has\_downloads) | Whether the repository has downloads | `bool` | `true` | no |
| <a name="input_has_issues"></a> [has\_issues](#input\_has\_issues) | Whether the repository has issues | `bool` | `true` | no |
| <a name="input_has_projects"></a> [has\_projects](#input\_has\_projects) | Whether the repository has projects | `bool` | `true` | no |
| <a name="input_has_wiki"></a> [has\_wiki](#input\_has\_wiki) | Whether the repository has wiki | `bool` | `true` | no |
| <a name="input_is_template"></a> [is\_template](#input\_is\_template) | Whether the repository is a template | `bool` | `false` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | List of labels to create in the repository | <pre>list(object({<br>    name        = string<br>    color       = string<br>    description = optional(string, null)<br>  }))</pre> | `[]` | no |
| <a name="input_merge_commit_message"></a> [merge\_commit\_message](#input\_merge\_commit\_message) | Title for merge commits | `string` | `"PR_TITLE"` | no |
| <a name="input_merge_commit_title"></a> [merge\_commit\_title](#input\_merge\_commit\_title) | Title for merge commits | `string` | `"MERGE_MESSAGE"` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the repository | `string` | n/a | yes |
| <a name="input_repository_environments"></a> [repository\_environments](#input\_repository\_environments) | List of environments to create | <pre>list(object({<br>    environment       = string<br>    can_admins_bypass = optional(bool, true)<br>    wait_timer        = optional(number, 0)<br>    deployment_branch_policy = optional(object({<br>      protected_branches     = bool<br>      custom_branch_policies = optional(bool, false) # Whether to allow custom branch policies<br>    }), null)<br>  }))</pre> | `[]` | no |
| <a name="input_repository_secrets"></a> [repository\_secrets](#input\_repository\_secrets) | A map of GitHub repository secrets | `map(string)` | `{}` | no |
| <a name="input_repository_variables"></a> [repository\_variables](#input\_repository\_variables) | A map of GitHub repositories variables | `map(string)` | `{}` | no |
| <a name="input_squash_merge_commit_message"></a> [squash\_merge\_commit\_message](#input\_squash\_merge\_commit\_message) | Title for squash merge commits | `string` | `"COMMIT_MESSAGES"` | no |
| <a name="input_squash_merge_commit_title"></a> [squash\_merge\_commit\_title](#input\_squash\_merge\_commit\_title) | Title for squash merge commits | `string` | `"COMMIT_OR_PR_TITLE"` | no |
| <a name="input_teams"></a> [teams](#input\_teams) | List of teams with their permissions | <pre>list(object({<br>    permission = string<br>    team_id    = string<br>  }))</pre> | `[]` | no |
| <a name="input_template"></a> [template](#input\_template) | Template configuration block | <pre>object({<br>    include_all_branches = optional(bool)<br>    owner                = string<br>    repository           = string<br>  })</pre> | `null` | no |
| <a name="input_users"></a> [users](#input\_users) | List of users with their permissions | <pre>list(object({<br>    permission = string<br>    username   = string<br>  }))</pre> | `[]` | no |
| <a name="input_visibility"></a> [visibility](#input\_visibility) | Visibility of the repository | `string` | `"private"` | no |
| <a name="input_vulnerability_alerts"></a> [vulnerability\_alerts](#input\_vulnerability\_alerts) | Whether vulnerability alerts are enabled | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_repo_id"></a> [repo\_id](#output\_repo\_id) | n/a |
| <a name="output_repository_id"></a> [repository\_id](#output\_repository\_id) | n/a |
| <a name="output_repository_name"></a> [repository\_name](#output\_repository\_name) | n/a |
<!-- END_TF_DOCS -->