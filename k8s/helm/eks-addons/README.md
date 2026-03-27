# EKS Addons

This directory contains Helm chart values files for essential AWS EKS addons that provide core functionality for running applications on Amazon EKS clusters.

## Description

The EKS addons in this directory are pre-configured Helm values files for deploying and managing critical infrastructure components on Amazon EKS clusters. These addons provide essential services for load balancing, storage, and secrets management.

## Prerequisites

### General Requirements
- Amazon EKS cluster running
- `kubectl` configured to communicate with your EKS cluster
- `helm` v3.x installed
- AWS CLI configured with appropriate permissions
- IAM roles and policies configured for each addon

### Specific Prerequisites

#### AWS Load Balancer Controller
- IAM role with ALB/NLB permissions attached to the controller service account
- VPC with proper tagging for load balancer discovery
- Security groups configured for ALB/NLB
- Cluster name properly configured

#### EFS CSI Driver
- EFS file system created in the same VPC as the EKS cluster
- IAM role with EFS permissions attached to the driver service account
- VPC endpoints for EFS (recommended for production)

#### Secrets Store CSI Driver
- IAM role with Secrets Manager/Parameter Store permissions
- AWS Secrets Manager or Systems Manager Parameter Store configured
- Kubernetes secrets syncing enabled (optional)

#### Target Group Bindings
- AWS Load Balancer Controller installed and configured
- Target groups created in AWS Application Load Balancer
- Proper IAM permissions for target group binding operations
- Kubernetes services to be bound to load balancers

## Usage

### Installation Order
1. **Secrets Store CSI Driver** - Foundation for secrets management
2. **Secrets Provider AWS** - AWS-specific secrets provider
3. **EFS CSI Driver** - Storage driver for EFS
4. **AWS Load Balancer Controller** - Load balancing functionality
5. **Target Group Bindings** - Connect services to load balancers

### Installation Commands

#### 1. Secrets Store CSI Driver
```bash
# Add the Helm repository
helm repo add secrets-store-csi-driver https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts

# Install the driver
helm upgrade --install csi-secrets-store secrets-store-csi-driver/secrets-store-csi-driver \
  -f secrets-store-csi-driver.yaml \
  -n kube-system
```

#### 2. Secrets Provider AWS
```bash
# Add the Helm repository
helm repo add secrets-store-csi-driver-provider-aws https://aws.github.io/secrets-store-csi-driver-provider-aws

# Install the AWS provider
helm upgrade --install secrets-provider-aws secrets-store-csi-driver-provider-aws/secrets-store-csi-driver-provider-aws \
  -f secrets-provider-aws.yaml \
  -n kube-system
```

#### 3. EFS CSI Driver
```bash
# Add the Helm repository
helm repo add aws-efs-csi-driver https://kubernetes-sigs.github.io/aws-efs-csi-driver/

# Install the EFS CSI driver
helm upgrade --install aws-efs-csi-driver aws-efs-csi-driver/aws-efs-csi-driver \
  -f efs-csi-driver.yaml \
  -n kube-system \
  --version 2.4.9
```

#### 4. AWS Load Balancer Controller
```bash
# Add the Helm repository
helm repo add eks https://aws.github.io/eks-charts

# Install the load balancer controller
helm upgrade --install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -f aws-load-balancer-controller.yaml \
  -n kube-system
```

#### 5. Target Group Bindings
```bash
# Apply target group bindings to connect services to load balancers
kubectl apply -f targetgroupbindings.yaml
```

### Configuration

Before installing, ensure to replace the placeholder values in each YAML file:

- `___ALB_ROLE___` - IAM role ARN for ALB controller
- `___CLUSTER_NAME___` - EKS cluster name
- `___ALB_SG___` - Security group ID for ALB
- `___EFS_ROLE___` - IAM role ARN for EFS CSI driver
- `___EFS_ID___` - EFS file system ID
- `___GRAFANA_TARGET_GROUP___` - Target group ARN for Grafana
- `___LOKI_TARGET_GROUP___` - Target group ARN for Loki
- `___PROMETHEUS_TARGET_GROUP___` - Target group ARN for Prometheus

## CI/CD Workflow

This folder is automated by:
- `.github/workflows/helm-eks-addons.yaml`

### Trigger mode

- The workflow runs via `workflow_dispatch` (manual run).
- It exposes a `deploy` input:
  - `'false'` (default): runs value templating, diff checks, and dry-run validation only.
  - `'true'`: applies addon changes when differences are detected.

### What the workflow validates/deploys

- AWS Load Balancer Controller (Helm diff + dry-run + deploy)
- Target Group Bindings (kubectl diff + apply)
- EFS CSI Driver (Helm diff + dry-run + deploy)
- CSI Secrets Store Driver (Helm diff + dry-run + deploy)
- Secrets Provider AWS (Helm diff + dry-run + deploy)

### Important note

- The workflow currently contains example env values for manual/testing usage.
- Replace those example values with real environment/secret wiring before production.

## Features

