# sk1

A local Kubernetes microservices cluster running on Minikube with 5 services managed via Kustomize overlays.

## Services

- `api-gateway` — entry point, NodePort :80
- `user-service`
- `product-service`
- `order-service`
- `notification-service`

## Setup

```bash
make venv       # create Python virtualenv
make install    # install dev dependencies
```

Minikube must be running before building or deploying.

## Build

```bash
make build TAG=<tag>   # builds all 5 Docker images into minikube's registry
# example: make build TAG=v1.0
```

Images are built directly into Minikube's Docker daemon (`minikube docker-env`) so no registry push is needed.

## Deploy

```bash
make deploy-dev          # deploy to dev (runs v3.0 by default)
make deploy-staging      # deploy to staging (runs v2.0 by default)
make deploy-production   # deploy to production (runs v1.0 by default)
```

Deployments use Kustomize overlays under `k8s/overlays/<env>/`. Each environment gets its own namespace per service (e.g. `dev-api-gateway`, `staging-user-service`).

## Creating new environments

Use the `new-env` skill:

```
/new-env <env-name>                    # scaffold from base
/new-env <env-name> --from <source>    # copy an existing environment
```

Examples:
```
/new-env sit --from dev
/new-env luat --from staging
```

The skill inspects the cluster, creates the kustomize overlay, deploys it, and confirms the namespaces are active.

See [skills/new-env/SKILL.md](skills/new-env/SKILL.md) for full details.

## Deleting environments

```bash
make delete-dev
make delete-staging
make delete-production
```

## Overlay structure

```
k8s/
  base/              # base manifests for all services
  overlays/
    dev/             # pinned to image tag v3.0
    staging/         # pinned to image tag v2.0
    production/      # pinned to image tag v1.0
    <dynamic>/       # ephemeral envs created by /new-env (gitignored)
```

## Code style

```bash
make lint    # ruff linter
make test    # pytest
```
