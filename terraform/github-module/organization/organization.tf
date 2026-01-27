resource "github_organization_settings" "organization_settings" {
  advanced_security_enabled_for_new_repositories               = false
  billing_email                                                = var.billing_email
  blog                                                         = var.blog
  default_repository_permission                                = "read"
  dependabot_alerts_enabled_for_new_repositories               = false
  dependabot_security_updates_enabled_for_new_repositories     = false
  dependency_graph_enabled_for_new_repositories                = false
  has_organization_projects                                    = true
  has_repository_projects                                      = true
  location                                                     = var.location
  members_can_create_repositories                              = true
  members_can_create_internal_repositories                     = true
  members_can_create_pages                                     = true
  members_can_create_private_pages                             = true
  members_can_create_private_repositories                      = true
  members_can_fork_private_repositories                        = true
  members_can_create_public_pages                              = false
  members_can_create_public_repositories                       = false
  name                                                         = var.organization_name
  secret_scanning_enabled_for_new_repositories                 = false
  secret_scanning_push_protection_enabled_for_new_repositories = false
  twitter_username                                             = var.twitter_username
  web_commit_signoff_required                                  = false
}

resource "github_actions_organization_variable" "organization_variable" {
  for_each      = var.organization_variables
  variable_name = each.key
  visibility    = "private"
  value         = each.value
}

resource "github_actions_organization_secret" "organization_secret" {
  for_each        = var.organization_secrets
  secret_name     = each.key
  visibility      = "private"
  plaintext_value = each.value
}