# Best Practices and Troubleshooting

## Key Concepts Summary

### Declarative vs Imperative

**Declarative**: You describe the desired state, Kubernetes makes it happen.
```yaml
apiVersion: apps/v1
kind: Deployment
spec:
  replicas: 3  # Desired state
```

**Imperative**: You tell Kubernetes exactly what to do.
```bash
kubectl scale deployment my-app --replicas=3
```

### Desired State vs Actual State

- **Desired State**: What you want (defined in YAML)
- **Actual State**: What currently exists in the cluster
- **Controllers**: Continuously reconcile actual state to match desired state

### Watch and Informer Pattern

- Components watch the API Server for changes
- API Server streams updates via watch API
- Controllers react to changes immediately
- Efficient resource usage (no polling)

### Event-Driven Architecture

- All changes trigger events
- Components react to events
- Asynchronous processing
- Eventual consistency

## Best Practices

### Control Plane
- Run multiple API Server instances for HA
- Use etcd backups regularly
- Monitor control plane components
- Separate control plane from worker nodes

### Worker Nodes
- Use node selectors and taints for workload isolation
- Configure resource limits
- Monitor node health
- Use node auto-scaling

### Networking
- Use Network Policies for security
- Choose appropriate CNI plugin
- Configure service mesh if needed
- Monitor network performance

### Storage
- Use appropriate storage classes
- Implement backup strategies
- Monitor storage usage
- Use CSI drivers for cloud storage

## Troubleshooting

### Check Control Plane Status
```bash
kubectl get componentstatuses
kubectl get nodes
```

### Check Pod Status
```bash
kubectl get pods --all-namespaces
kubectl describe pod <pod-name>
kubectl logs <pod-name>
```

### Check Service Status
```bash
kubectl get services
kubectl get endpoints
kubectl describe service <service-name>
```

### Check Node Resources
```bash
kubectl top nodes
kubectl top pods
kubectl describe node <node-name>
```

### Debug Networking
```bash
# Check kube-proxy
kubectl get pods -n kube-system | grep kube-proxy

# Check DNS
kubectl get pods -n kube-system | grep coredns

# Test DNS resolution
kubectl run -it --rm debug --image=busybox --restart=Never -- nslookup kubernetes.default
```

## References

- [Kubernetes Official Documentation](https://kubernetes.io/docs/)
- [Kubernetes Components](https://kubernetes.io/docs/concepts/overview/components/)
- [Kubernetes Architecture](https://kubernetes.io/docs/concepts/architecture/)
