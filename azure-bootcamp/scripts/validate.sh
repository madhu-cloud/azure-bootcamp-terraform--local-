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
  terraform plan -refresh=false -var-file="$TFVARS_REL" -out=plan.tfplan || true
else
  echo "=== WARNING: variables file not found: $TFVARS_REL ==="
  echo "Skipping terraform plan. Create the file '$ROOT_DIR/infra/terraform/$TFVARS_REL' or update the script to point to your tfvars."
fi

echo "=== kubectl dry-run apply for k8s manifests ==="
cd "$ROOT_DIR"
kubectl apply -f k8s/base/ --dry-run=client

echo "Validation complete."
