# Helm Documentation

This directory contains Helm-related documentation and examples.

## What is Helm?

Helm is the **package manager for Kubernetes**. Think of it like `apt` for Ubuntu or `npm` for Node.js, but for Kubernetes applications.

### Key Concepts

- **Chart**: A Helm package that contains all the resources needed to run an application
- **Release**: An instance of a chart running in a Kubernetes cluster
- **Repository**: A place where charts can be stored and shared
- **Values**: Configuration parameters that customize the chart

### Why Use Helm?

1. **Simplifies Deployment**: Package complex applications into reusable charts
2. **Version Management**: Track and manage application versions
3. **Configuration Management**: Use values files for different environments
4. **Template System**: Use Go templates to generate Kubernetes manifests
5. **Dependency Management**: Manage chart dependencies
6. **Rollback Support**: Easily rollback to previous versions

## Directory Structure

```
helm/
├── README.md                    # This file
├── HELM_GUIDE.md                # Comprehensive Helm guide
└── helm-demo/                   # Demo Helm chart
    ├── Chart.yaml               # Chart metadata
    ├── values.yaml              # Default values
    ├── templates/               # Kubernetes manifest templates
    │   ├── deployment.yaml
    │   ├── service.yaml
    │   ├── configmap.yaml
    │   ├── namespace.yaml
    │   └── _helpers.tpl         # Template helpers
    └── README.md                # Chart documentation
```

## Quick Start

### Install Helm

```bash
# macOS
brew install helm

# Linux
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Windows
choco install kubernetes-helm
```

### Install the Demo Chart

```bash
# Navigate to the chart directory
cd helm/helm-demo

# Install the chart
helm install my-demo .

# Check the release
helm list
helm status my-demo

# View generated manifests
helm get manifest my-demo
```

### Upgrade the Chart

```bash
# Upgrade with new values
helm upgrade my-demo . --set deployment.replicas=5

# Upgrade with values file
helm upgrade my-demo . -f custom-values.yaml
```

### Uninstall the Chart

```bash
helm uninstall my-demo
```

## Helm Commands Cheat Sheet

| Command | Description |
|---------|-------------|
| `helm install <name> <chart>` | Install a chart |
| `helm upgrade <name> <chart>` | Upgrade a release |
| `helm uninstall <name>` | Uninstall a release |
| `helm list` | List all releases |
| `helm status <name>` | Show release status |
| `helm rollback <name>` | Rollback to previous version |
| `helm template <name> <chart>` | Render templates locally |
| `helm lint <chart>` | Validate chart |
| `helm get values <name>` | Show release values |
| `helm get manifest <name>` | Show generated manifests |

## Documentation

- **[Helm Demo Chart](./helm-demo/README.md)**: Demo chart documentation
- **[Helm Guide](./HELM_GUIDE.md)**: Comprehensive Helm concepts and best practices

## Resources

- [Official Helm Documentation](https://helm.sh/docs/)
- [Helm Chart Template Guide](https://helm.sh/docs/chart_template_guide/)
- [Helm Best Practices](https://helm.sh/docs/chart_best_practices/)
- [Artifact Hub](https://artifacthub.io/) - Find and share Helm charts
