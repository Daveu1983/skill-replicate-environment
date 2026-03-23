#!/usr/bin/env bash
set -euo pipefail

ENV_NAME="${1:-}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"

if [[ -z "$ENV_NAME" ]]; then
  echo "Usage: $0 <env-name>"
  exit 1
fi

OVERLAY="${ROOT}/k8s/overlays/${ENV_NAME}"
if [[ ! -d "$OVERLAY" ]]; then
  echo "Error: overlay '${ENV_NAME}' not found at ${OVERLAY}"
  exit 1
fi

echo "Deleting environment '${ENV_NAME}'..."
kubectl delete -k "${OVERLAY}" --ignore-not-found=true
echo "Environment '${ENV_NAME}' deleted."
