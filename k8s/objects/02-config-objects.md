# Config Objects

## ConfigMaps

**Purpose**: Stores non-confidential configuration data.

**How it works**:
- Key-value pairs
- Mounted as files or environment variables
- Updated without pod restart (if mounted as volume)

## Secrets

**Purpose**: Stores sensitive data (passwords, tokens, keys).

**How it works**:
- Base64 encoded (not encrypted by default)
- Mounted as files or environment variables
- Can be encrypted at rest (with encryption config)

## Resource Quotas

**Purpose**: Limits the total amount of resources that can be consumed by namespaces.

**How it works**:
- Enforces limits on resource consumption per namespace
- Can limit compute resources (CPU, memory)
- Can limit object counts (pods, services, PVCs)
- Can limit storage resources
- Prevents resource exhaustion in shared clusters

**Resource Types**:
- **Compute Resources**: CPU, memory, ephemeral-storage
- **Storage Resources**: Persistent volume claims
- **Object Count**: Pods, services, configmaps, secrets, etc.

**Use Cases**:
- Multi-tenant clusters
- Resource isolation between teams
- Cost control and capacity planning

## Limit Ranges

**Purpose**: Constrains resource limits and requests per pod or container in a namespace.

**How it works**:
- Sets default resource requests/limits for containers
- Sets default resource requests/limits for pods
- Sets min/max constraints on resources
- Validates resource requests at pod creation
- Applies to individual containers and pods

**Use Cases**:
- Enforcing resource policies
- Preventing resource starvation
- Setting sensible defaults for developers

## Horizontal Pod Autoscalers (HPA)

**Purpose**: Automatically scales the number of pods based on observed CPU/memory utilization or custom metrics.

**How it works**:
- Monitors pod metrics (CPU, memory, custom metrics)
- Scales up when metrics exceed target threshold
- Scales down when metrics are below threshold
- Works with Deployments, ReplicaSets, StatefulSets
- Requires Metrics Server or custom metrics API

**Scaling Behavior**:
- **Scale Up**: Increases replicas when metrics > target
- **Scale Down**: Decreases replicas when metrics < target
- **Cooldown Periods**: Prevents rapid scaling oscillations

**Use Cases**:
- Applications with variable load
- Cost optimization (scale down during low traffic)
- Handling traffic spikes automatically

## Pod Disruption Budgets (PDB)

**Purpose**: Limits the number of pods that can be voluntarily disrupted during maintenance operations.

**How it works**:
- Specifies minimum available pods (or maximum unavailable)
- Protects pods during voluntary disruptions (drain, eviction)
- Does not protect against involuntary disruptions (node failure)
- Ensures high availability during cluster maintenance

**Use Cases**:
- Ensuring minimum service availability during updates
- Protecting critical workloads during node drains
- Maintaining service level agreements (SLAs)

## Priority Classes

**Purpose**: Defines the relative importance of pods for scheduling and preemption.

**How it works**:
- Assigns priority values to pods
- Higher priority pods can preempt lower priority pods
- Affects pod scheduling order
- Used by scheduler to make decisions

**Use Cases**:
- Critical workloads (high priority)
- Best-effort workloads (low priority)
- Preempting less important pods when resources are scarce

## Runtime Classes

**Purpose**: Defines different container runtime configurations for pods.

**How it works**:
- Allows pods to use different container runtimes
- Configures runtime-specific settings (e.g., Kata Containers, gVisor)
- Provides additional security isolation
- Requires runtime handler to be configured on nodes

**Use Cases**:
- Multi-runtime clusters
- Enhanced security isolation (gVisor, Kata)
- Specialized workloads requiring specific runtimes

## Leases

**Purpose**: Provides distributed locking mechanism for coordination between components.

**How it works**:
- Used for leader election and coordination
- Components acquire and renew leases
- Lease expiration indicates component failure
- Used internally by kube-controller-manager, kube-scheduler

**Use Cases**:
- Leader election in controller managers
- Component coordination
- Distributed system coordination

## Mutating Webhook Configurations

**Purpose**: Defines webhooks that modify objects before they are stored in etcd.

**How it works**:
- Intercepts API requests before persistence
- Can modify object specifications
- Runs before validation
- Used for defaulting values, injecting sidecars, etc.

**Use Cases**:
- Automatic sidecar injection (Istio, Linkerd)
- Setting default values
- Adding annotations or labels automatically

## Validating Webhook Configurations

**Purpose**: Defines webhooks that validate objects before they are stored in etcd.

**How it works**:
- Intercepts API requests before persistence
- Validates object specifications
- Can reject invalid objects
- Runs after mutating webhooks

**Use Cases**:
- Enforcing custom policies
- Validating resource constraints
- Security policy enforcement
- Compliance checks
