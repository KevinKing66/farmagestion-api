from src.config.database import get_connection

def get_all_existencias():
    conn = get_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("""
        SELECT e.*, 
               l.codigo_lote,
               i.descripcion AS item_descripcion,
               u.nombre AS ubicacion_nombre
        FROM existencias e
        INNER JOIN lotes l ON e.id_lote = l.id_lote
        INNER JOIN items i ON l.id_item = i.id_item
        INNER JOIN ubicaciones u ON e.id_ubicacion = u.id_ubicacion
    """)
    result = cursor.fetchall()
    cursor.close()
    conn.close()
    return result


def get_existencia_by_id(id_existencia):
    conn = get_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("""
        SELECT e.*, 
               l.codigo_lote,
               i.descripcion AS item_descripcion,
               u.nombre AS ubicacion_nombre
        FROM existencias e
        INNER JOIN lotes l ON e.id_lote = l.id_lote
        INNER JOIN items i ON l.id_item = i.id_item
        INNER JOIN ubicaciones u ON e.id_ubicacion = u.id_ubicacion
        WHERE e.id_existencia = %s
    """, (id_existencia,))
    result = cursor.fetchone()
    cursor.close()
    conn.close()
    return result


def create_existencia(id_lote, id_ubicacion, saldo):
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute("""
        INSERT INTO existencias (id_lote, id_ubicacion, saldo)
        VALUES (%s, %s, %s)
    """, (id_lote, id_ubicacion, saldo))
    conn.commit()
    cursor.close()
    conn.close()


def update_existencia(id_existencia, id_lote, id_ubicacion, saldo):
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute("""
        UPDATE existencias
        SET id_lote=%s, id_ubicacion=%s, saldo=%s
        WHERE id_existencia=%s
    """, (id_lote, id_ubicacion, saldo, id_existencia))
    conn.commit()
    cursor.close()
    conn.close()


def delete_existencia(id_existencia):
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute("DELETE FROM existencias WHERE id_existencia=%s", (id_existencia,))
    conn.commit()
    cursor.close()
    conn.close()
