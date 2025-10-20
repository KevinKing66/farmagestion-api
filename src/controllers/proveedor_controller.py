from src.service import proveedor_service

def get_all():
    return proveedor_service.get_all_proveedores()

def get_one(id_proveedor):
    return proveedor_service.get_proveedor_by_id(id_proveedor)

def create(data):
    proveedor_service.create_proveedor(
        data["nombre"],
        data["nit"]
    )
    return {"message": "Proveedor creado correctamente"}

def update(id_proveedor, data):
    proveedor_service.update_proveedor(
        id_proveedor,
        data["nombre"],
        data["nit"]
    )
    return {"message": "Proveedor actualizado correctamente"}

def delete(id_proveedor):
    proveedor_service.delete_proveedor(id_proveedor)
    return {"message": "Proveedor eliminado correctamente"}
