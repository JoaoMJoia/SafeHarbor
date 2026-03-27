# 🗂 AWS Terraform Repository Structure

This repository defines and manages all AWS infrastructure using **Terraform**, following a clear separation between reusable modules, global infrastructure, and per-environment stacks.

---

## 📁 Folder Structure

```bash
aws/
├─ modules/                                      # Reusable Terraform modules (building blocks)
│  ├─ frontend/                                   # Frontend static site + CDN module (S3 + CloudFront)
│  │  ├─ versions.tf                              # Terraform and provider constraints for the frontend module
│  │  ├─ variables.tf                             # Module inputs (bucket name, tags, geo whitelist, etc.)
│  │  ├─ data_source.tf                           # ACM certificate lookup; S3 bucket lookup for WAF Firehose logs
│  │  ├─ s3.tf                                    # Primary + failover S3 buckets and bucket policies for frontend static assets
│  │  ├─ waf.tf                                   # WAFv2 Web ACL, Firehose → log-archive, logging (CKV2_AWS_31)
│  │  ├─ cloudfront.tf                            # CloudFront OAC + distribution with origin group failover (5xx only)
│  │  ├─ outputs.tf                               # Exposes bucket id/arn and CloudFront id/domain
│  │  └─ iam_policies/                            # Frontend-specific IAM policies (e.g. S3 bucket access from CloudFront)
│  │     └─ frontend_bucket_policy.json           # Bucket policy template used by the frontend module
│  ├─ backend/                                    # Backend application module (VPC, ECS Fargate, ElastiCache, ALB, backend CloudFront, S3, IAM, KMS)
│  │  ├─ versions.tf                              # Terraform and provider constraints for the backend module
│  │  ├─ variables.tf                             # Module inputs (environment, region, tags, VPC CIDRs, AZs, ECR image URI, account ID, RDS connection details, etc.)
│  │  ├─ vpc.tf                                   # VPC definition (public/private subnets, NAT gateways, routing)
│  │  ├─ ecs.tf                                   # ECS cluster, services (task definitions owned by CI/CD), autoscaling, and alarms
│  │  ├─ ecr.tf                                   # ECR repository and pull policy for ECS execution role
│  │  ├─ s3.tf                                    # S3 bucket for backend assets used by the application
│  │  ├─ elasticache.tf                           # ElastiCache Redis replication group and SG rules
│  │  ├─ alb.tf                                   # Application Load Balancer, listeners, target groups, and SG
│  │  ├─ cloudfront.tf                            # CloudFront distribution in front of the backend ALB (HTTPS termination)
│  │  ├─ cloudwatch.tf                            # CloudWatch log groups for ECS workloads
│  │  ├─ kms.tf                                   # KMS key and alias for SSM parameter encryption
│  │  ├─ secretsmanager.tf                        # Secrets Manager secret (example-{env}-backend) from SOPS file
│  │  ├─ iam.tf                                   # ECS task and execution roles, IAM policies, and attachments
│  │  ├─ data.tf                                  # Shared data sources (e.g., caller identity, AZs)
│  │  ├─ outputs.tf                               # Exposes ALB, CloudFront, VPC, S3, ElastiCache, KMS, and Secrets Manager outputs
│  │  └─ iam_policies/                            # Backend-specific IAM policy templates
│  │     ├─ ecs-execution-secretsmanager-policy.json  # Allow ECS execution role to fetch secrets from Secrets Manager at task startup
│  │     ├─ ecs-exec-ssmmessages-policy.json         # Allow ECS task role to use ECS Exec (execute-command) via SSM
│  │     ├─ ecs-kms-ssm-policy.json               # Allow ECS task role to use KMS key and read DB password from SSM
│  │     ├─ ecs-php-s3-policy.json                # Allow ECS tasks (PHP app) to access backend S3 bucket
│  │     └─ kms-ssm-parameter-key-policy.json     # Key policy for SSM parameter encryption KMS key
│  ├─ rds/                                        # RDS database module (MySQL instance, security groups, password management)
│  │  ├─ versions.tf                              # Terraform and provider constraints for the RDS module
│  │  ├─ variables.tf                             # Module inputs (environment, VPC ID, subnet IDs, ECS security group, KMS key ARN, instance class, etc.)
│  │  ├─ main.tf                                  # RDS MySQL instance, security group, random password, and SSM parameter
│  │  └─ outputs.tf                               # Exposes RDS connection details (host, name, username, password, SSM parameter ARN)
│  └─ tfstate/                                    # Terraform remote state backend (S3+DDB) reusable module
│     ├─ versions.tf                              # Terraform and AWS provider constraints
│     ├─ variables.tf                             # Inputs for S3 bucket name, DynamoDB table name, and common tags
│     ├─ main.tf                                  # Creates S3 bucket for state + DynamoDB table for locks
│     └─ outputs.tf                               # Exposes created bucket and table names/ids
│
├─ global/                                       # Global AWS resources (provisioned rarely)
│  ├─ iam/                                         # Global IAM roles, users, and shared policies
│  │  ├─ backend.tf                                 # Backend config (uses example-tfstate-global)
│  │  ├─ github-oidc.tf                             # GitHub Actions OIDC integration
│  │  ├─ iam_policies/                              # Common IAM policy definitions
│  │  │  └─ github-actions-terraform.json            # Policy for GitHub Actions to manage infrastructure
│  │  ├─ locals.tf                                  # Local variables and tags
│  │  ├─ provider.tf                                # AWS provider configuration
│  │  └─ README.md                                  # IAM module documentation
│  ├─ log-archive/                                  # Centralised S3 bucket for CloudFront, ALB, and WAF access logs
│  │  ├─ backend.tf                                 # Backend config (uses example-tfstate-global)
│  │  ├─ main.tf                                    # S3 bucket + bucket policy (template from iam_policies)
│  │  ├─ outputs.tf                                 # Bucket name and domain name
│  │  ├─ locals.tf                                  # Local variables and tags
│  │  ├─ provider.tf                                # AWS provider configuration
│  │  ├─ iam_policies/                              # Bucket policy template
│  │  │  └─ log_archive_bucket_policy.json         # CloudFront + ALB write permissions
│  │  └─ README.md                                  # Log archive documentation
│  ├─ kms/                                          # Global KMS key for Secrets Manager (all environments)
│  │  ├─ backend.tf                                 # Backend config (uses example-tfstate-global)
│  │  ├─ main.tf                                    # KMS key via terraform-aws-modules/kms (alias example-global-secretsmanager)
│  │  ├─ data.tf                                    # Caller identity, GitHub Actions role lookup
│  │  ├─ outputs.tf                                 # KMS key ARN, key ID, alias name
│  │  ├─ locals.tf                                  # Local variables and tags
│  │  ├─ provider.tf                                # AWS provider configuration
│  │  └─ README.md                                  # KMS for Secrets Manager documentation
│  └─ tfstate/                                     # Remote state infrastructure management
│     ├─ bootstrap/                                  # Bootstrap state for creating initial backend
│     │  ├─ backend.tf                               # Backend config (uses example-terraform-state)
│     │  ├─ locals.tf                                # Local variables and tags
│     │  ├─ main.tf                                   # Creates bootstrap S3 bucket and DDB table
│     │  ├─ outputs.tf                                # Bootstrap outputs
│     │  ├─ provider.tf                               # AWS provider configuration
│     │  └─ README.md                                 # Bootstrap documentation
│     └─ backends/                                   # Creates per-environment S3+DDB backends
│        ├─ backend.tf                               # Backend config (uses bootstrap backend)
│        ├─ locals.tf                                # Local variables and tags
│        ├─ main.tf                                  # Creates 4 backends: global, dev, qa, production
│        ├─ outputs.tf                               # Backend outputs (S3 bucket and DDB table names)
│        ├─ provider.tf                               # AWS provider configuration
│        └─ README.md                                 # Backends documentation
│
├─ dev/                                          # Development environment infrastructure stacks
│  ├─ backend/                                     # Application backend (ECS Fargate + API)
│  │  ├─ backend.tf                                # Backend config (uses example-tfstate-dev)
│  │  ├─ data_remote_state.tf                      # Remote state data source for RDS outputs
│  │  ├─ data_source.tf                            # Data sources (caller identity, availability zones)
│  │  ├─ locals.tf                                 # Local variables and tags
│  │  ├─ main.tf                                   # Backend module instantiation
│  │  ├─ outputs.tf                                # Backend outputs
│  │  └─ provider.tf                               # AWS provider configuration
│  ├─ rds/                                         # Database resources for dev
│  │  ├─ backend.tf                                # Backend config (uses example-tfstate-dev)
│  │  ├─ data_remote_state.tf                      # Remote state data source for backend outputs (VPC, subnets, security groups, KMS)
│  │  ├─ locals.tf                                 # Local variables and tags
│  │  ├─ main.tf                                   # RDS module instantiation
│  │  ├─ outputs.tf                                # RDS outputs (connection details)
│  │  └─ provider.tf                               # AWS provider configuration
│  └─ frontend/                                    # Frontend static site + CDN
│     ├─ backend.tf                                # Backend config (uses example-tfstate-dev)
│     ├─ locals.tf                                 # Local variables and tags
│     ├─ main.tf                                   # Frontend module instantiation
│     ├─ outputs.tf                                # Frontend outputs (CloudFront distribution details)
│     └─ provider.tf                               # AWS provider configuration (includes us-east-1 for ACM certificates)
│
├─ qa/                                           # QA environment infrastructure stacks
│
└─ production/                                   # Production environment infrastructure stacks
```

