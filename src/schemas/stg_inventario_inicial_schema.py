from pydantic import BaseModel, Field
from datetime import date

class StgInventarioInicial(BaseModel):
    codigo_item: str = Field(..., max_length=50)
    nit_proveedor: str = Field(..., max_length=50)
    codigo_lote: str = Field(..., max_length=50)
    fecha_vencimiento: date
    costo_unitario: float
    nombre_ubicacion: str = Field(..., max_length=100)
    cantidad: int = Field(..., gt=0)
