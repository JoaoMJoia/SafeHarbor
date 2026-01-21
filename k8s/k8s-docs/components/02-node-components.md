# Node Components

Node components run on every node and maintain running pods and provide the Kubernetes runtime environment.

## kubelet

**Purpose**: An agent that runs on each node in the cluster. It ensures containers are running in a Pod.

**How it works**:
1. Registers the node with the API Server
2. Watches for pods assigned to its node
3. Creates/updates/deletes containers via container runtime
4. Reports pod and node status to API Server
5. Executes liveness and readiness probes
6. Mounts volumes and secrets

**Key Responsibilities**:
- Pod lifecycle management
- Container health monitoring
- Volume mounting
- Image pulling
- Node status reporting

**Interactions**:
```
kubelet → API Server → etcd (register node, report status)
kubelet → Container Runtime (create/start/stop containers)
kubelet → CRI (Container Runtime Interface)
kubelet → CSI (Container Storage Interface)
kubelet → CNI (Container Network Interface)
```

## kube-proxy

**Purpose**: Maintains network rules on nodes that allow network communication to your Pods.

**How it works**:
- Implements Kubernetes Service concept
- Maintains iptables rules (or IPVS) for service routing
- Routes traffic to backend pods
- Handles load balancing across pod endpoints

**Proxy Modes**:

### iptables Mode (default)
- Uses iptables rules for routing
- No userspace process for traffic
- Better performance
- Load balancing via iptables

### IPVS Mode
- Uses IPVS (IP Virtual Server)
- Better performance for large clusters
- More load balancing algorithms

**Service Routing Flow**:
```
Client Request → Service IP
    │
    ▼
kube-proxy iptables rules
    │
    ├──► DNAT (Destination NAT)
    │
    ▼
Pod IP (selected by load balancing)
```

**Interactions**:
```
kube-proxy → API Server → etcd (watch services and endpoints)
kube-proxy → iptables/IPVS (update routing rules)
```

## Container Runtime

**Purpose**: The software responsible for running containers.

**How it works**:
- Receives requests from kubelet via CRI (Container Runtime Interface)
- Pulls container images
- Creates and manages container lifecycle
- Handles container isolation and resource limits

**Common Runtimes**:
- **containerd**: Industry-standard container runtime
- **CRI-O**: Lightweight runtime for Kubernetes
- **Docker**: Uses containerd as backend

**Container Runtime Interface (CRI)**:
- Standard API between kubelet and container runtime
- Defines operations: create, start, stop, remove containers
- Image management: pull, list, remove images

**Interactions**:
```
kubelet → CRI → Container Runtime
    │
    ├──► Pull image
    ├──► Create container
    ├──► Start container
    ├──► Stop container
    └──► Remove container
```
