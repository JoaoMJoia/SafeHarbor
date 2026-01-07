variable "members" {
  description = "A map of GitHub usernames to their roles"
  type        = map(string)
  validation {
    condition = alltrue([
      for role in values(var.members) : contains(["admin", "member"], role)
    ])
    error_message = "Each member role must be either 'admin' or 'member'"
  }
  validation {
    condition = alltrue([
      for username in keys(var.members) : (
        can(regex("^[a-zA-Z0-9][a-zA-Z0-9-]*$", username))
      )
    ])
    error_message = "Each username must start with a letter or number and can only contain letters, numbers, and hyphens"
  }
}

variable "teams" {
  description = "Map of team names to their descriptions"
  type        = map(string)
  validation {
    condition = alltrue([
      for name in keys(var.teams) : (
        can(regex("^[a-zA-Z0-9][a-zA-Z0-9-]*$", name))
      )
    ])
    error_message = "Each team name must start with a letter or number and can only contain letters, numbers, and hyphens"
  }
  validation {
    condition = alltrue([
      for desc in values(var.teams) : length(trimspace(desc)) > 0
    ])
    error_message = "Each team description must be a non-empty string"
  }
}

variable "team_members" {
  description = "Map of team names to list of members"
  type = map(list(object({
    username = string
    role     = string
  })))
  validation {
    condition = alltrue([
      for team_name in keys(var.team_members) : (
        can(regex("^[a-zA-Z0-9][a-zA-Z0-9-]*$", team_name))
      )
    ])
    error_message = "Each team name must start with a letter or number and can only contain letters, numbers, and hyphens"
  }
  validation {
    condition = alltrue([
      for team in var.team_members : alltrue([
        for member in team : (
          can(regex("^[a-zA-Z0-9][a-zA-Z0-9-]*$", member.username)) &&
          contains(["maintainer", "member"], member.role)
        )
      ])
    ])
    error_message = "Each username must start with a letter or number and can only contain letters, numbers, and hyphens, and each member role must be either 'maintainer' or 'member'"
  }
}

variable "billing_email" {
  type        = string
  description = "GitHub organization billing email"
  validation {
    condition     = can(regex("^[^@]+@[^@]+\\.[^@]+$", var.billing_email))
    error_message = "The billing_email value must be a valid email address containing @ and a domain extension. Example: example@example.com"
  }
}

variable "blog" {
  type        = string
  description = "GitHub organization blog"
  default     = ""
}

variable "location" {
  type        = string
  description = "GitHub organization location"
  default     = ""
}

variable "organization_name" {
  type        = string
  description = "GitHub organization name"
}

variable "twitter_username" {
  type        = string
  description = "GitHub organization twitter username"
  default     = ""
}

variable "organization_variables" {
  description = "A map of GitHub organization variables"
  type        = map(string)
  validation {
    condition = alltrue([
      for name in keys(var.organization_variables) : (
        can(regex("^[A-Z][A-Z0-9_-]*$", name))
      )
    ])
    error_message = "Variable names must be uppercase, start with a letter, and can only contain letters, numbers, underscores, and hyphens"
  }
  validation {
    condition = alltrue([
      for value in values(var.organization_variables) : (
        length(trimspace(value)) > 0 &&
        !can(regex(" ", value))
      )
    ])
    error_message = "Variable values cannot be empty and cannot contain spaces (other special characters are allowed)"
  }
}

variable "organization_secrets" {
  description = "A map of GitHub organization secrets"
  type        = map(string)
  validation {
    condition = alltrue([
      for name in keys(var.organization_secrets) : (
        can(regex("^[A-Z][A-Z0-9_-]*$", name))
      )
    ])
    error_message = "Secret names must be uppercase, start with a letter, and can only contain letters, numbers, underscores, and hyphens"
  }
  validation {
    condition = alltrue([
      for value in values(var.organization_secrets) : (
        length(trimspace(value)) > 0 &&
        !can(regex(" ", value))
      )
    ])
    error_message = "Secret values cannot be empty and cannot contain spaces (other special characters are allowed)"
  }
}

variable "sops_kms_key_name" {
  description = "Name of the SOPS KMS key"
  type        = string
  validation {
    condition     = startswith(var.sops_kms_key_name, "sops-kms-key-") && length(var.sops_kms_key_name) > 14
    error_message = "SOPS KMS key name must start with 'sops-kms-key-' and at least 2 more characters"
  }
}
