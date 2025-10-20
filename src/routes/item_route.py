from fastapi import APIRouter
from src.controllers import item_controller

router = APIRouter(prefix="/items")

@router.get("/")
def get_all():
    return item_controller.get_all()

@router.get("/{id_item}")
def get_one(id_item: int):
    return item_controller.get_one(id_item)

@router.post("/")
def create(data: dict):
    return item_controller.create(data)

@router.put("/{id_item}")
def update(id_item: int, data: dict):
    return item_controller.update(id_item, data)

@router.delete("/{id_item}")
def delete(id_item: int):
    return item_controller.delete(id_item)


@router.put("/change-location/{id}")
def change_location(id: int, data: dict):
    return item_controller.update_location(id, data)
