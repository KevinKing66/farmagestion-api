-- =========================================================
--||                      DDL                              ||
-- =========================================================

-- drop database farmagestion;
CREATE DATABASE IF NOT EXISTS farmagestion
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;
USE farmagestion;

SET sql_safe_updates = 0;


SET FOREIGN_KEY_CHECKS = 0;

-- Drop Vistas (por si existían)
DROP VIEW IF EXISTS v_resumen_auditoria;
DROP VIEW IF EXISTS v_consumos_por_servicio;
DROP VIEW IF EXISTS v_stock_por_item;
DROP VIEW IF EXISTS v_lotes_vencidos;
DROP VIEW IF EXISTS v_alertas_stock_bajo;
DROP VIEW IF EXISTS v_alertas_vencimiento;
DROP VIEW IF EXISTS v_kardex_con_saldo;
DROP VIEW IF EXISTS v_kardex;
DROP VIEW IF EXISTS v_existencias_detalle;

-- Drop Triggers
DROP TRIGGER IF EXISTS trg_comprobante_ingreso_ai;
DROP TRIGGER IF EXISTS trg_mv2_ai;
DROP TRIGGER IF EXISTS trg_mv2_bd;
DROP TRIGGER IF EXISTS trg_mv2_bu;
DROP TRIGGER IF EXISTS trg_ubicaciones_ai;
DROP TRIGGER IF EXISTS trg_lotes_ai;
DROP TRIGGER IF EXISTS trg_items_ad;
DROP TRIGGER IF EXISTS trg_items_au;
DROP TRIGGER IF EXISTS trg_items_ai;
DROP TRIGGER IF EXISTS trg_auditoria_bd;
DROP TRIGGER IF EXISTS trg_auditoria_bu;

-- Drop Events
DROP EVENT IF EXISTS ev_generar_alertas_diarias;

-- Drop SP y Funciones
DROP PROCEDURE IF EXISTS sp_verificar_auditoria_integridad;
DROP PROCEDURE IF EXISTS sp_importar_inventario_inicial;
DROP PROCEDURE IF EXISTS sp_recalcular_existencias;
DROP PROCEDURE IF EXISTS sp_anular_movimiento;
DROP PROCEDURE IF EXISTS sp_ajustar_stock;
DROP PROCEDURE IF EXISTS sp_transferir_stock;
DROP PROCEDURE IF EXISTS sp_registrar_salida;
DROP PROCEDURE IF EXISTS sp_registrar_ingreso;
DROP PROCEDURE IF EXISTS sp_asegurar_lote;
DROP PROCEDURE IF EXISTS sp_registrar_login;
DROP FUNCTION  IF EXISTS fn_ultimo_hash;

-- Drop Tablas (orden inverso FKs)
DROP TABLE IF EXISTS comprobantes_recepcion;
DROP TABLE IF EXISTS notificaciones;
DROP TABLE IF EXISTS stg_inventario_inicial;
DROP TABLE IF EXISTS movimientos_v2;
DROP TABLE IF EXISTS auditoria;
DROP TABLE IF EXISTS existencias;
DROP TABLE IF EXISTS parametros_sistema;
DROP TABLE IF EXISTS lotes;
DROP TABLE IF EXISTS items;
DROP TABLE IF EXISTS usuarios;
DROP TABLE IF EXISTS ubicaciones;
DROP TABLE IF EXISTS proveedores;

SET FOREIGN_KEY_CHECKS = 1;

-- 2) Catálogos base
CREATE TABLE proveedores (
  id_proveedor INT AUTO_INCREMENT PRIMARY KEY,
  nombre       VARCHAR(150) NOT NULL,
  nit          VARCHAR(50)  NOT NULL UNIQUE
) ENGINE=InnoDB;

CREATE TABLE ubicaciones (
  id_ubicacion INT AUTO_INCREMENT PRIMARY KEY,
  nombre       VARCHAR(100) NOT NULL,
  tipo         ENUM('ALMACEN','SERVICIO') NOT NULL DEFAULT 'ALMACEN',
  activo       TINYINT(1) NOT NULL DEFAULT 1,
  UNIQUE KEY ux_ubicaciones_nombre (nombre)
) ENGINE=InnoDB;

CREATE TABLE usuarios (
  id_usuario      INT AUTO_INCREMENT PRIMARY KEY,
  nombre_completo VARCHAR(150) NOT NULL,
  correo          VARCHAR(150) NOT NULL UNIQUE,
  rol             ENUM('AUXILIAR','REGENTE','AUDITOR','ADMIN') NOT NULL,
  contrasena      VARCHAR(255) NOT NULL,
  intentos_fallidos TINYINT NOT NULL DEFAULT 0,
  bloqueado_hasta  DATETIME NULL
) ENGINE=InnoDB;

-- Índice adicional por correo (idempotente)
SET @idx_exists := (
  SELECT COUNT(*) FROM information_schema.statistics
   WHERE table_schema = DATABASE()
     AND table_name = 'usuarios'
     AND index_name = 'ix_usuarios_correo'
);
SET @sql := IF(@idx_exists=0,
  'CREATE INDEX ix_usuarios_correo ON usuarios (correo)',
  'DO 0'
);
PREPARE st FROM @sql; EXECUTE st; DEALLOCATE PREPARE st;

-- CHECK bcrypt (idempotente)
SET @chk_exists := (
  SELECT COUNT(*) FROM information_schema.table_constraints
   WHERE table_schema = DATABASE()
     AND table_name = 'usuarios'
     AND constraint_name = 'chk_pwd_bcrypt'
);
SET @sql := IF(@chk_exists=0,
  'ALTER TABLE usuarios ADD CONSTRAINT chk_pwd_bcrypt CHECK (contrasena LIKE ''$2%'')',
  'DO 0'
);
PREPARE st FROM @sql; EXECUTE st; DEALLOCATE PREPARE st;

-- 3) Items y Lotes
CREATE TABLE items (
  id_item       INT AUTO_INCREMENT PRIMARY KEY,
  id_ubicacion  INT NOT NULL,
  codigo        VARCHAR(50)  NULL,
  descripcion   VARCHAR(255) NOT NULL,
  tipo_item     ENUM('MEDICAMENTO','DISPOSITIVO') NOT NULL,
  unidad_medida VARCHAR(20)  NOT NULL DEFAULT 'UND',
  stock_minimo  INT NOT NULL DEFAULT 0,
  CONSTRAINT fk_items_ubi FOREIGN KEY (id_ubicacion) REFERENCES ubicaciones(id_ubicacion)
) ENGINE=InnoDB;

-- Código único (idempotente)
SET @idx_exists := (
  SELECT COUNT(*) FROM information_schema.statistics
   WHERE table_schema = DATABASE()
     AND table_name = 'items'
     AND index_name = 'ux_items_codigo'
);
SET @sql := IF(@idx_exists=0,
  'ALTER TABLE items ADD UNIQUE KEY ux_items_codigo (codigo)',
  'DO 0'
);
PREPARE st FROM @sql; EXECUTE st; DEALLOCATE PREPARE st;

-- FULLTEXT opcional para búsquedas por texto (idempotente)
SET @ft_exists := (
  SELECT COUNT(*) FROM information_schema.statistics
   WHERE table_schema = DATABASE()
     AND table_name = 'items'
     AND index_name = 'ft_items_text'
     AND index_type = 'FULLTEXT'
);
SET @sql := IF(@ft_exists=0,
  'ALTER TABLE items ADD FULLTEXT ft_items_text (codigo, descripcion)',
  'DO 0'
);
PREPARE st FROM @sql; EXECUTE st; DEALLOCATE PREPARE st;

CREATE TABLE lotes (
  id_lote           INT AUTO_INCREMENT PRIMARY KEY,
  id_item           INT NOT NULL,
  id_proveedor      INT NOT NULL,
  codigo_lote       VARCHAR(50) NOT NULL,
  fecha_vencimiento DATE NOT NULL,
  costo_unitario    DECIMAL(10,2) NOT NULL,
  CONSTRAINT fk_lotes_item      FOREIGN KEY (id_item)      REFERENCES items(id_item),
  CONSTRAINT fk_lotes_proveedor FOREIGN KEY (id_proveedor) REFERENCES proveedores(id_proveedor)
) ENGINE=InnoDB;

