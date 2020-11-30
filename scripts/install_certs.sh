#!/usr/bin/env bash

set -euo pipefail

_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
_cert_dir=$_dir/../certs

echo "Creating custom-metrics namespace ..."
kubectl create ns custom-metrics || true

echo "Installing certs ..."
kubectl delete secret cm-adapter-serving-certs \
  --namespace custom-metrics || true

kubectl create secret tls cm-adapter-serving-certs \
  --namespace custom-metrics \
  --cert "$_cert_dir/tls.crt" \
  --key "$_cert_dir/tls.key"
