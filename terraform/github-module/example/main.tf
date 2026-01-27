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
        pull_request_bypassers          = ["example-org/example"]
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