-- Único por item + código de lote
SET @idx_exists := (
  SELECT COUNT(*) FROM information_schema.statistics
   WHERE table_schema = DATABASE()
     AND table_name = 'lotes'
     AND index_name = 'ux_lote_item'
);
SET @sql := IF(@idx_exists=0,
  'ALTER TABLE lotes ADD UNIQUE KEY ux_lote_item (id_item, codigo_lote)',
  'DO 0'
);
PREPARE st FROM @sql; EXECUTE st; DEALLOCATE PREPARE st;

-- Índice por vencimiento
SET @idx_exists := (
  SELECT COUNT(*) FROM information_schema.statistics
   WHERE table_schema = DATABASE()
     AND table_name = 'lotes'
     AND index_name = 'ix_lotes_venc'
);
SET @sql := IF(@idx_exists=0,
  'ALTER TABLE lotes ADD INDEX ix_lotes_venc (fecha_vencimiento)',
  'DO 0'
);
PREPARE st FROM @sql; EXECUTE st; DEALLOCATE PREPARE st;

-- 4) Operativas y soporte
CREATE TABLE existencias (
  id_existencia BIGINT AUTO_INCREMENT PRIMARY KEY,
  id_lote       INT NOT NULL,
  id_ubicacion  INT NOT NULL,
  saldo         INT NOT NULL DEFAULT 0,
  UNIQUE KEY ux_lote_ubicacion (id_lote, id_ubicacion),
  CONSTRAINT fk_ex_lote FOREIGN KEY (id_lote) REFERENCES lotes(id_lote),
  CONSTRAINT fk_ex_ubi  FOREIGN KEY (id_ubicacion) REFERENCES ubicaciones(id_ubicacion)
) ENGINE=InnoDB;

-- Índice por ubicación (idempotente)
SET @idx_exists := (
  SELECT COUNT(*) FROM information_schema.statistics
   WHERE table_schema = DATABASE()
     AND table_name = 'existencias'
     AND index_name = 'ix_existencias_ubicacion'
);
SET @sql := IF(@idx_exists=0,
  'CREATE INDEX ix_existencias_ubicacion ON existencias (id_ubicacion)',
  'DO 0'
);
PREPARE st FROM @sql; EXECUTE st; DEALLOCATE PREPARE st;

CREATE TABLE parametros_sistema (
  clave       VARCHAR(50) PRIMARY KEY,
  valor       VARCHAR(100) NOT NULL,
  descripcion VARCHAR(255)
) ENGINE=InnoDB;

-- Semilla mínima de parámetros (no es migración; parametrización)
INSERT INTO parametros_sistema (clave, valor, descripcion)
VALUES ('dias_alerta_venc','30','Días para alerta de vencimiento'),
       ('umbral_stock_bajo_default','0','Umbral por defecto')
ON DUPLICATE KEY UPDATE valor = VALUES(valor), descripcion = VALUES(descripcion);

-- Auditoría encadenada (inalterable por triggers)
CREATE TABLE auditoria (
  id_evento       BIGINT AUTO_INCREMENT PRIMARY KEY,
  tabla_afectada  VARCHAR(100) NOT NULL,
  pk_afectada     VARCHAR(100) NOT NULL,
  accion          ENUM('INSERT','UPDATE','DELETE') NOT NULL,
  valores_antes   JSON NULL,
  valores_despues JSON NULL,
  id_usuario      INT NULL,
  fecha           DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  hash_anterior   CHAR(64) NULL,
  hash_evento     CHAR(64) NOT NULL,
  INDEX ix_aud_tabla_fecha (tabla_afectada, fecha),
  CONSTRAINT fk_aud_usuario FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario)
) ENGINE=InnoDB;

-- Outbox de notificaciones (para RF-04; materialización de alertas)
CREATE TABLE notificaciones (
  id_notificacion BIGINT AUTO_INCREMENT PRIMARY KEY,
  tipo ENUM('ALERTA_VENCIMIENTO','ALERTA_STOCK_BAJO') NOT NULL,
  payload JSON NOT NULL,
  destinatario VARCHAR(150) NULL,
  estado ENUM('PENDIENTE','ENVIADA','ERROR') NOT NULL DEFAULT 'PENDIENTE',
  detalle_error VARCHAR(255) NULL,
  fecha_creacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  fecha_envio DATETIME NULL
) ENGINE=InnoDB;

-- Staging de importación CSV (opcional)
CREATE TABLE stg_inventario_inicial (
  codigo_item       VARCHAR(50) NOT NULL,
  nit_proveedor     VARCHAR(50) NOT NULL,
  codigo_lote       VARCHAR(50) NOT NULL,
  fecha_vencimiento DATE NOT NULL,
  costo_unitario    DECIMAL(10,2) NOT NULL,
  nombre_ubicacion  VARCHAR(100) NOT NULL,
  cantidad          INT NOT NULL CHECK (cantidad > 0)
) ENGINE=InnoDB;

-- 5) Función de soporte auditoría
DELIMITER $$
CREATE FUNCTION fn_ultimo_hash()
RETURNS CHAR(64)
DETERMINISTIC
BEGIN
  DECLARE h CHAR(64);
  SELECT hash_evento INTO h FROM auditoria ORDER BY id_evento DESC LIMIT 1;
  RETURN COALESCE(h, REPEAT('0',64));
END$$
DELIMITER ;

-- 6) Movimientos (modelo final)
CREATE TABLE movimientos_v2 (
  id_movimiento        BIGINT AUTO_INCREMENT PRIMARY KEY,
  id_lote              INT NOT NULL,
  id_usuario           INT NOT NULL,
  tipo                 ENUM('INGRESO','SALIDA','TRANSFERENCIA','AJUSTE') NOT NULL,
  cantidad             INT NOT NULL,
  id_ubicacion_origen  INT NULL,
  id_ubicacion_destino INT NULL,
  motivo               VARCHAR(255) NULL,
  fecha                DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_mv2_lote   FOREIGN KEY (id_lote)    REFERENCES lotes(id_lote),
  CONSTRAINT fk_mv2_usuario FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario),
  CONSTRAINT fk_mv2_ori    FOREIGN KEY (id_ubicacion_origen)  REFERENCES ubicaciones(id_ubicacion),
  CONSTRAINT fk_mv2_des    FOREIGN KEY (id_ubicacion_destino) REFERENCES ubicaciones(id_ubicacion)
) ENGINE=InnoDB;

-- Índices útiles (idempotentes)
SET @idx_exists := (
  SELECT COUNT(*) FROM information_schema.statistics
   WHERE table_schema = DATABASE()
     AND table_name = 'movimientos_v2'
     AND index_name = 'ix_mv2_lote_fecha'
);
SET @sql := IF(@idx_exists=0,
  'CREATE INDEX ix_mv2_lote_fecha ON movimientos_v2 (id_lote, fecha)',
  'DO 0'
);
PREPARE st FROM @sql; EXECUTE st; DEALLOCATE PREPARE st;

SET @idx_exists := (
  SELECT COUNT(*) FROM information_schema.statistics
   WHERE table_schema = DATABASE()
     AND table_name = 'movimientos_v2'
     AND index_name = 'ix_mv2_destino_fecha'
);
SET @sql := IF(@idx_exists=0,
  'CREATE INDEX ix_mv2_destino_fecha ON movimientos_v2 (id_ubicacion_destino, fecha)',
  'DO 0'
);
PREPARE st FROM @sql; EXECUTE st; DEALLOCATE PREPARE st;

-- Índice extra sugerido por rendimiento: origen+fecha
SET @idx_exists := (
  SELECT COUNT(*) FROM information_schema.statistics
   WHERE table_schema = DATABASE()
     AND table_name = 'movimientos_v2'
     AND index_name = 'ix_mv2_origen_fecha'
);
SET @sql := IF(@idx_exists=0,
  'CREATE INDEX ix_mv2_origen_fecha ON movimientos_v2 (id_ubicacion_origen, fecha)',
  'DO 0'
);
PREPARE st FROM @sql; EXECUTE st; DEALLOCATE PREPARE st;

