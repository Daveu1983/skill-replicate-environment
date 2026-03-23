#!/usr/bin/env bash
set -euo pipefail

ENV_NAME="${1:-}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"

if [[ -z "$ENV_NAME" ]]; then
  echo "Usage: $0 <env-name>"
  echo "Example: $0 dev"
  exit 1
fi

OVERLAY="${ROOT}/k8s/overlays/${ENV_NAME}"
if [[ ! -d "$OVERLAY" ]]; then
  echo "Error: overlay '${ENV_NAME}' not found at ${OVERLAY}"
  echo "Run './scripts/create-env.sh ${ENV_NAME}' to create it first."
  exit 1
fi

if [[ -f "${OVERLAY}/versions.env" ]]; then
  echo "Injecting image versions from versions.env..."
  python3 - "${OVERLAY}" << 'PYEOF'
import sys, re

overlay = sys.argv[1]
versions = {}
with open(f"{overlay}/versions.env") as f:
    for line in f:
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        svc, tag = line.split("=", 1)
        versions[svc] = tag

kustomization = f"{overlay}/kustomization.yaml"
with open(kustomization) as f:
    content = f.read()

# Strip existing images block if present
content = re.sub(r"\nimages:.*", "", content, flags=re.DOTALL)
content = content.rstrip() + "\n"

# Append fresh images block
images_block = "\nimages:\n"
for svc, tag in versions.items():
    images_block += f"  - name: {svc}\n    newTag: \"{tag}\"\n"
content += images_block

with open(kustomization, "w") as f:
    f.write(content)

print(f"  Set images: { {s: t for s, t in versions.items()} }")
PYEOF
fi

echo "Deploying environment '${ENV_NAME}'..."
kubectl apply -k "${OVERLAY}"
echo "Done. Namespaces created:"
kubectl get namespaces -l "environment=${ENV_NAME}"
