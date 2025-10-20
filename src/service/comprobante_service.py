from src.config.database import get_connection

def get_all():
    conn = get_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("""
        SELECT c.id_comprobante, c.id_movimiento, c.id_proveedor,
               p.nombre AS proveedor, c.canal, c.entregado,
               c.fecha_creacion, c.fecha_entrega
        FROM comprobantes_recepcion c
        JOIN proveedores p ON c.id_proveedor = p.id_proveedor
        ORDER BY c.fecha_creacion DESC
    """)
    result = cursor.fetchall()
    cursor.close()
    conn.close()
    return result


def get_by_id(id_comprobante):
    conn = get_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("""
        SELECT * FROM comprobantes_recepcion WHERE id_comprobante = %s
    """, (id_comprobante,))
    result = cursor.fetchone()
    cursor.close()
    conn.close()
    return result


def create_comprobante(id_movimiento, id_proveedor, canal):
    conn = get_connection()
    cursor = conn.cursor()
    cursor.callproc("sp_crear_comprobante_recepcion", [id_movimiento, id_proveedor, canal])
    conn.commit()
    cursor.close()
    conn.close()


def marcar_entregado(id_comprobante):
    """
    Marca el comprobante como entregado.
    """
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute("""
        UPDATE comprobantes_recepcion
        SET entregado = 1, fecha_entrega = NOW()
        WHERE id_comprobante = %s
    """, (id_comprobante,))
    conn.commit()
    cursor.close()
    conn.close()


def delete_comprobante(id_comprobante):
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute("DELETE FROM comprobantes_recepcion WHERE id_comprobante = %s", (id_comprobante,))
    conn.commit()
    cursor.close()
    conn.close()