At **repository root** (alongside `aws/`):

```bash
sops_secrets/                                     # SOPS-encrypted secrets (used by Terraform)
├─ dev/
│  └─ backend.enc.json                            # Backend secrets for dev; decrypted and synced to Secrets Manager (example-dev-backend)
└─ <env>/                                         # One folder per environment (e.g. prod, qa)
   └─ backend.enc.json                            # Convention: sops_secrets/{env}/backend.enc.json
```

The backend module reads `sops_secrets/{environment}/backend.enc.json` (relative to repo root), decrypts it via the SOPS provider, and creates/updates the AWS Secrets Manager secret `example-{environment}-backend` using the global KMS key from `aws/global/kms`.

---

## 🔄 Deployment Dependencies

The infrastructure follows a **circular dependency pattern** resolved through Terraform remote state:

### Dependency Flow

```
1. Backend Stack (aws/dev/backend/)
   └─ Creates: VPC, Subnets, Security Groups, KMS Key, ECS, ALB, etc.
   
2. RDS Stack (aws/dev/rds/)
   └─ Depends on: VPC ID, Subnet IDs, ECS Security Group ID, KMS Key ARN (from backend remote state)
   └─ Creates: RDS MySQL instance, RDS Security Group, Database password (SSM Parameter)
```

### Deployment Order

