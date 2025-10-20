from src.schemas.auditoria_schema import AuditoriaBase
from src.service import auditoria_service

def get_all():
    return auditoria_service.get_all_auditorias()

def get_one(id_evento):
    return auditoria_service.get_auditoria_by_id(id_evento)

def get_by_tabla(tabla_afectada: str):
    return auditoria_service.get_auditorias_by_tabla(tabla_afectada)

def create(data:AuditoriaBase):
    auditoria_service.create_auditoria(
        data.tabla_afectada,
        data.pk_afectada,
        data.accion,
        data.valores_antes,
        data.valores_despues,
        data.id_usuario,
        data.hash_anterior,
        data.hash_evento
    )
    return {"message": "Evento de auditoría registrado correctamente"}

def delete(id_evento):
    auditoria_service.delete_auditoria(id_evento)
    return {"message": f"Evento de auditoría con id {id_evento} eliminado correctamente"}
