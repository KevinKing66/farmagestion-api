from fastapi import FastAPI
from src.config.base import Base
from src.routes import auditoria_route

app = FastAPI(title="Farma Gestión Backend")


app.include_router(auditoria_route.router)