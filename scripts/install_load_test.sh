#!/usr/bin/env bash

set -euo pipefail

_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
_chart_dir="$_dir/../manifests/load-test"

echo "Creating load-test namespace ..."
kubectl create ns load-test || true

echo "Installing load-test Helm chart ..."
helm upgrade \
  load-test \
  "$_chart_dir" \
  --namespace load-test \
  --set cnp.enabled="$1" \
  --install
