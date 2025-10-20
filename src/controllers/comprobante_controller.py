from src.service import comprobante_service

def get_all():
    return comprobante_service.get_all()

def get_one(id_comprobante):
    return comprobante_service.get_by_id(id_comprobante)

def create(data):
    comprobante_service.create_comprobante(
        data["id_movimiento"],
        data["id_proveedor"],
        data.get("canal", "PORTAL")
    )
    return {"message": "Comprobante registrado correctamente"}

def marcar_entregado(id_comprobante):
    comprobante_service.marcar_entregado(id_comprobante)
    return {"message": "Comprobante marcado como entregado"}

def delete(id_comprobante):
    comprobante_service.delete_comprobante(id_comprobante)
    return {"message": "Comprobante eliminado correctamente"}
