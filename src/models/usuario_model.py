class Usuario:
    def __init__(self, id_usuario, nombre_completo, correo, rol, contrasena, intentos_fallidos, bloqueado_hasta):
        self.id_usuario = id_usuario
        self.nombre_completo = nombre_completo
        self.correo = correo
        self.rol = rol
        self.contrasena = contrasena
        self.intentos_fallidos = intentos_fallidos
        self.bloqueado_hasta = bloqueado_hasta
