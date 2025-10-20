from fastapi import APIRouter
from src.controllers import stg_inventario_controller

router = APIRouter(prefix="/stg_inventario")

@router.get("/")
def get_all():
    return stg_inventario_controller.get_all()

@router.post("/")
def create(data: dict):
    return stg_inventario_controller.create(data)

@router.post("/bulk")
def bulk_create(data: list):
    return stg_inventario_controller.bulk_create(data)

@router.delete("/")
def delete_all():
    return stg_inventario_controller.delete_all()
