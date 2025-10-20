from pydantic import BaseModel

class ExistenciaBase(BaseModel):
    id_lote: int
    id_ubicacion: int
    saldo: int = 0

class ExistenciaCreate(ExistenciaBase):
    pass

class ExistenciaUpdate(BaseModel):
    saldo: int

class ExistenciaResponse(ExistenciaBase):
    id_existencia: int

    class Config:
        orm_mode = True
