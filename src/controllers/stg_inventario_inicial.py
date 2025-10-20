from src.service import stg_inventario_service

def get_all():
    return stg_inventario_service.get_all_registros()

def create(data):
    stg_inventario_service.insert_registro(
        data["codigo_item"],
        data["nit_proveedor"],
        data["codigo_lote"],
        data["fecha_vencimiento"],
        data["costo_unitario"],
        data["nombre_ubicacion"],
        data["cantidad"]
    )
    return {"message": "Registro cargado correctamente"}

def bulk_create(lista):
    stg_inventario_service.bulk_insert(lista)
    return {"message": f"{len(lista)} registros cargados correctamente"}

def delete_all():
    stg_inventario_service.delete_all()
    return {"message": "Tabla staging vaciada correctamente"}
