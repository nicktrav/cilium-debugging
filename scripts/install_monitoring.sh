#!/usr/bin/env bash

set -euo pipefail

_version=v1.9

echo "Installing Cilium monitoring ..."
kubectl apply -f \
  https://raw.githubusercontent.com/cilium/cilium/$_version/examples/kubernetes/addons/prometheus/monitoring-example.yaml
