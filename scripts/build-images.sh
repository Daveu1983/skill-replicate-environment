#!/usr/bin/env bash
set -euo pipefail

SERVICES=(api-gateway user-service product-service order-service notification-service)
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TAG="${1:-}"

if [[ -z "$TAG" ]]; then
  echo "Usage: $0 <tag>"
  echo "Example: $0 v1.2.0"
  exit 1
fi

echo "Pointing Docker to minikube's daemon..."
eval "$(minikube docker-env)"

for SVC in "${SERVICES[@]}"; do
  echo "Building ${SVC}:${TAG} ..."
  docker build -t "${SVC}:${TAG}" "${ROOT}/services/${SVC}/"
done

echo "All images built with tag: ${TAG}"
