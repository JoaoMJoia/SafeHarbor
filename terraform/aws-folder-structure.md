# 🗂 AWS Terraform Repository Structure

This repository defines and manages all AWS infrastructure using **Terraform**, following a clear separation between reusable modules, global infrastructure, and per-environment stacks.

---

## 📁 Folder Structure

```bash
aws/
├─ modules/                                      # Reusable Terraform modules (building blocks) # Modules should be on his own repository for independent lifecycle management
│  ├─ frontend/                                   # Frontend static site + CDN module (S3 + CloudFront)
│  │  ├─ versions.tf                              # Terraform and provider constraints for the frontend module
│  │  ├─ variables.tf                             # Module inputs (bucket name, tags, geo whitelist, etc.)
│  │  ├─ s3.tf                                    # S3 bucket definition for static frontend assets
│  │  ├─ cloudfront.tf                            # CloudFront OAC + distribution for the frontend
│  │  ├─ outputs.tf                               # Exposes bucket id/arn and CloudFront id/domain
│  │  └─ iam_policies/                            # Frontend-specific IAM policies (e.g. S3 bucket access from CloudFront)
│  │     └─ frontend_bucket_policy.json           # Bucket policy template used by the frontend module
│  ├─ backend/                                    # Backend application module (VPC, ECS Fargate, RDS, ElastiCache, ALB, backend CloudFront, S3, IAM, KMS)
│  │  ├─ versions.tf                              # Terraform and provider constraints for the backend module
│  │  ├─ variables.tf                             # Module inputs (environment, region, tags, VPC CIDRs, AZs, ECR image URI, account ID, etc.)
│  │  ├─ vpc.tf                                   # VPC definition (public/private subnets, NAT gateways, routing)
│  │  ├─ rds.tf                                   # RDS MySQL instance, SG, random password, and SSM parameter
│  │  ├─ ecs.tf                                   # ECS cluster, task definitions, services, autoscaling, and alarms
│  │  ├─ ecr.tf                                   # ECR repository and pull policy for ECS execution role
│  │  ├─ s3.tf                                    # S3 bucket for backend assets used by the application
│  │  ├─ elasticache.tf                           # ElastiCache Redis replication group and SG rules
│  │  ├─ alb.tf                                   # Application Load Balancer, listeners, target groups, and SG
│  │  ├─ cloudfront.tf                            # CloudFront distribution in front of the backend ALB (HTTPS termination)
│  │  ├─ cloudwatch.tf                            # CloudWatch log groups for ECS workloads
│  │  ├─ kms.tf                                   # KMS key and alias for SSM parameter encryption
│  │  ├─ iam.tf                                   # ECS task and execution roles, IAM policies, and attachments
│  │  ├─ data.tf                                  # Shared data sources (e.g., caller identity, AZs)
│  │  ├─ outputs.tf                               # Exposes ALB, CloudFront, VPC, RDS, S3, and ElastiCache outputs
│  │  ├─ env_vars.json                            # Base Laravel application environment variables (consumed by ECS tasks)
│  │  └─ iam_policies/                            # Backend-specific IAM policy templates
│  │     ├─ ecs-kms-ssm-policy.json               # Allow ECS tasks to use KMS key and read DB password from SSM
│  │     ├─ ecs-php-s3-policy.json                # Allow ECS tasks (PHP app) to access backend S3 bucket
│  │     └─ kms-ssm-parameter-key-policy.json     # Key policy for SSM parameter encryption KMS key
│  └─ tfstate/                                    # Terraform remote state backend (S3+DDB) reusable module
│     ├─ versions.tf                              # Terraform and AWS provider constraints
│     ├─ variables.tf                             # Inputs for S3 bucket name, DynamoDB table name, and common tags
│     ├─ main.tf                                  # Creates S3 bucket for state + DynamoDB table for locks
│     └─ outputs.tf                               # Exposes created bucket and table names/ids
│
├─ global/                                       # Global AWS resources (provisioned rarely)
│  ├─ iam/                                         # Global IAM roles, users, and shared policies
│  │  ├─ backend.tf                                 # Backend config (uses project-tfstate-global)
│  │  ├─ github-oidc.tf                             # GitHub Actions OIDC integration
│  │  ├─ iam_policies/                              # Common IAM policy definitions
│  │  │  └─ github-actions-terraform.json            # Policy for GitHub Actions to manage infrastructure
│  │  ├─ locals.tf                                  # Local variables and tags
│  │  ├─ provider.tf                                # AWS provider configuration
│  │  └─ README.md                                  # IAM module documentation
│  └─ tfstate/                                     # Remote state infrastructure management
│     ├─ bootstrap/                                  # Bootstrap state for creating initial backend
│     │  ├─ backend.tf                               # Backend config (uses project-terraform-state)
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
│  ├─ rds/                                         # Database resources for dev
│  └─ frontend/                                    # Frontend static site + CDN
│
├─ qa/                                           # QA environment infrastructure stacks
│
└─ production/                                   # Production environment infrastructure stacks
```

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
│      - S3: project-terraform-state                            │
│      - DynamoDB: project-terraform-state-locks                │
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
│      - Global: project-tfstate-global + project-tfstate-global-locks │
│      - Dev: project-tfstate-dev + project-tfstate-dev-locks     │
│      - QA: project-tfstate-qa + project-tfstate-qa-locks        │
│      - Production: project-tfstate-production + project-tfstate-production-locks │
└───────────────┬────────────────────────────────────────────┘
                │
                │ outputs S3/DDB details
                │
        ┌───────┴───────┐
        │               │
        ▼               ▼
