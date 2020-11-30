#!/usr/bin/env bash

set -euo pipefail

_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
_cert_dir=$_dir/../certs

echo "Creating cert dir ..."
rm -rf "$_cert_dir" || true
mkdir "$_cert_dir"

echo "Creating k8s-prometheus-adapter certs ..."
mkcert \
  -cert-file "$_cert_dir/tls.crt" \
  -key-file "$_cert_dir/tls.key" \
  custom-metrics-apiserver.custom-metrics \
  custom-metrics-apiserver.custom-metrics.svc \
  custom-metrics-apiserver.custom-metrics.svc.cluster.local
