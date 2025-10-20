from src.config.database import get_connection

def get_all_items():
    conn = get_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("""
        SELECT i.*, u.nombre AS nombre_ubicacion
        FROM items i
        INNER JOIN ubicaciones u ON i.id_ubicacion = u.id_ubicacion
    """)
    result = cursor.fetchall()
    cursor.close()
    conn.close()
    return result


def get_item_by_id(id_item):
    conn = get_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("""
        SELECT i.*, u.nombre AS nombre_ubicacion
        FROM items i
        INNER JOIN ubicaciones u ON i.id_ubicacion = u.id_ubicacion
        WHERE i.id_item = %s
    """, (id_item,))
    result = cursor.fetchone()
    cursor.close()
    conn.close()
    return result


def create_item(id_ubicacion, codigo, descripcion, tipo_item, unidad_medida, stock_minimo):
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute("""
        INSERT INTO items (id_ubicacion, codigo, descripcion, tipo_item, unidad_medida, stock_minimo)
        VALUES (%s, %s, %s, %s, %s, %s)
    """, (id_ubicacion, codigo, descripcion, tipo_item, unidad_medida, stock_minimo))
    conn.commit()
    cursor.close()
    conn.close()


def update_item(id_item, id_ubicacion, codigo, descripcion, tipo_item, unidad_medida, stock_minimo):
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute("""
        UPDATE items
        SET id_ubicacion=%s, codigo=%s, descripcion=%s, tipo_item=%s, unidad_medida=%s, stock_minimo=%s
        WHERE id_item=%s
    """, (id_ubicacion, codigo, descripcion, tipo_item, unidad_medida, stock_minimo, id_item))
    conn.commit()
    cursor.close()
    conn.close()


def delete_item(id_item):
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute("DELETE FROM items WHERE id_item=%s", (id_item,))
    conn.commit()
    cursor.close()
    conn.close()


def update_location(id_item, id_location):
    current = get_item_by_id(id_item)

    if current is None:
        raise Exception("Item no encontrado")
    
    conn = get_connection()
    cursor = conn.cursor(dictionary=True)

    cursor.execute("""CALL sp_actualizar_items(%s, %s, %s, %s, %s, %s, %s)""", 
                   (id_item, 
                    id_location, 
                    current.get("codigo", None),
                    current.get("descripcion", None), 
                    current.get("tipo_item", None), 
                    current.get("unidad_medida", None), 
                    current.get("stock_minimo", None)))
    result = cursor.fetchall()
    cursor.close()
    conn.close()
    return result


# CREATE PROCEDURE sp_actualizar_items(
#   IN p_id_item      INT,
#   IN p_id_ubicacion INT,
#   IN p_codigo       VARCHAR(50),
#   IN p_descripcion  VARCHAR(255),
#   IN p_tipo_item    VARCHAR(15),
#   IN p_unidad       VARCHAR(20),
#   IN p_stock_minimo INT
# )

    {
        "id_item": 1,
        "id_ubicacion": 2,
        "codigo": "COD001",
        "descripcion": "Item 1",
        "tipo_item": "DISPOSITIVO",
        "unidad_medida": "UND",
        "stock_minimo": 11,
        "nombre_ubicacion": "Ubicacion 2"
    },