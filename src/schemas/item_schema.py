from pydantic import BaseModel, Field
from typing import Literal

class ItemBase(BaseModel):
    id_ubicacion: int
    codigo: str | None = None
    descripcion: str = Field(..., max_length=255)
    tipo_item: Literal["MEDICAMENTO", "DISPOSITIVO"]
    unidad_medida: str = "UND"
    stock_minimo: int = 0

class ItemCreate(ItemBase):
    pass

class ItemUpdate(ItemBase):
    pass

class ItemResponse(ItemBase):
    id_item: int

    class Config:
        orm_mode = True
