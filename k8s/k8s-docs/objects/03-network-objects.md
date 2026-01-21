# Network Objects

## Services

**Purpose**: Exposes a set of pods as a network service.

**How it works**:
- Provides stable IP address and DNS name
- Load balances traffic to pods
- Selects pods via labels
- Maintains endpoint list

**Service Types**:
- **ClusterIP**: Internal service (default)
- **NodePort**: Exposes on node IP
- **LoadBalancer**: Cloud load balancer
- **ExternalName**: Maps to external DNS

**Service Flow**:
```
Client → Service IP → kube-proxy → Pod IP
```

## Endpoints

**Purpose**: Tracks the IP addresses and ports of pods that match a Service selector.

**How it works**:
- Automatically created and maintained for Services
- Contains list of pod IPs and ports
- Updated when pods are created/deleted
- Used by kube-proxy for service routing

**Endpoint Flow**:
```
Service → Selector → Pods → Endpoints → kube-proxy
```

**Use Cases**:
- Service discovery
- Load balancing target selection
- Custom service implementations

## Ingresses

**Purpose**: Manages external HTTP/HTTPS access to services within the cluster.

**How it works**:
- Provides HTTP/HTTPS routing rules
- Routes traffic to services based on hostname and path
- Supports TLS termination
- Requires an Ingress Controller (e.g., NGINX, Traefik)

**Ingress Rules**:
- **Host-based routing**: Route by domain name
- **Path-based routing**: Route by URL path
- **TLS**: HTTPS termination

**Use Cases**:
- Exposing multiple services under one IP
- SSL/TLS termination
- URL-based routing
- Load balancing at application layer

## Ingress Classes

**Purpose**: Defines which Ingress Controller should handle an Ingress resource.

**How it works**:
- Groups Ingress resources by controller type
- Allows multiple Ingress Controllers in one cluster
- Ingress specifies which class to use
- Controller watches for Ingresses with matching class

**Use Cases**:
- Multiple Ingress Controllers (NGINX, Traefik, etc.)
- Different routing requirements
- Controller-specific configurations

## Network Policies

**Purpose**: Controls network traffic flow between pods and network endpoints.

**How it works**:
- Defines ingress and egress rules for pods
- Uses pod selectors to identify source/destination
- Acts as a firewall for pod-to-pod communication
- Requires CNI plugin with NetworkPolicy support

**Policy Types**:
- **Ingress Rules**: Control incoming traffic to pods
- **Egress Rules**: Control outgoing traffic from pods
- **Default Deny**: Block all traffic unless explicitly allowed

**Use Cases**:
- Micro-segmentation
- Security isolation between namespaces
- Compliance and security requirements
- Multi-tenant network isolation

## Port Forwarding

**Purpose**: Forwards network traffic from local machine to a pod in the cluster.

**How it works**:
- Creates a tunnel between local port and pod port
- Uses kubectl port-forward command
- Useful for debugging and local development
- Temporary connection (not a persistent service)

**Use Cases**:
- Local development and testing
- Debugging pod applications
- Accessing services not exposed externally
- Database connections for development
