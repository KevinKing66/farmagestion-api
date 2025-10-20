from src.service import existencia_service

def get_all():
    return existencia_service.get_all_existencias()

def get_one(id_existencia):
    return existencia_service.get_existencia_by_id(id_existencia)

def create(data):
    existencia_service.create_existencia(
        data["id_lote"],
        data["id_ubicacion"],
        data["saldo"]
    )
    return {"message": "Existencia creada correctamente"}

def update(id_existencia, data):
    existencia_service.update_existencia(
        id_existencia,
        data["id_lote"],
        data["id_ubicacion"],
        data["saldo"]
    )
    return {"message": "Existencia actualizada correctamente"}

def delete(id_existencia):
    existencia_service.delete_existencia(id_existencia)
    return {"message": "Existencia eliminada correctamente"}
