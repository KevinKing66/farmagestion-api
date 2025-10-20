-- Proveedores
INSERT INTO proveedores (nombre, nit) VALUES ('Proveedor 1', 'NIT001');
INSERT INTO proveedores (nombre, nit) VALUES ('Proveedor 2', 'NIT002');
INSERT INTO proveedores (nombre, nit) VALUES ('Proveedor 3', 'NIT003');
INSERT INTO proveedores (nombre, nit) VALUES ('Proveedor 4', 'NIT004');
INSERT INTO proveedores (nombre, nit) VALUES ('Proveedor 5', 'NIT005');
INSERT INTO proveedores (nombre, nit) VALUES ('Proveedor 6', 'NIT006');
INSERT INTO proveedores (nombre, nit) VALUES ('Proveedor 7', 'NIT007');
INSERT INTO proveedores (nombre, nit) VALUES ('Proveedor 8', 'NIT008');
INSERT INTO proveedores (nombre, nit) VALUES ('Proveedor 9', 'NIT009');
INSERT INTO proveedores (nombre, nit) VALUES ('Proveedor 10', 'NIT010');

-- Ubicaciones
INSERT INTO ubicaciones (nombre, tipo) VALUES ('Ubicacion 1', 'SERVICIO');
INSERT INTO ubicaciones (nombre, tipo) VALUES ('Ubicacion 2', 'ALMACEN');
INSERT INTO ubicaciones (nombre, tipo) VALUES ('Ubicacion 3', 'SERVICIO');
INSERT INTO ubicaciones (nombre, tipo) VALUES ('Ubicacion 4', 'ALMACEN');
INSERT INTO ubicaciones (nombre, tipo) VALUES ('Ubicacion 5', 'SERVICIO');
INSERT INTO ubicaciones (nombre, tipo) VALUES ('Ubicacion 6', 'ALMACEN');
INSERT INTO ubicaciones (nombre, tipo) VALUES ('Ubicacion 7', 'SERVICIO');
INSERT INTO ubicaciones (nombre, tipo) VALUES ('Ubicacion 8', 'ALMACEN');
INSERT INTO ubicaciones (nombre, tipo) VALUES ('Ubicacion 9', 'SERVICIO');
INSERT INTO ubicaciones (nombre, tipo) VALUES ('Ubicacion 10', 'ALMACEN');

-- Usuarios
INSERT INTO usuarios (nombre_completo, correo, rol, contrasena) VALUES ('Usuario 1', 'user1@mail.com', 'REGENTE', '$2b$12$ExampleHash01');
INSERT INTO usuarios (nombre_completo, correo, rol, contrasena) VALUES ('Usuario 2', 'user2@mail.com', 'AUDITOR', '$2b$12$ExampleHash02');
INSERT INTO usuarios (nombre_completo, correo, rol, contrasena) VALUES ('Usuario 3', 'user3@mail.com', 'ADMIN', '$2b$12$ExampleHash03');
INSERT INTO usuarios (nombre_completo, correo, rol, contrasena) VALUES ('Usuario 4', 'user4@mail.com', 'AUXILIAR', '$2b$12$ExampleHash04');
INSERT INTO usuarios (nombre_completo, correo, rol, contrasena) VALUES ('Usuario 5', 'user5@mail.com', 'REGENTE', '$2b$12$ExampleHash05');
INSERT INTO usuarios (nombre_completo, correo, rol, contrasena) VALUES ('Usuario 6', 'user6@mail.com', 'AUDITOR', '$2b$12$ExampleHash06');
INSERT INTO usuarios (nombre_completo, correo, rol, contrasena) VALUES ('Usuario 7', 'user7@mail.com', 'ADMIN', '$2b$12$ExampleHash07');
INSERT INTO usuarios (nombre_completo, correo, rol, contrasena) VALUES ('Usuario 8', 'user8@mail.com', 'AUXILIAR', '$2b$12$ExampleHash08');
INSERT INTO usuarios (nombre_completo, correo, rol, contrasena) VALUES ('Usuario 9', 'user9@mail.com', 'REGENTE', '$2b$12$ExampleHash09');
INSERT INTO usuarios (nombre_completo, correo, rol, contrasena) VALUES ('Usuario 10', 'user10@mail.com', 'AUDITOR', '$2b$12$ExampleHash10');

