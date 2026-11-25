-- =====================================================================
-- Actualización de cierre - R-04 (validación de identidad con RENIEC)
-- Se aplica sobre una base existente sin borrar datos.
-- Es idempotente: puede ejecutarse varias veces.
-- =====================================================================
USE db_artdent_apf2;

-- R-04: 0 = identidad pendiente de revisión por la secretaría
SET @existe := (SELECT COUNT(*) FROM information_schema.COLUMNS
                WHERE TABLE_SCHEMA = DATABASE()
                  AND TABLE_NAME = 'Paciente'
                  AND COLUMN_NAME = 'IdentidadVerificada');
SET @sql := IF(@existe = 0,
  'ALTER TABLE Paciente ADD COLUMN IdentidadVerificada TINYINT(1) NOT NULL DEFAULT 1 AFTER ConsentimientoFecha',
  'SELECT ''Paciente.IdentidadVerificada ya existe'' AS resultado');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