-- 6.1) Comprobantes de recepción (opcional) para HU-10, tras crear movimientos_v2
CREATE TABLE comprobantes_recepcion (
  id_comprobante BIGINT AUTO_INCREMENT PRIMARY KEY,
  id_movimiento BIGINT NOT NULL,
  id_proveedor  INT NOT NULL,
  canal ENUM('PORTAL','EMAIL') NOT NULL DEFAULT 'PORTAL',
  entregado TINYINT(1) NOT NULL DEFAULT 0,
  fecha_creacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  fecha_entrega DATETIME NULL,
  FOREIGN KEY (id_movimiento) REFERENCES movimientos_v2(id_movimiento),
  FOREIGN KEY (id_proveedor)  REFERENCES proveedores(id_proveedor)
) ENGINE=InnoDB;


/* *********************************************************************
   SECCIÓN 1. PROVEEDORES (CRUD completo)
   ********************************************************************* */
DELIMITER //
DROP PROCEDURE IF EXISTS sp_crear_proveedores //
CREATE PROCEDURE sp_crear_proveedores(
  IN p_nombre VARCHAR(150),
  IN p_nit    VARCHAR(50)
)
BEGIN
  IF p_nombre IS NULL OR TRIM(p_nombre) = '' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Nombre de proveedor obligatorio';
  END IF;
  IF p_nit IS NULL OR TRIM(p_nit) = '' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'NIT obligatorio';
  END IF;

  INSERT INTO proveedores(nombre, nit) VALUES (p_nombre, p_nit);
  SELECT LAST_INSERT_ID() AS id_proveedor;
END //
DELIMITER;

DELIMITER //
DROP PROCEDURE IF EXISTS sp_obtener_proveedores //
CREATE PROCEDURE sp_obtener_proveedores(IN p_id_proveedor INT)
BEGIN
  SELECT * FROM proveedores WHERE id_proveedor = p_id_proveedor;
END //
DELIMITER;

DELIMITER //
DROP PROCEDURE IF EXISTS sp_listar_proveedores //
CREATE PROCEDURE sp_listar_proveedores()
BEGIN
  SELECT * FROM proveedores ORDER BY nombre;
END //
DELIMITER;

DELIMITER //
DROP PROCEDURE IF EXISTS sp_actualizar_proveedores //
CREATE PROCEDURE sp_actualizar_proveedores(
  IN p_id_proveedor INT,
  IN p_nombre       VARCHAR(150),
  IN p_nit          VARCHAR(50)
)
BEGIN
  IF (SELECT COUNT(*) FROM proveedores WHERE id_proveedor = p_id_proveedor) = 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Proveedor no existe';
  END IF;
  UPDATE proveedores SET nombre = p_nombre, nit = p_nit
  WHERE id_proveedor = p_id_proveedor;
END //
DELIMITER;



DELIMITER //
DROP PROCEDURE IF EXISTS sp_eliminar_proveedores //
CREATE PROCEDURE sp_eliminar_proveedores(IN p_id_proveedor INT)
BEGIN
  IF (SELECT COUNT(*) FROM lotes WHERE id_proveedor = p_id_proveedor) > 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede eliminar: tiene lotes asociados';
  END IF;
  DELETE FROM proveedores WHERE id_proveedor = p_id_proveedor;
END //
DELIMITER;

/* *********************************************************************
   SECCIÓN 2. UBICACIONES (CRUD con validaciones y bloqueos por dependencias)
   ********************************************************************* */
DELIMITER //
DROP PROCEDURE IF EXISTS sp_crear_ubicaciones //
CREATE PROCEDURE sp_crear_ubicaciones(
  IN p_nombre VARCHAR(100),
  IN p_tipo   VARCHAR(10),
  IN p_activo TINYINT
)
BEGIN
  IF p_nombre IS NULL OR TRIM(p_nombre) = '' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Nombre de ubicación obligatorio';
  END IF;
  SET p_tipo = UPPER(TRIM(p_tipo));
  IF p_tipo NOT IN ('ALMACEN','SERVICIO') THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Tipo inválido (ALMACEN|SERVICIO)';
  END IF;

  INSERT INTO ubicaciones(nombre, tipo, activo)
  VALUES (p_nombre, p_tipo, COALESCE(p_activo,1));
  SELECT LAST_INSERT_ID() AS id_ubicacion;
END //
DELIMITER;

CALL sp_crear_ubicaciones('Almacén Principal', 'ALMACEN', 1);

DELIMITER //
DROP PROCEDURE IF EXISTS sp_obtener_ubicaciones //
CREATE PROCEDURE sp_obtener_ubicaciones(IN p_id_ubicacion INT)
BEGIN
  SELECT * FROM ubicaciones WHERE id_ubicacion = p_id_ubicacion;
END //

DROP PROCEDURE IF EXISTS sp_listar_ubicaciones //
CREATE PROCEDURE sp_listar_ubicaciones()
BEGIN
  SELECT * FROM ubicaciones ORDER BY nombre;
END //
DELIMITER;

DELIMITER //
DROP PROCEDURE IF EXISTS sp_actualizar_ubicaciones //
CREATE PROCEDURE sp_actualizar_ubicaciones(
  IN p_id_ubicacion INT,
  IN p_nombre       VARCHAR(100),
  IN p_tipo         VARCHAR(10),
  IN p_activo       TINYINT
)
BEGIN
  SET p_tipo = UPPER(TRIM(p_tipo));
  IF p_tipo NOT IN ('ALMACEN','SERVICIO') THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Tipo inválido (ALMACEN|SERVICIO)';
  END IF;
  UPDATE ubicaciones
     SET nombre = p_nombre,
         tipo   = p_tipo,
         activo = p_activo
   WHERE id_ubicacion = p_id_ubicacion;
END //
DELIMITER;

DELIMITER //
DROP PROCEDURE IF EXISTS sp_eliminar_ubicaciones //
CREATE PROCEDURE sp_eliminar_ubicaciones(IN p_id_ubicacion INT)
BEGIN
  IF (SELECT COUNT(*) FROM existencias WHERE id_ubicacion = p_id_ubicacion) > 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede eliminar: tiene existencias';
  END IF;
  IF (SELECT COUNT(*) FROM movimientos_v2
        WHERE id_ubicacion_origen = p_id_ubicacion
           OR id_ubicacion_destino = p_id_ubicacion) > 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede eliminar: tiene movimientos';
  END IF;
  DELETE FROM ubicaciones WHERE id_ubicacion = p_id_ubicacion;
END //
DELIMITER;
/* *********************************************************************
   SECCIÓN 3. ITEMS (CRUD con validaciones de dominio)
   ********************************************************************* */
DELIMITER //
DROP PROCEDURE IF EXISTS sp_crear_items //
CREATE PROCEDURE sp_crear_items(
  IN p_id_ubicacion INT,
  IN p_codigo       VARCHAR(50),
  IN p_descripcion  VARCHAR(255),
  IN p_tipo_item    VARCHAR(15),
  IN p_unidad       VARCHAR(20),
  IN p_stock_minimo INT
)
BEGIN
  SET p_tipo_item = UPPER(TRIM(p_tipo_item));
  IF p_descripcion IS NULL OR TRIM(p_descripcion) = '' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Descripción obligatoria';
  END IF;
  IF p_tipo_item NOT IN ('MEDICAMENTO','DISPOSITIVO') THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Tipo de ítem inválido (MEDICAMENTO|DISPOSITIVO)';
  END IF;

  INSERT INTO items(id_ubicacion, codigo, descripcion, tipo_item, unidad_medida, stock_minimo)
  VALUES (p_id_ubicacion, p_codigo, p_descripcion, p_tipo_item, COALESCE(p_unidad,'UND'), COALESCE(p_stock_minimo,0));
  SELECT LAST_INSERT_ID() AS id_item;
END //
DELIMITER;

DELIMITER //
DROP PROCEDURE IF EXISTS sp_obtener_items //
CREATE PROCEDURE sp_obtener_items(IN p_id_item INT)
BEGIN
  SELECT * FROM items WHERE id_item = p_id_item;
