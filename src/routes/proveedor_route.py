from fastapi import APIRouter
from src.controllers import proveedor_controller

router = APIRouter(prefix="/proveedores")

@router.get("/")
def get_all():
    return proveedor_controller.get_all()

@router.get("/{id_proveedor}")
def get_one(id_proveedor: int):
    return proveedor_controller.get_one(id_proveedor)

@router.post("/")
def create(data: dict):
    return proveedor_controller.create(data)

@router.put("/{id_proveedor}")
def update(id_proveedor: int, data: dict):
    return proveedor_controller.update(id_proveedor, data)

@router.delete("/{id_proveedor}")
def delete(id_proveedor: int):
    return proveedor_controller.delete(id_proveedor)
