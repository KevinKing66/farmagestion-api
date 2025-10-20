from pydantic import BaseModel, Field
from typing import Literal

class UbicacionBase(BaseModel):
    nombre: str = Field(..., max_length=100)
    tipo: Literal["ALMACEN", "SERVICIO"] = "ALMACEN"
    activo: bool = True

class UbicacionCreate(UbicacionBase):
    pass

class UbicacionUpdate(UbicacionBase):
    pass

class UbicacionResponse(UbicacionBase):
    id_ubicacion: int

    class Config:
        orm_mode = True
