resource "github_repository" "repository" {
  description                 = var.description
  allow_auto_merge            = var.allow_auto_merge
  allow_merge_commit          = var.allow_merge_commit
  allow_rebase_merge          = var.allow_rebase_merge
  allow_squash_merge          = var.allow_squash_merge
  allow_update_branch         = var.allow_update_branch
  archived                    = var.archived
  auto_init                   = var.auto_init
  delete_branch_on_merge      = var.delete_branch_on_merge
  is_template                 = var.is_template
  name                        = var.name
  visibility                  = var.visibility
  has_downloads               = var.has_downloads
  has_issues                  = var.has_issues
  has_projects                = var.has_projects
  has_wiki                    = var.has_wiki
  merge_commit_message        = var.merge_commit_message
  merge_commit_title          = var.merge_commit_title
  squash_merge_commit_message = var.squash_merge_commit_message
  squash_merge_commit_title   = var.squash_merge_commit_title
  vulnerability_alerts        = var.vulnerability_alerts
  dynamic "template" {
    for_each = var.template == null ? [] : [var.template]
    content {
      include_all_branches = template.value.include_all_branches
      owner                = template.value.owner
      repository           = template.value.repository
    }
  }
}

resource "github_repository_collaborators" "repository_collaborators" {
  repository = github_repository.repository.name

  dynamic "team" {
    for_each = var.teams
    content {
      permission = team.value.permission
      team_id    = team.value.team_id
    }
  }
  dynamic "user" {
    for_each = var.users
    content {
      permission = user.value.permission
      username   = user.value.username
    }
  }
}

resource "github_branch_default" "branch_default" {
  repository = github_repository.repository.name
  branch     = var.default_branch
}

resource "github_branch" "repo_branches" {
  for_each   = { for bp in var.branches : bp.branch => bp }
  repository = github_repository.repository.name
  branch     = each.value.branch
}
resource "github_branch_protection" "branch_protection" {
  for_each = { for bp in var.branches : bp.branch => bp }

  repository_id                   = github_repository.repository.node_id
  pattern                         = each.value.branch
  allows_deletions                = each.value.allows_deletions
  allows_force_pushes             = each.value.allows_force_pushes
  enforce_admins                  = each.value.enforce_admins
  lock_branch                     = each.value.lock_branch
  require_conversation_resolution = each.value.require_conversation_resolution
  require_signed_commits          = each.value.require_signed_commits
  required_linear_history         = each.value.required_linear_history
  force_push_bypassers            = each.value.force_push_bypassers

  dynamic "required_pull_request_reviews" {
    for_each = each.value.required_pull_request_reviews == null ? [] : [each.value.required_pull_request_reviews]
    content {
      dismiss_stale_reviews           = required_pull_request_reviews.value.dismiss_stale_reviews
      dismissal_restrictions          = required_pull_request_reviews.value.dismissal_restrictions
      require_code_owner_reviews      = required_pull_request_reviews.value.require_code_owner_reviews
      require_last_push_approval      = required_pull_request_reviews.value.require_last_push_approval
      required_approving_review_count = required_pull_request_reviews.value.required_approving_review_count
      restrict_dismissals             = required_pull_request_reviews.value.restrict_dismissals
      pull_request_bypassers          = required_pull_request_reviews.value.pull_request_bypassers
    }
  }

  dynamic "required_status_checks" {
    for_each = each.value.required_status_checks == null ? [] : [each.value.required_status_checks]
    content {
      contexts = required_status_checks.value.contexts
      strict   = required_status_checks.value.strict
    }
  }
}

resource "github_actions_variable" "repository_variables" {
  for_each      = var.repository_variables
  repository    = github_repository.repository.name
  variable_name = each.key
  value         = each.value
}

resource "github_actions_secret" "repository_secrets" {
  for_each        = var.repository_secrets
  repository      = github_repository.repository.name
  secret_name     = each.key
  plaintext_value = each.value
}

resource "github_repository_environment" "repository_environment" {
  for_each          = { for bp in var.repository_environments : bp.environment => bp }
  environment       = each.value.environment
  repository        = github_repository.repository.name
  can_admins_bypass = each.value.can_admins_bypass
  wait_timer        = each.value.wait_timer
  dynamic "deployment_branch_policy" {
    for_each = each.value.deployment_branch_policy == null ? [] : [each.value.deployment_branch_policy]
    content {
      protected_branches     = deployment_branch_policy.value.protected_branches
      custom_branch_policies = coalesce(deployment_branch_policy.value.custom_branch_policies, false)
    }
  }
}

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
  repository    = github_repository.repository.name
  environment   = each.value.environment
  variable_name = each.value.variable_name
  value         = each.value.value
}

resource "github_actions_environment_secret" "env_secret" {
  for_each = merge([
    for env, secrets in var.environment_secrets : {
      for secret in secrets : "${env}:${secret.secret_name}" => {
        environment = env
        secret_name = secret.secret_name
        value       = secret.value
      }
    }
  ]...)
  repository      = github_repository.repository.name
  environment     = each.value.environment
  secret_name     = each.value.secret_name
  plaintext_value = each.value.value
}

resource "github_repository_dependabot_security_updates" "repository_dependabot_security_updates" {
  repository = github_repository.repository.id
  enabled    = var.dependabot_security_updates
}

resource "github_issue_label" "repository_labels" {
  for_each    = { for label in var.labels : label.name => label }
  repository  = github_repository.repository.name
  name        = each.value.name
  color       = each.value.color
  description = each.value.description
}


