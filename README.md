# k1s: The world's simplest Kubernetes dashboard

A simplistic Kubernetes dashboard implemented with 50 lines of Bash code.

```
 ____ ____ ____                                                         |┻┳
||k |||1 |||s ||                                                     __ |┳┻
||__|||__|||__||     The world's simplest Kubernetes dashboard     (•.• |┻┳
|/__\|/__\|/__\|                                                      \⊃|┳┻
                                                                        |┻┳
```

![Screencast](https://raw.githubusercontent.com/weibeld/k1s/master/assets/screencast-1.gif)


## What is it?

A minimalistic Kubernetes dashboard allowing you to observe Kubernetes resources of any type in any namespace (or across all namespaces) in real-time.

It's implemented as a Bash script with 50 lines of code.

## What is it not?

k1s does not attempt to be a fully-featured production-grade Kubernetes dashboard (for such cases, it would be better to use a real programming language, such as Go).

Instead, it attempts to be as minimalistic as possible with the goal of being easy to install and use and adaptable to various use cases.

## How does it work?

With a lot of highly condensed Bash scripting. [This article](https://itnext.io/the-worlds-simplest-kubernetes-dashboard-k1s-4246e03191df) explains how the code works.

## Installation

### macOS with Homebrew

```bash
brew install weibeld/core/k1s
```

### In all other cases

Download the [`k1s`](k1s) script, make it executable, and move it to any directory in your `PATH`. For example:

```bash
{
  wget https://raw.githubusercontent.com/weibeld/k1s/master/k1s
  chmod +x k1s
  mv k1s /usr/local/bin
}
```

## Dependencies

The `k1s` script depends on the following tools being installed on your system:

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
- [**`kubectl`**](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
    ```bash
    # macOS
    brew install kubernetes-cli
    # Linux
    # See https://kubernetes.io/docs/tasks/tools/install-kubectl/
    ```

## Usage

The [`k1s`](k1s) script is run directly on your local machine. It has the following command-line interface:

```bash
k1s [namespace] [resource-type]
```

Both arguments are optional. The default values are:

- `namespace`: _default_
- `resource-type`: _pods_

You can run multiple instances of the `k1s` script simultaneously.

To exit the dashboard, type _Ctrl-C_.

### Example usages

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
k1s - deployments
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

You can specify `-` for the `namespace` argument to list the specified resource type across all namespaces of the cluster.

For example, the following displays the Deployments from all the namespaces:

```bash
k1s - deployments
```

In the same way, you can list non-namespaced resources (such as Namespaces, ClusterRoles, PersistentVolumes, etc.).

For example:

```bash
k1s - persistentvolumes
```

> You can find out all the non-namespaced resources with `kubectl api-resources --namespaced=false`.


## Usage scenario

An example usage scenario of k1s is using multiple instances of k1s for observing what's going on under the hood of scaling and rolling update operations on a Deployment:

![Example application](https://raw.githubusercontent.com/weibeld/k1s/master/assets/screencast-2.gif)

> Note how during the rolling update, you can observe how the replica count of the Deployment always stays within a certain range. You can influence this range with the [`maxSurge` and `maxUnavailable`](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#rolling-update-deployment) settings in the Deployment specification.

To recreate the above example, launch three instances of k1s in separate terminal windows (or in different [tmux](https://github.com/tmux/tmux/wiki) panes, as shown above):

```bash
k1s default deployments
```

```bash
k1s default replicasets
```

```bash
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

Patch the Deployment with a new container image, which causes a rolling update:

```bash
kubectl patch deployment dep1 -p '{"spec":{"template":{"spec":{"containers":[{"name":"nginx","image":"nginx:1.19.0"}]}}}}'
```

> You can also manually edit the Deployment with `kubectl edit deployment dep1`.

Finally, delete the Deployment:

```bash
kubectl delete deployment dep1
```

## Advanced usage scenarios

Here's a list of more advanced usage scenarios contributed by users of k1s:

- [**mjbright/k1s-scenarios**](https://github.com/mjbright/k1s-scenarios) by Mike Bright

> If you want to have your work added, file an issue, or directly make a pull request with your link added to this list.
