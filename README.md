cilium-custom-metrics-demo
==========================

This repo demonstrates how to use Cilium Layer 7 (i.e. HTTP) metrics to drive a
K8s Horizontal Pod Autoscaler (HPA).

## Components

### [Cilium](https://github.com/cilium/cilium)

The Container Network Interface (CNI) used for networking in the cluster. Runs
in the `kube-system` namespace.

### [`k8s-prometheus-adapter`](https://github.com/DirectXMan12/k8s-prometheus-adapter)

Provides an interface for the K8s API server to call into to fetch metrics on
which autoscaling (via an HPA) can be performed. Runs in the `custom-metrics`
namespace.

### `cilium-monitoring`

Provides a Prometheus and Grafana deployment for monitoring of Cilium
components. The Prometheus instance is queried by the `k8s-prometheus-adapter`.
Runs in the `cilium-monitoring` namespace.

### `backend`

A simple HTTP server that echoes a response to a client. Runs in the `backend`
namespace.

### `load-test`

The load driver. Uses [vegeta](https://github.com/tsenart/vegeta). Runs in the
`load-test` namespace.

## Setup

The demo requires the following:

- `docker`: for building the `backend` and `load-test` container images. Tested
  with version `19.0.3`.
- `kind`: K8s in Docker. Tested with version `v0.8.1`.
- `helm`: the various components are installed as Helm charts. Tested with
  `v3.4.0`.

Creating a cluster:

```shell
$ make create
```

From scratch, the cluster can take ~5 minutes to create and for the HPA to
become active.

## Autoscaling

Use `make watch-hpa` to view the status of the autoscaler.

Initially, the autoscaler will be in an unknown state, as it takes some time
for the monitoring to collect enough metrics and for the Prometheus adapter to
register the timeseries.

```shell
$ kubectl get hpa -n backend
NAME        REFERENCE              TARGETS        MINPODS   MAXPODS   REPLICAS   AGE
backend-1   Deployment/backend-1   <unknown>/25   1         10        1          7m10s
backend-2   Deployment/backend-2   <unknown>/10   1         10        1          7m10s
```

The HPAs should eventually converge to the following state:

- `backend-1`: 2 replicas (load: 50 QPS, target: 25 QPS per pod)
- `backend-2`: 5 replicas (load: 50 QPS, target: 10 QPS per pod)

The load and target values can be altered in the following files:

- [`manifests/backend/values.yaml`](manifests/backend/values.yaml)
- [`manifests/load-test/values.yaml`](manifests/load-test/values.yaml)

After changing values, re-deploy with `make install-backend` and / or `make
install-load-test`.

## Metrics

View metrics in Prometheus with the following:

```shell
$ make port-forward-prometheus
```

View metrics in Grafana with the following:

```shell
$ make port-forward-grafana
```

## Cleanup

Destroy a cluster:

```shell
$ make destroy
```

## Open issues

* There is currently an issue with the Cilium metrics that results in metrics
  being double counted, which can result in the HPA creating twice the number
  of desired pods.

* Load balancing between the load-test driver and the backend pods is uneven.
  This is assumed to be due to the use of kube-proxy for load balancing, which
  is far from perfect in how it distributes load. Cilium can run entirely
  without kube-proxy, though this scenario was not tested in the kind cluster.
