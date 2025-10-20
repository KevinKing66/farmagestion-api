from src.config.database import get_connection

def get_all_registros():
    conn = get_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT * FROM stg_inventario_inicial")
    result = cursor.fetchall()
    cursor.close()
    conn.close()
    return result


def insert_registro(codigo_item, nit_proveedor, codigo_lote, fecha_vencimiento, costo_unitario, nombre_ubicacion, cantidad):
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute("""
        INSERT INTO stg_inventario_inicial
        (codigo_item, nit_proveedor, codigo_lote, fecha_vencimiento, costo_unitario, nombre_ubicacion, cantidad)
        VALUES (%s, %s, %s, %s, %s, %s, %s)
    """, (codigo_item, nit_proveedor, codigo_lote, fecha_vencimiento, costo_unitario, nombre_ubicacion, cantidad))
    conn.commit()
    cursor.close()
    conn.close()


def bulk_insert(lista_registros):
    conn = get_connection()
    cursor = conn.cursor()
    query = """
        INSERT INTO stg_inventario_inicial
        (codigo_item, nit_proveedor, codigo_lote, fecha_vencimiento, costo_unitario, nombre_ubicacion, cantidad)
        VALUES (%s, %s, %s, %s, %s, %s, %s)
    """
    data = [
        (
            r["codigo_item"],
            r["nit_proveedor"],
            r["codigo_lote"],
            r["fecha_vencimiento"],
            r["costo_unitario"],
            r["nombre_ubicacion"],
            r["cantidad"]
        )
        for r in lista_registros
    ]
    cursor.executemany(query, data)
    conn.commit()
    cursor.close()
    conn.close()


def delete_all():
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute("DELETE FROM stg_inventario_inicial")
    conn.commit()
    cursor.close()
    conn.close()
