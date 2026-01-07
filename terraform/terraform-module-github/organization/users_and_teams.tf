resource "github_membership" "members" {
  for_each = var.members
  role     = each.value
  username = each.key
}
resource "github_team" "teams" {
  for_each    = var.teams
  description = each.value
  name        = each.key
  privacy     = "closed"
}
resource "github_team_members" "team_members" {
  for_each = var.team_members
  team_id  = github_team.teams[each.key].id

  dynamic "members" {
    for_each = each.value
    content {
      username = members.value.username
      role     = members.value.role
    }
  }
}