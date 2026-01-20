# Kubernetes Components Documentation

This document provides a comprehensive explanation of how Kubernetes components work, their architecture, and how they interact with each other.

## Table of Contents

1. [Overview](#overview)
2. [Control Plane Components](#control-plane-components)
3. [Node Components](#node-components)
4. [Addon Components](#addon-components)
5. [Kubernetes Objects](#kubernetes-objects)
6. [Component Interactions](#component-interactions)
7. [Request Flow](#request-flow)
8. [Architecture Diagrams](#architecture-diagrams)

## Overview

Kubernetes is a container orchestration platform that manages containerized applications across a cluster of machines. The architecture consists of:

- **Control Plane**: The brain of Kubernetes that manages the cluster
- **Worker Nodes**: Machines that run your application containers
- **Pods**: The smallest deployable units in Kubernetes
- **Services**: Network abstraction for pods
- **Controllers**: Components that maintain desired state

## Control Plane Components

The control plane makes global decisions about the cluster and responds to cluster events.

### API Server (kube-apiserver)

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

### etcd

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

### Controller Manager (kube-controller-manager)

**Purpose**: Runs controller processes that regulate the state of the cluster.

**How it works**:
- Watches the desired state (from API Server)
- Compares with actual state
- Takes corrective actions to match desired state
- Runs multiple controllers in a single process

**Key Controllers**:

#### Replication Controller
- Maintains the correct number of pod replicas
- Creates/deletes pods to match desired count

#### Deployment Controller
- Manages deployments and replica sets
- Handles rolling updates and rollbacks

#### Node Controller
- Monitors node health
- Handles node failures and evictions

#### Service Controller
- Manages service endpoints
- Updates service-to-pod mappings

#### Endpoint Controller
- Populates Endpoint objects
- Links services to pods

#### Namespace Controller
- Manages namespace lifecycle
- Handles namespace deletion

**Interactions**:
```
Controller Manager → API Server → etcd (read desired state)
Controller Manager → API Server → etcd (write actual state)
Controller Manager → API Server → etcd (create/update/delete resources)
```

### Scheduler (kube-scheduler)

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

### Cloud Controller Manager (cloud-controller-manager)

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

## Node Components

Node components run on every node and maintain running pods and provide the Kubernetes runtime environment.

### kubelet

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

### kube-proxy

**Purpose**: Maintains network rules on nodes that allow network communication to your Pods.

**How it works**:
- Implements Kubernetes Service concept
- Maintains iptables rules (or IPVS) for service routing
- Routes traffic to backend pods
- Handles load balancing across pod endpoints

**Proxy Modes**:

#### iptables Mode (default)
- Uses iptables rules for routing
- No userspace process for traffic
- Better performance
- Load balancing via iptables

#### IPVS Mode
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

### Container Runtime

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

## Addon Components

Addons extend Kubernetes functionality with cluster-level features.

### DNS (CoreDNS)

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

### CNI (Container Network Interface) Plugin

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

### CSI (Container Storage Interface) Driver

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

## Kubernetes Objects

### Pods

**Purpose**: The smallest deployable unit in Kubernetes.

**How it works**:
- Contains one or more containers
- Shares network and storage
- Has a unique IP address
- Ephemeral by nature

**Pod Lifecycle**:
```
Pending → Running → Succeeded/Failed
    │
    ├──► ContainerCreating
    ├──► ImagePullBackOff
    └──► CrashLoopBackOff
```

### Services

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

### Deployments

**Purpose**: Manages ReplicaSets and provides declarative updates.

**How it works**:
- Maintains desired number of replicas
- Handles rolling updates
- Supports rollbacks
- Manages ReplicaSets

**Deployment Flow**:
```
Deployment → ReplicaSet → Pods
    │
    ├──► Desired: 3 replicas
    ├──► Current: 3 replicas
    └──► Ready: 3 replicas
```

### ReplicaSets

**Purpose**: Maintains a stable set of replica pods.

**How it works**:
- Ensures specified number of pods are running
- Creates/deletes pods to match desired count
- Uses pod selectors to identify pods

### ConfigMaps

**Purpose**: Stores non-confidential configuration data.

**How it works**:
- Key-value pairs
- Mounted as files or environment variables
- Updated without pod restart (if mounted as volume)

### Secrets

**Purpose**: Stores sensitive data (passwords, tokens, keys).

**How it works**:
- Base64 encoded (not encrypted by default)
- Mounted as files or environment variables
- Can be encrypted at rest (with encryption config)

## Component Interactions

### Pod Creation Flow

```
1. User → kubectl → API Server
   (Create Pod request)

2. API Server → etcd
   (Store Pod definition)

3. API Server → Scheduler
   (Notify new pod)

4. Scheduler → API Server → etcd
   (Bind pod to node)

5. API Server → kubelet (on node)
   (Notify pod assignment)

6. kubelet → Container Runtime
   (Create container)

7. kubelet → CNI Plugin
   (Configure network)

8. kubelet → CSI Driver
   (Mount volumes)

9. kubelet → API Server
   (Report pod status: Running)
```

### Service Discovery Flow

```
1. Pod A wants to reach Pod B via Service
   (DNS query: my-service.default.svc.cluster.local)

2. Pod A → CoreDNS
   (DNS resolution)

3. CoreDNS → API Server
   (Query service endpoints)

4. CoreDNS → Pod A
   (Return Service IP)

5. Pod A → Service IP
   (Network request)

6. kube-proxy → iptables rules
   (Route to Pod B IP)

7. Pod A → Pod B
   (Direct connection)
```

### Scaling Flow

```
1. User → kubectl → API Server
   (Scale deployment to 5 replicas)

2. API Server → etcd
   (Update desired replicas)

3. Deployment Controller → API Server
   (Watch deployment change)

4. Deployment Controller → API Server
   (Update ReplicaSet)

5. ReplicaSet Controller → API Server
   (Watch ReplicaSet change)

6. ReplicaSet Controller → API Server
   (Create 2 new pods)

7. Scheduler → API Server
   (Schedule new pods)

8. kubelet → Container Runtime
   (Start new containers)

9. kubelet → API Server
   (Report pod status)
```

## Request Flow

### External Request to Application

```
Internet
    │
    ▼
Load Balancer (Cloud Provider)
    │
    ▼
Service (NodePort/LoadBalancer)
    │
    ▼
kube-proxy (iptables rules)
    │
    ├──► Pod 1
    ├──► Pod 2
    └──► Pod 3
    (Load balanced)
```

### Internal Pod-to-Pod Communication

```
Pod A
    │
    ▼
Cluster Network (CNI)
    │
    ▼
Pod B
    (Direct connection via pod IPs)
```

### Pod-to-Service Communication

```
Pod A
    │
    ▼
Service DNS (CoreDNS)
    │
    ▼
Service IP
    │
    ▼
kube-proxy (iptables)
    │
    ▼
Pod B (selected by load balancing)
```

## Architecture Diagrams

### Complete Kubernetes Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Control Plane                         │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐             │
│  │API Server│  │Controller │  │Scheduler │             │
│  │          │  │ Manager   │  │          │             │
│  └──────────┘  └──────────┘  └──────────┘             │
│       │              │              │                   │
│       └──────────────┼──────────────┘                   │
│                      │                                  │
│                      ▼                                  │
│                 ┌────────┐                             │
│                 │ etcd   │                             │
│                 └────────┘                             │
└─────────────────────────────────────────────────────────┘
         │                    │                    │
         ▼                    ▼                    ▼
┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐
│   Worker Node 1 │  │   Worker Node 2 │  │   Worker Node 3 │
│  ┌──────────┐   │  │  ┌──────────┐   │  │  ┌──────────┐   │
│  │ kubelet  │   │  │  │ kubelet  │   │  │  │ kubelet  │   │
│  └──────────┘   │  │  └──────────┘   │  │  └──────────┘   │
│  ┌──────────┐   │  │  ┌──────────┐   │  │  ┌──────────┐   │
│  │kube-proxy│   │  │  │kube-proxy│   │  │  │kube-proxy│   │
│  └──────────┘   │  │  └──────────┘   │  │  └──────────┘   │
│  ┌──────────┐   │  │  ┌──────────┐   │  │  ┌──────────┐   │
│  │Container │   │  │  │Container │   │  │  │Container │   │
│  │ Runtime  │   │  │  │ Runtime  │   │  │  │ Runtime  │   │
│  └──────────┘   │  │  └──────────┘   │  │  └──────────┘   │
│  ┌──────────┐   │  │  ┌──────────┐   │  │  ┌──────────┐   │
│  │   Pods   │   │  │  │   Pods   │   │  │  │   Pods   │   │
│  └──────────┘   │  │  └──────────┘   │  │  └──────────┘   │
└─────────────────┘  └─────────────────┘  └─────────────────┘
```

### Component Communication Flow

```
┌─────────────────────────────────────────────────────────┐
│                    Client (kubectl)                      │
└─────────────────────────────────────────────────────────┘
         │
         │ HTTPS
         ▼
┌─────────────────────────────────────────────────────────┐
│                    API Server                            │
│  ┌──────────────────────────────────────────────────┐  │
│  │ Authentication → Authorization → Admission Control│  │
│  └──────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
         │                    │                    │
         │                    │                    │
         ▼                    ▼                    ▼
┌──────────────┐    ┌──────────────┐    ┌──────────────┐
│    etcd      │    │  Controller  │    │  Scheduler   │
│              │    │   Manager    │    │              │
└──────────────┘    └──────────────┘    └──────────────┘
         │                    │                    │
         │                    │                    │
         └────────────────────┼────────────────────┘
                              │
                              ▼
                    ┌──────────────┐
                    │   kubelet    │
                    │  (on nodes)  │
                    └──────────────┘
```

### Pod Lifecycle Management

```
┌─────────────────────────────────────────────────────────┐
│                    User/Controller                       │
│              (Create Pod Request)                        │
└─────────────────────────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────────────────────┐
│                    API Server                            │
│              (Validate & Store)                          │
└─────────────────────────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────────────────────┐
│                    Scheduler                             │
│              (Select Node)                               │
└─────────────────────────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────────────────────┐
│                    kubelet                               │
│  ┌──────────────────────────────────────────────────┐  │
│  │ 1. Pull Image                                    │  │
│  │ 2. Create Container                              │  │
│  │ 3. Setup Network (CNI)                          │  │
│  │ 4. Mount Volumes (CSI)                          │  │
│  │ 5. Start Container                              │  │
│  └──────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────────────────────┐
│                    Pod Running                           │
└─────────────────────────────────────────────────────────┘
```

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
