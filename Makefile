# -----------------------------------------------------------------------------
# All
# -----------------------------------------------------------------------------

.PHONY: create
create: kind cilium k8s-prometheus-adapter backend load-test

.PHONY: destroy
destroy: destroy-cluster

# -----------------------------------------------------------------------------
# Kind
# -----------------------------------------------------------------------------

.PHONY: kind
kind: create-cluster

.PHONY: create-cluster
create-cluster:
	@kind create cluster --config cluster.yaml --name cluster || true

.PHONY: destroy-cluster
destroy-cluster:
	@kind delete cluster --name cluster

# -----------------------------------------------------------------------------
# Cilium
# -----------------------------------------------------------------------------

.PHONY: cilium
cilium: \
	install-cilium \
	install-cilium-monitoring \
	apply-prometheus-configmap-patch

.PHONY: install-cilium
install-cilium:
	@./scripts/install_cilium.sh

.PHONY: install-cilium-monitoring
install-cilium-monitoring:
	@./scripts/install_cilium_monitoring.sh

.PHONY: apply-prometheus-configmap-patch
apply-prometheus-configmap-patch:
	@./scripts/apply_prometheus_configmap.sh

# -----------------------------------------------------------------------------
# k8s-prometheus-adapter
# -----------------------------------------------------------------------------

.PHONY: k8s-prometheus-adapter
k8s-prometheus-adapter: \
	generate-k8s-prometheus-adapter-certs \
	install-k8s-prometheus-adapter-certs \
	install-k8s-prometheus-adapter

.PHONY: generate-k8s-prometheus-adapter-certs
generate-k8s-prometheus-adapter-certs:
	@./scripts/generate_certs.sh

.PHONY: install-k8s-prometheus-adapter-certs
install-k8s-prometheus-adapter-certs:
	@./scripts/install_certs.sh

.PHONY: install-k8s-prometheus-adapter
install-k8s-prometheus-adapter:
	@./scripts/install_k8s_prometheus_adapter.sh

# -----------------------------------------------------------------------------
# Backend
# -----------------------------------------------------------------------------

.PHONY: backend
backend: \
	build-backend \
	tag-backend \
	push-backend-image \
	install-backend

.PHONY: build-backend
build-backend:
	@docker build -t backend -f backend/Dockerfile backend

.PHONY: tag-backend
tag-backend:
	@docker tag backend backend:v1
	@docker tag backend backend:v2

.PHONY: push-backend-image
push-backend-image:
	@kind load docker-image backend:v1 --name cluster
	@kind load docker-image backend:v2 --name cluster

.PHONY: install-backend
install-backend:
	@./scripts/install_backend.sh

# -----------------------------------------------------------------------------
# Load Test
# -----------------------------------------------------------------------------

.PHONY: load-test
load-test: \
	build-load-test \
	push-load-test-image \
	install-load-test

.PHONY: build-load-test
build-load-test:
	@docker build -t load-test -f load-test/Dockerfile load-test

.PHONY: push-load-test-image
push-load-test-image:
	@kind load docker-image load-test --name cluster

.PHONY: install-load-test
install-load-test:
	@./scripts/install_load_test.sh

# -----------------------------------------------------------------------------
# Misc.
# -----------------------------------------------------------------------------
#
.PHONY: check-api
check-api:
	@kubectl get --raw /apis/custom.metrics.k8s.io/v1beta1 | jq .

.PHONY: port-forward-prometheus
port-forward-prometheus:
	@echo "Open http://localhost:9090/graph?g0.range_input=1h&g0.expr=hubble_http_requests_total&g0.tab=1"
	@kubectl -n cilium-monitoring port-forward svc/prometheus 9090:9090

.PHONY: port-forward-grafana
port-forward-grafana:
	@echo "Open http://localhost:3000/d/5HftnJAWz/hubble?orgId=1&refresh=30s&from=now-15m&to=now"
	@kubectl -n cilium-monitoring port-forward svc/grafana 3000:3000

.PHONY: watch-hpa
watch-hpa:
	@watch kubectl -n backend get hpa