END //
DELIMITER;

DELIMITER //
DROP PROCEDURE IF EXISTS sp_listar_items //
CREATE PROCEDURE sp_listar_items()
BEGIN
  SELECT * FROM items ORDER BY descripcion;
END //
DELIMITER;

DELIMITER //
DROP PROCEDURE IF EXISTS sp_actualizar_items //
CREATE PROCEDURE sp_actualizar_items(
  IN p_id_item      INT,
  IN p_id_ubicacion INT,
  IN p_codigo       VARCHAR(50),
  IN p_descripcion  VARCHAR(255),
  IN p_tipo_item    VARCHAR(15),
  IN p_unidad       VARCHAR(20),
  IN p_stock_minimo INT
)
BEGIN
  SET p_tipo_item = UPPER(TRIM(p_tipo_item));
  IF p_tipo_item NOT IN ('MEDICAMENTO','DISPOSITIVO') THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Tipo de ítem inválido (MEDICAMENTO|DISPOSITIVO)';
  END IF;

  UPDATE items
     SET id_ubicacion = p_id_ubicacion,
         codigo       = p_codigo,
         descripcion  = p_descripcion,
         tipo_item    = p_tipo_item,
         unidad_medida= p_unidad,
         stock_minimo = p_stock_minimo
   WHERE id_item = p_id_item;
END //
DELIMITER;

DELIMITER //
DROP PROCEDURE IF EXISTS sp_eliminar_items //
CREATE PROCEDURE sp_eliminar_items(IN p_id_item INT)
BEGIN
  IF (SELECT COUNT(*) FROM lotes WHERE id_item = p_id_item) > 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede eliminar: tiene lotes asociados';
  END IF;
  DELETE FROM items WHERE id_item = p_id_item;
END //
DELIMITER;
/* *********************************************************************
   SECCIÓN 4. LOTES (CRUD con salvaguardas y delegación a sp_asegurar_lote)
   ********************************************************************* */
DELIMITER //
DROP PROCEDURE IF EXISTS sp_crear_lotes //
CREATE PROCEDURE sp_crear_lotes(
  IN  p_id_item        INT,
  IN  p_id_proveedor   INT,
  IN  p_codigo_lote    VARCHAR(50),
  IN  p_fecha_venc     DATE,
  IN  p_costo_unitario DECIMAL(10,2)
)
BEGIN
  DECLARE v_id_lote INT;
  -- Usa la lógica de negocio (valida fecha, costo, y evita duplicados por item+codigo_lote)
  CALL sp_asegurar_lote(p_id_item, p_id_proveedor, p_codigo_lote, p_fecha_venc, p_costo_unitario, v_id_lote);
  SELECT v_id_lote AS id_lote;
END //
DELIMITER;

DELIMITER //
DROP PROCEDURE IF EXISTS sp_obtener_lotes //
CREATE PROCEDURE sp_obtener_lotes(IN p_id_lote INT)
BEGIN
  SELECT l.*, i.codigo AS codigo_item, i.descripcion
    FROM lotes l
    JOIN items i ON i.id_item = l.id_item
   WHERE l.id_lote = p_id_lote;
END //
DELIMITER;

DELIMITER //
DROP PROCEDURE IF EXISTS sp_listar_lotes //
CREATE PROCEDURE sp_listar_lotes(IN p_id_item INT)
BEGIN
  SELECT l.*, i.codigo AS codigo_item, i.descripcion
    FROM lotes l
    JOIN items i ON i.id_item = l.id_item
   WHERE (p_id_item IS NULL OR l.id_item = p_id_item)
   ORDER BY l.id_item, l.codigo_lote;
END //
DELIMITER;

DELIMITER //
DROP PROCEDURE IF EXISTS sp_actualizar_lotes //
CREATE PROCEDURE sp_actualizar_lotes(
  IN p_id_lote      INT,
  IN p_fecha_venc   DATE,
  IN p_costo_unit   DECIMAL(10,2)
)
BEGIN
  IF p_fecha_venc < CURRENT_DATE() THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Fecha de vencimiento inválida (pasada)';
  END IF;
  IF p_costo_unit <= 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Costo unitario debe ser > 0';
  END IF;

  -- Restricción: no se permite cambiar id_item, proveedor o codigo_lote aquí
  UPDATE lotes
     SET fecha_vencimiento = p_fecha_venc,
         costo_unitario    = p_costo_unit
   WHERE id_lote = p_id_lote;
END //
DELIMITER;

DELIMITER //
DROP PROCEDURE IF EXISTS sp_eliminar_lotes //
CREATE PROCEDURE sp_eliminar_lotes(IN p_id_lote INT)
BEGIN
  IF (SELECT COUNT(*) FROM existencias WHERE id_lote = p_id_lote) > 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede eliminar: tiene existencias';
  END IF;
  IF (SELECT COUNT(*) FROM movimientos_v2 WHERE id_lote = p_id_lote) > 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede eliminar: tiene movimientos';
  END IF;
  DELETE FROM lotes WHERE id_lote = p_id_lote;
END //
DELIMITER;
/* *********************************************************************
   SECCIÓN 5. USUARIOS (CRUD con validación de rol y hash bcrypt)
   ********************************************************************* */
DELIMITER //
DROP PROCEDURE IF EXISTS sp_crear_usuarios //
CREATE PROCEDURE sp_crear_usuarios(
  IN p_nombre_completo VARCHAR(150),
  IN p_correo          VARCHAR(150),
  IN p_rol             VARCHAR(10),
  IN p_contrasena      VARCHAR(255)  -- Hash bcrypt esperado: $2...
)
BEGIN
  SET p_rol = UPPER(TRIM(p_rol));
  IF p_rol NOT IN ('AUXILIAR','REGENTE','AUDITOR','ADMIN') THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Rol inválido';
  END IF;
  IF p_contrasena NOT LIKE '$2%' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Se espera hash bcrypt ($2...) en contrasena';
  END IF;

  INSERT INTO usuarios(nombre_completo, correo, rol, contrasena)
  VALUES (p_nombre_completo, p_correo, p_rol, p_contrasena);

  SELECT LAST_INSERT_ID() AS id_usuario;
END //
DELIMITER;

DELIMITER //
DROP PROCEDURE IF EXISTS sp_obtener_usuarios //
CREATE PROCEDURE sp_obtener_usuarios(IN p_id_usuario INT)
BEGIN
  -- No devolvemos la contraseña por seguridad
  SELECT id_usuario, nombre_completo, correo, rol, intentos_fallidos, bloqueado_hasta
    FROM usuarios
   WHERE id_usuario = p_id_usuario;
END //
DELIMITER;

DELIMITER //
DROP PROCEDURE IF EXISTS sp_listar_usuarios //
CREATE PROCEDURE sp_listar_usuarios()
BEGIN
  SELECT id_usuario, nombre_completo, correo, rol, intentos_fallidos, bloqueado_hasta
    FROM usuarios
   ORDER BY nombre_completo;
END //
DELIMITER;

DELIMITER //
DROP PROCEDURE IF EXISTS sp_actualizar_usuarios //
CREATE PROCEDURE sp_actualizar_usuarios(
  IN p_id_usuario      INT,
  IN p_nombre_completo VARCHAR(150),
  IN p_correo          VARCHAR(150),
  IN p_rol             VARCHAR(10),
  IN p_contrasena      VARCHAR(255)
)
BEGIN
  SET p_rol = UPPER(TRIM(p_rol));
  IF p_rol NOT IN ('AUXILIAR','REGENTE','AUDITOR','ADMIN') THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Rol inválido';
  END IF;
  IF p_contrasena NOT LIKE '$2%' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Se espera hash bcrypt ($2...) en contrasena';
  END IF;

  UPDATE usuarios
     SET nombre_completo = p_nombre_completo,
         correo          = p_correo,
         rol             = p_rol,
         contrasena      = p_contrasena
   WHERE id_usuario = p_id_usuario;
END //
DELIMITER;

