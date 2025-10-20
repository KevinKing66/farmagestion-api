class StgInventarioInicial:
    def __init__(
        self,
        codigo_item,
        nit_proveedor,
        codigo_lote,
        fecha_vencimiento,
        costo_unitario,
        nombre_ubicacion,
        cantidad
    ):
        self.codigo_item = codigo_item
        self.nit_proveedor = nit_proveedor
        self.codigo_lote = codigo_lote
        self.fecha_vencimiento = fecha_vencimiento
        self.costo_unitario = costo_unitario
        self.nombre_ubicacion = nombre_ubicacion
        self.cantidad = cantidad
