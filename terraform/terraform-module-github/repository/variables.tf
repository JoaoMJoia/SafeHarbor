variable "name" {
  type        = string
  description = "Name of the repository"
  validation {
    condition     = can(regex("^[a-z][a-z0-9_-]*$", var.name))
    error_message = "Repository name must be lowercase, start with a letter, and can only contain letters, numbers, hyphens, and underscores"
  }
  validation {
    condition     = length(var.name) >= 1 && length(var.name) <= 50
    error_message = "Repository name must be between 1 and 50 characters long"
  }
  validation {
    condition     = !can(regex("^[._-]", var.name))
    error_message = "Repository name cannot start with a dot, underscore, or hyphen"
  }
}

variable "description" {
  type        = string
  description = "Description of the GitHub repository"
  validation {
    condition     = length(trimspace(var.description)) > 0
    error_message = "Description cannot be empty or contain only whitespace"
  }
  validation {
    condition     = length(var.description) <= 350
    error_message = "Description must be 350 characters or less"
  }
  validation {
    condition     = !can(regex("^[\\s\\t\\n]+$", var.description))
    error_message = "Description cannot contain only whitespace characters"
  }
  validation {
    condition     = !can(regex("[<>]", var.description))
    error_message = "Description cannot contain angle brackets (< or >)"
  }
}

variable "allow_auto_merge" {
  type        = bool
  default     = false
  description = "Whether to allow auto-merge"
  validation {
    condition     = contains([true, false], var.allow_auto_merge)
    error_message = "The allow_auto_merge value must be either true or false"
  }
}

variable "allow_merge_commit" {
  type        = bool
  default     = true
  description = "Whether to allow merge commit"
  validation {
    condition     = contains([true, false], var.allow_merge_commit)
    error_message = "The allow_merge_commit value must be either true or false"
  }
}

variable "allow_rebase_merge" {
  type        = bool
  default     = true
  description = "Whether to allow rebase merge"
  validation {
    condition     = contains([true, false], var.allow_rebase_merge)
    error_message = "The allow_rebase_merge value must be either true or false"
  }
}

variable "allow_squash_merge" {
  type        = bool
  default     = true
  description = "Whether to allow squash merge"
  validation {
    condition     = contains([true, false], var.allow_squash_merge)
    error_message = "The allow_squash_merge value must be either true or false"
  }
}

variable "allow_update_branch" {
  type        = bool
  default     = false
  description = "Whether to allow branch update"
  validation {
    condition     = contains([true, false], var.allow_update_branch)
    error_message = "The allow_update_branch value must be either true or false"
  }
}

variable "archived" {
  type        = bool
  default     = false
  description = "Whether the repository is archived"
  validation {
    condition     = contains([true, false], var.archived)
    error_message = "The archived value must be either true or false"
  }
}

variable "auto_init" {
  type        = bool
  default     = false
  description = "Whether to auto initialize the repository"
  validation {
    condition     = contains([true, false], var.auto_init)
    error_message = "The auto_init value must be either true or false"
  }
}

variable "delete_branch_on_merge" {
  type        = bool
  default     = true
  description = "Whether to delete branch on merge"
  validation {
    condition     = contains([true, false], var.delete_branch_on_merge)
    error_message = "The delete_branch_on_merge value must be either true or false"
  }
}

variable "is_template" {
  type        = bool
  default     = false
  description = "Whether the repository is a template"
  validation {
    condition     = contains([true, false], var.is_template)
    error_message = "The is_template value must be either true or false"
  }
}

variable "visibility" {
  type        = string
  default     = "private"
  description = "Visibility of the repository"
  validation {
    condition     = contains(["public", "private", "internal"], var.visibility)
    error_message = "Visibility must be one of: public, private, or internal"
  }
}

variable "has_downloads" {
  type        = bool
  default     = true
  description = "Whether the repository has downloads"
  validation {
    condition     = contains([true, false], var.has_downloads)
    error_message = "The has_downloads value must be either true or false"
  }
}

variable "has_issues" {
  type        = bool
  default     = true
  description = "Whether the repository has issues"
  validation {
    condition     = contains([true, false], var.has_issues)
    error_message = "The has_issues value must be either true or false"
  }
}

variable "has_projects" {
  type        = bool
  default     = true
  description = "Whether the repository has projects"
  validation {
    condition     = contains([true, false], var.has_projects)
    error_message = "The has_projects value must be either true or false"
  }
}

variable "has_wiki" {
  type        = bool
  default     = true
  description = "Whether the repository has wiki"
  validation {
    condition     = contains([true, false], var.has_wiki)
    error_message = "The has_wiki value must be either true or false"
  }
}

