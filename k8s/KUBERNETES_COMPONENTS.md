# Kubernetes Components Documentation

This document provides a comprehensive explanation of how Kubernetes components work, their architecture, and how they interact with each other.

The documentation has been organized into focused files for easier navigation and maintenance.

## Overview

Kubernetes is a container orchestration platform that manages containerized applications across a cluster of machines. The architecture consists of:

- **Control Plane**: The brain of Kubernetes that manages the cluster
- **Worker Nodes**: Machines that run your application containers
- **Pods**: The smallest deployable units in Kubernetes
- **Services**: Network abstraction for pods
- **Controllers**: Components that maintain desired state

## Table of Contents

### Components

1. [Control Plane Components](./components/01-control-plane.md)
   - API Server (kube-apiserver)
   - etcd
   - Controller Manager (kube-controller-manager)
   - Scheduler (kube-scheduler)
   - Cloud Controller Manager

2. [Node Components](./components/02-node-components.md)
   - kubelet
   - kube-proxy
   - Container Runtime

3. [Addon Components](./components/03-addon-components.md)
   - DNS (CoreDNS)
   - CNI (Container Network Interface) Plugin
   - CSI (Container Storage Interface) Driver

### Kubernetes Objects

4. [Workload Objects](./objects/01-workload-objects.md)
   - Pods
   - Deployments
   - ReplicaSets
   - Daemon Sets
   - Stateful Sets
   - Jobs
   - Cron Jobs

5. [Config Objects](./objects/02-config-objects.md)
   - ConfigMaps
   - Secrets
   - Resource Quotas
   - Limit Ranges
   - Horizontal Pod Autoscalers (HPA)
   - Pod Disruption Budgets (PDB)
   - Priority Classes
   - Runtime Classes
   - Leases
   - Mutating Webhook Configurations
   - Validating Webhook Configurations

6. [Network Objects](./objects/03-network-objects.md)
   - Services
   - Endpoints
   - Ingresses
   - Ingress Classes
   - Network Policies
   - Port Forwarding

7. [Storage Objects](./objects/04-storage-objects.md)
   - Persistent Volume Claims (PVCs)
   - Persistent Volumes (PVs)
   - Storage Classes

8. [Access Control Objects](./objects/05-access-control-objects.md)
   - Service Accounts
   - Roles
   - Cluster Roles
   - Role Bindings
   - Cluster Role Bindings

### Guides

9. [Component Interactions](./guides/component-interactions.md)
   - Pod Creation Flow
   - Service Discovery Flow
   - Scaling Flow

10. [Request Flows and Architecture Diagrams](./guides/request-flows.md)
    - External Request to Application
    - Internal Pod-to-Pod Communication
    - Pod-to-Service Communication
    - Complete Kubernetes Architecture
    - Component Communication Flow
    - Pod Lifecycle Management

11. [Best Practices and Troubleshooting](./guides/best-practices-troubleshooting.md)
    - Key Concepts Summary
    - Best Practices
    - Troubleshooting Commands
    - References

## Quick Navigation

- **New to Kubernetes?** Start with the [Overview](#overview) and [Control Plane Components](./components/01-control-plane.md)
- **Working with workloads?** See [Workload Objects](./objects/01-workload-objects.md)
- **Configuring applications?** Check [Config Objects](./objects/02-config-objects.md)
- **Setting up networking?** Review [Network Objects](./objects/03-network-objects.md)
- **Managing storage?** Read [Storage Objects](./objects/04-storage-objects.md)
- **Configuring access control?** See [Access Control Objects](./objects/05-access-control-objects.md)
- **Understanding interactions?** Explore [Component Interactions](./guides/component-interactions.md)
- **Need help?** Consult [Best Practices and Troubleshooting](./guides/best-practices-troubleshooting.md)
