from pydantic import BaseModel
from typing import Optional, Literal, Any

class AuditoriaBase(BaseModel):
    tabla_afectada: str
    pk_afectada: str
    accion: Literal["INSERT", "UPDATE", "DELETE"]
    valores_antes: Optional[Any] = None
    valores_despues: Optional[Any] = None
    id_usuario: Optional[int] = None
    hash_anterior: Optional[str] = None
    hash_evento: str

class AuditoriaResponse(AuditoriaBase):
    id_evento: int
    fecha: str

    class Config:
        orm_mode = True
