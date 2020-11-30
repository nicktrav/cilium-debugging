#!/usr/bin/env bash

set -euo pipefail

_version=1.9.0

echo "Pulling Cilium image ..."
docker pull cilium/cilium:"v$_version"

echo "Loading Cilium image to local cluster ..."
kind load docker-image cilium/cilium:"v$_version" --name cluster

echo "Installing Cilium ..."
helm upgrade cilium cilium/cilium \
  --install \
  --version "$_version" \
  --namespace kube-system \
  --set nodeinit.enabled=true \
  --set kubeProxyReplacement=partial \
  --set hostServices.enabled=false \
  --set externalIPs.enabled=true \
  --set nodePort.enabled=true \
  --set hostPort.enabled=true \
  --set bpf.masquerade=false \
  --set image.pullPolicy=IfNotPresent \
  --set ipam.mode=kubernetes \
  --set hubble.metrics.enabled="{dns,drop,tcp,flow,icmp,http:sourceContext=pod;destinationContext=pod}" \
  --set hubble.listenAddress=":4244" \
  --set hubble.relay.enabled=true \
  --set hubble.ui.enabled=true \
  --set prometheus.enabled=true \
  --set operator.prometheus.enabled=true \
  --set debug.enabled=true
