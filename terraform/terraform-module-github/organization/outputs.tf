output "members" {
  description = "Names of the users"
  value       = github_membership.members
}
output "team_ids" {
  description = "IDs of the created teams"
  value       = { for k, v in github_team.teams : k => v.id }
}
output "team_memberships" {
  description = "Members of the created teams"
  value       = github_team_members.team_members
}
output "variables" {
  description = "Organization Variables"
  value       = github_actions_organization_variable.organization_variable
}
output "sops_kms_alias_key_name" {
  description = "SOPS KMS Alias Key name"
  value       = aws_kms_alias.sops_key_alias.name
}