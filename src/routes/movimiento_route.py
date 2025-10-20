from fastapi import APIRouter
from src.controllers import movimiento_controller

router = APIRouter(prefix="/movimientos")

@router.get("/")
def get_all():
    return movimiento_controller.get_all()

@router.get("/lote/{id_lote}")
def get_by_lote(id_lote: int):
    return movimiento_controller.get_by_lote(id_lote)

@router.post("/")
def create(data: dict):
    return movimiento_controller.create(data)