┌──────────────────┐  ┌──────────────────────────────────────┐
│ Global Resources │  │  Environment Stacks                  │
│ (global/iam/)    │  │  (dev/, qa/, production/)            │
│                  │  │                                      │
│ • Uses global    │  │  • Each stack uses its env backend  │
│   backend:       │  │  • Examples:                         │
│   project-tfstate-  │  │    - dev/networking →                │
│   global         │  │      dev/networking/terraform.tfstate│
│ • State key:     │  │    - qa/backend →                    │
│   global/iam/    │  │      qa/backend/terraform.tfstate    │
│   terraform.tfstate│ │    - production/rds →                │
│ • Manages IAM    │  │      production/rds/terraform.tfstate│
│   roles, policies│  │  • IAM roles restricted per env      │
│   & GitHub OIDC  │  │                                      │
└──────────────────┘  └──────────────────────────────────────┘
```

### 🔐 State Isolation Rules
- **Bootstrap backend**: `project-terraform-state` - Used only for bootstrap and backends management
- **Global backend**: `project-tfstate-global` - Used for global resources (IAM, etc.)
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
| **Bootstrap** | Seeds the infrastructure for Terraform backends | Local (initially), then self-managed | S3: `project-terraform-state`<br>DynamoDB: `project-terraform-state-locks`<br>State key: `global/tfstate/bootstrap/terraform.tfstate` |
| **Backends** | Creates per-environment Terraform backends | Bootstrap backend (`project-terraform-state`) | 4 backends:<br>• Global: `project-tfstate-global` + `project-tfstate-global-locks`<br>• Dev: `project-tfstate-dev` + `project-tfstate-dev-locks`<br>• QA: `project-tfstate-qa` + `project-tfstate-qa-locks`<br>• Production: `project-tfstate-production` + `project-tfstate-production-locks`<br>State key: `global/tfstate/backends/terraform.tfstate` |
| **Global IAM** | Manages global IAM resources | Global backend (`project-tfstate-global`) | IAM roles, policies, GitHub OIDC integration<br>State key: `global/iam/terraform.tfstate` |
| **Environments** | Deploys actual infrastructure stacks | Per-env backend | Future stacks (networking, backend, RDS, frontend) will use their respective environment backends |
