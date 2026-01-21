# Control Plane Components

The control plane makes global decisions about the cluster and responds to cluster events.

## API Server (kube-apiserver)

**Purpose**: The front-end for the Kubernetes control plane. All communication goes through the API Server.

**How it works**:
- Exposes the Kubernetes API (RESTful API)
- Validates and processes API requests
- Updates etcd with the current state
- Acts as the single source of truth for the cluster state
- Handles authentication, authorization, and admission control

**Key Features**:
- RESTful API interface
- Horizontal scaling (multiple instances)
- State management via etcd
- Request validation and transformation

**Interactions**:
```
Client (kubectl) → API Server → etcd (read/write)
Controller Manager → API Server → etcd (read/write)
Scheduler → API Server → etcd (read)
kubelet → API Server → etcd (read/watch)
```

## etcd

**Purpose**: Consistent and highly-available key-value store used as Kubernetes' backing store for all cluster data.

**How it works**:
- Stores all cluster state (pods, services, deployments, etc.)
- Uses Raft consensus algorithm for consistency
- Provides watch functionality for real-time updates
- Only the API Server communicates directly with etcd

**Key Features**:
- Distributed key-value store
- Strong consistency guarantees
- Watch API for change notifications
- Backup and restore capabilities

**Data Stored**:
- Cluster configuration
- Pod definitions
- Service endpoints
- Secrets and ConfigMaps
- Deployment state
- Node information

## Controller Manager (kube-controller-manager)

**Purpose**: Runs controller processes that regulate the state of the cluster.

**How it works**:
- Watches the desired state (from API Server)
- Compares with actual state
- Takes corrective actions to match desired state
- Runs multiple controllers in a single process

**Key Controllers**:

### Replication Controller
- Maintains the correct number of pod replicas
- Creates/deletes pods to match desired count

### Deployment Controller
- Manages deployments and replica sets
- Handles rolling updates and rollbacks

### Node Controller
- Monitors node health
- Handles node failures and evictions

### Service Controller
- Manages service endpoints
- Updates service-to-pod mappings

### Endpoint Controller
- Populates Endpoint objects
- Links services to pods

### Namespace Controller
- Manages namespace lifecycle
- Handles namespace deletion

**Interactions**:
```
Controller Manager → API Server → etcd (read desired state)
Controller Manager → API Server → etcd (write actual state)
Controller Manager → API Server → etcd (create/update/delete resources)
```

## Scheduler (kube-scheduler)

**Purpose**: Assigns newly created pods to nodes based on resource requirements and constraints.

**How it works**:
1. Watches for new pods with no assigned node
2. Filters nodes based on:
   - Resource requirements (CPU, memory)
   - Node selectors and affinity rules
   - Taints and tolerations
   - Pod anti-affinity rules
3. Scores remaining nodes
4. Selects the best node
5. Binds the pod to the node

**Scheduling Process**:
```
New Pod Created
    │
    ▼
Filter Nodes (feasible nodes)
    │
    ├──► Resource requirements met?
    ├──► Node selectors match?
    ├──► Taints/tolerations compatible?
    └──► Affinity rules satisfied?
    │
    ▼
Score Nodes (best node)
    │
    ├──► Resource availability
    ├──► Affinity preferences
    ├──► Anti-affinity penalties
    └──► Other factors
    │
    ▼
Bind Pod to Node
    │
    ▼
kubelet on node starts pod
```

**Interactions**:
```
Scheduler → API Server → etcd (watch for unscheduled pods)
Scheduler → API Server → etcd (bind pod to node)
```

## Cloud Controller Manager (cloud-controller-manager)

**Purpose**: Links your cluster into your cloud provider's API.

**How it works**:
- Runs controllers specific to your cloud provider
- Manages cloud resources (load balancers, routes, volumes)
- Separates cloud-specific logic from core Kubernetes

**Key Controllers**:
- **Node Controller**: Updates node information from cloud provider
- **Route Controller**: Configures routes in cloud
- **Service Controller**: Creates/updates cloud load balancers
- **Volume Controller**: Manages cloud storage volumes
