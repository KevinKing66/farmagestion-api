from pydantic import BaseModel
from typing import Literal, Optional

class ComprobanteBase(BaseModel):
    id_movimiento: int
    id_proveedor: int
    canal: Literal["PORTAL", "EMAIL"] = "PORTAL"

class ComprobanteCreate(ComprobanteBase):
    pass

class ComprobanteResponse(ComprobanteBase):
    id_comprobante: int
    entregado: bool
    fecha_creacion: str
    fecha_entrega: Optional[str]

    class Config:
        orm_mode = True
