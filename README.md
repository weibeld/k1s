# k1s - the world's tiniest Kubernetes dashboard

A simplistic Kubernetes dashboard implemened with 50 lines of Bash code.

```
 ____ ____ ____                                                     |┻┳
||k |||1 |||s ||                                                 __ |┳┻
||__|||__|||__||   The world's tiniest Kubernetes dashboard    (•.• |┻┳
|/__\|/__\|/__\|                                                  \⊃|┳┻
                                                                    |┻┳
```

![Screencast](assets/screencast-1.gif)


## What is it?

k1s is a minimalistic Kubernetes dashboard that allows to observe any resources in any namespace (or across all namespaces) of your Kubernetes cluster in real time.

It's implemented with 50 lines of Bash code.

## What is it not?

k1s is not a full-featured production-grade Kubernetes dashboard (for such a use case, it would be better to use a real programming language, like Go).

Instead, k1s is an experiment of how far you can go with using Bash for building something useful with as little code and as few dependencies as possible.


## Installation

Download the [`k1s`](k1s) script, make it executable, and move it to any directory in your `PATH`. For example:

```bash
{
  wget https://raw.githubusercontent.com/weibeld/k1s/master/k1s
  chmod +x k1s
  mv k1s /usr/local/bin
}
```

Also make sure that you have all the [dependencies](#dependencies) installed on your machine.

## Usage

The [`k1s`](k1s) script is run directly on your local machine. It has the following command-line interface:

```bash
k1s [<namespace>] [<resource-type>]
```

Both arguments are optional. The default values are:

- `<namespace>`: `default`
- `<resource-type>`: `pods`

You can run multiple instances of the `k1s` script simultanesouly.

To exit the dashboard, type _Ctrl-C_.

### Examples

Observe Pods in the `default` namespace:

```bash
k1s
```

Observe Pods in the `kube-system` namespace:

```bash
k1s kube-system
```

Observe Deployments in the `default` namespace:

```bash
k1s "" deployments
```

Observe Deployments in the `kube-system` namespace:

```bash
k1s kube-system deployments
```

Observe Deployments across all namespaces:

```bash
k1s - Deployments
```

Observe ClusterRoles (non-namespaced resource):

```bash
k1s - clusterroles
```

### Resource types

You can specify the desired resource type in any of the name variants accepted by Kubernetes. In general, this includes:

- The plural form
- The singular form
- The shortname (if available)

Furthermore, the capitalisation of the plural and singular forms doesn't matter.

For example, all the following invocations are equivalent:

```bash
k1s default replicasets
k1s default replicaset
k1s default rs
k1s default ReplicaSets
k1s default ReplicaSet
```

> You can find out the shortnames of all Kubernetes resources that have one with `kubectl api-resources`.

### All namespaces and non-namespaced resources

You can specify `-` for the `<namespace>` argument to list the requested resources across all namespaces of the cluster.

For example, the following displays the Deployments across all namespaces:

```bash
k1s - deployments
```

In the same way, you can list non-namespaced resources (such as Namespaces, ClusterRoles, PersistentVolumes, etc.).

For example:

```bash
k1s - persistentvolumes
```

> You can find out all the non-namespaced resources with `kubectl api-resources --namespaced=false`.

## Dependencies

The `k1s` script depends on the following commands being installed on your machine:

- [**`jq`**](https://stedolan.github.io/jq/)
    ```bash
    # macOS
    brew install jq
    # Linux
    sudo apt-get install jq
    ```
- [**`watch`**](https://linux.die.net/man/1/watch)
    ```bash
    # macOS
    brew install watch
    # Linux (installed by default)
    ```
- [**`curl`**](https://curl.haxx.se/)
    ```bash
    # macOS (installed by default)
    # Linux
    sudo apt-get install curl
    ```

Furthermore, you also must have installed and configured [`kubectl`](https://kubernetes.io/docs/tasks/tools/install-kubectl/) to point to your target cluster.

## Example application

A suitable example application of k1s is observing scalings and rolling updates of Deployments:

![Example application](assets/screencast-2.gif)

Note how during the rolling update you can observe the ReplicaSets that the Deployment creates and manages, and how the replica count of the Deployment stays within a certain range.

> You can influence this range with the [`maxSurge` and `maxUnavailable`](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#rolling-update-deployment) settings in the Deployment.

To recreate the above example, launch three instances of k1s, one for Deployments, one for ReplicaSets, and one for Pods:

```bash
k1s default deployments
k1s default replicasets
k1s default pods
```

Then, create a Deployment:

```bash
kubectl create deployment dep1 --image=nginx
```

Scale the Deployment:

```bash
kubectl scale deployment dep1 --replicas=10
```

Change the container image in the Pod template of the Deployment, which causes a rolling update:

```bash
kubectl patch deployment dep1 -p '{"spec":{"template":{"spec":{"containers":[{"name":"nginx","image":"nginx:1.19.0"}]}}}}'
```

> You can also manually edit the Deployment with `kubectl edit deployment dep1`.

Finally, delete the Deployment:

```bash
kubectl delete deployment dep1
```