-- Items
INSERT INTO items (id_ubicacion, codigo, descripcion, tipo_item, unidad_medida, stock_minimo) VALUES (2, 'COD001', 'Item 1', 'DISPOSITIVO', 'UND', 11);
INSERT INTO items (id_ubicacion, codigo, descripcion, tipo_item, unidad_medida, stock_minimo) VALUES (3, 'COD002', 'Item 2', 'MEDICAMENTO', 'UND', 15);
INSERT INTO items (id_ubicacion, codigo, descripcion, tipo_item, unidad_medida, stock_minimo) VALUES (4, 'COD003', 'Item 3', 'DISPOSITIVO', 'UND', 17);
INSERT INTO items (id_ubicacion, codigo, descripcion, tipo_item, unidad_medida, stock_minimo) VALUES (5, 'COD004', 'Item 4', 'MEDICAMENTO', 'UND', 6);
INSERT INTO items (id_ubicacion, codigo, descripcion, tipo_item, unidad_medida, stock_minimo) VALUES (6, 'COD005', 'Item 5', 'DISPOSITIVO', 'UND', 20);
INSERT INTO items (id_ubicacion, codigo, descripcion, tipo_item, unidad_medida, stock_minimo) VALUES (7, 'COD006', 'Item 6', 'MEDICAMENTO', 'UND', 10);
INSERT INTO items (id_ubicacion, codigo, descripcion, tipo_item, unidad_medida, stock_minimo) VALUES (8, 'COD007', 'Item 7', 'DISPOSITIVO', 'UND', 7);
INSERT INTO items (id_ubicacion, codigo, descripcion, tipo_item, unidad_medida, stock_minimo) VALUES (9, 'COD008', 'Item 8', 'MEDICAMENTO', 'UND', 13);
INSERT INTO items (id_ubicacion, codigo, descripcion, tipo_item, unidad_medida, stock_minimo) VALUES (10, 'COD009', 'Item 9', 'DISPOSITIVO', 'UND', 7);
INSERT INTO items (id_ubicacion, codigo, descripcion, tipo_item, unidad_medida, stock_minimo) VALUES (1, 'COD010', 'Item 10', 'MEDICAMENTO', 'UND', 13);

-- Lotes
INSERT INTO lotes (id_item, id_proveedor, codigo_lote, fecha_vencimiento, costo_unitario) VALUES (1, 2, 'L001', '2025-11-02', 55.00);
INSERT INTO lotes (id_item, id_proveedor, codigo_lote, fecha_vencimiento, costo_unitario) VALUES (2, 3, 'L002', '2025-11-03', 150.00);
INSERT INTO lotes (id_item, id_proveedor, codigo_lote, fecha_vencimiento, costo_unitario) VALUES (3, 4, 'L003', '2025-11-04', 50.00);
INSERT INTO lotes (id_item, id_proveedor, codigo_lote, fecha_vencimiento, costo_unitario) VALUES (4, 5, 'L004', '2025-11-05', 81.00);
INSERT INTO lotes (id_item, id_proveedor, codigo_lote, fecha_vencimiento, costo_unitario) VALUES (5, 6, 'L005', '2025-11-06', 84.00);
INSERT INTO lotes (id_item, id_proveedor, codigo_lote, fecha_vencimiento, costo_unitario) VALUES (6, 7, 'L006', '2025-11-07', 127.00);
INSERT INTO lotes (id_item, id_proveedor, codigo_lote, fecha_vencimiento, costo_unitario) VALUES (7, 8, 'L007', '2025-11-08', 81.00);
INSERT INTO lotes (id_item, id_proveedor, codigo_lote, fecha_vencimiento, costo_unitario) VALUES (8, 9, 'L008', '2025-11-09', 82.00);
INSERT INTO lotes (id_item, id_proveedor, codigo_lote, fecha_vencimiento, costo_unitario) VALUES (9, 10, 'L009', '2025-11-10', 121.00);
INSERT INTO lotes (id_item, id_proveedor, codigo_lote, fecha_vencimiento, costo_unitario) VALUES (10, 1, 'L010', '2025-11-11', 146.00);

-- Existencias
INSERT INTO existencias (id_lote, id_ubicacion, saldo) VALUES (1, 2, 30);
INSERT INTO existencias (id_lote, id_ubicacion, saldo) VALUES (2, 3, 50);
INSERT INTO existencias (id_lote, id_ubicacion, saldo) VALUES (3, 4, 90);
INSERT INTO existencias (id_lote, id_ubicacion, saldo) VALUES (4, 5, 81);
INSERT INTO existencias (id_lote, id_ubicacion, saldo) VALUES (5, 6, 62);
INSERT INTO existencias (id_lote, id_ubicacion, saldo) VALUES (6, 7, 65);
INSERT INTO existencias (id_lote, id_ubicacion, saldo) VALUES (7, 8, 83);
INSERT INTO existencias (id_lote, id_ubicacion, saldo) VALUES (8, 9, 43);
INSERT INTO existencias (id_lote, id_ubicacion, saldo) VALUES (9, 10, 81);
INSERT INTO existencias (id_lote, id_ubicacion, saldo) VALUES (10, 1, 10);

