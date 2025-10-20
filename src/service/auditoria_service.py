from src.config.database import get_connection

def get_all_auditorias():
    conn = get_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("""
        SELECT a.*, u.nombre_completo AS usuario_nombre
        FROM auditoria a
        LEFT JOIN usuarios u ON a.id_usuario = u.id_usuario
        ORDER BY a.fecha DESC
    """)
    result = cursor.fetchall()
    cursor.close()
    conn.close()
    return result


def get_auditoria_by_id(id_evento):
    conn = get_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("""
        SELECT a.*, u.nombre_completo AS usuario_nombre
        FROM auditoria a
        LEFT JOIN usuarios u ON a.id_usuario = u.id_usuario
        WHERE a.id_evento = %s
    """, (id_evento,))
    result = cursor.fetchone()
    cursor.close()
    conn.close()
    return result


def get_auditorias_by_tabla(tabla_afectada):
    conn = get_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("""
        SELECT a.*, u.nombre_completo AS usuario_nombre
        FROM auditoria a
        LEFT JOIN usuarios u ON a.id_usuario = u.id_usuario
        WHERE a.tabla_afectada = %s
        ORDER BY a.fecha DESC
    """, (tabla_afectada,))
    result = cursor.fetchall()
    cursor.close()
    conn.close()
    return result


def create_auditoria(tabla_afectada, pk_afectada, accion, valores_antes, valores_despues, id_usuario, hash_anterior, hash_evento):
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute("""
        INSERT INTO auditoria (
            tabla_afectada, pk_afectada, accion, valores_antes, valores_despues,
            id_usuario, hash_anterior, hash_evento
        )
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
    """, (tabla_afectada, pk_afectada, accion, valores_antes, valores_despues, id_usuario, hash_anterior, hash_evento))
    conn.commit()
    cursor.close()
    conn.close()


def delete_auditoria(id_evento):
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute("DELETE FROM auditoria WHERE id_evento=%s", (id_evento,))
    conn.commit()
    cursor.close()
    conn.close()
