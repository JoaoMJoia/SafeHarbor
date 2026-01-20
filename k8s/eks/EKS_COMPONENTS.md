# EKS Components Documentation

This document provides a comprehensive overview of all EKS pods and components deployed in the cluster, including architecture diagrams, user flows, and component interactions.

## Table of Contents

1. [Overview](#overview)
2. [Component Categories](#component-categories)
3. [Architecture Diagrams](#architecture-diagrams)
4. [Component Interactions](#component-interactions)
5. [User Flows](#user-flows)
6. [Data Flows](#data-flows)
7. [Component Details](#component-details)

## Overview

The EKS cluster is composed of three main categories of components:

- **EKS Addons**: Core infrastructure components for load balancing, storage, and secrets management
- **EKS Configurations**: Operational tools for cluster management, security, and backup
- **Observability Stack**: Complete monitoring, logging, and alerting solution

## Component Categories

### EKS Addons (Infrastructure Components)

| Component | Namespace | Purpose |
|-----------|-----------|---------|
| AWS Load Balancer Controller | `kube-system` | Manages AWS ALB/NLB for Kubernetes services |
| EFS CSI Driver | `kube-system` | Provides EFS persistent storage for pods |
| Secrets Store CSI Driver | `kube-system` | Integrates Kubernetes with external secret stores |
| Secrets Provider AWS | `kube-system` | AWS provider for Secrets Store CSI Driver |
| Target Group Bindings | `infrastructure` | Binds Kubernetes services to ALB target groups |

### EKS Configurations (Cluster Management)

| Component | Namespace | Purpose |
|-----------|-----------|---------|
| Cluster Autoscaler | `kube-system` | Automatically scales cluster nodes |
| Trivy Operator | `trivy-system` | Security scanning for container images |
| Velero | `infrastructure` | Backup and disaster recovery |

### Observability Stack (Monitoring & Logging)

| Component | Namespace | Purpose |
|-----------|-----------|---------|
| Prometheus | `infrastructure` | Metrics collection and storage |
| Grafana | `infrastructure` | Visualization and dashboards |
| Alertmanager | `infrastructure` | Alert routing and notification |
| Prometheus Operator | `infrastructure` | Manages Prometheus and Alertmanager |
| Loki | `infrastructure` | Log aggregation and storage |
| Promtail | `infrastructure` | Log collection agent |
| Thanos | `infrastructure` | Long-term metrics storage |
| Grafana Alloy | `infrastructure` | Telemetry collector |
| Blackbox Exporter | `infrastructure` | External endpoint monitoring |
| Prometheus MSTeams | `infrastructure` | MS Teams alert connector |

## Architecture Diagrams

### 1. System Overview - Three Main Layers
```
┌─────────────────────────────────────────────────────────┐
│                    EKS Cluster                          │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  ┌──────────────────┐  ┌──────────────────┐          │
│  │ Application Pods │  │ Infrastructure    │          │
│  │                  │  │ - Load Balancer  │          │
│  │                  │  │ - EFS Driver      │          │
│  │                  │  │ - Secrets        │          │
│  └──────────────────┘  └──────────────────┘          │
│                                                          │
│  ┌──────────────────┐  ┌──────────────────┐          │
│  │ Operations       │  │ Observability    │          │
│  │ - Autoscaler     │  │ - Prometheus     │          │
│  │ - Velero         │  │ - Grafana        │          │
│  │ - Trivy          │  │ - Loki           │          │
│  └──────────────────┘  └──────────────────┘          │
│                                                          │
└─────────────────────────────────────────────────────────┘
         │                    │                    │
         ▼                    ▼                    ▼
┌──────────────┐    ┌──────────────┐    ┌──────────────┐
│ AWS Services │    │ AWS Services │    │ AWS Services │
│ - ALB        │    │ - EFS        │    │ - S3         │
│ - Secrets    │    │              │    │              │
└──────────────┘    └──────────────┘    └──────────────┘
```

### 2. How Users Access Applications
```
User (Browser)
    │
    ▼
AWS Load Balancer (Public Internet)
    │
    ▼
Target Group (Routes Traffic)
    │
    ▼
Kubernetes Service (Internal)
    │
    ▼
Application Pod (Runs Your App)
```

### 3. How Applications Get Storage
```
Application Pod (Needs Storage)
    │
    ▼
Persistent Volume Claim (Request Storage)
    │
    ▼
EFS CSI Driver (Kubernetes Component)
    │
    ▼
AWS EFS (Shared File System)
    │
    └─────────────────┐
                      │ (Mounts back to Pod)
                      ▼
              Application Pod
```

### 4. How Applications Get Secrets
```
Application Pod (Needs Secret)
    │
    ▼
Secrets Store CSI Driver (Kubernetes)
    │
    ▼
Secrets Provider AWS (AWS Integration)
    │
    ▼
AWS Secrets Manager (Stores Secrets)
    │
    └─────────────────┐
                      │ (Returns Secret)
                      ▼
              Secrets Provider AWS
                      │
                      │ (Mounts as File)
                      ▼
              Application Pod
```

### 5. Metrics Collection Flow (Simple View)
```
Application Pod (Exposes /metrics)
    │
    ├─────────────────┐
    │                 │
    ▼                 ▼
Prometheus        Grafana
(Collects         (Dashboards)
 Every 30s)           │
    │                 │
    ├──► Local Storage│
    │    (3 days)     │
    │                 │
    ▼                 │
Thanos Receive        │
(Long-term)           │
    │                 │
    ▼                 │
S3 Bucket ◄───────────┘
(Months of Data)
```

### 6. Log Collection Flow (Simple View)
```
Application Pod (Writes to stdout/stderr)
    │
    ▼
Promtail (Log Collector)
    │
    ▼
Loki (Log Storage)
    │
    ├─────────────────┐
    │                 │
    ▼                 │
S3 Bucket        Grafana
(Long-term)      (Dashboards)
    │                 │
    └─────────────────┘
```

### 7. Alert Flow (Simple View)
```
Prometheus (Monitors Metrics)
    │
    ├──► Threshold Exceeded
    │
    ▼
Alertmanager (Routes Alerts)
    │
    ▼
Prometheus MSTeams (Formats Message)
    │
    ▼
Microsoft Teams (Notification)
    │
    │
    └──► User receives alert
         │
         ▼
    Grafana (User Views)
         │
         └──► Queries Prometheus for details
```

### 8. Observability Stack - Complete Picture
```
┌─────────────────────────────────────────────────────────┐
│                    Data Sources                         │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐ │
│  │ Application │  │ Kubernetes   │  │ External     │ │
│  │ Pods         │  │ Components   │  │ Services     │ │
│  └──────────────┘  └──────────────┘  └──────────────┘ │
└─────────────────────────────────────────────────────────┘
         │                    │                    │
         ▼                    ▼                    ▼
┌─────────────────────────────────────────────────────────┐
│              Collection Layer                           │
│  ┌────────┐  ┌────────┐  ┌────────┐  ┌──────────────┐ │
│  │Promtail│  │ Alloy  │  │Blackbox│  │ Prometheus   │ │
│  │(Logs)  │  │(Tele.)│  │(Ext.)  │  │ (Metrics)    │ │
│  └────────┘  └────────┘  └────────┘  └──────────────┘ │
└─────────────────────────────────────────────────────────┘
         │                    │                    │
         ▼                    ▼                    ▼
┌─────────────────────────────────────────────────────────┐
│              Storage Layer                              │
│  ┌──────────┐  ┌──────────┐  ┌──────────────────────┐  │
│  │   Loki   │  │  Thanos  │  │    S3 Buckets       │  │
│  │(Logs)    │  │(Metrics) │  │                      │  │
│  └──────────┘  └──────────┘  └──────────────────────┘  │
└─────────────────────────────────────────────────────────┘
         │                    │                    │
         └────────────────────┼────────────────────┘
                              │
                              ▼
                    ┌─────────────────┐
                    │     Grafana     │
                    │  (Dashboards)   │
                    └─────────────────┘
```

## Component Interactions

### Request Flow: User → Application

```
1. User → ALB: HTTP Request
2. ALB → Target Group: Route to Target
3. Target Group → Kubernetes Service: Forward Request
4. Kubernetes Service → Application Pod
5. Application Pod: Process Request
6. Application Pod → Kubernetes Service: Return Response
7. Kubernetes Service → Target Group: Forward Response
8. Target Group → ALB: Return to ALB
9. ALB → User: HTTP Response
```

### Metrics Collection Flow

```
1. Application Pod → Prometheus: Expose /metrics
2. Prometheus: Scrape (every 30s)
3. Prometheus → Thanos Receive: Send Metrics
4. Thanos Receive → S3: Store Long-term
5. Grafana → Prometheus: Query Current Metrics
6. Grafana → Thanos: Query Historical Metrics
7. Prometheus → Grafana: Return Data
8. Thanos → Grafana: Return Historical Data
```

### Log Collection Flow

```
1. Application Pod: Write Logs (stdout)
2. Promtail → Application Pod: Discover Pod
3. Promtail → Application Pod: Collect Logs
4. Promtail: Add Labels
5. Promtail → Loki: Push Logs
6. Loki → S3: Store in S3
7. Grafana → Loki: Query Logs
8. Loki → S3: Retrieve from S3
9. Loki → Grafana: Return Results
```

### Alert Flow

```
1. Prometheus: Evaluate Rules
2. Prometheus → Alertmanager: Send Alert
3. Alertmanager: Group & Route
4. Alertmanager → MSTeams: Send Webhook
5. MSTeams → Teams: Format & Send
6. Teams → User: Show Notification
7. User → Grafana: Investigate
8. Grafana → Prometheus: Query Metrics
```

### Secrets Management Flow

```
1. Application Pod → CSI Driver: Request Secret Mount
2. CSI Driver → AWS Provider: Call Provider
3. AWS Provider → Secrets Manager: Get Secret (IAM)
4. Secrets Manager → AWS Provider: Return Secret
5. AWS Provider → CSI Driver: Provide Data
6. CSI Driver → Application Pod: Mount as Volume
7. Application Pod: Read Secret File
```

### Backup Flow (Velero)

```
Schedule: Daily at Midnight

1. Velero → Kubernetes API: Discover Resources
2. Velero → Kubernetes API: Backup Definitions
3. Velero → EBS: Snapshot Volumes
4. Velero → S3: Upload Backup

Retention: 5 days
```

## User Flows

### Developer Accessing Logs

```
Start: Developer needs logs
    │
    ▼
Login to Grafana (via Azure AD)
    │
    ▼
Select Loki datasource
    │
    ▼
Write LogQL query (e.g., namespace=prod)
    │
    ▼
View log results
    │
    ├──► Found issue? ──No──► Write LogQL query
    │
    Yes
    │
    ▼
Export logs
    │
    ▼
Share with team
    │
    ▼
End: Issue resolved
```

### Monitoring Application

```
Start: Monitor application
    │
    ▼
Open Grafana dashboard
    │
    ▼
View metrics
    │
    ├──► Alert triggered? ──No──► View metrics
    │
    Yes
    │
    ▼
Receive MS Teams notification
    │
    ▼
Investigate in Grafana
    │
    ▼
Check logs in Loki
    │
    ▼
Take action
    │
    ▼
End: Issue resolved
```

### Security Scanning

```
Start: New image deployed
    │
    ▼
Trivy detects image
    │
    ▼
Scan for vulnerabilities
    │
    ├──► Vulnerabilities found? ──No──► End: All clear
    │
    Yes
    │
    ▼
Generate report
    │
    ▼
Expose to Prometheus
    │
    ▼
Show in Grafana
    │
    ▼
Developer fixes
    │
    ▼
End: Resolved
```

## Data Flows

### Complete Observability Data Flow

```
┌─────────────────────────────────────────────────────────┐
│              Data Sources                                │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐ │
│  │ Application │  │ Kubernetes   │  │ External     │ │
│  │ Pods         │  │              │  │ Services     │ │
│  └──────────────┘  └──────────────┘  └──────────────┘ │
└─────────────────────────────────────────────────────────┘
         │                    │                    │
         ▼                    ▼                    ▼
┌─────────────────────────────────────────────────────────┐
│              Collection                                 │
│  ┌────────┐  ┌────────┐  ┌────────┐  ┌──────────────┐ │
│  │Promtail│  │ Alloy  │  │Blackbox│  │ Prometheus   │ │
│  └────────┘  └────────┘  └────────┘  └──────────────┘ │
└─────────────────────────────────────────────────────────┘
         │                    │                    │
         ▼                    ▼                    ▼
┌─────────────────────────────────────────────────────────┐
│              Processing                                 │
│  ┌──────────┐  ┌──────────┐                           │
│  │   Loki   │  │  Thanos  │                           │
│  └──────────┘  └──────────┘                           │
└─────────────────────────────────────────────────────────┘
         │                    │
         ▼                    ▼
┌─────────────────────────────────────────────────────────┐
│              Storage                                    │
│  ┌──────────────┐  ┌──────────────┐                   │
│  │ S3 - Logs    │  │ S3 - Metrics │                   │
│  └──────────────┘  └──────────────┘                   │
└─────────────────────────────────────────────────────────┘
         │                    │
         └────────────────────┼────────────────────┐
                              │                    │
                              ▼                    ▼
                    ┌─────────────────┐  ┌─────────────────┐
                    │     Grafana     │  │   Alertmanager  │
                    │  (Dashboards)   │  │                 │
                    └─────────────────┘  └─────────────────┘
                              │                    │
                              │                    ▼
                              │            ┌─────────────────┐
                              │            │    MSTeams      │
                              │            └─────────────────┘
                              │                    │
                              │                    ▼
                              │            ┌─────────────────┐
                              │            │   MS Teams      │
                              │            └─────────────────┘
```

## Component Details

### EKS Addons

#### AWS Load Balancer Controller
- **Purpose**: Manages AWS Application Load Balancers (ALB) and Network Load Balancers (NLB) for Kubernetes services
- **Key Features**:
  - Automatic ALB/NLB provisioning
  - SSL/TLS termination
  - Health check management
  - Security group management
- **Interactions**:
  - Creates and manages ALB/NLB resources in AWS
  - Binds Kubernetes services to target groups
  - Monitors ingress resources for load balancer creation

#### EFS CSI Driver
- **Purpose**: Provides Amazon EFS as persistent storage for Kubernetes pods
- **Key Features**:
  - Dynamic volume provisioning
  - Multi-AZ support
  - Encryption support
  - Access point management
- **Interactions**:
  - Provisions EFS access points for PVCs
  - Mounts EFS volumes to pods
  - Manages volume lifecycle

#### Secrets Store CSI Driver & Provider
- **Purpose**: Integrates Kubernetes with AWS Secrets Manager
- **Key Features**:
  - External secret mounting
  - Kubernetes secret syncing
  - Secret rotation support
  - IAM-based authentication
- **Interactions**:
  - Retrieves secrets from AWS Secrets Manager
  - Mounts secrets as volumes in pods
  - Optionally syncs to Kubernetes secrets

### EKS Configurations

#### Cluster Autoscaler
- **Purpose**: Automatically adjusts the number of nodes in the cluster
- **Key Features**:
  - Automatic node scaling
  - Cost optimization
  - Pod disruption protection
  - Multi-node group support
- **Interactions**:
  - Monitors pod scheduling needs
  - Communicates with AWS Auto Scaling Groups
  - Exposes metrics to Prometheus

#### Trivy Operator
- **Purpose**: Security scanning for container images and Kubernetes resources
- **Key Features**:
  - Vulnerability scanning
  - Configuration scanning
  - Compliance reporting
  - Prometheus metrics
- **Interactions**:
  - Scans images on deployment
  - Generates vulnerability reports
  - Exposes metrics to Prometheus
  - Creates vulnerability CRDs

#### Velero
- **Purpose**: Backup and disaster recovery for Kubernetes clusters
- **Key Features**:
  - Application backup
  - Scheduled backups
  - Volume snapshots
  - Cross-region backup
- **Interactions**:
  - Backs up cluster resources to S3
  - Creates EBS volume snapshots
  - Restores applications on demand

### Observability Stack

#### Prometheus
- **Purpose**: Metrics collection and storage
- **Key Features**:
  - Service discovery
  - PromQL query language
  - Alert rule evaluation
  - Remote write support
- **Interactions**:
  - Scrapes metrics from targets
  - Stores metrics locally (3-day retention)
  - Sends metrics to Thanos Receive
  - Evaluates alert rules
  - Exposes metrics via API

#### Grafana
- **Purpose**: Visualization and dashboards
- **Key Features**:
  - Multi-datasource support
  - Azure AD SSO
  - Dashboard management
  - Alert management
- **Interactions**:
  - Queries Prometheus for metrics
  - Queries Loki for logs
  - Queries Thanos for historical metrics
  - Integrates with CloudWatch and GitHub
  - Sends alerts to MS Teams

#### Loki
- **Purpose**: Log aggregation and storage
- **Key Features**:
  - LogQL query language
  - S3 storage backend
  - Multi-tenant support
  - High availability
- **Interactions**:
  - Receives logs from Promtail
  - Stores logs in S3
  - Serves log queries to Grafana
  - Manages log retention

#### Thanos
- **Purpose**: Long-term metrics storage and querying
- **Components**:
  - **Query**: Aggregates metrics from multiple sources
  - **Query Frontend**: Caches and optimizes queries
  - **Receive**: Accepts remote writes from Prometheus
  - **Store Gateway**: Queries historical data from S3
  - **Compactor**: Compacts and deduplicates data
- **Interactions**:
  - Receives metrics from Prometheus
  - Stores metrics in S3
  - Serves historical queries to Grafana
  - Compacts data for efficiency

#### Promtail
- **Purpose**: Log collection agent
- **Key Features**:
  - Kubernetes service discovery
  - Automatic label assignment
  - Log relabeling
  - High performance
- **Interactions**:
  - Discovers pods via Kubernetes API
  - Collects logs from pod stdout/stderr
  - Sends logs to Loki

#### Blackbox Exporter
- **Purpose**: External endpoint monitoring
- **Key Features**:
  - HTTP/HTTPS checks
  - DNS checks
  - TCP checks
  - ICMP checks
- **Interactions**:
  - Probes external endpoints
  - Exposes metrics to Prometheus
  - Monitors production and dev applications

#### Grafana Alloy
- **Purpose**: Telemetry collector
- **Key Features**:
  - Metrics collection
  - Log collection
  - Trace collection
  - Faro Web SDK receiver
- **Interactions**:
  - Collects telemetry from applications
  - Forwards to Prometheus and Loki
  - Receives frontend telemetry via Faro

#### Prometheus MSTeams
- **Purpose**: MS Teams alert connector
- **Key Features**:
  - Alert formatting
  - Multiple channel support
  - Webhook integration
- **Interactions**:
  - Receives alerts from Alertmanager
  - Formats alerts for MS Teams
  - Sends notifications to Teams channels

## Network Architecture

### How Services Are Exposed

```
Internet
    │
    ▼
AWS Load Balancer (Public)
    │
    ├─────────────────┬─────────────────┐
    │                 │                 │
    ▼                 ▼                 ▼
Grafana Service    Prometheus Service  Loki Service
Port 30100         Port 30300          Port 30200
    │                 │                 │
    ▼                 ▼                 ▼
Grafana Pod        Prometheus Pod      Loki Pod
```

## Storage Architecture

### Persistent Storage Flow

```
Application Pod
    │
    ▼
Persistent Volume Claim
    │
    ▼
EFS CSI Driver
    │
    ▼
EFS Access Point
    │
    ▼
AWS EFS File System
```

## Security Architecture

### IAM Roles for Service Accounts

```
┌─────────────────────────────────────────────────────────┐
│              Kubernetes                                  │
│  ┌──────────────────┐  ┌──────────────────┐          │
│  │ Service Account  │  │ Service Account  │          │
│  │ ALB Controller   │  │ EFS Driver       │          │
│  └──────────────────┘  └──────────────────┘          │
│  ┌──────────────────┐  ┌──────────────────┐          │
│  │ Service Account  │  │ Service Account  │          │
│  │ Velero           │  │ Loki             │          │
│  └──────────────────┘  └──────────────────┘          │
│  ┌──────────────────┐                                │
│  │ Service Account  │                                │
│  │ Thanos           │                                │
│  └──────────────────┘                                │
└─────────────────────────────────────────────────────────┘
         │                    │                    │
         │ (IRSA)             │ (IRSA)            │ (IRSA)
         ▼                    ▼                    ▼
┌─────────────────────────────────────────────────────────┐
│              AWS IAM                                     │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐              │
│  │IAM Role 1│  │IAM Role 2│  │IAM Role 3│              │
│  └──────────┘  └──────────┘  └──────────┘              │
│  ┌──────────┐  ┌──────────┐                            │
│  │IAM Role 4│  │IAM Role 5│                            │
│  └──────────┘  └──────────┘                            │
└─────────────────────────────────────────────────────────┘
         │                    │                    │
         ▼                    ▼                    ▼
┌─────────────────────────────────────────────────────────┐
│              AWS Services                               │
│  ┌──────────┐  ┌──────────┐  ┌──────────────┐         │
│  │ ALB/NLB  │  │   EFS    │  │ S3 Buckets   │         │
│  └──────────┘  └──────────┘  └──────────────┘         │
└─────────────────────────────────────────────────────────┘
```

## Resource Allocation

### Node Placement Strategy

Most infrastructure components are configured to run on nodes labeled with `node-role: helper`:

- **Helper Nodes**: Dedicated nodes for infrastructure components
  - Grafana
  - Prometheus
  - Loki
  - Thanos components
  - Cluster Autoscaler
  - Trivy Operator
  - Velero

- **Application Nodes**: Regular nodes for application workloads
  - Application pods
  - EFS CSI Driver (daemonset on all nodes)
  - Secrets Store CSI Driver (daemonset on all nodes)
  - Promtail (daemonset on all nodes)

## Best Practices

### High Availability
- Multiple replicas for critical components (Loki: 2 replicas, Prometheus: HA via Thanos)
- Node affinity to distribute pods across nodes
- Persistent storage for stateful components

### Security
- IAM roles for service accounts (IRSA) for AWS service access
- Network policies for pod-to-pod communication
- Secrets stored in AWS Secrets Manager
- Azure AD SSO for Grafana access

### Performance
- Resource limits and requests configured for all components
- Storage optimization with appropriate retention policies
- Query optimization with Thanos query frontend
- Log retention and compaction strategies

### Reliability
- Automated backups with Velero
- Health checks and readiness probes
- Alerting on component failures
- Monitoring of the monitoring stack itself

## Troubleshooting Quick Reference

### Check Component Status
```bash
# EKS Addons
kubectl get pods -n kube-system | grep -E "(aws-load-balancer|efs-csi|secrets-store)"

# EKS Configurations
kubectl get pods -n kube-system | grep cluster-autoscaler
kubectl get pods -n infrastructure | grep velero
kubectl get pods -n trivy-system

# Observability Stack
kubectl get pods -n infrastructure | grep -E "(prometheus|grafana|loki|thanos)"
```

### Access Services
```bash
# Grafana
kubectl port-forward -n infrastructure svc/prometheus-grafana-grafana 3000:80

# Prometheus
kubectl port-forward -n infrastructure svc/prometheus-grafana-kube-pr-prometheus 9090:9090

# Loki
kubectl port-forward -n infrastructure svc/loki-gateway 3100:80
```

### View Logs
```bash
# Component logs
kubectl logs -n infrastructure deployment/prometheus-grafana-prometheus
kubectl logs -n infrastructure deployment/prometheus-grafana-grafana
kubectl logs -n infrastructure statefulset/loki
```