-- Parametros del sistema
INSERT INTO parametros_sistema (clave, valor, descripcion) VALUES ('dias_alerta_venc','30','Días para alerta de vencimiento'),
('umbral_stock_bajo_default','10','Umbral por defecto')
ON DUPLICATE KEY UPDATE valor = VALUES(valor), descripcion = VALUES(descripcion);
-- Notificaciones
INSERT INTO notificaciones (tipo, payload, estado, fecha_creacion) VALUES ('ALERTA_STOCK_BAJO', '{"id":1,"mensaje":"Notificación 1"}', 'PENDIENTE', NOW());
INSERT INTO notificaciones (tipo, payload, estado, fecha_creacion) VALUES ('ALERTA_VENCIMIENTO', '{"id":2,"mensaje":"Notificación 2"}', 'PENDIENTE', NOW());
INSERT INTO notificaciones (tipo, payload, estado, fecha_creacion) VALUES ('ALERTA_STOCK_BAJO', '{"id":3,"mensaje":"Notificación 3"}', 'PENDIENTE', NOW());
INSERT INTO notificaciones (tipo, payload, estado, fecha_creacion) VALUES ('ALERTA_VENCIMIENTO', '{"id":4,"mensaje":"Notificación 4"}', 'PENDIENTE', NOW());
INSERT INTO notificaciones (tipo, payload, estado, fecha_creacion) VALUES ('ALERTA_STOCK_BAJO', '{"id":5,"mensaje":"Notificación 5"}', 'PENDIENTE', NOW());
INSERT INTO notificaciones (tipo, payload, estado, fecha_creacion) VALUES ('ALERTA_VENCIMIENTO', '{"id":6,"mensaje":"Notificación 6"}', 'PENDIENTE', NOW());
INSERT INTO notificaciones (tipo, payload, estado, fecha_creacion) VALUES ('ALERTA_STOCK_BAJO', '{"id":7,"mensaje":"Notificación 7"}', 'PENDIENTE', NOW());
INSERT INTO notificaciones (tipo, payload, estado, fecha_creacion) VALUES ('ALERTA_VENCIMIENTO', '{"id":8,"mensaje":"Notificación 8"}', 'PENDIENTE', NOW());
INSERT INTO notificaciones (tipo, payload, estado, fecha_creacion) VALUES ('ALERTA_STOCK_BAJO', '{"id":9,"mensaje":"Notificación 9"}', 'PENDIENTE', NOW());
INSERT INTO notificaciones (tipo, payload, estado, fecha_creacion) VALUES ('ALERTA_VENCIMIENTO', '{"id":10,"mensaje":"Notificación 10"}', 'PENDIENTE', NOW());

-- Staging inventario inicial
INSERT INTO stg_inventario_inicial (codigo_item, nit_proveedor, codigo_lote, fecha_vencimiento, costo_unitario, nombre_ubicacion, cantidad) VALUES ('COD001', 'NIT001', 'L001', '2025-12-02', 105.00, 'Ubicacion 2', 25);
INSERT INTO stg_inventario_inicial (codigo_item, nit_proveedor, codigo_lote, fecha_vencimiento, costo_unitario, nombre_ubicacion, cantidad) VALUES ('COD002', 'NIT002', 'L002', '2025-12-03', 60.00, 'Ubicacion 3', 50);
INSERT INTO stg_inventario_inicial (codigo_item, nit_proveedor, codigo_lote, fecha_vencimiento, costo_unitario, nombre_ubicacion, cantidad) VALUES ('COD003', 'NIT003', 'L003', '2025-12-04', 130.00, 'Ubicacion 4', 47);
INSERT INTO stg_inventario_inicial (codigo_item, nit_proveedor, codigo_lote, fecha_vencimiento, costo_unitario, nombre_ubicacion, cantidad) VALUES ('COD004', 'NIT004', 'L004', '2025-12-05', 133.00, 'Ubicacion 5', 21);
INSERT INTO stg_inventario_inicial (codigo_item, nit_proveedor, codigo_lote, fecha_vencimiento, costo_unitario, nombre_ubicacion, cantidad) VALUES ('COD005', 'NIT005', 'L005', '2025-12-06', 110.00, 'Ubicacion 6', 12);
INSERT INTO stg_inventario_inicial (codigo_item, nit_proveedor, codigo_lote, fecha_vencimiento, costo_unitario, nombre_ubicacion, cantidad) VALUES ('COD006', 'NIT006', 'L006', '2025-12-07', 51.00, 'Ubicacion 7', 13);
INSERT INTO stg_inventario_inicial (codigo_item, nit_proveedor, codigo_lote, fecha_vencimiento, costo_unitario, nombre_ubicacion, cantidad) VALUES ('COD007', 'NIT007', 'L007', '2025-12-08', 94.00, 'Ubicacion 8', 39);
INSERT INTO stg_inventario_inicial (codigo_item, nit_proveedor, codigo_lote, fecha_vencimiento, costo_unitario, nombre_ubicacion, cantidad) VALUES ('COD008', 'NIT008', 'L008', '2025-12-09', 62.00, 'Ubicacion 9', 17);
INSERT INTO stg_inventario_inicial (codigo_item, nit_proveedor, codigo_lote, fecha_vencimiento, costo_unitario, nombre_ubicacion, cantidad) VALUES ('COD009', 'NIT009', 'L009', '2025-12-10', 114.00, 'Ubicacion 10', 41);
INSERT INTO stg_inventario_inicial (codigo_item, nit_proveedor, codigo_lote, fecha_vencimiento, costo_unitario, nombre_ubicacion, cantidad) VALUES ('COD010', 'NIT010', 'L010', '2025-12-11', 87.00, 'Ubicacion 1', 35);

