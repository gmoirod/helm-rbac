# RBAC Management in Kubernetes/Openshift

## Description

This repo defines a Helm Chart allowing to centralize and maintain RBAC for each Kubernetes/Openshift cluster.

Guidelines :
- A `User` belongs to a `Group`
- `Groups` bind to `Roles` (via `RoleBindings`) and `ClusterRoles` (via `ClusterRoleBindings`)

⚠️ Rules :
- Avoid to bind `User` directly to `Roles`/`ClusterRoles`
- Avoid to give habilitations via CLI

Note :
This Chart has primarily been designed for Openshift, so apiVersion in [values.yaml](values.yaml) reflects that. Change it for your needs.

## How to

### The GitOps way

Use it with ArgoCD or Flux to automatically updates and reconcile RBAC in cluster from your Git repo.

Hence, managing rights are just a matter of reviewing code ! 🤩

### Manually
#### Install / Update a release manually

⚠️ **Need cluster-admin role**

Deploy it by specifying the right cluster value files
```bash
$ helm upgrade --install --force --create-namespace -f values.cluster1.yaml helm-rbac . -n helm-rbac
```

#### Uninstall a release manually

```bash
$ helm uninstall helm-rbac -n helm-rbac
```

## RBAC Maintainance

Common definitions shared between clusters must be defined in `values.yaml`. 
While specific definitions for a cluster must be defined in its own value files.

### Rules

**Where to define ?**

1. If your update concerns every cluster : put it in `values.yaml`
2. If your update concerns a specific cluster, put it in the values defined for the concerned cluster (e.g. `values.cluster1.yaml`).
3. If your update concerns every cluster but one specific :
    1. put it in `values.yaml`
    2. override it in the values defined for the concerned cluster

**What to define ?**

⚠️ You are free to define values but you have to use existing objects (Groups, Namespaces, Roles, ClusterRoles) :
- Roles are defined in namespaces. By default, no one is defined. See specific namespace definition for that.
- Main ClusterRoles are (`admin`, `edit`, `view`, `guest`)


Groups must be defined like this :
```yaml
groups:
  <name of the group>:
  - <username1>
  - <username2>
  - ...
```

RoleBindings must be defined like this :
```yaml
roleBindings:
  <Existing namespace name>:
    <Existing Role name>:
      groups:
      - <Existing Group "name">
      - ...
      users:
      - <Existing User "name">
      - ...
      serviceAccounts:
      - <Existing ServiceAccount "namespace/name" )>
      - ...
```

ClusterRoleBindings must be defined like this :
```yaml
clusterRoleBindings:
  <Existing ClusterRole name>:
    groups:
    - <Existing Group "name">
    - ...
    users:
    - <Existing User "name">
    - ...
    serviceAccounts:
    - <Existing ServiceAccount "namespace/name" )>
    - ...
```

**Remove a definition**

To remove a Map, define it like this :
```yaml
clusterRoleBindings: {}
```

To remove a List, define it like this :
```yaml
clusterRoleBindings:
  cluster-admin:
    groups: []
```

## Known problems

1. Users in RoleBindings

It seems that this definition is not applied by Openshift 3.11.

`groupNames` and `userNames` should be used in legacy servers. See https://docs.openshift.com/container-platform/3.11/rest_api/authorization_openshift_io/rolebinding-authorization-openshift-io-v1.html#specification

```yaml
apiVersion: authorization.openshift.io/v1
kind: RoleBinding
metadata:
  name: factory-edit
  namespace: factory
roleRef:
  name: edit
subjects:
- kind: User
  name: toto
```