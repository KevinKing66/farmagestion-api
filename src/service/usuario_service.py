from typing import Any, Dict, cast
from src.models.usuario_model import Usuario
from src.schemas.usuario_schema import Login, UsuarioCreate, UsuarioResponse, UsuarioUpdate
from src.config.database import get_connection
import bcrypt


def hash_password(password: str) -> str:
    password_bytes = password.encode('utf-8')
    hashed_bytes = bcrypt.hashpw(password_bytes, bcrypt.gensalt(rounds=12))
    return hashed_bytes.decode('utf-8')

def verify_password(plain_password: str, hashed_password: str) -> bool:
    try:
        plain_password_bytes = plain_password.encode('utf-8')
        hashed_password_bytes = hashed_password.encode('utf-8')
        
        return bcrypt.checkpw(plain_password_bytes, hashed_password_bytes)
    except ValueError:
        return False
    
def get_all_usuarios():
    conn = get_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT * FROM usuarios")
    result = cursor.fetchall()
    cursor.close()
    conn.close()
    return result


def get_usuario_by_id(id_usuario):
    conn = get_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT * FROM usuarios WHERE id_usuario = %s", (id_usuario,))
    result = cursor.fetchone()
    cursor.close()
    conn.close()
    return result

def get_usuario_by_email(email: str) -> Usuario | None:
    conn = get_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT * FROM usuarios WHERE correo = %s LIMIT 1", (email,))
    result = cursor.fetchone()
    cursor.close()
    conn.close()

    return Usuario(**cast(Dict[str, Any], result)) if result else None

def create_usuario(user: UsuarioCreate):
    if get_usuario_by_email(user.correo) is not None:
        raise Exception("Ya eciste un usuario con ese correo")
    
    password = hash_password(user.correo)
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute(
        """
        INSERT INTO usuarios (nombre_completo, correo, rol, contrasena)
        VALUES (%s, %s, %s, %s)
        """,
        (user.nombre_completo, user.correo, user.rol, password)
    )
    conn.commit()
    cursor.close()
    conn.close()


def login(user: Login) -> UsuarioResponse:
    user_db = get_usuario_by_email(user.correo)
    if not user_db:
        raise Exception("Usuario no encontrado")

    if not verify_password(user.password, user_db.contrasena):
        raise Exception("Contraseña incorrecta")

    return UsuarioResponse(**user_db.__dict__)

def update_usuario(id_usuario, user: UsuarioUpdate):
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute(
        """
        UPDATE usuarios 
        SET nombre_completo=%s, correo=%s, rol=%s, contrasena=%s 
        WHERE id_usuario=%s
        """,
        (user.nombre_completo, user.correo, user.rol, user.contrasena, id_usuario)
    )
    conn.commit()
    cursor.close()
    conn.close()


def delete_usuario(id_usuario):
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute("DELETE FROM usuarios WHERE id_usuario = %s", (id_usuario,))
    conn.commit()
    cursor.close()
    conn.close()
