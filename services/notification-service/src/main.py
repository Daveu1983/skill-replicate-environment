import os
from datetime import datetime
from fastapi import FastAPI

app = FastAPI(title="Notification Service")

SERVICE_NAME = os.getenv("SERVICE_NAME", "notification-service")
ENV_NAME = os.getenv("ENV_NAME", "default")

_notifications: list[dict] = [
    {"id": 1, "user_id": 1, "type": "email", "message": "Your order has shipped!", "sent_at": "2024-01-01T10:00:00"},
    {"id": 2, "user_id": 2, "type": "sms",   "message": "Order confirmed.",         "sent_at": "2024-01-02T09:30:00"},
]


@app.get("/")
def root():
    return {"service": SERVICE_NAME, "environment": ENV_NAME, "status": "running"}


@app.get("/health")
def health():
    return {"status": "healthy"}


@app.get("/notifications")
def list_notifications():
    return {"environment": ENV_NAME, "notifications": _notifications}


@app.post("/notifications")
def send_notification(user_id: int, type: str, message: str):
    notification = {
        "id": len(_notifications) + 1,
        "user_id": user_id,
        "type": type,
        "message": message,
        "sent_at": datetime.utcnow().isoformat(),
    }
    _notifications.append(notification)
    return notification
