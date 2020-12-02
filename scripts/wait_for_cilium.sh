#!/usr/bin/env bash

set -euo pipefail

function unready() {
  kubectl -n kube-system get pods \
    -l k8s-app=cilium \
    -o jsonpath='{range .items[*]}{.status.containerStatuses[0].ready}{"\n"}{end}' \
      | grep -c 'false' \
      || true
}

while true; do
  _unready=$(unready)
  if [[ "$_unready" -eq "0" ]]; then
    echo "All Cilium pods ready"
    exit 0
  fi

  printf "%s pods unready; waiting ...\n" "$_unready"
  sleep 5
done
