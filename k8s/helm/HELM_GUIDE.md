# Helm Guide

A comprehensive guide to Helm, the package manager for Kubernetes.

## Table of Contents

1. [Introduction](#introduction)
2. [Core Concepts](#core-concepts)
3. [Chart Structure](#chart-structure)
4. [Templates and Values](#templates-and-values)
5. [Helm Commands](#helm-commands)
6. [Best Practices](#best-practices)
7. [Advanced Topics](#advanced-topics)

## Introduction

Helm is the package manager for Kubernetes. It simplifies the deployment and management of Kubernetes applications by:

- **Packaging** applications into reusable charts
- **Managing** application lifecycles (install, upgrade, rollback)
- **Templating** Kubernetes manifests with configurable values
- **Versioning** applications and their configurations

### Installation

```bash
# macOS
brew install helm

# Linux
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Windows
choco install kubernetes-helm

# Verify installation
helm version
```

## Core Concepts

### Chart

A **Chart** is a Helm package. It contains all the resource definitions necessary to run an application, tool, or service in a Kubernetes cluster.

**Chart Components:**
- `Chart.yaml`: Chart metadata (name, version, description)
- `values.yaml`: Default configuration values
- `templates/`: Kubernetes manifest templates
- `charts/`: Chart dependencies (sub-charts)

### Release

A **Release** is an instance of a chart running in a Kubernetes cluster. One chart can be installed multiple times, each creating a new release.

**Release Lifecycle:**
```
Install → Upgrade → Rollback → Uninstall
```

### Repository

A **Repository** is a location where charts can be stored and shared. Helm can connect to remote repositories or use local chart directories.

**Common Repositories:**
- [Artifact Hub](https://artifacthub.io/): Public Helm chart repository
- GitHub: Store charts in Git repositories
- Chart Museum: Self-hosted chart repository

### Values

**Values** are configuration parameters that customize the chart. They can be:
- Defined in `values.yaml` (defaults)
- Overridden via `--set` flag
- Provided via `-f` flag (values file)
- Merged from multiple sources

## Chart Structure

### Standard Chart Structure

```
mychart/
├── Chart.yaml          # Chart metadata
├── values.yaml         # Default configuration
├── charts/             # Chart dependencies
├── templates/          # Template files
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── configmap.yaml
│   └── _helpers.tpl    # Template helpers
└── README.md           # Chart documentation
```

### Chart.yaml

```yaml
apiVersion: v2
name: mychart
description: A Helm chart for Kubernetes
type: application
version: 0.1.0
appVersion: "1.0.0"
keywords:
  - demo
  - example
maintainers:
  - name: Your Name
    email: your.email@example.com
```

### values.yaml

```yaml
# Default values
replicas: 3
image:
  repository: nginx
  tag: "1.21"
  pullPolicy: IfNotPresent

service:
  type: ClusterIP
  port: 80

resources:
  requests:
    memory: "64Mi"
    cpu: "100m"
  limits:
    memory: "128Mi"
    cpu: "200m"
```

## Templates and Values

### Template Syntax

Helm uses Go templates with additional functions:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Release.Name }}-{{ .Chart.Name }}
spec:
  replicas: {{ .Values.replicas }}
  template:
    spec:
      containers:
      - name: {{ .Chart.Name }}
        image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
```

### Built-in Objects

| Object | Description |
|--------|-------------|
| `.Release` | Release information (Name, Namespace, Service, Revision) |
| `.Chart` | Chart metadata from Chart.yaml |
| `.Values` | Values from values.yaml and command line |
| `.Template` | Current template information |
| `.Files` | Access to non-template files |
| `.Capabilities` | Kubernetes cluster capabilities |

### Template Functions

**Common Functions:**
- `default`: Provide default value
- `required`: Require a value
- `include`: Include another template
- `tpl`: Render string as template
- `toYaml`: Convert to YAML
- `fromYaml`: Parse YAML
- `indent`: Indent text
- `nindent`: Newline and indent

**Example:**
```yaml
{{- default "default-value" .Values.myValue }}
{{- required "myValue is required" .Values.myValue }}
{{- include "mychart.labels" . | nindent 4 }}
```

### Helpers (_helpers.tpl)

Helper templates are reusable template snippets:

```yaml
{{- define "mychart.labels" -}}
app.kubernetes.io/name: {{ include "mychart.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "mychart.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}
```

## Helm Commands

### Installation

```bash
# Install from local chart
helm install myrelease ./mychart

# Install from repository
helm install myrelease stable/nginx

# Install with values
helm install myrelease ./mychart -f values.yaml

# Install with set values
helm install myrelease ./mychart --set key=value

# Dry-run (test without installing)
helm install myrelease ./mychart --dry-run --debug
```

### Upgrade

```bash
# Upgrade release
helm upgrade myrelease ./mychart

# Upgrade with new values
helm upgrade myrelease ./mychart --set replicas=5

# Upgrade with values file
helm upgrade myrelease ./mychart -f new-values.yaml

# Upgrade with atomic (rollback on failure)
helm upgrade myrelease ./mychart --atomic
```

### Management

```bash
# List releases
helm list
helm list --all-namespaces

# Show release status
helm status myrelease

# Show release values
helm get values myrelease

# Show generated manifests
helm get manifest myrelease

# Show release notes
helm get notes myrelease

# Show release history
helm history myrelease
```

### Rollback

```bash
# Rollback to previous version
helm rollback myrelease

# Rollback to specific revision
helm rollback myrelease 2
```

### Uninstall

```bash
# Uninstall release
helm uninstall myrelease

# Uninstall with keep history
helm uninstall myrelease --keep-history
```

### Testing

```bash
# Lint chart
helm lint ./mychart

# Template rendering (dry-run)
helm template myrelease ./mychart

# Template with values
helm template myrelease ./mychart -f values.yaml
```

## Best Practices

### Chart Organization

1. **Use Semantic Versioning**: Follow semver for chart versions
2. **Document Values**: Document all configurable values in README
3. **Use Helpers**: Create reusable template helpers
4. **Validate Inputs**: Use `required` for critical values
5. **Provide Defaults**: Set sensible defaults in values.yaml

### Values Management

1. **Environment-Specific Values**: Use separate values files per environment
   ```bash
   values-dev.yaml
   values-staging.yaml
   values-prod.yaml
   ```

2. **Sensitive Data**: Use Secrets, not values.yaml for sensitive data
3. **Value Validation**: Validate values in templates
4. **Documentation**: Document all values in README.md

### Template Best Practices

1. **Use Indentation**: Use `nindent` for proper YAML indentation
2. **Conditional Resources**: Use `if` to conditionally include resources
3. **Template Helpers**: Extract common patterns to helpers
4. **Comments**: Add comments for complex logic
5. **Error Handling**: Use `required` for critical values

### Security

1. **Least Privilege**: Use minimal RBAC permissions
2. **Secrets Management**: Use Kubernetes Secrets or external secret managers
3. **Image Security**: Use specific image tags, not `latest`
4. **Resource Limits**: Always set resource requests and limits
5. **Network Policies**: Consider network policies for isolation

## Advanced Topics

### Chart Dependencies

Define dependencies in `Chart.yaml`:

```yaml
dependencies:
  - name: postgresql
    version: "10.0.0"
    repository: "https://charts.bitnami.com/bitnami"
    condition: postgresql.enabled
```

Manage dependencies:
```bash
helm dependency update
helm dependency build
```

### Hooks

Hooks allow you to run jobs at specific points in a release lifecycle:

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: pre-install-job
  annotations:
    "helm.sh/hook": pre-install
    "helm.sh/hook-weight": "-5"
    "helm.sh/hook-delete-policy": hook-succeeded
```

**Hook Types:**
- `pre-install`: Before installation
- `post-install`: After installation
- `pre-upgrade`: Before upgrade
- `post-upgrade`: After upgrade
- `pre-rollback`: Before rollback
- `post-rollback`: After rollback
- `pre-delete`: Before deletion
- `post-delete`: After deletion

### Library Charts

Library charts provide reusable templates without creating resources:

```yaml
# Chart.yaml
type: library
```

Use in other charts:
```yaml
{{- include "library-chart.template" . }}
```

### Subcharts

Charts can include other charts as dependencies:

```yaml
# Chart.yaml
dependencies:
  - name: subchart
    version: "1.0.0"
    repository: "file://../subchart"
```

### Testing

**Unit Testing:**
```bash
helm unittest ./mychart
```

**Integration Testing:**
```bash
helm test myrelease
```

## Troubleshooting

### Common Issues

1. **Template Errors**: Use `--debug` flag to see rendered templates
2. **Value Issues**: Use `helm get values` to see applied values
3. **Upgrade Failures**: Use `--atomic` for automatic rollback
4. **Dependency Issues**: Run `helm dependency update`

### Debug Commands

```bash
# Debug template rendering
helm template myrelease ./mychart --debug

# Show all values
helm get values myrelease --all

# Validate chart
helm lint ./mychart

# Check release status
helm status myrelease
```

## Resources

- [Helm Official Documentation](https://helm.sh/docs/)
- [Chart Template Guide](https://helm.sh/docs/chart_template_guide/)
- [Best Practices Guide](https://helm.sh/docs/chart_best_practices/)
- [Artifact Hub](https://artifacthub.io/)
- [Helm GitHub](https://github.com/helm/helm)
