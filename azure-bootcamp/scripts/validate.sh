#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

# quick binary checks
command -v terraform >/dev/null 2>&1 || { echo "terraform not found in PATH"; exit 1; }
command -v kubectl >/dev/null 2>&1 || { echo "kubectl not found in PATH"; exit 1; }

cd "$ROOT_DIR/infra/terraform" || exit 1

echo "=== terraform init ==="
terraform init -input=false

echo "=== terraform validate ==="
terraform validate

TFVARS_REL="envs/dev/terraform.tfvars"
if [ -f "$TFVARS_REL" ]; then
  echo "=== terraform plan (offline: -refresh=false) using $TFVARS_REL ==="

  # If az is installed, only run terraform plan when az login exists.
  # This avoids the azurerm provider failing when no Azure auth is set up.
  if command -v az >/dev/null 2>&1; then
    if az account show >/dev/null 2>&1; then
      echo "Azure CLI logged in — running terraform plan"
      terraform plan -refresh=false -var-file="$TFVARS_REL" -out=plan.tfplan || true
    else
      echo "Azure CLI found but not logged in — skipping terraform plan."
      echo "Run 'az login' (or set ARM_* env vars for a service principal) to enable terraform plan/apply."
    fi
  else
    echo "Azure CLI not installed — skipping terraform plan."
    echo "Install Azure CLI or run terraform plan manually with proper authentication if needed."
  fi

else
  echo "=== WARNING: variables file not found: $TFVARS_REL ==="
  echo "Skipping terraform plan. Create the file '$ROOT_DIR/infra/terraform/$TFVARS_REL' or update the script to point to your tfvars."
fi

echo "=== kubectl dry-run apply for k8s manifests ==="
cd "$ROOT_DIR"

# Only run kubectl apply dry-run if kubectl has a usable current-context
if kubectl version --client >/dev/null 2>&1; then
  # check if there is a current context and that the server is reachable (quick non-blocking check)
  CURRENT_CTX="$(kubectl config current-context 2>/dev/null || true)"
  if [ -n "$CURRENT_CTX" ]; then
    # attempt to contact server API (short timeout)
    if kubectl get --raw="/healthz" >/dev/null 2>&1; then
      echo "kubectl context is set to '$CURRENT_CTX' and cluster is reachable — running dry-run"
      kubectl apply -f k8s/base/ --dry-run=client
    else
      echo "kubectl context '$CURRENT_CTX' found but cluster API unreachable — skipping kubectl dry-run."
      echo "If you want to validate manifests locally, create a local cluster (kind/microk8s) or get credentials for your cluster."
    fi
  else
    echo "kubectl has no current context — skipping kubectl dry-run."
    echo "Use 'kubectl config use-context <ctx>' or 'az aks get-credentials' after creating a cluster to enable manifest validation."
  fi
else
  echo "kubectl client not functional — skipping kubectl dry-run."
fi

echo "Validation complete."