DELIMITER //
DROP PROCEDURE IF EXISTS sp_eliminar_usuarios //
CREATE PROCEDURE sp_eliminar_usuarios(IN p_id_usuario INT)
BEGIN
  IF (SELECT COUNT(*) FROM movimientos_v2 WHERE id_usuario = p_id_usuario) > 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede eliminar: tiene trazas de movimientos';
  END IF;
  DELETE FROM usuarios WHERE id_usuario = p_id_usuario;
END //
DELIMITER;

-- Wrapper opcional: bloqueo temporal (delegando al SP maestro si existe)

DELIMITER //
DROP PROCEDURE IF EXISTS sp_bloquear_usuarios //
CREATE PROCEDURE sp_bloquear_usuarios(IN p_id_usuario INT, IN p_min INT)
BEGIN
  -- Si existe sp_usuario_bloquear en el maestro:
  CALL sp_usuario_bloquear(p_id_usuario, p_min);
END //
DELIMITER;

/* *********************************************************************
   SECCIÓN 6. PARÁMETROS DEL SISTEMA 
   ********************************************************************* */

DELIMITER //
DROP PROCEDURE IF EXISTS sp_crear_parametro //
CREATE PROCEDURE sp_crear_parametro(
  IN p_clave       VARCHAR(50),
  IN p_valor       VARCHAR(100),
  IN p_descripcion VARCHAR(255)
)
BEGIN
  CALL sp_param_set(p_clave, p_valor, p_descripcion);
  SELECT p_clave AS clave;
END //
DELIMITER;

DELIMITER //
DROP PROCEDURE IF EXISTS sp_obtener_parametro //
CREATE PROCEDURE sp_obtener_parametro(IN p_clave VARCHAR(50))
BEGIN
  CALL sp_param_get(p_clave);
END //
DELIMITER;

DELIMITER //
DROP PROCEDURE IF EXISTS sp_listar_parametros //
CREATE PROCEDURE sp_listar_parametros()
BEGIN
  SELECT * FROM parametros_sistema ORDER BY clave;
END //
DELIMITER;

DELIMITER //
DROP PROCEDURE IF EXISTS sp_actualizar_parametro //
CREATE PROCEDURE sp_actualizar_parametro(
  IN p_clave       VARCHAR(50),
  IN p_valor       VARCHAR(100),
  IN p_descripcion VARCHAR(255)
)
BEGIN
  CALL sp_param_set(p_clave, p_valor, p_descripcion);
END //
DELIMITER;

DELIMITER //
DROP PROCEDURE IF EXISTS sp_eliminar_parametro //
CREATE PROCEDURE sp_eliminar_parametro(IN p_clave VARCHAR(50))
BEGIN
  DELETE FROM parametros_sistema WHERE clave = p_clave;
END //
DELIMITER;

/* *********************************************************************
   SECCIÓN 7. EXISTENCIAS (SOLO LECTURA - derivadas de movimientos)
   ********************************************************************* */
-- Importante: NO crear/actualizar/eliminar existencias manualmente.

DELIMITER //
DROP PROCEDURE IF EXISTS sp_obtener_existencias //
CREATE PROCEDURE sp_obtener_existencias(IN p_id_existencia BIGINT)
BEGIN
  SELECT * FROM existencias WHERE id_existencia = p_id_existencia;
END //
DELIMITER;

DELIMITER //
DROP PROCEDURE IF EXISTS sp_listar_existencias_por_lote //
CREATE PROCEDURE sp_listar_existencias_por_lote(IN p_id_lote INT)
BEGIN
  SELECT * FROM existencias WHERE id_lote = p_id_lote ORDER BY id_ubicacion;
END //
DELIMITER;

DELIMITER //
DROP PROCEDURE IF EXISTS sp_listar_existencias_por_item //
CREATE PROCEDURE sp_listar_existencias_por_item(IN p_id_item INT)
BEGIN
  SELECT e.*
    FROM existencias e
    JOIN lotes l ON l.id_lote = e.id_lote
   WHERE l.id_item = p_id_item
   ORDER BY e.id_ubicacion;
END //
DELIMITER;

DELIMITER //
DROP PROCEDURE IF EXISTS sp_listar_existencias_detalle //
CREATE PROCEDURE sp_listar_existencias_detalle()
BEGIN
  SELECT * FROM v_existencias_detalle
  ORDER BY item, fecha_vencimiento, id_ubicacion;
END //
DELIMITER;

/* *********************************************************************
   SECCIÓN 8. MOVIMIENTOS (LECTURA + API DE NEGOCIO; NO UPDATE/DELETE)
   ********************************************************************* */
-- Lecturas (seguras)

DELIMITER //
DROP PROCEDURE IF EXISTS sp_obtener_movimientos_v2 //
CREATE PROCEDURE sp_obtener_movimientos_v2(IN p_id_movimiento BIGINT)
BEGIN
  SELECT * FROM movimientos_v2 WHERE id_movimiento = p_id_movimiento;
END //
DELIMITER;

DELIMITER //
DROP PROCEDURE IF EXISTS sp_listar_movimientos_por_lote //
CREATE PROCEDURE sp_listar_movimientos_por_lote(IN p_id_lote INT)
BEGIN
  SELECT * FROM movimientos_v2 WHERE id_lote = p_id_lote ORDER BY fecha, id_movimiento;
END //
DELIMITER;

DELIMITER //
DROP PROCEDURE IF EXISTS sp_listar_movimientos_por_fecha //
CREATE PROCEDURE sp_listar_movimientos_por_fecha(IN p_desde DATETIME, IN p_hasta DATETIME)
BEGIN
  SELECT * FROM movimientos_v2
   WHERE fecha BETWEEN p_desde AND p_hasta
   ORDER BY fecha, id_movimiento;
END //
DELIMITER;

-- Bloqueo explícito de rutas que violan los triggers (para evitar usos indebidos)

DELIMITER //
DROP PROCEDURE IF EXISTS sp_actualizar_movimientos_v2 //
CREATE PROCEDURE sp_actualizar_movimientos_v2(
  IN p_id_movimiento BIGINT, IN p_id_lote INT, IN p_id_usuario INT,
  IN p_tipo VARCHAR(15), IN p_cantidad INT, IN p_id_ubicacion_origen INT,
  IN p_id_ubicacion_destino INT, IN p_motivo VARCHAR(255)
)
BEGIN
  SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'UPDATE de movimientos está prohibido. Use sp_anular_movimiento() o los SPs de negocio.';
END //
DELIMITER;

DELIMITER //
DROP PROCEDURE IF EXISTS sp_eliminar_movimientos_v2 //
CREATE PROCEDURE sp_eliminar_movimientos_v2(IN p_id_movimiento BIGINT)
BEGIN
  SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'DELETE de movimientos está prohibido. Use sp_anular_movimiento().';
END //
DELIMITER;

-- 1) INGRESO (si necesitas crear/asegurar lote en la misma operación)

DELIMITER //
DROP PROCEDURE IF EXISTS sp_mov_registrar_ingreso //
CREATE PROCEDURE sp_mov_registrar_ingreso(
  IN p_id_item        INT,
  IN p_id_proveedor   INT,
  IN p_codigo_lote    VARCHAR(50),
  IN p_fecha_venc     DATE,
  IN p_costo_unitario DECIMAL(10,2),
  IN p_id_ubic_dest   INT,
  IN p_cantidad       INT,
  IN p_id_usuario     INT,
  IN p_motivo         VARCHAR(255)
)
BEGIN
  CALL sp_registrar_ingreso(p_id_item, p_id_proveedor, p_codigo_lote, p_fecha_venc,
                            p_costo_unitario, p_id_ubic_dest, p_cantidad, p_id_usuario, p_motivo);
END //
DELIMITER;

-- 2) SALIDA

DELIMITER //
DROP PROCEDURE IF EXISTS sp_mov_registrar_salida //
CREATE PROCEDURE sp_mov_registrar_salida(
  IN p_id_lote        INT,
  IN p_id_ubic_origen INT,
  IN p_id_ubic_dest   INT,
  IN p_cantidad       INT,
  IN p_id_usuario     INT,
  IN p_motivo         VARCHAR(255)
)
BEGIN
  CALL sp_registrar_salida(p_id_lote, p_id_ubic_origen, p_id_ubic_dest, p_cantidad, p_id_usuario, p_motivo);
