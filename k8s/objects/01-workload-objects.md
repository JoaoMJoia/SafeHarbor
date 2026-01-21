# Workload Objects

## Pods

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

## Deployments

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

## ReplicaSets

**Purpose**: Maintains a stable set of replica pods.

**How it works**:
- Ensures specified number of pods are running
- Creates/deletes pods to match desired count
- Uses pod selectors to identify pods

## Daemon Sets

**Purpose**: Ensures a copy of a pod runs on all (or specific) nodes in the cluster.

**How it works**:
- Creates one pod per node automatically
- New nodes get the pod when they join the cluster
- Pods are removed when nodes are removed
- Useful for system-level services (logging, monitoring, networking)

**Use Cases**:
- Log collection agents (Fluentd, Logstash)
- Monitoring agents (Prometheus node exporter)
- Network plugins (kube-proxy)
- Storage daemons

## Stateful Sets

**Purpose**: Manages stateful applications with stable network identities and persistent storage.

**How it works**:
- Maintains sticky identity for pods (stable hostname, persistent storage)
- Pods are created in order (0, 1, 2...)
- Pods are terminated in reverse order
- Each pod gets its own PersistentVolumeClaim
- Stable network identity via headless service

**Use Cases**:
- Databases (MySQL, PostgreSQL, MongoDB)
- Message queues (RabbitMQ, Kafka)
- Distributed systems requiring stable identities

## Jobs

**Purpose**: Creates one or more pods and ensures they complete successfully.

**How it works**:
- Runs pods until completion (not continuously)
- Retries failed pods until success or retry limit
- Pods are not restarted after completion
- Useful for batch processing and one-time tasks

**Job Types**:
- **Non-parallel**: One pod at a time
- **Parallel with fixed completion count**: Multiple pods, wait for N completions
- **Parallel with work queue**: Multiple pods processing from a queue

**Use Cases**:
- Data processing jobs
- Backup operations
- Database migrations
- One-time computations

## Cron Jobs

**Purpose**: Creates Jobs on a time-based schedule (cron format).

**How it works**:
- Runs Jobs on a schedule defined by cron expression
- Creates a new Job for each scheduled execution
- Maintains history of successful and failed jobs
- Can limit the number of concurrent jobs

**Cron Schedule Format**:
```
┌───────────── minute (0 - 59)
│ ┌───────────── hour (0 - 23)
│ │ ┌───────────── day of month (1 - 31)
│ │ │ ┌───────────── month (1 - 12)
│ │ │ │ ┌───────────── day of week (0 - 6)
│ │ │ │ │
* * * * *
```

**Use Cases**:
- Scheduled backups
- Periodic data synchronization
- Cleanup tasks
- Report generation
