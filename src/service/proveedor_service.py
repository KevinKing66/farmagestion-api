from src.config.database import get_connection

def get_all_proveedores():
    conn = get_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT * FROM proveedores")
    result = cursor.fetchall()
    cursor.close()
    conn.close()
    return result


def get_proveedor_by_id(id_proveedor):
    conn = get_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT * FROM proveedores WHERE id_proveedor = %s", (id_proveedor,))
    result = cursor.fetchone()
    cursor.close()
    conn.close()
    return result


def create_proveedor(nombre, nit):
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute(
        "INSERT INTO proveedores (nombre, nit) VALUES (%s, %s)",
        (nombre, nit)
    )
    conn.commit()
    cursor.close()
    conn.close()


def update_proveedor(id_proveedor, nombre, nit):
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute(
        "UPDATE proveedores SET nombre = %s, nit = %s WHERE id_proveedor = %s",
        (nombre, nit, id_proveedor)
    )
    conn.commit()
    cursor.close()
    conn.close()


def delete_proveedor(id_proveedor):
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute("DELETE FROM proveedores WHERE id_proveedor = %s", (id_proveedor,))
    conn.commit()
    cursor.close()
    conn.close()