1. **Deploy Backend** (`aws/dev/backend/`)
   - Creates VPC, networking, ECS, and other backend resources
   - Outputs VPC ID, subnet IDs, security group IDs, and KMS key ARN
   - Reads RDS outputs via `data.terraform_remote_state.rds`

2. **Deploy RDS** (`aws/dev/rds/`)
   - Reads backend outputs via `data.terraform_remote_state.backend`
   - Creates RDS instance in the backend VPC
   - Outputs database connection details

**Note**: ECS task definitions and environment variables are owned by CI/CD. Terraform manages only ECS services (with pinned placeholder task definitions and `ignore_changes`).

---

## 🧱 Structure Overview

| Area | Description |
|------|--------------|
| **modules/** | All reusable Terraform modules — each folder represents a logical AWS component. |
| **global/** | Resources that are deployed once and shared across environments, such as IAM policies and Terraform backend infrastructure. |
| **dev/, qa/, prod/** | Environment-specific stacks. Each folder holds isolated Terraform configurations that use their own remote state backend. |

---

## ⚙️ Terraform State Management Flow

The Terraform state management is fully automated, following a **cascade pattern** that splits into two parallel paths after backend creation:

```text
┌────────────────────────────────────────────────────────────┐
│                Bootstrap (global/tfstate/bootstrap)        │
│  • Initially uses local state or minimal remote state      │
│  • Creates bootstrap backend:                               │
│      - S3: example-terraform-state                            │
│      - DynamoDB: example-terraform-state-locks                │
│  • After creation, migrates to its own backend             │
│  • State key: global/tfstate/bootstrap/terraform.tfstate   │
└───────────────┬────────────────────────────────────────────┘
                │
                │ terraform apply
                ▼
┌────────────────────────────────────────────────────────────┐
│                Backends (global/tfstate/backends)           │
│  • Uses the bootstrap state backend                        │
│  • State key: global/tfstate/backends/terraform.tfstate    │
│  • Provisions 4 per-environment backends:                  │
│      - Global: example-tfstate-global + example-tfstate-global-locks │
│      - Dev: example-tfstate-dev + example-tfstate-dev-locks     │
│      - QA: example-tfstate-qa + example-tfstate-qa-locks        │
│      - Production: example-tfstate-production + example-tfstate-production-locks │
└───────────────┬────────────────────────────────────────────┘
                │
                │ outputs S3/DDB details
                │
        ┌───────┴───────┐
        │               │
        ▼               ▼
┌──────────────────┐  ┌──────────────────────────────────────┐
│ Global Resources │  │  Environment Stacks                  │
│ (global/iam/,     │  │  (dev/, qa/, production/)            │
│  global/log-     │  │                                      │
│  archive/,        │  │  • Each stack uses its env backend  │
│  global/kms/)     │  │                                      │
│                  │  │  • Examples:                         │
│ • Uses global    │  │    - dev/networking →                │
│   backend:       │  │      dev/networking/terraform.tfstate│
│   example-tfstate-  │  │    - qa/backend →                    │
│   global         │  │      qa/backend/terraform.tfstate    │
│ • IAM: roles,    │  │    - production/rds →                │
│   policies,      │  │      production/rds/terraform.tfstate│
│   GitHub OIDC    │  │  • IAM roles restricted per env      │
│ • Log archive:   │  │  • Frontend/backend write logs to    │
│   S3 bucket for  │  │    global log-archive bucket         │
│   CloudFront/ALB │  │  • Secrets Manager can use global     │
│ • KMS: key for   │  │    KMS key (global/kms)              │
│   Secrets Manager│  │                                      │
└──────────────────┘  └──────────────────────────────────────┘
```

### 🔐 State Isolation Rules
- **Bootstrap backend**: `example-terraform-state` - Used only for bootstrap and backends management
- **Global backend**: `example-tfstate-global` - Used for global resources (IAM, etc.)
- **One S3 bucket and DynamoDB table per environment** (dev, qa, production)
- No shared workspaces — isolation is by bucket/prefix
- CI/CD roles only access their environment's backend
- Versioning and encryption (AES256) enforced via bucket policies
- DynamoDB locks prevent concurrent changes
- All backends use region: `af-south-1`

---

## 🚀 Bootstrap-to-Env Summary

| Stage | Purpose | Backend Used | Created Resources |
|--------|----------|---------------|-------------------|
| **Bootstrap** | Seeds the infrastructure for Terraform backends | Local (initially), then self-managed | S3: `example-terraform-state`<br>DynamoDB: `example-terraform-state-locks`<br>State key: `global/tfstate/bootstrap/terraform.tfstate` |
| **Backends** | Creates per-environment Terraform backends | Bootstrap backend (`example-terraform-state`) | 4 backends:<br>• Global: `example-tfstate-global` + `example-tfstate-global-locks`<br>• Dev: `example-tfstate-dev` + `example-tfstate-dev-locks`<br>• QA: `example-tfstate-qa` + `example-tfstate-qa-locks`<br>• Production: `example-tfstate-production` + `example-tfstate-production-locks`<br>State key: `global/tfstate/backends/terraform.tfstate` |
| **Global IAM** | Manages global IAM resources | Global backend (`example-tfstate-global`) | IAM roles, policies, GitHub OIDC integration<br>State key: `global/iam/terraform.tfstate` |
| **Log archive** | Centralised access logs bucket | Global backend (`example-tfstate-global`) | S3 bucket `example-org-log-archive`; CloudFront, ALB, and WAF (Firehose) logs (prefixes `cloudfront/*`, `alb/*`, `waf/*`)<br>State key: `global/log-archive/terraform.tfstate` |
| **KMS (Secrets Manager)** | Single KMS key for Secrets Manager | Global backend (`example-tfstate-global`) | KMS key and alias `example-global-secretsmanager`; used to encrypt Secrets Manager secrets across environments<br>State key: `global/kms/terraform.tfstate`<br>**Apply after** global/iam (key policy references `github-actions-terraform` role). |
| **Environments** | Deploys actual infrastructure stacks | Per-env backend | Stacks (backend, RDS, frontend) use their respective environment backends. **Note**: Backend must be deployed before RDS (RDS depends on VPC/subnets from backend), then backend references RDS outputs via remote state. Log archive should be applied before frontend/backend so the bucket exists for access logging. The **backend** stack creates a Secrets Manager secret `example-{env}-backend` from the SOPS file `sops_secrets/{env}/backend.enc.json` (global KMS key from `global/kms`). CI/CD maps changes to `sops_secrets/<env>/backend.enc.json` to the corresponding `aws/<env>/backend` folder so plan/apply run when secrets change. |