END //
DELIMITER;

-- 3) TRANSFERENCIA

DELIMITER //
DROP PROCEDURE IF EXISTS sp_mov_transferir_stock //
CREATE PROCEDURE sp_mov_transferir_stock(
  IN p_id_lote        INT,
  IN p_id_ubic_origen INT,
  IN p_id_ubic_dest   INT,
  IN p_cantidad       INT,
  IN p_id_usuario     INT,
  IN p_motivo         VARCHAR(255)
)
BEGIN
  CALL sp_transferir_stock(p_id_lote, p_id_ubic_origen, p_id_ubic_dest, p_cantidad, p_id_usuario, p_motivo);
END //
DELIMITER;

-- 4) AJUSTE (AUMENTO/DISMINUCION de una sola ubicación)

DELIMITER //
DROP PROCEDURE IF EXISTS sp_mov_ajustar_stock //
CREATE PROCEDURE sp_mov_ajustar_stock(
  IN p_id_lote    INT,
  IN p_id_ubic    INT,
  IN p_cantidad   INT,
  IN p_sentido    VARCHAR(12),  -- 'AUMENTO' | 'DISMINUCION'
  IN p_id_usuario INT,
  IN p_motivo     VARCHAR(255)
)
BEGIN
  CALL sp_ajustar_stock(p_id_lote, p_id_ubic, p_cantidad, p_sentido, p_id_usuario, p_motivo);
END //
DELIMITER ;

-- 5) ANULAR MOVIMIENTO (genera contra-movimiento)

DELIMITER //
DROP PROCEDURE IF EXISTS sp_mov_anular //
CREATE PROCEDURE sp_mov_anular(
  IN p_id_movimiento BIGINT,
  IN p_id_usuario    INT,
  IN p_motivo        VARCHAR(255)
)
BEGIN
  CALL sp_anular_movimiento(p_id_movimiento, p_id_usuario, p_motivo);
END //
DELIMITER ;



-- |==========================================================================================|
-- |                                        VISTAS                                            |
-- |==========================================================================================|

-- 1)
CREATE OR REPLACE VIEW v_existencias_detalle AS
SELECT
  e.id_lote,
  l.id_item,
  i.codigo AS codigo_item,
  i.descripcion AS item,
  i.unidad_medida,
  u.id_ubicacion,
  u.nombre AS ubicacion,
  e.saldo
FROM existencias e
JOIN lotes l ON l.id_lote = e.id_lote
JOIN items i ON i.id_item = l.id_item
JOIN ubicaciones u ON u.id_ubicacion = e.id_ubicacion;


-- 2)
CREATE OR REPLACE VIEW v_kardex AS
SELECT
  mv.id_movimiento,
  mv.fecha,
  mv.id_lote,
  l.id_item,
  mv.tipo,
  COALESCE(mv.id_ubicacion_origen, mv.id_ubicacion_destino) AS id_ubicacion,
  CASE
    WHEN mv.tipo IN ('INGRESO','TRANSFERENCIA') AND mv.id_ubicacion_destino IS NOT NULL THEN mv.cantidad
    WHEN mv.tipo IN ('SALIDA','TRANSFERENCIA','AJUSTE')   AND mv.id_ubicacion_origen  IS NOT NULL THEN -mv.cantidad
    ELSE 0
  END AS delta,
  mv.id_usuario,
  mv.motivo
FROM movimientos_v2 mv
JOIN lotes l ON l.id_lote = mv.id_lote;

-- 3)
CREATE OR REPLACE VIEW v_kardex_con_saldo AS
SELECT
  k.*,
  SUM(k.delta) OVER (PARTITION BY k.id_lote, k.id_ubicacion ORDER BY k.fecha, k.id_movimiento) AS saldo_acum
FROM v_kardex k;

-- 4)
CREATE OR REPLACE VIEW v_alertas_vencimiento AS
SELECT
  l.id_lote, l.id_item, i.codigo, i.descripcion, l.fecha_vencimiento,
  DATEDIFF(l.fecha_vencimiento, CURRENT_DATE()) AS dias_para_vencer
FROM lotes l
JOIN items i ON i.id_item = l.id_item
WHERE DATEDIFF(l.fecha_vencimiento, CURRENT_DATE()) BETWEEN 0 AND
      (SELECT CAST(valor AS SIGNED) FROM parametros_sistema WHERE clave = 'dias_alerta_venc');
      
-- 5)
CREATE OR REPLACE VIEW v_alertas_stock_bajo AS
SELECT
  e.id_lote, l.id_item, i.codigo, i.descripcion,
  e.id_ubicacion, u.nombre AS ubicacion, e.saldo, i.stock_minimo
FROM existencias e
JOIN lotes l ON l.id_lote = e.id_lote
JOIN items i ON i.id_item = l.id_item
JOIN ubicaciones u ON u.id_ubicacion = e.id_ubicacion
WHERE e.saldo < i.stock_minimo;

-- 6)
CREATE OR REPLACE VIEW v_lotes_vencidos AS
SELECT l.id_lote, l.id_item, i.codigo, i.descripcion, l.fecha_vencimiento
FROM lotes l
JOIN items i ON i.id_item = l.id_item
WHERE DATEDIFF(l.fecha_vencimiento, CURRENT_DATE()) < 0;

-- 7)
CREATE OR REPLACE VIEW v_stock_por_item AS
SELECT
  l.id_item,
  i.codigo,
  i.descripcion,
  i.unidad_medida,
  COALESCE(SUM(e.saldo),0) AS stock_total
FROM items i
LEFT JOIN lotes l ON l.id_item = i.id_item
LEFT JOIN existencias e ON e.id_lote = l.id_lote
GROUP BY l.id_item, i.codigo, i.descripcion, i.unidad_medida;

-- 8)
CREATE OR REPLACE VIEW v_consumos_por_servicio AS
SELECT
  mv.id_ubicacion_destino AS id_servicio,
  u.nombre AS servicio,
  l.id_item,
  i.codigo,
  i.descripcion AS item,
  SUM(mv.cantidad) AS consumo_total,
  MIN(mv.fecha) AS desde,
  MAX(mv.fecha) AS hasta
FROM movimientos_v2 mv
JOIN lotes l ON l.id_lote = mv.id_lote
JOIN items i ON i.id_item = l.id_item
JOIN ubicaciones u ON u.id_ubicacion = mv.id_ubicacion_destino
WHERE mv.tipo = 'SALIDA' AND mv.id_ubicacion_destino IS NOT NULL
GROUP BY mv.id_ubicacion_destino, u.nombre, l.id_item, i.codigo, i.descripcion;

-- 9)
CREATE OR REPLACE VIEW v_resumen_auditoria AS
SELECT
  tabla_afectada,
  COUNT(*) AS total_eventos,
  MAX(fecha) AS ultimo_evento,
  MAX(id_evento) AS id_ultimo
FROM auditoria
GROUP BY tabla_afectada;

-- 10. Vista v_kardex: se agrega nombre de ubicación y tipo de movimiento más descriptivo
CREATE OR REPLACE VIEW v_kardex AS
SELECT
    mv.id_movimiento,
    mv.fecha,
    mv.id_lote,
    l.id_item,
    i.codigo AS codigo_item,
    i.descripcion AS item,
    mv.tipo,
    COALESCE(mv.id_ubicacion_origen, mv.id_ubicacion_destino) AS id_ubicacion,
    u.nombre AS ubicacion,
    CASE
        WHEN mv.tipo IN ('INGRESO','TRANSFERENCIA') AND mv.id_ubicacion_destino IS NOT NULL THEN mv.cantidad
        WHEN mv.tipo IN ('SALIDA','TRANSFERENCIA','AJUSTE')   AND mv.id_ubicacion_origen  IS NOT NULL THEN -mv.cantidad
        ELSE 0
    END AS delta,
    mv.id_usuario,
    us.nombre_completo AS usuario,
    mv.motivo
