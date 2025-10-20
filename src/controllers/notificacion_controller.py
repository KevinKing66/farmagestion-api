from src.service import notificacion_service

def get_all():
    return notificacion_service.get_all_notificaciones()

def get_one(id_notificacion):
    return notificacion_service.get_notificacion_by_id(id_notificacion)

def create(data):
    notificacion_service.create_notificacion(
        data["tipo"],
        data["payload"],
        data.get("destinatario")
    )
    return {"message": "Notificación creada correctamente"}

def update_estado(id_notificacion, data):
    notificacion_service.update_estado(
        id_notificacion,
        data["estado"],
        data.get("detalle_error")
    )
    return {"message": "Estado de notificación actualizado correctamente"}

def delete(id_notificacion):
    notificacion_service.delete_notificacion(id_notificacion)
    return {"message": "Notificación eliminada correctamente"}
