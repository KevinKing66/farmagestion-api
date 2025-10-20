from pydantic import BaseModel, Field

class ProveedorBase(BaseModel):
    nombre: str = Field(..., max_length=150)
    nit: str = Field(..., max_length=50)

class ProveedorCreate(ProveedorBase):
    pass

class ProveedorUpdate(ProveedorBase):
    pass

class ProveedorResponse(ProveedorBase):
    id_proveedor: int

    class Config:
        orm_mode = True
