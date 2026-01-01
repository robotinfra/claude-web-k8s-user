# claude-web-k8s-user

Helm chart for per-user namespace infrastructure (RBAC) for Claude Web Kubernetes Engine.

## Description

This chart creates the necessary Kubernetes RBAC resources to set up a per-user namespace in the Claude Web Kubernetes Engine multi-tenant environment. Each user gets their own namespace with appropriate permissions to manage Claude Code instances.

## Features

- **Namespace Creation**: Automatically creates a namespace for each user (`claude-{userid}`)
- **RBAC Setup**: Creates ServiceAccount, ClusterRole, ClusterRoleBinding, Role, and RoleBinding
- **Fine-grained Permissions**:
  - Read access to most Kubernetes resources
  - Write access for instance management
  - Pod operations (logs, exec, port-forward)
  - ArgoCD Application management (full access)
  - CNPG Database management (optional)

## Installation

### Via ArgoCD (Recommended)

This chart is typically deployed via ArgoCD as part of user provisioning:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: claude-user123
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/robotinfra/claude-web-k8s-user
    chart: .
    targetRevision: main
    helm:
      values: |
        userid: "user123"
  destination:
    server: https://kubernetes.default.svc
    namespace: claude-user123
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
```

### Via Helm CLI

For testing purposes:

```bash
helm install claude-user123 ./claude-web-k8s-user \
  --namespace claude-user123 \
  --create-namespace \
  --set userid=user123
```

## Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `userid` | Unique user identifier (e.g., GitHub username) | `"user123"` |
| `namespace.name` | Custom namespace name (if empty, uses `claude-{userid}`) | `""` |
| `namespace.create` | Create namespace if it doesn't exist | `true` |
| `rbac.createClusterRole` | Create ClusterRole for cluster-wide access | `true` |
| `rbac.permissions.read` | Resources with read-only access | See values.yaml |
| `rbac.permissions.write` | Resources with write access | See values.yaml |
| `rbac.permissions.argocdApplications` | Enable ArgoCD application management | `true` |
| `rbac.permissions.databases.create` | Enable CNPG database creation | `true` |
| `rbac.permissions.databases.namespace` | CNPG cluster namespace | `"database"` |

## RBAC Permissions

### Cluster-Wide Access (ClusterRole)

The chart creates a ClusterRole granting:

1. **Read Access**: List, get, watch on core resources
2. **Write Access**: Create, update, patch, delete on instance resources
3. **Pod Operations**: logs, exec, portforward
4. **ArgoCD**: Full management of Applications, AppProjects, ApplicationSets
5. **CNPG Databases**: Create and manage databases in the shared PostgreSQL cluster

### Namespace-Scoped Access (Role)

The chart creates a Role granting full admin access within the user's namespace.

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│  Kubernetes Cluster                                     │
│                                                         │
│  Namespace: claude-user123                             │
│  ┌───────────────────────────────────────────────────┐ │
│  │ ServiceAccount: claude-user123                   │ │
│  │                                                   │ │
│  │ ClusterRoleBinding (cluster-wide)                │ │
│  │   └─> ClusterRole: claude-user123-admin          │ │
│  │       - Read resources cluster-wide               │ │
│  │       - Manage ArgoCD Applications               │ │
│  │       - Create CNPG Databases                    │ │
│  │                                                   │ │
│  │ RoleBinding (namespace-scoped)                   │ │
│  │   └─> Role: claude-user123-admin                 │ │
│  │       - Full admin in user namespace              │ │
│  └───────────────────────────────────────────────────┘ │
│                                                         │
│  User can now deploy Claude instances in this namespace│
└─────────────────────────────────────────────────────────┘
```

## Usage

### Deploying for a New User

When provisioning a new user in Claude Web Kubernetes Engine:

1. Create an ArgoCD Application referencing this chart
2. Set the `userid` to the unique user identifier
3. ArgoCD will create the namespace and RBAC resources
4. User can now create Claude Code instances in their namespace

### Example Values

```yaml
userid: "alice"
namespace:
  name: ""  # Will default to "claude-alice"
  create: true

rbac:
  createClusterRole: true
  permissions:
    argocdApplications: true
    databases:
      create: true
      namespace: "database"
```

## Permissions Breakdown

### Instance Management

Users can:
- Create/update/delete Deployments, Services, ConfigMaps, Secrets
- View pod logs and exec into pods
- Port-forward to local services
- Create and manage Ingress resources

### ArgoCD Integration

Users can:
- Create and manage ArgoCD Applications for their instances
- Sync and monitor their applications
- Manage ApplicationSets (if needed)

### Database Access

Users can:
- Create databases in the shared CNPG PostgreSQL cluster
- Each instance gets its own database (if postgres feature is enabled)
- Database automatically cleaned up when instance is deleted

## Security Considerations

- Each user is isolated to their own namespace
- ClusterRole allows read access cluster-wide but write access is restricted
- ArgoCD permissions are scoped to Applications the user creates
- Database creation is limited to the shared CNPG cluster
- Network policies can be added in future phases for additional isolation

## Future Enhancements

Planned for future phases:
- Network policies (zero-trust model)
- Resource quotas (CPU, memory, storage limits)
- Limit ranges (default resource requests/limits)
- Pod security policies/pod security standards

## Troubleshooting

### User Cannot Create Resources

Check the ClusterRoleBinding:

```bash
kubectl get clusterrolebinding claude-user123-binding -o yaml
```

### User Cannot Access ArgoCD

Verify ArgoCD permissions are granted:

```bash
kubectl get clusterrole claude-user123-admin -o yaml | grep -A 10 argoproj.io
```

### Namespace Not Created

Check if namespace exists:

```bash
kubectl get namespace claude-user123
```

## Contributing

This is part of the Claude Web Kubernetes Engine project. Contributions are welcome via pull requests.

## License

MIT

## Maintainer

- robotinfra (infra@robotinfra.com)

## See Also

- [claude-web-k8s-instance](https://github.com/robotinfra/claude-web-k8s-instance) - Per-instance Claude Code deployment
- [claude-web-k8s-engine](https://github.com/robotinfra/claude-web-k8s-engine) - Go proxy + React frontend