### AWS Load Balancer Controller
- **Application Load Balancer (ALB) Support**: Automatically provision and configure ALBs
- **Network Load Balancer (NLB) Support**: Provision NLBs for TCP/UDP traffic
- **Target Group Binding**: Bind Kubernetes services to ALB/NLB target groups
- **SSL/TLS Termination**: Handle SSL certificates and termination
- **Health Checks**: Automatic health check configuration
- **Security Groups**: Automatic security group management

### EFS CSI Driver
- **Persistent Storage**: Provide persistent file storage using Amazon EFS
- **Dynamic Provisioning**: Automatically provision EFS access points
- **Multi-AZ Support**: Access EFS from multiple availability zones
- **Encryption**: Support for EFS encryption at rest and in transit
- **Access Control**: Fine-grained access control using EFS access points
- **Performance**: Optimized for high-throughput workloads

### Secrets Store CSI Driver
- **External Secrets**: Mount secrets from external sources into pods
- **Kubernetes Secrets Sync**: Automatically sync external secrets to Kubernetes secrets
- **Secret Rotation**: Support for automatic secret rotation
- **Multiple Providers**: Support for various secret providers (AWS, Azure, GCP, etc.)
- **Security**: Secrets are never stored in etcd

### Secrets Provider AWS
- **AWS Secrets Manager Integration**: Mount secrets from AWS Secrets Manager
- **Parameter Store Integration**: Mount parameters from Systems Manager Parameter Store
- **IAM Authentication**: Use IAM roles for authentication
- **Automatic Rotation**: Support for automatic secret rotation
- **Cross-Region Support**: Access secrets from different AWS regions

### Target Group Bindings
- **Load Balancer Integration**: Connect Kubernetes services to Application Load Balancer target groups
- **Service Discovery**: Automatically bind Kubernetes services to ALB target groups
- **Health Check Integration**: Leverage ALB health checks for service endpoints
- **Node Selector Support**: Route traffic to specific node groups when needed
- **Multi-Service Support**: Bind multiple services to different target groups
- **SSL/TLS Support**: Handle secure connections to services

## Best Practices

### Security
- **Principle of Least Privilege**: Use minimal IAM permissions for each addon
- **Network Security**: Use VPC endpoints for AWS services in production
- **Secret Management**: Never store secrets in plain text or commit them to version control
- **Pod Security**: Use pod security policies and security contexts

### Performance
- **Resource Limits**: Set appropriate CPU and memory limits for all components
- **Node Affinity**: Use node affinity to control pod placement
- **Horizontal Pod Autoscaling**: Configure HPA for controllers when appropriate
- **Monitoring**: Implement comprehensive monitoring and alerting

### Reliability
- **High Availability**: Deploy multiple replicas for critical components
- **Health Checks**: Configure proper liveness and readiness probes
- **Backup Strategy**: Implement backup strategies for persistent data
- **Disaster Recovery**: Plan for disaster recovery scenarios

### Maintenance
- **Version Management**: Keep addons updated to the latest stable versions
- **Testing**: Test upgrades in non-production environments first
- **Documentation**: Maintain up-to-date documentation for configurations
- **Monitoring**: Monitor addon health and performance metrics

## Troubleshooting

### Common Issues

#### Load Balancer Controller
- **ALB not created**: Check IAM permissions and VPC tagging
- **Target group binding failures**: Verify service annotations and target group configuration
- **SSL certificate issues**: Ensure certificates are properly configured in AWS Certificate Manager

#### EFS CSI Driver
- **Mount failures**: Check EFS file system accessibility and security groups
- **Performance issues**: Consider using EFS access points for better performance
- **Permission denied**: Verify IAM roles and EFS access point permissions

#### Secrets Store CSI Driver
- **Secret mounting failures**: Check IAM permissions and secret provider configuration
- **Sync issues**: Verify Kubernetes secrets syncing configuration
- **Rotation failures**: Check rotation policies and IAM permissions

#### Target Group Bindings
- **Binding failures**: Check target group ARN and service configuration
- **Health check failures**: Verify service endpoints and port configuration
- **Node selector issues**: Ensure target nodes have proper labels

### Debugging Commands
```bash
# Check addon status
kubectl get pods -n kube-system | grep -E "(aws-load-balancer-controller|efs-csi|secrets-store)"

# View logs
kubectl logs -n kube-system deployment/aws-load-balancer-controller
kubectl logs -n kube-system daemonset/efs-csi-node

# Check target group bindings
kubectl get targetgroupbindings -n infrastructure
kubectl describe targetgroupbinding -n infrastructure

# Check events
kubectl get events -n kube-system --sort-by='.lastTimestamp'
```

## Support

For issues and questions:
- Check the [AWS Load Balancer Controller documentation](https://kubernetes-sigs.github.io/aws-load-balancer-controller/)
- Review the [EFS CSI Driver documentation](https://github.com/kubernetes-sigs/aws-efs-csi-driver)
- Consult the [Secrets Store CSI Driver documentation](https://secrets-store-csi-driver.sigs.k8s.io/)
- Contact your platform team for internal support

## Contributing

When modifying these addon configurations:
1. Test changes in a development environment first
2. Update this README with any new configuration options
3. Document any breaking changes
4. Follow the established naming conventions
5. Ensure all placeholder values are properly documented 