#!/usr/bin/env bash
#
# kubernetes/monitoring/install-monitoring.sh
#
# Adds Prometheus and Grafana to the Week 08 KoalaTech deployment on AKS.
# Run after the application is already deployed; monitoring is deliberately
# outside the CI/CD pipeline, as permitted by Task 9.1P.
#
set -euo pipefail

RESOURCE_GROUP="${RESOURCE_GROUP:-koalatech-week08-rg}"
CLUSTER_NAME="${CLUSTER_NAME:-sanjai-week08-aks}"
RELEASE="${RELEASE:-monitoring}"
NAMESPACE="${NAMESPACE:-monitoring}"
GRAFANA_PASSWORD="${GRAFANA_PASSWORD:?set GRAFANA_PASSWORD before running}"

VALUES="$(dirname "$0")/values.yaml"

# 1. Point kubectl at the Week 08 cluster.
az aks get-credentials \
    --resource-group "$RESOURCE_GROUP" \
    --name "$CLUSTER_NAME" \
    --overwrite-existing

# 2. Add the chart repository that publishes kube-prometheus-stack.
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# 3. Install (or upgrade) the stack into its own namespace.
#    The Grafana password is passed on the command line rather than committed
#    to values.yaml.
helm upgrade --install "$RELEASE" prometheus-community/kube-prometheus-stack \
    --namespace "$NAMESPACE" \
    --create-namespace \
    --values "$VALUES" \
    --set grafana.adminPassword="$GRAFANA_PASSWORD" \
    --wait \
    --timeout 15m

# 4. Show what was created.
kubectl get pods -n "$NAMESPACE"
kubectl get svc  -n "$NAMESPACE"

cat <<'MSG'

Monitoring installed.

  Grafana:     kubectl port-forward -n monitoring svc/monitoring-grafana 3000:80
               then open http://localhost:3000  (user: admin)

  Prometheus:  kubectl port-forward -n monitoring svc/monitoring-kube-prometheus-prometheus 9090:9090
               then open http://localhost:9090

MSG
