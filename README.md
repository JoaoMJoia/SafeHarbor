# SafeHarbor

A curated collection of reliable jobs and pipelines worth preserving.

## Overview

SafeHarbor is a comprehensive repository containing production-ready infrastructure code, deployment configurations, and documentation for modern cloud-native applications. This project serves as a reference implementation and learning resource for:

- **Kubernetes** deployments and configurations
- **Helm** charts and package management
- **Docker** containerization
- **Ansible** configuration management
- **Terraform** infrastructure as code
- **GitHub Actions** CI/CD workflows

## Project Structure

```
SafeHarbor/
├── .github/                # GitHub Actions workflows and linting configurations
│   ├── workflows/          # CI/CD workflows
│   │   ├── amplify-preview-url.yaml      # Manual AWS Amplify branch management
│   │   ├── ci-amplify-preview-url.yaml   # Automated Amplify deployment monitoring
│   │   └── pr-lint-github-actions.yaml   # GitHub Actions and YAML linting
│   └── linters/            # Linting configuration files
│       ├── .checkov.yaml   # Checkov security scanning config
│       ├── .yaml-lint.yml  # YAML linting rules
│       └── actionlint.yml  # GitHub Actions linting rules
├── ansible/                # Ansible playbooks and configurations
│   ├── playbook.yml        # Main deployment playbook
│   ├── inventory.ini        # Server inventory
│   ├── templates/          # Jinja2 templates
│   └── group_vars/         # Group-specific variables
├── diagrams/               # Architecture and workflow diagrams
│   ├── front-back-end-eks-cluster/  # EKS cluster architecture diagrams
│   └── s3-fargate-cluster/          # S3/Fargate architecture diagrams
├── docker-app/             # Docker containerization examples
│   ├── app.js              # Node.js application
│   ├── Dockerfile          # Container build instructions
│   └── docker-compose.yml  # Multi-container orchestration
├── k8s/                    # Kubernetes configurations and documentation
│   ├── demo-app/           # Demo application Kubernetes manifests
│   ├── helm/               # Helm charts and guides
│   ├── eks/                # EKS-specific components and documentation
│   ├── components/         # Kubernetes component documentation
│   ├── objects/            # Kubernetes objects documentation
│   └── guides/             # Best practices and troubleshooting guides
└── terraform/              # Terraform modules and configurations
    ├── amplify.tf          # AWS Amplify infrastructure
    ├── github.tf           # GitHub resources
    └── terraform-module-github/  # GitHub organization/repository management
        ├── organization/   # Organization management module
        └── repository/     # Repository management module
```

## Quick Start

### GitHub Actions
The `.github/` directory contains CI/CD workflows and linting configurations:
- **Workflows**: AWS Amplify deployment automation and GitHub Actions linting
- **Linters**: Configuration for Checkov, YAML linting, and actionlint
- See workflow files in `.github/workflows/` for detailed documentation

### Ansible
See [ansible/README.md](./ansible/README.md) for Ansible playbook documentation.

### Docker
See [docker-app/README.md](./docker-app/README.md) for Docker examples.

### Kubernetes
See [k8s/README.md](./k8s/README.md) for Kubernetes documentation and examples.

### Helm
See [k8s/helm/README.md](./k8s/helm/README.md) for Helm chart documentation.

### Terraform
See [terraform/terraform-module-github/](./terraform/terraform-module-github/) for Terraform module documentation.

## Documentation

Each directory contains comprehensive README files with:
- Setup instructions
- Usage examples
- Best practices
- Troubleshooting guides
- Architecture diagrams

## License

See [LICENSE](./LICENSE) for license information.
