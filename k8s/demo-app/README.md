# Demo App - Kubernetes Deployment

This is a simple demo application demonstrating a Kubernetes deployment with associated components.

## Components

### Namespace (`namespace.yaml`)
- **Name**: `demo-app` - Isolated namespace for the demo application
- Provides resource isolation and organization
- All resources are deployed to this namespace

### Deployment (`deployment.yaml`)
- **Image**: `hashicorp/http-echo:latest` - A simple HTTP server that echoes text
- **Replicas**: 3 pods for high availability
- **Port**: 8080 (container port)
- **Resources**: 
  - Requests: 64Mi memory, 100m CPU
  - Limits: 128Mi memory, 200m CPU
- **Health Checks**:
  - Liveness probe: Checks if container is alive
  - Readiness probe: Checks if container is ready to serve traffic

### Service (`service.yaml`)
- **Type**: ClusterIP (internal cluster access)
- **Port**: 80 (service port) → 8080 (target port)
- **Session Affinity**: ClientIP (sticky sessions)

### ConfigMap (`configmap.yaml`)
- Contains application configuration data
- Can be mounted as environment variables or files

## Usage

### Deploy the application:
```bash
kubectl apply -f k8s/demo-app/
```

### Check deployment status:
```bash
# All resources are in the demo-app namespace
kubectl get deployments -n demo-app
kubectl get pods -n demo-app -l app=demo-app
kubectl get svc -n demo-app demo-app-service
kubectl get all -n demo-app
```

### Access the application:
```bash
# Port forward to access locally (specify namespace)
kubectl port-forward -n demo-app svc/demo-app-service 8080:80

# Then access via browser or curl
curl http://localhost:8080
```

### Test from within the cluster:
```bash
# Run a temporary pod in the demo-app namespace
kubectl run curl-test -n demo-app --image=curlimages/curl:latest --rm -it --restart=Never -- sh

# Inside the pod, test the service (using namespace in FQDN)
curl http://demo-app-service.demo-app.svc.cluster.local
# Or just the service name (if in same namespace)
curl http://demo-app-service
```

### Scale the deployment:
```bash
kubectl scale deployment demo-app -n demo-app --replicas=5
```

### View logs:
```bash
kubectl logs -n demo-app -l app=demo-app --tail=50
```

### Delete the application:
```bash
kubectl delete -f k8s/demo-app/
```

## Key Features

1. **Namespace**: Provides resource isolation and logical grouping
2. **Deployment**: Manages pod replicas, rolling updates, rollbacks
3. **Service**: Provides stable network endpoint and load balancing
4. **ConfigMap**: Externalizes configuration from container image
5. **Health Probes**: Ensures only healthy pods receive traffic
6. **Resource Limits**: Prevents resource exhaustion
7. **Labels & Selectors**: Used for service discovery and management
8. **Session Affinity**: Useful for stateful applications

## Optional Enhancements

For more advanced use cases, you could add:
- **Ingress**: External access via HTTP/HTTPS
- **HorizontalPodAutoscaler**: Auto-scaling based on metrics
- **PodDisruptionBudget**: Ensures availability during disruptions
- **NetworkPolicy**: Network security policies
- **Secret**: For sensitive configuration data
