-- =====================================================================
-- Actualización de cierre - R-01 (pago con tarjeta / Mercado Pago)
-- Se aplica sobre una base existente sin borrar datos.
-- Es idempotente: puede ejecutarse varias veces.
-- =====================================================================
USE db_artdent_apf2;

-- Método de pago propio para la pasarela (1 = En línea, 2 = Efectivo)
INSERT INTO MetodoPago (idMetodo, NombreMetodo) VALUES (3, 'Mercado Pago')
ON DUPLICATE KEY UPDATE NombreMetodo = VALUES(NombreMetodo);

-- R-01: una misma operación del proveedor no puede registrarse dos veces.
-- Los NULL siguen permitidos varias veces en MySQL, así que no afecta al efectivo.
SET @existe := (SELECT COUNT(*) FROM information_schema.STATISTICS
                WHERE TABLE_SCHEMA = DATABASE()
                  AND TABLE_NAME = 'Pago'
                  AND INDEX_NAME = 'CodigoTransaccion_UNIQUE');
SET @sql := IF(@existe = 0,
  'ALTER TABLE Pago ADD UNIQUE KEY CodigoTransaccion_UNIQUE (CodigoTransaccion)',
  'SELECT ''Pago.CodigoTransaccion_UNIQUE ya existe'' AS resultado');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SELECT idMetodo, NombreMetodo FROM MetodoPago ORDER BY idMetodo;
