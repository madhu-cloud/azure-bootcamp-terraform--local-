#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
CLUSTER_NAME=bootcamp

echo "==> Creating kind cluster: ${CLUSTER_NAME} (if not exists)"
kind create cluster --name "${CLUSTER_NAME}" || true

echo "==> Switch kubectl context to kind-${CLUSTER_NAME}"
kubectl cluster-info --context "kind-${CLUSTER_NAME}" || true

echo "==> Apply base manifests"
kubectl apply -f "$ROOT_DIR/k8s/base/"

echo "==> Installing helm charts (local chart preferred, otherwise use official repos)"

# helper to uninstall release if exists (cleanup bad/partial installs)
safe_uninstall() {
  local name=$1
  local ns=$2
  if helm status "$name" -n "$ns" >/dev/null 2>&1; then
    echo "  -> Uninstalling existing Helm release $name in namespace $ns"
    helm uninstall "$name" -n "$ns" || true
  fi
}

# ARGOCD: prefer local chart if Chart.yaml exists, else install from repo
if [ -f "$ROOT_DIR/k8s/apps/argocd/Chart.yaml" ]; then
  echo "  -> Found local chart for argocd, installing local chart"
  safe_uninstall argocd argocd
  helm upgrade --install argocd "$ROOT_DIR/k8s/apps/argocd" --namespace argocd --create-namespace || true
else
  echo "  -> No local chart found for argocd, installing from official helm repo"
  safe_uninstall argocd argocd
  helm repo add argo https://argoproj.github.io/argo-helm || true
  helm repo update
  # use values.yaml if present
  if [ -f "$ROOT_DIR/k8s/apps/argocd/values.yaml" ]; then
    helm upgrade --install argocd argo/argo-cd -n argocd --create-namespace -f "$ROOT_DIR/k8s/apps/argocd/values.yaml" || true
  else
    helm upgrade --install argocd argo/argo-cd -n argocd --create-namespace || true
  fi
fi

# PROMETHEUS+GRAFANA: prefer local chart if Chart.yaml exists, else install kube-prometheus-stack
if [ -f "$ROOT_DIR/k8s/apps/prometheus-grafana/Chart.yaml" ]; then
  echo "  -> Found local chart for prometheus-grafana, installing local chart"
  safe_uninstall monitoring monitoring
  helm upgrade --install monitoring "$ROOT_DIR/k8s/apps/prometheus-grafana" --namespace monitoring --create-namespace || true
else
  echo "  -> No local chart found for prometheus-grafana, installing kube-prometheus-stack from repo"
  safe_uninstall monitoring monitoring
  helm repo add prometheus-community https://prometheus-community.github.io/helm-charts || true
  helm repo update
  if [ -f "$ROOT_DIR/k8s/apps/prometheus-grafana/values.yaml" ]; then
    helm upgrade --install monitoring prometheus-community/kube-prometheus-stack -n monitoring --create-namespace -f "$ROOT_DIR/k8s/apps/prometheus-grafana/values.yaml" || true
  else
    helm upgrade --install monitoring prometheus-community/kube-prometheus-stack -n monitoring --create-namespace || true
  fi
fi

echo "==> Wait for deployments to become available (argocd & monitoring)"

wait_for_ns_deployments() {
  local ns=$1
  echo "  -> Waiting for deployments in namespace: $ns"
  deployments=$(kubectl -n "$ns" get deployments -o name 2>/dev/null || true)
  if [ -z "$deployments" ]; then
    echo "     (no deployments found in $ns — continuing)"
    return 0
  fi

  for dep in $deployments; do
    echo "     waiting for $dep ..."
    kubectl -n "$ns" rollout status "$dep" --timeout=180s || {
      echo "     Timeout waiting for $dep — printing pod status in $ns"
      kubectl -n "$ns get pods -o wide || true"
    }
  done
}

wait_for_ns_deployments argocd || true
wait_for_ns_deployments monitoring || true

echo "==> Final pod status (all namespaces)"
kubectl get pods -A

echo "Local kind setup complete. To access, add entries in /etc/hosts for ingress hosts (e.g. argocd.local -> 127.0.0.1), or use port-forwarding."
