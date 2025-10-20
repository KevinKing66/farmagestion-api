class ComprobanteRecepcion:
    def __init__(
        self,
        id_movimiento,
        id_proveedor,
        canal="PORTAL",
        entregado=False,
        fecha_entrega=None
    ):
        self.id_movimiento = id_movimiento
        self.id_proveedor = id_proveedor
        self.canal = canal
        self.entregado = entregado
        self.fecha_entrega = fecha_entrega
