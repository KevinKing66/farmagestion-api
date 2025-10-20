from pydantic import BaseModel
from typing import Literal, Optional, Any

class NotificacionBase(BaseModel):
    tipo: Literal["ALERTA_VENCIMIENTO", "ALERTA_STOCK_BAJO"]
    payload: Any
    destinatario: Optional[str] = None
    estado: Literal["PENDIENTE", "ENVIADA", "ERROR"] = "PENDIENTE"
    detalle_error: Optional[str] = None

class NotificacionCreate(NotificacionBase):
    pass

class NotificacionResponse(NotificacionBase):
    id_notificacion: int
    fecha_creacion: str
    fecha_envio: Optional[str]

    class Config:
        orm_mode = True
