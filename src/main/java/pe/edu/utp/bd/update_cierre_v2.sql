-- =====================================================================
-- Actualización de cierre - R-08 (gestión de contraseñas del personal)
-- Se aplica sobre una base existente sin borrar datos.
-- Es idempotente: puede ejecutarse varias veces.
-- =====================================================================
USE db_artdent_apf2;

-- R-08: obliga a cambiar la clave temporal en el siguiente ingreso
SET @existe := (SELECT COUNT(*) FROM information_schema.COLUMNS
                WHERE TABLE_SCHEMA = DATABASE()
                  AND TABLE_NAME = 'Usuario'
                  AND COLUMN_NAME = 'DebeCambiarClave');
SET @sql := IF(@existe = 0,
  'ALTER TABLE Usuario ADD COLUMN DebeCambiarClave TINYINT(1) NOT NULL DEFAULT 0 AFTER BloqueadoHasta',
  'SELECT ''Usuario.DebeCambiarClave ya existe'' AS resultado');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