FROM movimientos_v2 mv
JOIN lotes l ON l.id_lote = mv.id_lote
JOIN items i ON i.id_item = l.id_item
LEFT JOIN ubicaciones u ON u.id_ubicacion = COALESCE(mv.id_ubicacion_origen, mv.id_ubicacion_destino)
LEFT JOIN usuarios us ON us.id_usuario = mv.id_usuario;

-- 11. Vista v_existencias_detalle: se agrega proveedor y fecha de vencimiento
CREATE OR REPLACE VIEW v_existencias_detalle AS
SELECT
    e.id_lote,
    l.id_item,
    i.codigo AS codigo_item,
    i.descripcion AS item,
    i.unidad_medida,
    u.id_ubicacion,
    u.nombre AS ubicacion,
    e.saldo,
    p.nombre AS proveedor,
    l.fecha_vencimiento
FROM existencias e
JOIN lotes l ON l.id_lote = e.id_lote
JOIN items i ON i.id_item = l.id_item
JOIN ubicaciones u ON u.id_ubicacion = e.id_ubicacion
JOIN proveedores p ON p.id_proveedor = l.id_proveedor;

-- 12. 
CREATE OR REPLACE VIEW v_alertas_vencimiento AS
SELECT 
  l.id_lote, l.id_item, i.codigo, i.descripcion, l.fecha_vencimiento,
  DATEDIFF(l.fecha_vencimiento, CURRENT_DATE()) AS dias_para_vencer
FROM lotes l
JOIN items i ON i.id_item = l.id_item
WHERE DATEDIFF(l.fecha_vencimiento, CURRENT_DATE()) BETWEEN 0 AND 
  (SELECT CAST(valor AS SIGNED) FROM parametros_sistema WHERE clave = 'dias_alerta_venc');

-- |==========================================================================================|
-- |                                     DISPARADORES                                         |
-- |==========================================================================================|

-- 1. Trigger trg_lotes_ai: validación de costo_unitario positivo
DROP TRIGGER IF EXISTS trg_lotes_ai;
DELIMITER $$
CREATE TRIGGER trg_lotes_ai
BEFORE INSERT ON lotes FOR EACH ROW
BEGIN
    IF NEW.costo_unitario <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Costo unitario debe ser mayor a cero';
    END IF;
END$$

-- 2)

DELIMITER $$

/* Auditoría de items */
DROP TRIGGER IF EXISTS trg_items_ai $$
CREATE TRIGGER trg_items_ai
AFTER INSERT ON items FOR EACH ROW
BEGIN
  INSERT INTO auditoria(tabla_afectada, pk_afectada, accion, valores_antes, valores_despues, id_usuario, hash_anterior, hash_evento)
  SELECT 'items', NEW.id_item, 'INSERT', NULL,
         JSON_OBJECT('id_item', NEW.id_item, 'codigo', NEW.codigo, 'descripcion', NEW.descripcion,
                     'unidad_medida', NEW.unidad_medida, 'tipo_item', NEW.tipo_item, 'stock_minimo', NEW.stock_minimo),
         NULL, fn_ultimo_hash(),
         SHA2(CONCAT('items', NEW.id_item, 'INSERT',
                     JSON_OBJECT('id_item', NEW.id_item, 'codigo', NEW.codigo),
                     fn_ultimo_hash()), 256);
END$$

-- 3)

DROP TRIGGER IF EXISTS trg_items_au $$
CREATE TRIGGER trg_items_au
AFTER UPDATE ON items FOR EACH ROW
BEGIN
  INSERT INTO auditoria(tabla_afectada, pk_afectada, accion, valores_antes, valores_despues, id_usuario, hash_anterior, hash_evento)
  SELECT 'items', NEW.id_item, 'UPDATE',
         JSON_OBJECT('id_item', OLD.id_item, 'codigo', OLD.codigo, 'descripcion', OLD.descripcion,
                     'unidad_medida', OLD.unidad_medida, 'tipo_item', OLD.tipo_item, 'stock_minimo', OLD.stock_minimo),
         JSON_OBJECT('id_item', NEW.id_item, 'codigo', NEW.codigo, 'descripcion', NEW.descripcion,
                     'unidad_medida', NEW.unidad_medida, 'tipo_item', NEW.tipo_item, 'stock_minimo', NEW.stock_minimo),
         NULL, fn_ultimo_hash(),
         SHA2(CONCAT('items', NEW.id_item, 'UPDATE',
                     JSON_OBJECT('antes', JSON_OBJECT('codigo', OLD.codigo,'descripcion', OLD.descripcion),
                                 'despues', JSON_OBJECT('codigo', NEW.codigo,'descripcion', NEW.descripcion)),
                     fn_ultimo_hash()), 256);
END$$

-- 4)

DROP TRIGGER IF EXISTS trg_items_ad $$
CREATE TRIGGER trg_items_ad
AFTER DELETE ON items FOR EACH ROW
BEGIN
  INSERT INTO auditoria(tabla_afectada, pk_afectada, accion, valores_antes, valores_despues, id_usuario, hash_anterior, hash_evento)
  SELECT 'items', OLD.id_item, 'DELETE',
         JSON_OBJECT('id_item', OLD.id_item, 'codigo', OLD.codigo, 'descripcion', OLD.descripcion,
                     'unidad_medida', OLD.unidad_medida, 'tipo_item', OLD.tipo_item, 'stock_minimo', OLD.stock_minimo),
         NULL, NULL, fn_ultimo_hash(),
         SHA2(CONCAT('items', OLD.id_item, 'DELETE',
                     JSON_OBJECT('id_item', OLD.id_item, 'codigo', OLD.codigo),
                     fn_ultimo_hash()), 256);
END$$

-- 5)

/* Auditoría de lotes */
DROP TRIGGER IF EXISTS trg_lotes_ai $$
CREATE TRIGGER trg_lotes_ai
AFTER INSERT ON lotes FOR EACH ROW
BEGIN
  INSERT INTO auditoria(tabla_afectada, pk_afectada, accion, valores_antes, valores_despues, id_usuario, hash_anterior, hash_evento)
  SELECT 'lotes', NEW.id_lote, 'INSERT', NULL,
         JSON_OBJECT('id_lote', NEW.id_lote, 'id_item', NEW.id_item, 'codigo_lote', NEW.codigo_lote,
                     'vencimiento', NEW.fecha_vencimiento, 'costo_u', NEW.costo_unitario),
         NULL, fn_ultimo_hash(),
         SHA2(CONCAT('lotes', NEW.id_lote, 'INSERT',
                     JSON_OBJECT('id_item', NEW.id_item, 'codigo_lote', NEW.codigo_lote),
                     fn_ultimo_hash()), 256);
END$$

-- 6)

/* Auditoría de ubicaciones */
DROP TRIGGER IF EXISTS trg_ubicaciones_ai $$
CREATE TRIGGER trg_ubicaciones_ai
AFTER INSERT ON ubicaciones FOR EACH ROW
BEGIN
  INSERT INTO auditoria(tabla_afectada, pk_afectada, accion, valores_antes, valores_despues, id_usuario, hash_anterior, hash_evento)
  SELECT 'ubicaciones', NEW.id_ubicacion, 'INSERT', NULL,
         JSON_OBJECT('id_ubicacion', NEW.id_ubicacion, 'nombre', NEW.nombre, 'tipo', NEW.tipo, 'activo', NEW.activo),
         NULL, fn_ultimo_hash(),
         SHA2(CONCAT('ubicaciones', NEW.id_ubicacion, 'INSERT',
                     JSON_OBJECT('nombre', NEW.nombre),
                     fn_ultimo_hash()), 256);
END$$

-- 7)

/* Movimientos_v2: inmutabilidad + existencias */
DROP TRIGGER IF EXISTS trg_mv2_bu $$
CREATE TRIGGER trg_mv2_bu
BEFORE UPDATE ON movimientos_v2 FOR EACH ROW
BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Los movimientos no se pueden actualizar. Use sp_anular_movimiento()';
END$$

-- 8)

