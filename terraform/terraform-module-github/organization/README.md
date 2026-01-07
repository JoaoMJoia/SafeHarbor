# Organization Terraform Module

## Description
This module manages GitHub organization settings, members, teams, team memberships, organization-level variables, and secrets. It also provisions an AWS KMS key for SOPS integration.

## Prerequisites
- Terraform >= 1.9.7
- AWS provider >= 5.56.1 (for SOPS KMS key)
- GitHub provider >= 5.0
- SOPS provider >= 1.0.0 (for secrets encryption)
- Sufficient permissions to manage GitHub organizations and AWS KMS

## Usage
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
    "example" = [
      { username = "ExampleMember", role = "member" },
    ]
  }
  organization_variables = {
    "EXAMPLE_VARIABLE" = "example"
  }
  organization_secrets = {
    "EXAMPLE_SECRET" = "example"
  }
  sops_kms_key_name = "sops-kms-key-example"
}
```

## Features
- Manage GitHub organization settings (default permissions, security, projects, etc.)
- Manage organization members and teams
- Assign users to teams with specific roles
- Manage organization-level variables and secrets for GitHub Actions
- Provision and alias an AWS KMS key for SOPS

## Best Practices
- Use strong, unique names for KMS keys and secrets
- Regularly review organization members and team memberships
- Use variables and secrets for sensitive data, and manage them via SOPS
- Follow GitHub's naming conventions for teams and variables
- Use version pinning for providers to ensure reproducibility

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.56.1 |
| <a name="requirement_github"></a> [github](#requirement\_github) | >= 5.0 |
| <a name="requirement_sops"></a> [sops](#requirement\_sops) | >= 1.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.56.1 |
| <a name="provider_github"></a> [github](#provider\_github) | >= 5.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_kms_alias.sops_key_alias](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.sops_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [github_actions_organization_secret.organization_secret](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_organization_secret) | resource |
| [github_actions_organization_variable.organization_variable](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_organization_variable) | resource |
| [github_membership.members](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/membership) | resource |
| [github_organization_settings.organization_settings](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/organization_settings) | resource |
| [github_team.teams](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/team) | resource |
| [github_team_members.team_members](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/team_members) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_billing_email"></a> [billing\_email](#input\_billing\_email) | GitHub organization billing email | `string` | n/a | yes |
| <a name="input_blog"></a> [blog](#input\_blog) | GitHub organization blog | `string` | `""` | no |
| <a name="input_location"></a> [location](#input\_location) | GitHub organization location | `string` | `""` | no |
| <a name="input_members"></a> [members](#input\_members) | A map of GitHub usernames to their roles | `map(string)` | n/a | yes |
| <a name="input_organization_name"></a> [organization\_name](#input\_organization\_name) | GitHub organization name | `string` | n/a | yes |
| <a name="input_organization_secrets"></a> [organization\_secrets](#input\_organization\_secrets) | A map of GitHub organization secrets | `map(string)` | n/a | yes |
| <a name="input_organization_variables"></a> [organization\_variables](#input\_organization\_variables) | A map of GitHub organization variables | `map(string)` | n/a | yes |
| <a name="input_sops_kms_key_name"></a> [sops\_kms\_key\_name](#input\_sops\_kms\_key\_name) | Name of the SOPS KMS key | `string` | n/a | yes |
| <a name="input_team_members"></a> [team\_members](#input\_team\_members) | Map of team names to list of members | <pre>map(list(object({<br>    username = string<br>    role     = string<br>  })))</pre> | n/a | yes |
| <a name="input_teams"></a> [teams](#input\_teams) | Map of team names to their descriptions | `map(string)` | n/a | yes |
| <a name="input_twitter_username"></a> [twitter\_username](#input\_twitter\_username) | GitHub organization twitter username | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_members"></a> [members](#output\_members) | Names of the users |
| <a name="output_sops_kms_alias_key_name"></a> [sops\_kms\_alias\_key\_name](#output\_sops\_kms\_alias\_key\_name) | SOPS KMS Alias Key name |
| <a name="output_team_ids"></a> [team\_ids](#output\_team\_ids) | IDs of the created teams |
| <a name="output_team_memberships"></a> [team\_memberships](#output\_team\_memberships) | Members of the created teams |
| <a name="output_variables"></a> [variables](#output\_variables) | Organization Variables |
<!-- END_TF_DOCS -->