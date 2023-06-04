# Simple and centralized RBAC Management in Kubernetes/Openshift 📜 👮‍♂️

Define your Kubernetes RBAC rules in a centralized and automatically way without any CRDs ! 🚀

## How to

1. [Fork this repo](/fork)
2. [Define your rules](#rbac-rules-maintenance)
3. [Deploy the way you want](#deploy-it) !

## Deploy it

### Deploy the GitOps way

Use a GitOps controller (like [ArgoCD](https://argoproj.github.io/cd/) or [Flux](https://fluxcd.io/)) to point to your fork. Then your rules are automatically applied and reconcilied. 

Now, give rights to everybody in your organisation to submit a PR and managing rights are just a matter of reviewing code ! 🤩

### Deploy manually
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

## RBAC Rules Maintainance

### Best practices

- Use a dedicated namespace for your helm release
- ⚠️ Avoid to bind users directly to `Roles`/`ClusterRoles`. Instead define groups of users (e.g. devteam, qateam, etc.).
- Prefer predefined `ClusterRoles`
- In case of multi-clusters, define common rules in default `values.yaml`, while specific definitions for a cluster will be defined in its own value files.


### Rules

**Where to define ?**

1. If your update concerns every cluster : put it in `values.yaml`
2. If your update concerns a specific cluster, put it in the values defined for the concerned cluster (e.g. `values.cluster1.yaml`).
3. If your update concerns every cluster but one specific :
    1. put it in `values.yaml`
    2. override it in the values defined for the concerned cluster

**What to define ?**

You can define :
- `Roles` (prefer using predefined ones),
- `ClusterRoles` (prefer using predefined ones),
- `Groups`,
- `RoleBindings`,
- `ClusterRoleBindings`.

⚠️ You are free to define values but you have to use existing objects (Groups, Namespaces, Roles, ClusterRoles) :
- Roles are defined in namespaces. By default, no one is defined. See specific namespace definition for that.
- Some convenient predefined ClusterRoles are `admin`, `edit`, `view`, `guest`.

Roles must be defined like this :
```yaml
roles:
  <Existing namespace name>:
    <Role name>:
    # List of grants
    - apiGroups: [""]
      resources: ["pods", "configmaps"]
      verbs: ["get", "list"]
    - apiGroups: [""]
      resources: ["pvc"]
      verbs: ["get", "list"]
```

ClusterRoles must be defined like this :
```yaml
clusterRoles:
  <ClusterRole name>:
  # List of grants
  - apiGroups: [""]
    resources: ["pods", "pods/log"]
    verbs: ["get", "list"]
```

Groups must be defined like this :
```yaml
groups:
  <name of the group>:
  # List of users
  - <username1>
  - <username2>
  - ...
```

RoleBindings must be defined like this :
```yaml
roleBindings:
  <Existing namespace name>:
    <Existing/Defined Role/ClusterRole name>:
      # List of groups/users/serviceAccounts granted with this role/clusterRole in this namespace
      groups:
      - <Existing/Defined Group "name">
      - ...
      users:
      - <Existing User "name">
      - ...
      serviceAccounts:
      - <Existing ServiceAccount "namespace:name" )>
      - ...
```

ClusterRoleBindings must be defined like this :
```yaml
clusterRoleBindings:
  <Existing/Defined ClusterRole name>:
    # List of groups/users/serviceAccounts granted with this clusterRole in the cluster
    groups:
    - <Existing/Defined Group "name">
    - ...
    users:
    - <Existing User "name">
    - ...œ
    serviceAccounts:
    - <Existing ServiceAccount "namespace:name" )>
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

### 1. Openshift 3.11 : Users in RoleBindings

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