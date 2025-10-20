from src.schemas.ubicacion_schema import UbicacionCreate, UbicacionUpdate
from src.service import ubicacion_service

def get_all():
    return ubicacion_service.get_all_ubicaciones()

def get_one(id_ubicacion): 
    return ubicacion_service.get_ubicacion_by_id(id_ubicacion)

def create(data: UbicacionCreate):
    print("------------entraaaaaaaaaaaaaaaaaaa")
    
    ubicacion_service.create_ubicacion(
        data.nombre,
        data.tipo if data.tipo else "ALMACEN",
        data.activo if data.activo else 1
    )
    return {"message": "Ubicación creada correctamente"}

def update(id_ubicacion, data: UbicacionUpdate):
    ubicacion_service.update_ubicacion(
        id_ubicacion,
        data.nombre,
        data.tipo if data.tipo else "ALMACEN",
        data.activo if data.activo else 1
    )
    return {"message": "Ubicación actualizada correctamente"}

def delete(id_ubicacion):
    ubicacion_service.delete_ubicacion(id_ubicacion)
    return {"message": "Ubicación eliminada correctamente"}
