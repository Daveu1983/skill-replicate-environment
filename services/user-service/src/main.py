import os
from fastapi import FastAPI

app = FastAPI(title="User Service")

SERVICE_NAME = os.getenv("SERVICE_NAME", "user-service")
ENV_NAME = os.getenv("ENV_NAME", "default")

_users: dict[int, dict] = {
    1: {"id": 1, "name": "Alice", "email": "alice@example.com"},
    2: {"id": 2, "name": "Bob",   "email": "bob@example.com"},
}


@app.get("/")
def root():
    return {"service": SERVICE_NAME, "environment": ENV_NAME, "status": "running"}


@app.get("/health")
def health():
    return {"status": "healthy"}


@app.get("/users")
def list_users():
    return {"environment": ENV_NAME, "users": list(_users.values())}


@app.get("/users/{user_id}")
def get_user(user_id: int):
    user = _users.get(user_id)
    if not user:
        from fastapi import HTTPException
        raise HTTPException(status_code=404, detail="User not found")
    return user