DROP TRIGGER IF EXISTS trg_mv2_bd $$
CREATE TRIGGER trg_mv2_bd
BEFORE DELETE ON movimientos_v2 FOR EACH ROW
BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Los movimientos no se pueden eliminar. Use sp_anular_movimiento()';
END$$

-- 9)

DELIMITER $$

CREATE TRIGGER trg_mv2_ai
AFTER INSERT ON movimientos_v2
FOR EACH ROW
BEGIN
  -- Auditoría del movimiento
  INSERT INTO auditoria(tabla_afectada, pk_afectada, accion, valores_antes, valores_después, id_usuario, hash_anterior, hash_evento)
  SELECT 'movimientos_v2', NEW.id_movimiento, 'INSERT', NULL,
         JSON_OBJECT('id_mov', NEW.id_movimiento, 'id_lote', NEW.id_lote, 'tipo', NEW.tipo,
                     'cant', NEW.cantidad, 'ori', NEW.id_ubicacion_origen, 'des', NEW.id_ubicacion_destino,
                     'motivo', NEW.motivo, 'fecha', DATE_FORMAT(NEW.fecha, '%Y-%m-%d %H:%i:%s')),
         NEW.id_usuario, fn_ultimo_hash(),
         SHA2(CONCAT('movimientos_v2', NEW.id_movimiento, 'INSERT',
                     JSON_OBJECT('id_lote', NEW.id_lote, 'tipo', NEW.tipo, 'cant', NEW.cantidad),
                     fn_ultimo_hash()), 256);

  -- Procesar movimiento
  CALL sp_procesar_movimiento(NEW.id_movimiento);
END$$

-- 10)

/* Auditoría inalterable */
DROP TRIGGER IF EXISTS trg_auditoria_bu $$
CREATE TRIGGER trg_auditoria_bu BEFORE UPDATE ON auditoria
FOR EACH ROW
BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Tabla de auditoría es inmutable (UPDATE prohibido)';
END$$

-- 11)

DROP TRIGGER IF EXISTS trg_auditoria_bd $$
CREATE TRIGGER trg_auditoria_bd BEFORE DELETE ON auditoria
FOR EACH ROW
BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Tabla de auditoría es inmutable (DELETE prohibido)';
END$$

-- 12)

/* Comprobantes de recepción tras INGRESO (opcional) */
DROP TRIGGER IF EXISTS trg_comprobante_ingreso_ai $$
CREATE TRIGGER trg_comprobante_ingreso_ai
AFTER INSERT ON movimientos_v2 FOR EACH ROW
BEGIN
  IF NEW.tipo = 'INGRESO' THEN
    INSERT INTO comprobantes_recepcion (id_movimiento, id_proveedor)
    SELECT NEW.id_movimiento, l.id_proveedor
    FROM lotes l WHERE l.id_lote = NEW.id_lote;
  END IF;
END$$

DELIMITER ;


-- |==========================================================================================|
-- |                                        EVENTOS                                           |
-- |==========================================================================================|

-- 1) evento
DELIMITER //
DROP EVENT IF EXISTS ev_generar_alertas_diarias;
CREATE EVENT ev_generar_alertas_diarias
ON SCHEDULE EVERY 1 DAY
STARTS TIMESTAMP(CURRENT_DATE, '06:00:00')
DO
BEGIN
  -- Vencimientos próximos (según 'dias_alerta_venc')
  INSERT INTO notificaciones(tipo, payload, destinatario)
  SELECT 'ALERTA_VENCIMIENTO',
         JSON_OBJECT('id_lote', l.id_lote, 'id_item', l.id_item, 'codigo', i.codigo,
                     'descripcion', i.descripcion, 'fecha_vencimiento', l.fecha_vencimiento),
         NULL
  FROM v_alertas_vencimiento av
  JOIN lotes l ON l.id_lote = av.id_lote
  JOIN items i ON i.id_item = l.id_item;

  -- Stock bajo (por ubicación)
  INSERT INTO notificaciones(tipo, payload, destinatario)
  SELECT 'ALERTA_STOCK_BAJO',
         JSON_OBJECT('id_item', i.id_item, 'codigo', i.codigo, 'descripcion', i.descripcion,
                     'id_ubicacion', e.id_ubicacion, 'ubicacion', u.nombre,
                     'saldo', e.saldo, 'stock_minimo', i.stock_minimo),
         NULL
  FROM v_alertas_stock_bajo vb
  JOIN existencias e ON e.id_lote = vb.id_lote AND e.id_ubicacion = vb.id_ubicacion
  JOIN items i ON i.id_item = vb.id_item
  JOIN ubicaciones u ON u.id_ubicacion = e.id_ubicacion;
END //
DELIMITER ;



CALL sp_crear_proveedores('Proveedor Ejemplo', '1234567890'); -- listo
CALL sp_obtener_proveedores(1); -- listo
CALL sp_listar_proveedores(); -- listo
CALL sp_actualizar_proveedores(11, 'Proveedor Ejemplo', '1234567890'); -- listo
CALL sp_eliminar_proveedores(12); -- listo


CALL sp_crear_ubicaciones('almacen de ejemplo', 'ALMACEN', 1); -- listo
CALL sp_obtener_ubicaciones(1); -- listo
CALL sp_listar_ubicaciones(); -- listo
CALL sp_actualizar_ubicaciones(11, 'almacen_ejemplo', 'ALMACEN', 0); -- listo
CALL sp_eliminar_ubicaciones(11); -- listo


CALL sp_crear_items(5,'EJM001','item de ejemplo', 'DISPOSITIVO', 'UND', 30);
CALL sp_obtener_items(1); -- listo
CALL sp_listar_items(); -- listo
CALL sp_actualizar_items(13, 5, 'EJM001', 'Item_de_ejemplo', 'MEDICAMENTO', 'UND', 100); -- listo
CALL sp_eliminar_items(13); -- listo


CALL sp_crear_lotes(1, 1, 'L011','2026-11-02', 12.00); -- listo
CALL sp_obtener_lotes(2);
CALL sp_listar_lotes(NULL); -- listo
CALL sp_actualizar_lotes(1, '2025-12-31', 123.45); -- listo
CALL sp_eliminar_lotes(11); -- listo
CALL sp_crear_usuarios('Juan Pérez', 'juan.perez@ejemplo.com', 'ADMIN', '$2b$12$EjemploHashBcrypt1234567890'); -- listo


CALL sp_obtener_usuarios(1); -- listo
CALL sp_listar_usuarios(); -- listo
CALL sp_actualizar_usuarios(1, 'Juan Pérez Actualizado', 'juan.actualizado@ejemplo.com', 'REGENTE', '$2b$12$NuevoHashBcrypt1234567890'); -- listo
CALL sp_eliminar_usuarios(1); -- listo
CALL sp_bloquear_usuarios(2, 15); -- listo

CALL sp_crear_parametro('CLAVE1', 'VALOR1', 'Parámetro de prueba'); -- listo
CALL sp_obtener_parametro('CLAVE1'); -- listo
CALL sp_listar_parametros(); -- listo
CALL sp_actualizar_parametro('CLAVE1', 'VALOR2', 'Parámetro actualizado'); -- listo
CALL sp_eliminar_parametro('CLAVE1'); -- listo

CALL sp_obtener_existencias(1); -- listo
CALL sp_listar_existencias_por_lote(1); -- listo
CALL sp_listar_existencias_por_item(1); -- listo
CALL sp_listar_existencias_detalle(); -- listo

CALL sp_obtener_movimientos_v2(1);
CALL sp_listar_movimientos_por_lote(1);
CALL sp_listar_movimientos_por_fecha('2025-12-31');
CALL sp_actualizar_movimientos_v2(1, 'ALMACEN');
CALL sp_eliminar_movimientos_v2(1);
CALL sp_mov_registrar_ingreso(1, 1, 'COD001');
CALL sp_mov_registrar_salida(1, 1, 1, 1, 1, 'Motivo de prueba');
CALL sp_mov_transferir_stock(1, 1, 1, 1, 1, 'Motivo de prueba');
CALL sp_mov_ajustar_stock(1, 1, 1, 'AUMENTO');
CALL sp_mov_anular(1, 1, 'Motivo de prueba');