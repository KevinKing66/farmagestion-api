from src.service import movimiento_service

def get_all():
    return movimiento_service.get_all()

def create(data):
    movimiento_service.insert_movimiento(
        data["id_lote"],
        data["id_usuario"],
        data["tipo"],
        data["cantidad"],
        data.get("id_ubicacion_origen"),
        data.get("id_ubicacion_destino"),
        data.get("motivo")
    )
    return {"message": "Movimiento registrado correctamente"}

def get_by_lote(id_lote: int):
    return movimiento_service.get_by_lote(id_lote)
