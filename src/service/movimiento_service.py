from src.config.database import get_connection

def get_all():
    conn = get_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("""
        SELECT mv.id_movimiento, mv.tipo, mv.cantidad, mv.fecha,
               mv.motivo, l.codigo_lote, u.usuario AS usuario,
               ori.nombre AS origen, des.nombre AS destino
        FROM movimientos_v2 mv
        JOIN lotes l ON mv.id_lote = l.id_lote
        JOIN usuarios u ON mv.id_usuario = u.id_usuario
        LEFT JOIN ubicaciones ori ON mv.id_ubicacion_origen = ori.id_ubicacion
        LEFT JOIN ubicaciones des ON mv.id_ubicacion_destino = des.id_ubicacion
        ORDER BY mv.fecha DESC
    """)
    result = cursor.fetchall()
    cursor.close()
    conn.close()
    return result


def insert_movimiento(
    id_lote,
    id_usuario,
    tipo,
    cantidad,
    id_ubicacion_origen,
    id_ubicacion_destino,
    motivo
):
    conn = get_connection()
    cursor = conn.cursor()
    cursor.callproc("sp_registrar_movimiento", [
        id_lote,
        id_usuario,
        tipo,
        cantidad,
        id_ubicacion_origen,
        id_ubicacion_destino,
        motivo
    ])
    conn.commit()
    cursor.close()
    conn.close()


def get_by_lote(id_lote):
    conn = get_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("""
        SELECT * FROM movimientos_v2 WHERE id_lote = %s ORDER BY fecha DESC
    """, (id_lote,))
    result = cursor.fetchall()
    cursor.close()
    conn.close()
    return result
