import os
from fastapi import FastAPI

app = FastAPI(title="API Gateway")

SERVICE_NAME = os.getenv("SERVICE_NAME", "api-gateway")
ENV_NAME = os.getenv("ENV_NAME", "default")

UPSTREAM_SERVICES = {
    "user":         f"http://user-service.{ENV_NAME}-user-service.svc.cluster.local",
    "product":      f"http://product-service.{ENV_NAME}-product-service.svc.cluster.local",
    "order":        f"http://order-service.{ENV_NAME}-order-service.svc.cluster.local",
    "notification": f"http://notification-service.{ENV_NAME}-notification-service.svc.cluster.local",
}


@app.get("/")
def root():
    return {
        "service": SERVICE_NAME,
        "environment": ENV_NAME,
        "status": "running",
        "upstreams": UPSTREAM_SERVICES,
    }


@app.get("/health")
def health():
    return {"status": "healthy"}


@app.get("/services")
def list_services():
    return {"environment": ENV_NAME, "services": list(UPSTREAM_SERVICES.keys())}
