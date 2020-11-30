#!/usr/bin/env bash

set -euo pipefail

_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
_config_dir=$_dir/../manifests/cilium-monitoring

echo "Applying prometheus ConfigMap ..."
kubectl -n cilium-monitoring apply \
  -f "$_config_dir/prometheus-configmap.yaml"

echo "Restarting Prometheus ..."
kubectl -n cilium-monitoring rollout restart \
  deployment/prometheus
