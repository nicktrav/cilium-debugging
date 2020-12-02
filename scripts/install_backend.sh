#!/usr/bin/env bash

set -euo pipefail

_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
_chart_dir="$_dir/../manifests/backend"

_cnp_enabled="$1"
_hpa_enabled="$2"

echo "Creating backend namespace ..."
kubectl create ns backend || true

echo "Installing backend Helm chart ..."
helm upgrade \
  backend \
  "$_chart_dir" \
  --namespace backend \
  --set cnp.enabled="$_cnp_enabled" \
  --set hpa.enabled="$_hpa_enabled" \
  --install
