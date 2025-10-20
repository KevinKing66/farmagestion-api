class Notificacion:
    def __init__(
        self,
        id_notificacion,
        tipo,
        payload,
        destinatario,
        estado,
        detalle_error,
        fecha_creacion,
        fecha_envio
    ):
        self.id_notificacion = id_notificacion
        self.tipo = tipo
        self.payload = payload
        self.destinatario = destinatario
        self.estado = estado
        self.detalle_error = detalle_error
        self.fecha_creacion = fecha_creacion
        self.fecha_envio = fecha_envio
