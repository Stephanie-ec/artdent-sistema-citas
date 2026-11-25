-- =====================================================================
-- Actualización de cierre - R-06 (Ley 29733)
-- Se aplica sobre una base existente sin borrar datos.
-- Es idempotente: puede ejecutarse varias veces.
-- =====================================================================
USE db_artdent_apf2;

-- R-06: fecha y hora de aceptación de la Política de privacidad
SET @existe := (SELECT COUNT(*) FROM information_schema.COLUMNS
                WHERE TABLE_SCHEMA = DATABASE()
                  AND TABLE_NAME = 'Paciente'
                  AND COLUMN_NAME = 'ConsentimientoFecha');
SET @sql := IF(@existe = 0,
  'ALTER TABLE Paciente ADD COLUMN ConsentimientoFecha DATETIME NULL AFTER Correo',
  'SELECT ''Paciente.ConsentimientoFecha ya existe'' AS resultado');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
