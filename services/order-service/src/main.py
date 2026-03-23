import os
from fastapi import FastAPI

app = FastAPI(title="Order Service")

SERVICE_NAME = os.getenv("SERVICE_NAME", "order-service")
ENV_NAME = os.getenv("ENV_NAME", "default")

_orders: dict[int, dict] = {
    1: {"id": 1, "user_id": 1, "product_id": 2, "quantity": 2, "status": "shipped"},
    2: {"id": 2, "user_id": 2, "product_id": 1, "quantity": 5, "status": "pending"},
}


@app.get("/")
def root():
    return {"service": SERVICE_NAME, "environment": ENV_NAME, "status": "running"}


@app.get("/health")
def health():
    return {"status": "healthy"}


@app.get("/orders")
def list_orders():
    return {"environment": ENV_NAME, "orders": list(_orders.values())}


@app.get("/orders/{order_id}")
def get_order(order_id: int):
    order = _orders.get(order_id)
    if not order:
        from fastapi import HTTPException
        raise HTTPException(status_code=404, detail="Order not found")
    return order