-- INGRESO
INSERT INTO movimientos_v2 (id_lote, id_usuario, tipo, cantidad, id_ubicacion_destino, motivo) VALUES
(1, 1, 'INGRESO', 100, 2, 'Ingreso por compra'),
(2, 1, 'INGRESO', 50, 2, 'Reposición de stock'),
(3, 2, 'INGRESO', 200, 3, 'Donación recibida'),
(4, 3, 'INGRESO', 75, 2, 'Ingreso por devolución'),
(5, 4, 'INGRESO', 120, 3, 'Ingreso por ajuste de inventario');

-- SALIDA
INSERT INTO movimientos_v2 (id_lote, id_usuario, tipo, cantidad, id_ubicacion_origen, motivo) VALUES
(1, 2, 'SALIDA', 20, 2, 'Entrega a servicio de urgencias'),
(2, 3, 'SALIDA', 15, 3, 'Consumo interno'),
(3, 4, 'SALIDA', 30, 2, 'Salida por vencimiento'),
(4, 1, 'SALIDA', 10, 3, 'Salida por error de ingreso'),
(5, 2, 'SALIDA', 25, 2, 'Entrega a paciente');

-- TRANSFERENCIA
INSERT INTO movimientos_v2 (id_lote, id_usuario, tipo, cantidad, id_ubicacion_origen, id_ubicacion_destino, motivo) VALUES
(1, 3, 'TRANSFERENCIA', 40, 2, 3, 'Transferencia a farmacia principal'),
(2, 4, 'TRANSFERENCIA', 60, 3, 2, 'Reubicación por reorganización'),
(3, 1, 'TRANSFERENCIA', 30, 2, 4, 'Transferencia por solicitud'),
(4, 2, 'TRANSFERENCIA', 20, 3, 2, 'Cambio de ubicación'),
(5, 3, 'TRANSFERENCIA', 50, 4, 2, 'Optimización de inventario');

-- AJUSTE
INSERT INTO movimientos_v2 (id_lote, id_usuario, tipo, cantidad, id_ubicacion_origen, motivo) VALUES
(1, 4, 'AJUSTE', -5, 2, 'Ajuste por pérdida'),
(2, 1, 'AJUSTE', 10, 3, 'Ajuste por conteo físico'),
(3, 2, 'AJUSTE', -3, 2, 'Producto dañado'),
(4, 3, 'AJUSTE', 7, 4, 'Corrección de ingreso'),
(5, 4, 'AJUSTE', -2, 3, 'Ajuste por error de sistema');

INSERT INTO comprobantes_recepcion (id_movimiento, id_proveedor, canal, entregado) VALUES (2, 3, 'PORTAL', 0);
INSERT INTO comprobantes_recepcion (id_movimiento, id_proveedor, canal, entregado) VALUES (3, 4, 'EMAIL', 0);
INSERT INTO comprobantes_recepcion (id_movimiento, id_proveedor, canal, entregado) VALUES (4, 5, 'PORTAL', 0);
INSERT INTO comprobantes_recepcion (id_movimiento, id_proveedor, canal, entregado) VALUES (5, 6, 'EMAIL', 0);
INSERT INTO comprobantes_recepcion (id_movimiento, id_proveedor, canal, entregado) VALUES (6, 7, 'PORTAL', 0);
INSERT INTO comprobantes_recepcion (id_movimiento, id_proveedor, canal, entregado) VALUES (7, 8, 'EMAIL', 0);
INSERT INTO comprobantes_recepcion (id_movimiento, id_proveedor, canal, entregado) VALUES (8, 9, 'PORTAL', 0);
INSERT INTO comprobantes_recepcion (id_movimiento, id_proveedor, canal, entregado) VALUES (9, 10, 'EMAIL', 0);
INSERT INTO comprobantes_recepcion (id_movimiento, id_proveedor, canal, entregado) VALUES (10, 1, 'PORTAL', 0);