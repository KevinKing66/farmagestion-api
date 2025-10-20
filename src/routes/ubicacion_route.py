from fastapi import APIRouter
from src.schemas.ubicacion_schema import UbicacionCreate, UbicacionUpdate
from src.controllers import ubicacion_controller

router = APIRouter(prefix="/ubicaciones")

@router.get("/")
def get_all():
    return ubicacion_controller.get_all()

@router.get("/{id_ubicacion}")
def get_one(id_ubicacion: int):
    return ubicacion_controller.get_one(id_ubicacion)

@router.post("/")
def create(data: UbicacionCreate):
    return ubicacion_controller.create(data)

@router.put("/{id_ubicacion}")
def update(id_ubicacion: int, data: UbicacionUpdate):
    return ubicacion_controller.update(id_ubicacion, data)

@router.delete("/{id_ubicacion}")
def delete(id_ubicacion: int):
    return ubicacion_controller.delete(id_ubicacion)