variable "merge_commit_message" {
  type        = string
  default     = "PR_TITLE"
  description = "Title for merge commits"
  validation {
    condition     = contains(["PR_BODY", "PR_TITLE", "BLANK"], var.merge_commit_message)
    error_message = "Merge commit message must be one of: PR_BODY, PR_TITLE, or BLANK"
  }
  validation {
    condition     = var.allow_merge_commit || var.merge_commit_message == "PR_TITLE"
    error_message = "Merge commit message can only be set when allow_merge_commit is true"
  }
}

variable "merge_commit_title" {
  type        = string
  default     = "MERGE_MESSAGE"
  description = "Title for merge commits"
  validation {
    condition     = contains(["PR_TITLE", "MERGE_MESSAGE"], var.merge_commit_title)
    error_message = "Merge commit title must be either PR_TITLE or MERGE_MESSAGE"
  }
  validation {
    condition     = var.allow_merge_commit || var.merge_commit_title == "MERGE_MESSAGE"
    error_message = "Merge commit title can only be set when allow_merge_commit is true"
  }
}

variable "squash_merge_commit_message" {
  type        = string
  default     = "COMMIT_MESSAGES"
  description = "Title for squash merge commits"
  validation {
    condition     = contains(["PR_BODY", "COMMIT_MESSAGES", "BLANK"], var.squash_merge_commit_message)
    error_message = "Squash merge commit message must be one of: PR_BODY, COMMIT_MESSAGES, or BLANK"
  }
  validation {
    condition     = var.allow_squash_merge || var.squash_merge_commit_message == "COMMIT_MESSAGES"
    error_message = "Squash merge commit message can only be set when allow_squash_merge is true"
  }
}

variable "squash_merge_commit_title" {
  type        = string
  default     = "COMMIT_OR_PR_TITLE"
  description = "Title for squash merge commits"
  validation {
    condition     = contains(["PR_TITLE", "COMMIT_OR_PR_TITLE"], var.squash_merge_commit_title)
    error_message = "Squash merge commit title must be either PR_TITLE or COMMIT_OR_PR_TITLE"
  }
  validation {
    condition     = var.allow_squash_merge || var.squash_merge_commit_title == "COMMIT_OR_PR_TITLE"
    error_message = "Squash merge commit title can only be set when allow_squash_merge is true"
  }
}

variable "vulnerability_alerts" {
  type        = bool
  default     = true
  description = "Whether vulnerability alerts are enabled"
  validation {
    condition     = contains([true, false], var.vulnerability_alerts)
    error_message = "The vulnerability_alerts value must be either true or false"
  }
}

variable "template" {
  description = "Template configuration block"
  type = object({
    include_all_branches = optional(bool)
    owner                = string
    repository           = string
  })
  default = null
}

variable "teams" {
  description = "List of teams with their permissions"
  type = list(object({
    permission = string
    team_id    = string
  }))
  default = []
  validation {
    condition = alltrue([
      for team in var.teams : contains(["pull", "push", "maintain", "triage", "admin"], team.permission)
    ])
    error_message = "Each team permission must be one of: pull, push, maintain, triage, or admin"
  }
  validation {
    condition = alltrue([
      for team in var.teams : contains(["admins", "design", "developer", "elp-admins", "ids-admins", "qa"], team.team_id)
    ])
    error_message = "Each team_id must be one of: admins, design, developer, elp-admins, ids-admins, or qa"
  }
}

variable "users" {
  description = "List of users with their permissions"
  type = list(object({
    permission = string
    username   = string
  }))
  default = []
  validation {
    condition = alltrue([
      for user in var.users : contains(["pull", "push", "maintain", "triage", "admin"], user.permission)
    ])
    error_message = "Each user permission must be one of: pull, push, maintain, triage, or admin"
  }
  validation {
    condition = alltrue([
      for user in var.users : can(regex("^[a-zA-Z0-9][a-zA-Z0-9-]*$", user.username))
    ])
    error_message = "Each username must start with a letter or number and can only contain letters, numbers, and hyphens"
  }
}

variable "default_branch" {
  type        = string
  default     = "main"
  description = "Default branch for the repository"
  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9._/-]*$", var.default_branch))
    error_message = "Default branch name must start with a letter or number and can only contain letters, numbers, dots, underscores, hyphens, and forward slashes"
  }
  validation {
    condition     = !can(regex("^[._/-]", var.default_branch))
    error_message = "Default branch name cannot start with a dot, underscore, hyphen, or forward slash"
  }
  validation {
    condition     = !can(regex("[.][.]", var.default_branch))
    error_message = "Default branch name cannot contain '..'"
  }
  validation {
    condition     = !can(regex("^[._/-].*[._/-]$", var.default_branch))
    error_message = "Default branch name cannot end with a dot, underscore, hyphen, or forward slash"
  }
  validation {
    condition     = length(var.default_branch) <= 255
    error_message = "Default branch name must be 255 characters or less"
  }
}

