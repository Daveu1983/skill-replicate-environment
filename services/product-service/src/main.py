import os
from fastapi import FastAPI

app = FastAPI(title="Product Service")

SERVICE_NAME = os.getenv("SERVICE_NAME", "product-service")
ENV_NAME = os.getenv("ENV_NAME", "default")

_products: dict[int, dict] = {
    1: {"id": 1, "name": "Widget A", "price": 9.99,  "stock": 100},
    2: {"id": 2, "name": "Widget B", "price": 19.99, "stock": 50},
    3: {"id": 3, "name": "Gadget X", "price": 49.99, "stock": 25},
}


@app.get("/")
def root():
    return {"service": SERVICE_NAME, "environment": ENV_NAME, "status": "running"}


@app.get("/health")
def health():
    return {"status": "healthy"}


@app.get("/products")
def list_products():
    return {"environment": ENV_NAME, "products": list(_products.values())}


@app.get("/products/{product_id}")
def get_product(product_id: int):
    product = _products.get(product_id)
    if not product:
        from fastapi import HTTPException
        raise HTTPException(status_code=404, detail="Product not found")
    return product
