# Kubernetes Apply Plugin

This is a resource plugin that provisions Kubernetes resources for use within a
Signadot Sandbox. Such resources will be created with owner references set to
the corresponding sandbox resource CRD, and so the deprovision will be performed
directly by Kubernetes during sandbox deletion.

## Installing the Plugin

Use the `signadot` CLI to register the plugin in Signadot Control Plane:

```sh
signadot resourceplugin apply -f ./plugin.yaml
```

**IMPORTANT:** The plugin will run as an extension to
`signadot-controller-manager`, and so, it will run using the same service
account. Even though `signadot-controller-manager` has permissions to `get` and
`create` multiple Kubernetes resources (such as `Deployments`, `Pods`,
`Services`, `ConfigMaps`, `Secrets` and so on), it's important to check
permissions for the resources you are planning to use. To do so, you can use
`kubectl auth can-i` command, for example:

```bash
# Check rbacs for configmap
$ kubectl auth can-i get configmap --as=system:serviceaccount:signadot:signadot-controller-manager
yes
$ kubectl auth can-i create configmap --as=system:serviceaccount:signadot:signadot-controller-manager
yes

# Check rbacs for jobs
$ kubectl auth can-i get job --as=system:serviceaccount:signadot:signadot-controller-manager
no
$ kubectl auth can-i create job --as=system:serviceaccount:signadot:signadot-controller-manager
no
```

Imagine you are planning to create Kubernetes `Jobs` in the `default` namespace,
then you may create a `Role` and `RoleBinding` as follows (or use a
`ClusterRole` and `ClusterRoleBinding`):

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: signadot-k8s-apply
rules:
- apiGroups:
  - batch
  resources:
  - jobs
  verbs:
  - get
  - create
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: signadot-controller-manager-k8s-apply
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: signadot-k8s-apply
subjects:
- kind: ServiceAccount
  name: signadot-controller-manager
  namespace: signadot
```

## Using the Plugin

When creating a Signadot Sandbox, you can request the creation of temporary
Kubernetes resources from this plugin by specifying the plugin name `k8s-apply`
and passing the following input parameters.

| Parameter         | Description                                     |
| ----------------- | ----------------------------------------------- |
| `data` (Required) | The desired Kubernetes resources in YAML format |


[`example-sandbox.yaml`](./example-sandbox.yaml) is an example of a sandbox that
uses this plugin. To run it, you will need to install the
[`example-baseline`](./../example-baseline/) application in your cluster, and
use `signadot` CLI to create the sandbox (replacing `<sandbox-name>` with the
name you want to assign to the sandbox, `<cluster-name>` with your cluster name,
and `<example-baseline-namespace>` with the namespace where `example-baseline`
was deployed):

```bash
signadot sandbox apply -f ./example-sandbox.yaml --set name=<sandbox-name> --set cluster=<cluster-name> --set namespace=<example-baseline-namespace>
```

Now, in the [Signadot Dashboard](https://app.signadot.com/sandboxes), you can follow the status of your sandbox,
and once ready, you will be able to access the preview endpoint, where you will see the added env var: `TOKEN`.

## Removing the Plugin

Make sure all sandboxes using the plugin are deleted, and then use `signadot`
CLI to uninstall the plugin:

```sh
signadot resourceplugin delete -f ./plugin.yaml
```