variable "branches" {
  description = "List of branch protections to apply"
  type = list(object({
    branch                          = string
    allows_deletions                = optional(bool, false)
    allows_force_pushes             = optional(bool, false)
    enforce_admins                  = optional(bool, false)
    lock_branch                     = optional(bool, false)
    require_conversation_resolution = optional(bool, true)
    require_signed_commits          = optional(bool, false)
    required_linear_history         = optional(bool, false)
    force_push_bypassers            = optional(list(string), [])
    required_pull_request_reviews = optional(object({
      dismiss_stale_reviews           = optional(bool, false)
      dismissal_restrictions          = optional(list(string), [])
      require_code_owner_reviews      = bool
      require_last_push_approval      = optional(bool, false)
      required_approving_review_count = number
      restrict_dismissals             = optional(bool, false)
      pull_request_bypassers          = optional(list(string), [])
    }), null)
    required_status_checks = optional(object({
      contexts = optional(list(string), [])
      strict   = bool
    }), null)
  }))
  default = []
  validation {
    condition = alltrue([
      for branch in var.branches : can(regex("^[a-zA-Z0-9][a-zA-Z0-9._/-]*$", branch.branch))
    ])
    error_message = "Branch names must start with a letter or number and can only contain letters, numbers, dots, underscores, hyphens, and forward slashes"
  }
  validation {
    condition = alltrue([
      for branch in var.branches : !can(regex("^[._/-]", branch.branch))
    ])
    error_message = "Branch names cannot start with a dot, underscore, hyphen, or forward slash"
  }
  validation {
    condition = alltrue([
      for branch in var.branches : !can(regex("[.][.]", branch.branch))
    ])
    error_message = "Branch names cannot contain '..'"
  }
  validation {
    condition = alltrue([
      for branch in var.branches : !can(regex("^[._/-].*[._/-]$", branch.branch))
    ])
    error_message = "Branch names cannot end with a dot, underscore, hyphen, or forward slash"
  }
  validation {
    condition = alltrue([
      for branch in var.branches : length(branch.branch) <= 255
    ])
    error_message = "Branch names must be 255 characters or less"
  }
  validation {
    condition = alltrue([
      for branch in var.branches : contains([true, false], branch.allows_deletions)
    ])
    error_message = "allows_deletions must be either true or false"
  }
  validation {
    condition = alltrue([
      for branch in var.branches : contains([true, false], branch.allows_force_pushes)
    ])
    error_message = "allows_force_pushes must be either true or false"
  }
  validation {
    condition = alltrue([
      for branch in var.branches : contains([true, false], branch.enforce_admins)
    ])
    error_message = "enforce_admins must be either true or false"
  }
  validation {
    condition = alltrue([
      for branch in var.branches : contains([true, false], branch.lock_branch)
    ])
    error_message = "lock_branch must be either true or false"
  }
  validation {
    condition = alltrue([
      for branch in var.branches : contains([true, false], branch.require_conversation_resolution)
    ])
    error_message = "require_conversation_resolution must be either true or false"
  }
  validation {
    condition = alltrue([
      for branch in var.branches : contains([true, false], branch.require_signed_commits)
    ])
    error_message = "require_signed_commits must be either true or false"
  }
  validation {
    condition = alltrue([
      for branch in var.branches : contains([true, false], branch.required_linear_history)
    ])
    error_message = "required_linear_history must be either true or false"
  }

  validation {
    condition = alltrue([
      for branch in var.branches : length(branch.force_push_bypassers) > 0
    ])
    error_message = "force_push_bypassers must include at least one team or user"
  }
  validation {
    condition = alltrue([
      for branch in var.branches : alltrue([
        for bypasser in branch.force_push_bypassers : can(regex("^[a-zA-Z0-9/][a-zA-Z0-9._/-]*$", bypasser))
      ])
    ])
    error_message = "Force push bypassers must start with a letter, number, or forward slash and can only contain letters, numbers, dots, underscores, hyphens, and forward slashes"
  }

  validation {
    condition = alltrue([
      for branch in var.branches : alltrue([
        for bypasser in branch.force_push_bypassers : !can(regex("[.][.]", bypasser))
      ])
    ])
    error_message = "Force push bypassers cannot contain '..'"
  }
  validation {
    condition = alltrue([
      for branch in var.branches : alltrue([
        for bypasser in branch.force_push_bypassers : !can(regex("^[._/-].*[._/-]$", bypasser))
      ])
    ])
    error_message = "Force push bypassers cannot end with a dot, underscore, hyphen, or forward slash"
  }
  validation {
    condition = alltrue([
      for branch in var.branches : alltrue([
        for bypasser in branch.force_push_bypassers : length(bypasser) <= 255
      ])
    ])
    error_message = "Force push bypassers must be 255 characters or less"
  }
}

