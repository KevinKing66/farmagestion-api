class Auditoria:
    def __init__(
        self,
        id_evento,
        tabla_afectada,
        pk_afectada,
        accion,
        valores_antes,
        valores_despues,
        id_usuario,
        fecha,
        hash_anterior,
        hash_evento
    ):
        self.id_evento = id_evento
        self.tabla_afectada = tabla_afectada
        self.pk_afectada = pk_afectada
        self.accion = accion
        self.valores_antes = valores_antes
        self.valores_despues = valores_despues
        self.id_usuario = id_usuario
        self.fecha = fecha
        self.hash_anterior = hash_anterior
        self.hash_evento = hash_evento
