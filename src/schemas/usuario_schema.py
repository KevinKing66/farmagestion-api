from datetime import datetime
from pydantic import BaseModel, EmailStr, Field
from typing import Literal, Optional

class Login(BaseModel):
    correo: EmailStr
    password: str = Field(..., max_length=150)

class UsuarioBase(BaseModel):
    nombre_completo: str = Field(..., max_length=150)
    correo: EmailStr

class UsuarioCreate(UsuarioBase):
    contrasena: str = Field(..., max_length=255)
    rol: Literal["AUXILIAR", "REGENTE", "AUDITOR", "ADMIN"] = Field("ADMIN", max_length=255)

class UsuarioUpdate(BaseModel):
    nombre_completo: Optional[str]
    correo: Optional[EmailStr]
    rol: Optional[Literal["AUXILIAR", "REGENTE", "AUDITOR", "ADMIN"]]
    contrasena: Optional[str]
    
class UsuarioResponse(UsuarioBase):
    id: int
    rol: Literal["AUXILIAR", "REGENTE", "AUDITOR", "ADMIN"]
    bloqueado_hasta: Optional[datetime] 