variable "repository_variables" {
  description = "A map of GitHub repositories variables"
  type        = map(string)
  default     = {}
  validation {
    condition = alltrue([
      for name in keys(var.repository_variables) : can(regex("^[A-Z][A-Z0-9_-]*$", name))
    ])
    error_message = "Variable names must be uppercase, start with a letter, and can only contain letters, numbers, underscores, and hyphens"
  }
  validation {
    condition = alltrue([
      for value in values(var.repository_variables) : length(trimspace(value)) > 0
    ])
    error_message = "Variable values cannot be empty"
  }
  validation {
    condition = alltrue([
      for value in values(var.repository_variables) : !can(regex(" ", value))
    ])
    error_message = "Variable values cannot contain spaces (other special characters are allowed)"
  }
}

variable "repository_secrets" {
  description = "A map of GitHub repository secrets"
  type        = map(string)
  default     = {}
  validation {
    condition = alltrue([
      for name in keys(var.repository_secrets) : can(regex("^[A-Z][A-Z0-9_-]*$", name))
    ])
    error_message = "Secret names must be uppercase, start with a letter, and can only contain letters, numbers, underscores, and hyphens"
  }
  validation {
    condition = alltrue([
      for value in values(var.repository_secrets) : length(trimspace(value)) > 0
    ])
    error_message = "Secret values cannot be empty"
  }
  validation {
    condition = alltrue([
      for value in values(var.repository_secrets) : !can(regex(" ", value))
    ])
    error_message = "Secret values cannot contain spaces (other special characters are allowed)"
  }
}

variable "repository_environments" {
  description = "List of environments to create"
  type = list(object({
    environment       = string
    can_admins_bypass = optional(bool, true)
    wait_timer        = optional(number, 0)
    deployment_branch_policy = optional(object({
      protected_branches     = bool
      custom_branch_policies = optional(bool, false) # Whether to allow custom branch policies
    }), null)
  }))
  default = []
  validation {
    condition = alltrue([
      for env in var.repository_environments : (
        can(regex("^[a-zA-Z0-9][a-zA-Z0-9._/-]*$", env.environment)) &&
        !can(regex("^[._/-]", env.environment)) &&
        !can(regex("[.][.]", env.environment)) &&
        !can(regex("^[._/-].*[._/-]$", env.environment)) &&
        length(env.environment) <= 255
      )
    ])
    error_message = "Environment names must follow GitHub's naming conventions: start with a letter or number, contain only letters, numbers, dots, underscores, hyphens, and forward slashes, not start or end with special characters, not contain '..', and be 255 characters or less"
  }
  validation {
    condition = alltrue([
      for env in var.repository_environments : env.wait_timer >= 0
    ])
    error_message = "wait_timer must be a non-negative number"
  }
  validation {
    condition = alltrue([
      for env in var.repository_environments : env.wait_timer <= 43200
    ])
    error_message = "wait_timer must be less than or equal to 43200 (12 hours in minutes)"
  }
}

variable "environment_variables" {
  description = "Map of environment variables where key is environment name and value is list of variables"
  type = map(list(object({
    variable_name = string
    value         = string
  })))
  default = {}
}

variable "environment_secrets" {
  description = "Map of environment secrets where key is environment name and value is list of secrets"
  type = map(list(object({
    secret_name = string
    value       = string
  })))
  default = {}
}

variable "dependabot_security_updates" {
  type        = bool
  default     = false
  description = "Whether Dependabot security updates are enabled"
  validation {
    condition     = contains([true, false], var.dependabot_security_updates)
    error_message = "The dependabot_security_updates value must be either true or false"
  }
}

variable "labels" {
  description = "List of labels to create in the repository"
  type = list(object({
    name        = string
    color       = string
    description = optional(string, null)
  }))
  default = []
  validation {
    condition = alltrue([
      for label in var.labels : can(regex("^[a-zA-Z0-9][a-zA-Z0-9/-]*$", label.name))
    ])
    error_message = "Label names must start with a letter or number and can only contain letters, numbers, hyphens, and forward slashes"
  }
  validation {
    condition = alltrue([
      for label in var.labels : can(regex("^[0-9A-Fa-f]{6}$", label.color))
    ])
    error_message = "Label colors must be a valid 6-character hex color code (e.g., 'DBC840')"
  }
  validation {
    condition = alltrue([
      for label in var.labels : label.description == null || (length(trimspace(label.description)) > 0 && length(label.description) <= 100)
    ])
    error_message = "Label descriptions must be between 1 and 100 characters long if provided"
  }
  validation {
    condition     = length(var.labels) <= 100
    error_message = "Maximum of 100 labels can be created per repository"
  }
}
