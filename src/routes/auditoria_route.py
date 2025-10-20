from fastapi import APIRouter
from src.schemas.auditoria_schema import AuditoriaBase
from src.controllers import auditoria_controller

router = APIRouter(prefix="/auditoria")

@router.get("/")
def get_all():
    return auditoria_controller.get_all()

@router.get("/{id_evento}")
def get_one(id_evento: int):
    return auditoria_controller.get_one(id_evento)

@router.get("/tabla/{tabla_afectada}")
def get_by_tabla(tabla_afectada: str):
    return auditoria_controller.get_by_tabla(tabla_afectada)

@router.post("/")
def create(data: AuditoriaBase):
    return auditoria_controller.create(data)

@router.delete("/{id_evento}")
def delete(id_evento: int):
    return auditoria_controller.delete(id_evento)
