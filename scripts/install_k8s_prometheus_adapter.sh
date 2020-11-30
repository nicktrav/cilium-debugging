#!/usr/bin/env bash

set -euo pipefail

echo "Creating custom-metrics namespace ..."
kubectl create ns custom-metrics || true

echo "Installing k8s-prometheus-adapter ..."
helm upgrade \
  k8s-prometheus-adapter \
  manifests/k8s-prometheus-adapter \
  --install
