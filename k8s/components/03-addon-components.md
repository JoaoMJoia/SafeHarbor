# Addon Components

Addons extend Kubernetes functionality with cluster-level features.

## DNS (CoreDNS)

**Purpose**: Provides DNS-based service discovery for the cluster.

**How it works**:
- Resolves service names to IP addresses
- Provides DNS records for services and pods
- Enables service discovery via DNS names

**DNS Resolution**:
```
<service-name>.<namespace>.svc.cluster.local
    │
    ▼
CoreDNS
    │
    ▼
Service IP
    │
    ▼
kube-proxy routes to Pod IP
```

**Interactions**:
```
Pod → CoreDNS (DNS query)
CoreDNS → API Server (watch services)
CoreDNS → Pod (DNS response)
```

## CNI (Container Network Interface) Plugin

**Purpose**: Provides networking for pods.

**How it works**:
- Assigns IP addresses to pods
- Configures network connectivity
- Implements network policies
- Handles pod-to-pod communication

**Common CNI Plugins**:
- **Calico**: Network policy and routing
- **Flannel**: Simple overlay network
- **Weave**: Network policy and encryption
- **AWS VPC CNI**: Native AWS networking

**Network Flow**:
```
Pod A → CNI Plugin → Network Interface
    │
    ▼
Cluster Network
    │
    ▼
CNI Plugin → Network Interface → Pod B
```

## CSI (Container Storage Interface) Driver

**Purpose**: Provides persistent storage for pods.

**How it works**:
- Provisions storage volumes
- Attaches volumes to nodes
- Mounts volumes to pods
- Manages volume lifecycle

**Storage Flow**:
```
Pod → PVC (Persistent Volume Claim)
    │
    ▼
CSI Driver
    │
    ├──► Provision Volume
    ├──► Attach to Node
    └──► Mount to Pod
```
