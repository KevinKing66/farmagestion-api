from fastapi import FastAPI
from src.config.base import Base
from src.routes import auditoria_route, comprobante_route

app = FastAPI(title="Farma Gestión Backend")


app.include_router(auditoria_route.router)
app.include_router(comprobante_route.router)
