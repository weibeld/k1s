# k1s: The world's simplest Kubernetes dashboard

A minimalistic Kubernetes dashboard implemented with 50 lines of Bash code.

![Screencast](https://raw.githubusercontent.com/weibeld/k1s/master/assets/screencast-1.gif)

## Introduction

### What is it?

A minimalistic Kubernetes dashboard showing the current state of Kubernetes resources of a specific type in real-time. The entire tool consists merely of a Bash script with about 50 lines of code.

### What is it not?

It's not a production-grade dashboard with many features. It's mainly intended for educational purposes.

### How does it work?

With a lot of highly condensed Bash scripting. [This article](https://itnext.io/the-worlds-simplest-kubernetes-dashboard-k1s-4246e03191df) explains how it works in detail.

## Installation

### On macOS

```bash
brew install weibeld/tap/k1s
```

### On other systems

Simply download the [`k1s`](k1s) script, make it executable, and move it to any directory in your `PATH`.

For example:

```bash
wget https://raw.githubusercontent.com/weibeld/k1s/master/k1s
chmod +x k1s
mv k1s /usr/local/bin
```

### Dependencies

The `k1s` script depends on the following tools:

#### [`jq`](https://stedolan.github.io/jq/)

| OS    | Installation              |
|-------|---------------------------|
| macOS | `brew install jq`         |
| Linux | `sudo apt-get install jq` |

#### [`watch`](https://linux.die.net/man/1/watch)

| OS    | Installation               |
|-------|----------------------------|
| macOS | `brew install watch`       |
| Linux | — _(installed by default)_ |


#### [`curl`](https://curl.haxx.se/)

| OS    | Installation               |
|-------|----------------------------|
| macOS | — _(installed by default)_ |
| Linux | sudo apt-get install curl  |

#### [`kubectl`](https://kubernetes.io/docs/tasks/tools/install-kubectl/)

| OS    | Installation                                                        |
|-------|---------------------------------------------------------------------|
| macOS | `brew install kubernetes-cli`                                       |
| Linux | _See https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/_ |

## Usage

k1s runs directly on your local machine and it uses the usual [kubeconfig](https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/) configuration on your machine. That means, it connects to the same cluster that also `kubectl` connects to by default.

The command-line interface is as follows:

```bash
k1s [<namespace>] [<resource-type>]
```

Both arguments are optional. The default values are:

| Argument          | Default value |
|-------------------|---------------|
| `<namespace>`     | `default`     |
| `<resource-type>` | `pods`        |

The `<namespace>` argument may be set to any valid namespace in the cluster. In addition, `<namespace>` may be set to `-` to imply "all namespaces" for namespaced resource types and "no namespace" for non-namespaced resource types (e.g. ClusterRoles).

> You can find out which resource types are namespaced or non-namespaced with `kubectl api-resources --namespaced=true|false`.

The `<resource-type>` argument may be set to any valid resource type name (including their singular, plural and short forms).

> You can list all supported resource type names with `kubectl api-resources`.

To exit the dashboard, type _Ctrl-C_.

## Example usage scenario

Below is an example usage scenario for k1s. It uses multiple instances of k1s for observing what's going on under the hood when scaling a Deployment:

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
