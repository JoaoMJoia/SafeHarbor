# Access Control Objects

## Service Accounts

**Purpose**: Provides an identity for pods and processes running in the cluster.

**How it works**:
- Each pod has a service account (default if not specified)
- Service accounts are namespaced resources
- Automatically mounted as a volume in pods
- Contains authentication tokens and credentials
- Used for API authentication and authorization

**Default Service Account**:
- Every namespace has a default service account
- Automatically created if not specified
- Can be used for basic pod operations

**Use Cases**:
- Pod authentication to API Server
- Accessing external services (with tokens)
- RBAC (Role-Based Access Control) integration
- Service mesh authentication

## Roles

**Purpose**: Defines a set of permissions (verbs) on resources within a namespace.

**How it works**:
- Namespaced resource (scoped to a single namespace)
- Defines what actions can be performed on which resources
- Uses verbs: get, list, create, update, patch, delete, watch
- Can specify resource names or use wildcards
- Bound to subjects via RoleBindings

**Role Example**:
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: default
  name: pod-reader
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "watch", "list"]
```

**Use Cases**:
- Namespace-specific permissions
- Team-level access control
- Application-specific permissions
- Development environment access

## Cluster Roles

**Purpose**: Defines a set of permissions (verbs) on cluster-scoped resources or across all namespaces.

**How it works**:
- Cluster-scoped resource (applies cluster-wide)
- Can grant access to cluster resources (nodes, PVs)
- Can grant access to resources across all namespaces
- Bound to subjects via ClusterRoleBindings or RoleBindings
- Used for system components and administrators

**Cluster Role Example**:
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: cluster-admin
rules:
- apiGroups: ["*"]
  resources: ["*"]
  verbs: ["*"]
```

**Use Cases**:
- Cluster administrator permissions
- System component access
- Cross-namespace access
- Cluster-level resource management

## Role Bindings

**Purpose**: Grants the permissions defined in a Role to a user, group, or service account within a namespace.

**How it works**:
- Namespaced resource (scoped to a single namespace)
- Links a Role to subjects (users, groups, service accounts)
- Can reference a Role (namespaced) or ClusterRole (cluster-scoped)
- Subjects can be users, groups, or service accounts
- Multiple subjects can be bound to the same role

**Role Binding Example**:
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: read-pods
  namespace: default
subjects:
- kind: ServiceAccount
  name: my-service-account
  namespace: default
roleRef:
  kind: Role
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io
```

**Use Cases**:
- Granting namespace-specific permissions
- Binding service accounts to roles
- Team access management
- Application permission assignment

## Cluster Role Bindings

**Purpose**: Grants the permissions defined in a ClusterRole to a user, group, or service account cluster-wide.

**How it works**:
- Cluster-scoped resource (applies cluster-wide)
- Links a ClusterRole to subjects (users, groups, service accounts)
- Can grant permissions across all namespaces
- Subjects can be users, groups, or service accounts
- Used for cluster administrators and system components

**Cluster Role Binding Example**:
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: cluster-admin-binding
subjects:
- kind: User
  name: admin-user
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: cluster-admin
  apiGroup: rbac.authorization.k8s.io
```

**Use Cases**:
- Cluster administrator access
- System component permissions
- Cross-namespace access grants
- Global service account permissions

## RBAC Flow

```
User/ServiceAccount
    │
    ▼
RoleBinding/ClusterRoleBinding
    │
    ├──► References Role or ClusterRole
    │
    ▼
Role/ClusterRole
    │
    ├──► Defines permissions (verbs + resources)
    │
    ▼
API Server Authorization
    │
    ├──► Allows or denies request
```

## Best Practices

- **Principle of Least Privilege**: Grant minimum required permissions
- **Use Service Accounts**: Prefer service accounts over user accounts for pods
- **Namespace Isolation**: Use Roles and RoleBindings for namespace-specific access
- **Cluster Roles**: Reserve ClusterRoles for cluster-wide or system operations
- **Regular Audits**: Review and audit RBAC configurations regularly
- **Avoid Wildcards**: Be specific with resource names when possible
