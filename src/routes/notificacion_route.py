from fastapi import APIRouter
from src.controllers import notificacion_controller

router = APIRouter(prefix="/notificaciones")

@router.get("/")
def get_all():
    return notificacion_controller.get_all()

@router.get("/{id_notificacion}")
def get_one(id_notificacion: int):
    return notificacion_controller.get_one(id_notificacion)

@router.post("/")
def create(data: dict):
    return notificacion_controller.create(data)

@router.put("/{id_notificacion}/estado")
def update_estado(id_notificacion: int, data: dict):
    return notificacion_controller.update_estado(id_notificacion, data)

@router.delete("/{id_notificacion}")
def delete(id_notificacion: int):
    return notificacion_controller.delete(id_notificacion)
