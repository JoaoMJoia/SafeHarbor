# Helm Demo Chart

A Helm chart for the SafeHarbor Demo Application demonstrating Helm concepts and best practices.

## What is Helm?

Helm is the package manager for Kubernetes. It helps you:
- **Package** Kubernetes applications into charts
- **Manage** application deployments
- **Template** Kubernetes manifests with values
- **Version** and **Upgrade** applications easily

## Chart Structure

```
helm-demo/
├── Chart.yaml          # Chart metadata
├── values.yaml         # Default configuration values
├── templates/          # Kubernetes manifest templates
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── configmap.yaml
│   ├── namespace.yaml
│   └── _helpers.tpl    # Template helpers
└── README.md           # This file
```

## Installation

### Install the chart

```bash
# Install with default values
helm install my-demo ./helm-demo

# Install with custom values
helm install my-demo ./helm-demo --set deployment.replicas=5

# Install from values file
helm install my-demo ./helm-demo -f custom-values.yaml
```

### Upgrade the chart

```bash
# Upgrade with new values
helm upgrade my-demo ./helm-demo --set deployment.replicas=5

# Upgrade with values file
helm upgrade my-demo ./helm-demo -f custom-values.yaml
```

### Uninstall the chart

```bash
helm uninstall my-demo
```

## Configuration

The following table lists the configurable parameters and their default values:

| Parameter | Description | Default |
|-----------|-------------|---------|
| `namespace.name` | Namespace name | `helm-demo` |
| `namespace.create` | Create namespace | `true` |
| `image.repository` | Container image repository | `hashicorp/http-echo` |
| `image.tag` | Container image tag | `latest` |
| `image.pullPolicy` | Image pull policy | `IfNotPresent` |
| `container.name` | Container name | `helm-demo` |
| `container.port` | Container port | `8080` |
| `container.args` | Container arguments | `["-text=...", "-listen=:8080"]` |
| `deployment.replicas` | Number of replicas | `3` |
| `service.type` | Service type | `ClusterIP` |
| `service.port` | Service port | `80` |
| `service.targetPort` | Service target port | `8080` |
| `service.sessionAffinity` | Session affinity | `ClientIP` |
| `resources.requests.memory` | Memory request | `64Mi` |
| `resources.requests.cpu` | CPU request | `100m` |
| `resources.limits.memory` | Memory limit | `128Mi` |
| `resources.limits.cpu` | CPU limit | `200m` |
| `probes.liveness.enabled` | Enable liveness probe | `true` |
| `probes.liveness.path` | Liveness probe path | `/` |
| `probes.liveness.port` | Liveness probe port | `8080` |
| `probes.readiness.enabled` | Enable readiness probe | `true` |
| `probes.readiness.path` | Readiness probe path | `/` |
| `probes.readiness.port` | Readiness probe port | `8080` |
| `configMap.enabled` | Enable ConfigMap | `true` |
| `app.message` | Application message | `Hello from SafeHarbor Helm Demo App!` |
| `app.version` | Application version | `v1` |
| `app.environment` | Application environment | `demo` |

## Examples

### Example 1: Install with custom replica count

```bash
helm install my-demo ./helm-demo --set deployment.replicas=5
```

### Example 2: Install with custom image

```bash
helm install my-demo ./helm-demo \
  --set image.repository=nginx \
  --set image.tag=1.21
```

### Example 3: Install with custom values file

Create `custom-values.yaml`:
```yaml
deployment:
  replicas: 5

resources:
  requests:
    memory: "128Mi"
    cpu: "200m"
  limits:
    memory: "256Mi"
    cpu: "500m"
```

Then install:
```bash
helm install my-demo ./helm-demo -f custom-values.yaml
```

## Helm Commands

### List installed releases
```bash
helm list
```

### Get release status
```bash
helm status my-demo
```

### View generated manifests (dry-run)
```bash
helm template my-demo ./helm-demo
```

### View values
```bash
helm get values my-demo
```

### Rollback to previous version
```bash
helm rollback my-demo
```

## Testing

### Validate chart
```bash
helm lint ./helm-demo
```

### Dry-run installation
```bash
helm install my-demo ./helm-demo --dry-run --debug
```

### Template rendering
```bash
helm template my-demo ./helm-demo
```

## Learn More

- [Helm Documentation](https://helm.sh/docs/)
- [Chart Template Guide](https://helm.sh/docs/chart_template_guide/)
- [Best Practices](https://helm.sh/docs/chart_best_practices/)
