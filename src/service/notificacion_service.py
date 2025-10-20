import json
from src.config.database import get_connection

def get_all_notificaciones():
    conn = get_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("""
        SELECT * 
        FROM notificaciones
        ORDER BY fecha_creacion DESC
    """)
    result = cursor.fetchall()
    cursor.close()
    conn.close()
    return result


def get_notificacion_by_id(id_notificacion):
    conn = get_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT * FROM notificaciones WHERE id_notificacion=%s", (id_notificacion,))
    result = cursor.fetchone()
    cursor.close()
    conn.close()
    return result


def create_notificacion(tipo, payload, destinatario=None):
    conn = get_connection()
    cursor = conn.cursor()
    payload_json = json.dumps(payload, ensure_ascii=False)
    cursor.execute("""
        INSERT INTO notificaciones (tipo, payload, destinatario)
        VALUES (%s, %s, %s)
    """, (tipo, payload_json, destinatario))
    conn.commit()
    cursor.close()
    conn.close()


def update_estado(id_notificacion, estado, detalle_error=None):
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute("""
        UPDATE notificaciones
        SET estado=%s, detalle_error=%s, fecha_envio=NOW()
        WHERE id_notificacion=%s
    """, (estado, detalle_error, id_notificacion))
    conn.commit()
    cursor.close()
    conn.close()


def delete_notificacion(id_notificacion):
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute("DELETE FROM notificaciones WHERE id_notificacion=%s", (id_notificacion,))
    conn.commit()
    cursor.close()
    conn.close()
