-- =====================================================================
-- Actualización de cierre - R-15 (registro de eventos y alertas)
-- Se aplica sobre una base existente sin borrar datos.
-- Es idempotente: puede ejecutarse varias veces.
-- =====================================================================
USE db_artdent_apf2;

CREATE TABLE IF NOT EXISTS Evento (
  idEvento      INT NOT NULL AUTO_INCREMENT,
  Fecha         DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  Nivel         VARCHAR(15) NOT NULL,          -- INFO / ADVERTENCIA / ERROR
  Origen        VARCHAR(60) NOT NULL,
  Mensaje       VARCHAR(500) NOT NULL,
  Atendido      TINYINT(1) NOT NULL DEFAULT 0,
  AtendidoPor   INT NULL,
  FechaAtencion DATETIME NULL,
  AccionTomada  VARCHAR(500) NULL,
  PRIMARY KEY (idEvento),
  KEY idx_Evento_Fecha (Fecha),
  KEY idx_Evento_Nivel (Nivel, Atendido),
  CONSTRAINT chk_Evento_Nivel CHECK (Nivel IN ('INFO','ADVERTENCIA','ERROR')),
  CONSTRAINT fk_Evento_Usuario FOREIGN KEY (AtendidoPor) REFERENCES Usuario (idUsuario)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
