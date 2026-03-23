---
name: new-env
description: Use this skill when the user wants to create a new Kubernetes environment, clone an existing environment, deploy to a new namespace, or spin up a new environment in the cluster. Triggered by phrases like "create a new environment", "new env", "spin up env", "clone staging", "copy dev to", or "/new-env".
compatibility: Requires kubectl configured and pointing at a running cluster. Project must use kustomize overlays under k8s/overlays/.
metadata:
  author: Dave
  version: "1.1"
---

# new-env

Create a new Kubernetes environment overlay and deploy it to the cluster, either scaffolded from base or copied from an existing environment. All overlay files are created directly using the Write tool — no external scripts required.

## Usage

```
/new-env <env-name>
/new-env <env-name> --from <source-env>
```

**Examples:**
```
/new-env sit
/new-env sit --from dev
/new-env luat --from staging
/new-env luat --staging        # shorthand for --from staging
```

## Services

The five services in this project are:
`api-gateway`, `user-service`, `product-service`, `order-service`, `notification-service`

## Instructions

### Step 1 — Parse arguments

- First token = new environment name (e.g. `sit`)
- `--from <source-env>` = copy from an existing overlay instead of scaffolding from base
- Any shorthand like `--staging` means `--from staging`
- If no name provided, ask the user before continuing

### Step 2 — Inspect the cluster

Run both commands and summarise findings for the user:

```bash
kubectl get namespaces
kubectl get deployments --all-namespaces -o custom-columns='NAMESPACE:.metadata.namespace,NAME:.metadata.name,IMAGE:.spec.template.spec.containers[0].image'
```

Report: existing environments (namespace prefixes), services running, and image tags in use.

### Step 3 — Create the overlay

**Without `--from`** — scaffold from base by creating these files for each service using the Write tool:

`k8s/overlays/<env-name>/versions.env`:
```
api-gateway=latest
user-service=latest
product-service=latest
order-service=latest
notification-service=latest
```

`k8s/overlays/<env-name>/kustomization.yaml`:
```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - api-gateway
  - user-service
  - product-service
  - order-service
  - notification-service
```

For each service, create `k8s/overlays/<env-name>/<service>/namespace.yaml`:
```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: <env-name>-<service>
  labels:
    environment: <env-name>
    service: <service>
```

For each service, create `k8s/overlays/<env-name>/<service>/kustomization.yaml`:
```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

namespace: <env-name>-<service>

resources:
  - ../../../base/<service>
  - namespace.yaml

patches:
  - patch: |-
      apiVersion: apps/v1
      kind: Deployment
      metadata:
        name: <service>
      spec:
        template:
          spec:
            containers:
              - name: <service>
                env:
                  - name: ENV_NAME
                    value: "<env-name>"
    target:
      kind: Deployment
      name: <service>
```

Stop and tell the user if `k8s/overlays/<env-name>/` already exists.

**With `--from <source-env>`** — copy an existing overlay:

1. Verify `k8s/overlays/<source-env>/` exists — stop if not
2. Verify `k8s/overlays/<env-name>/` does not exist — stop if it does

3. **Check live image versions** in the cluster for the source environment and compare against its `versions.env`:

```bash
kubectl get deployments --all-namespaces -o custom-columns='NAMESPACE:.metadata.namespace,NAME:.metadata.name,IMAGE:.spec.template.spec.containers[0].image' \
  | grep "^<source-env>-"
```

For each service, extract the live image tag (the part after `:` in the IMAGE column). Compare each against the tag in `k8s/overlays/<source-env>/versions.env`. If any live tag differs from the overlay tag, tell the user which services have drifted and use the **live tag** as the authoritative version.

4. Copy and substitute all occurrences of the source env name with the new env name:

```bash
cp -r k8s/overlays/<source-env> k8s/overlays/<env-name>
find k8s/overlays/<env-name> \( -name "*.yaml" -o -name "*.env" \) -exec sed -i 's/<source-env>/<env-name>/g' {} +
```

5. Overwrite `k8s/overlays/<env-name>/versions.env` with the live tags resolved in step 3 (not the overlay file tags), one per line in `service=tag` format.

Tell the user what was copied, what was substituted, and whether any live versions differed from the overlay.

### Step 4 — Deploy

```bash
./scripts/deploy-env.sh <env-name>
```

### Step 5 — Confirm

```bash
kubectl get namespaces -l environment=<env-name>
```

Report the resulting namespaces and status to the user.
