# Kubernetes Documentation

This directory contains comprehensive documentation about Kubernetes components and architecture.

## Documentation Files

### [KUBERNETES_COMPONENTS.md](./KUBERNETES_COMPONENTS.md)
General Kubernetes components documentation explaining:
- Control plane components (API Server, etcd, Controller Manager, Scheduler)
- Node components (kubelet, kube-proxy, Container Runtime)
- Addon components (DNS, CNI, CSI)
- Kubernetes objects (Pods, Services, Deployments)
- Component interactions and request flows
- Architecture diagrams

### [eks/EKS_COMPONENTS.md](./eks/EKS_COMPONENTS.md)
EKS-specific components documentation covering:
- EKS Addons (Load Balancer Controller, EFS CSI Driver, Secrets Store)
- EKS Configurations (Cluster Autoscaler, Trivy, Velero)
- Observability Stack (Prometheus, Grafana, Loki, Thanos)
- Component interactions and data flows
- User flows and troubleshooting

## Quick Navigation

- **New to Kubernetes?** Start with [KUBERNETES_COMPONENTS.md](./KUBERNETES_COMPONENTS.md) to understand the fundamentals
- **Working with EKS?** Check [eks/EKS_COMPONENTS.md](./eks/EKS_COMPONENTS.md) for EKS-specific components
- **Need troubleshooting?** Both documents include troubleshooting sections

## Structure

```
k8s/
├── README.md                    # This file
├── KUBERNETES_COMPONENTS.md    # General Kubernetes components
└── eks/
    ├── EKS_COMPONENTS.md        # EKS-specific components
    └── diagrams/                # Architecture diagrams
```
