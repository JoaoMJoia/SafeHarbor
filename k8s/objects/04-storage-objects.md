# Storage Objects

## Persistent Volume Claims (PVCs)

**Purpose**: Requests storage resources from a cluster.

**How it works**:
- User requests storage with specific size and access modes
- Binds to a PersistentVolume (PV) that matches requirements
- Provides pod with persistent storage
- Lifecycle independent of pods

**Access Modes**:
- **ReadWriteOnce (RWO)**: Single node read-write
- **ReadOnlyMany (ROX)**: Multiple nodes read-only
- **ReadWriteMany (RWX)**: Multiple nodes read-write

**Use Cases**:
- Database storage
- Application data persistence
- Shared file systems
- Stateful application storage

## Persistent Volumes (PVs)

**Purpose**: Represents a piece of storage in the cluster that has been provisioned.

**How it works**:
- Cluster-wide resource (not namespaced)
- Can be statically or dynamically provisioned
- Bound to PersistentVolumeClaims
- Lifecycle managed by storage administrators

**Provisioning Types**:
- **Static**: Pre-created by administrator
- **Dynamic**: Automatically created via StorageClass

**Use Cases**:
- Pre-provisioned storage
- Storage abstraction layer
- Integration with cloud storage systems

## Storage Classes

**Purpose**: Describes different classes of storage available in the cluster.

**How it works**:
- Defines provisioner, parameters, and reclaim policy
- Used for dynamic volume provisioning
- PVCs can reference a StorageClass
- Enables automatic volume creation

**Reclaim Policies**:
- **Retain**: Manual cleanup required
- **Delete**: Automatically delete when PVC is deleted
- **Recycle**: Deprecated, replaced by dynamic provisioning

**Use Cases**:
- Different storage tiers (SSD, HDD)
- Cloud provider storage integration
- Automatic volume provisioning
- Storage performance optimization
