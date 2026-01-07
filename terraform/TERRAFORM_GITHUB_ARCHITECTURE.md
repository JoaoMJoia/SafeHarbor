# GitHub Infrastructure as Code Architecture

Terraform configuration for managing GitHub organization settings, repositories, teams, and secrets using reusable modules.

**See [`github.tf`](./github.tf) for a complete working example with backend, providers, organization, and repository configurations.**

## Modules

- **Organization Module** (`terraform-module-github/organization/`): Organization settings, members, teams, AWS KMS keys, and organization-wide variables/secrets
- **Repository Module** (`terraform-module-github/repository/`): Repository configuration, branch protection, access control, environments, variables/secrets, labels, and Dependabot

## Configuration

**See [`github.tf`](./github.tf) for complete examples including:**
- Backend configuration (S3 + DynamoDB state locking)
- Provider configuration (GitHub + SOPS)
- Organization module with members, teams, and organization-wide variables/secrets
- Repository modules with branch protection, access control, environments, and secrets
- SOPS data sources for encrypted secrets

**Prerequisites:**
- Set `TF_MANAGE_GITHUB_TOKEN` environment variable with GitHub PAT
- Configure SOPS with KMS key for secret encryption
- Create encrypted secrets: `sops -e -i sops_secrets/<name>.enc.yaml`

## Quick Start

1. **Setup**: Configure backend/providers (see `github.tf`), set `TF_MANAGE_GITHUB_TOKEN`, configure SOPS
2. **Add Repository**: Add module block to `github.tf`, create encrypted secrets, add SOPS data source
3. **Apply**: Run `terraform init && terraform plan && terraform apply`

## Best Practices

- Protect main branches, require PR reviews for production
- Never commit unencrypted secrets, use separate secrets per environment
- Use remote state backends with state locking
- Pin module versions when using git sources

## Troubleshooting

- **Authentication errors**: Verify `TF_MANAGE_GITHUB_TOKEN` is set
- **SOPS failures**: Check SOPS key and KMS permissions
- **State locking errors**: Verify DynamoDB table exists with proper permissions
