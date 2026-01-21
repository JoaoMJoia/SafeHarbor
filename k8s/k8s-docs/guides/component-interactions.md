# Component Interactions

## Pod Creation Flow

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

## Service Discovery Flow

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

## Scaling Flow

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
