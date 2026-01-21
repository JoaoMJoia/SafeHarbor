# 🗂 GitHub Terraform Repository Structure

This repository defines and manages **GitHub organization and repositories** using **Terraform**, following the same conventions and backend flow used in the AWS Terraform structure.

---

## 📁 Folder Structure

```bash
github/
├─ modules/                            # Reusable Terraform modules
│  ├─ organisation/                    # Org-level: members, teams, rules, policies
│  └─ repository/                      # “Repo factory” (one module call per repo)
│
├─ terraform.tf                        # Example: repo “terraform”
├─ database.tf                         # Example: repo “database”
└─ organisation-settings.tf            # Org-wide settings
```

```bash
aws
└─ global/
   └─ tfstate/
      └─ backends/                        # Creates and manages backends for each platform
         └─ github/                       # Backend for GitHub Terraform state
            ├─ main.tf                    # Provisions the GitHub tfstate backend infra
            └─ README.md
```

---

## ⚙️ Terraform State Management Flow (GitHub)

Same 3-stage cascade used for AWS, adapted for GitHub:

```text
┌────────────────────────────────────────────────────────────┐
│              Bootstrap (global/tfstate/bootstrap)          │
│  • Uses remote backend                                     │
│  • Creates bootstrap S3 + DynamoDB (optional KMS)          │
└───────────────┬────────────────────────────────────────────┘
                │
                │ terraform apply
                ▼
┌────────────────────────────────────────────────────────────┐
│                Backends (global/tfstate/backends)          │
│  • Uses the bootstrap state backend                        │
│  • Provisions backends:                                    │
│      - S3: tfstate-github                                  │
│      - DynamoDB lock tables & KMS keys                     │
└───────────────┬────────────────────────────────────────────┘
                │
                │ outputs bucket/table/region/kms details
                ▼
┌────────────────────────────────────────────────────────────┐
│                    GitHub Root (github/)                   │
│  • Uses the created backend (tfstate-github)               │
│  • Single tfstate for all GitHub resources                 │
│  • Backend key: terraform.tfstate                          │
└────────────────────────────────────────────────────────────┘
```

---

## 🧱 Structure Overview

| Area | Description |
|------|-------------|
| **github/modules/** | Reusable logic for org settings and repository creation. |
| **github/*.tf** | One file per GitHub repository (calls `modules/repository`). |
| **global/tfstate/bootstrap/** | Stack that uses your existing **bootstrap** backend to create the dedicated S3 + DynamoDB (and optional KMS) for **GitHub tfstate**. |
| **global/tfstate/backends/** | Contains the Terraform configuration to provision the GitHub backend (`tfstate-github`) using the bootstrap backend. |

---
