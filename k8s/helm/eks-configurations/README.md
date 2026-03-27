# EKS Configurations

This directory contains essential Kubernetes configurations and Helm chart values for Amazon EKS cluster management, including cluster autoscaling, RBAC, and namespace management.

## Description

The EKS configurations provide a comprehensive set of operational tools and infrastructure components for managing production-ready Amazon EKS clusters. These configurations include cluster autoscaling, access control, and namespace organization.

## Prerequisites

### General Requirements
- Amazon EKS cluster running
- `kubectl` configured to communicate with your EKS cluster
- `helm` v3.x installed
- AWS CLI configured with appropriate permissions
- IAM roles and policies configured for each component

### Specific Prerequisites

#### Cluster Autoscaler
- EKS cluster with node groups configured for autoscaling
- IAM role with EC2 autoscaling permissions
- Proper node group tagging for discovery
- Cluster name properly configured

#### RBAC & Namespaces
- Cluster admin permissions for namespace creation
- Proper RBAC policies for development teams

## Usage

### Installation Order
1. **Namespaces** - Create required namespaces first
2. **RBAC** - Set up cluster roles and bindings
3. **Cluster Autoscaler** - Enable automatic node scaling

### Installation Commands

#### 1. Create Namespaces
```bash
# Production namespaces
kubectl apply -f namespaces-prod.yaml

# Non-production namespaces
kubectl apply -f namespaces-non-prod.yaml
```

#### 2. Configure RBAC
```bash
# Create cluster role for development team
kubectl apply -f dev-view-clusterrole.yaml

# Create cluster role binding
kubectl apply -f dev-view-clusterrolebinding.yaml
```

#### 3. Cluster Autoscaler
```bash
# Add the Helm repository
helm repo add autoscaler https://kubernetes.github.io/autoscaler
helm repo update

# Install cluster autoscaler
helm upgrade --install -n kube-system cluster-autoscaler autoscaler/cluster-autoscaler \
  -f cluster_autoscaler.yaml \
  --version "~9.43.2" \
  --atomic \
  --timeout 5m
```

### Configuration

Before installing, ensure to replace the placeholder values in each YAML file:

- `___CLUSTER_NAME___` - EKS cluster name for autoscaler
- `___AWS_REGION___` - AWS region for services

## CI/CD Workflow

This folder is automated by:
- `.github/workflows/helm-eks-configurations.yaml`

### Trigger mode

- The workflow runs via `workflow_dispatch` (manual run).
- It exposes a `deploy` input:
  - `'false'` (default): runs diff and dry-run validation only.
  - `'true'`: applies configuration changes when differences are detected.

### What the workflow validates/deploys

- Namespaces (`kubectl diff` + `kubectl apply`)
- Dev View ClusterRole (`kubectl diff` + `kubectl apply`)
- Dev View ClusterRoleBinding (`kubectl diff` + `kubectl apply`)
- Cluster Autoscaler (Helm diff + dry-run + deploy)
- Metrics Server apply step when deploy is enabled

### Important note

- The workflow currently contains example env values for manual/testing usage.
- Replace those example values with real environment/secret wiring before production.

## Features

### Cluster Autoscaler
- **Automatic Node Scaling**: Scale nodes up and down based on pod scheduling needs
- **Multi-Node Group Support**: Handle multiple node groups with different configurations
- **Cost Optimization**: Scale down nodes during low usage periods
- **Pod Disruption Protection**: Respect pod disruption budgets during scaling
- **AWS Integration**: Native integration with AWS Auto Scaling Groups
- **Monitoring**: Prometheus metrics for autoscaling operations

### RBAC & Access Control
- **Development Team Access**: Controlled access for development teams
- **Namespace Isolation**: Proper namespace-based access control
- **Resource Permissions**: Granular permissions for different resource types
- **Audit Trail**: Track access and changes to cluster resources

### Namespace Management
- **Environment Separation**: Separate namespaces for different environments
- **Resource Quotas**: Control resource usage per namespace
- **Network Policies**: Isolate network traffic between namespaces
- **Team Organization**: Organize workloads by team or project

## Best Practices

### Security
- **Principle of Least Privilege**: Use minimal permissions for all components
- **Network Security**: Use VPC endpoints for AWS services in production
- **Secret Management**: Store sensitive configuration in AWS Secrets Manager
- **Pod Security**: Implement pod security policies and security contexts

### Performance
- **Resource Limits**: Set appropriate CPU and memory limits for all components
- **Node Affinity**: Use node affinity to control pod placement
- **Autoscaling Tuning**: Configure autoscaler parameters for your workload patterns
- **Monitoring**: Implement comprehensive monitoring and alerting

### Reliability
- **High Availability**: Deploy critical components with multiple replicas
- **Health Checks**: Configure proper liveness and readiness probes

### Maintenance
- **Version Management**: Keep components updated to the latest stable versions
- **Testing**: Test upgrades in non-production environments first
- **Documentation**: Maintain up-to-date documentation for configurations
- **Monitoring**: Monitor component health and performance metrics

## Troubleshooting

### Common Issues

#### Cluster Autoscaler
- **Nodes not scaling up**: Check IAM permissions and node group configuration
- **Nodes not scaling down**: Verify pod disruption budgets and node protection
- **Scaling delays**: Check autoscaler logs and configuration parameters

### Debugging Commands
```bash
# Check component status
kubectl get pods -n kube-system | grep cluster-autoscaler

# View logs
kubectl logs -n kube-system deployment/cluster-autoscaler

# Check events
kubectl get events -n kube-system --sort-by='.lastTimestamp'
```

## Support

For issues and questions:
- Check the [Cluster Autoscaler documentation](https://github.com/kubernetes/autoscaler/tree/master/cluster-autoscaler)
- Contact your platform team for internal support

## Contributing

When modifying these configurations:
1. Test changes in a development environment first
2. Update this README with any new configuration options
3. Document any breaking changes
4. Follow the established naming conventions
5. Ensure all placeholder values are properly documented 