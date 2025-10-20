from fastapi import APIRouter
from src.controllers import existencia_controller

router = APIRouter(prefix="/existencias")

@router.get("/")
def get_all():
    return existencia_controller.get_all()

@router.get("/{id_existencia}")
def get_one(id_existencia: int):
    return existencia_controller.get_one(id_existencia)

@router.post("/")
def create(data: dict):
    return existencia_controller.create(data)

@router.put("/{id_existencia}")
def update(id_existencia: int, data: dict):
    return existencia_controller.update(id_existencia, data)

@router.delete("/{id_existencia}")
def delete(id_existencia: int):
    return existencia_controller.delete(id_existencia)
