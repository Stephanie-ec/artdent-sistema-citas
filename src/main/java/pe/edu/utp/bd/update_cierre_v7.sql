-- =====================================================================
-- Actualización de cierre - R-11 (bloqueos de agenda)
-- Se aplica sobre una base existente sin borrar datos.
-- Es idempotente: puede ejecutarse varias veces.
-- =====================================================================
USE db_artdent_apf2;

CREATE TABLE IF NOT EXISTS BloqueoAgenda (
  idBloqueo INT NOT NULL AUTO_INCREMENT,
  Desde DATE NOT NULL,
  Hasta DATE NOT NULL,
  Usuario_idUsuario INT NULL,               -- NULL = toda la clínica
  Motivo VARCHAR(200) NOT NULL,
  Actor_idUsuario INT NOT NULL,
  Creado DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (idBloqueo),
  KEY idx_Bloqueo_Fechas (Desde, Hasta),
  KEY fk_Bloqueo_Usuario_idx (Usuario_idUsuario),
  CONSTRAINT chk_Bloqueo_Fechas CHECK (Hasta >= Desde),
  CONSTRAINT fk_Bloqueo_Usuario FOREIGN KEY (Usuario_idUsuario) REFERENCES Usuario (idUsuario),
  CONSTRAINT fk_Bloqueo_Actor FOREIGN KEY (Actor_idUsuario) REFERENCES Usuario (idUsuario)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DELIMITER ;;

DROP PROCEDURE IF EXISTS `sp_artdent_validarAgenda`;;
CREATE PROCEDURE sp_artdent_validarAgenda(IN pCita INT, IN pDoctor INT, IN pServicio INT, IN pDia DATE, IN pHora TIME)
BEGIN
  DECLARE vActivo INT DEFAULT NULL;
  DECLARE vRol INT DEFAULT NULL;
  DECLARE vConflicto INT DEFAULT NULL;
  DECLARE CONTINUE HANDLER FOR NOT FOUND BEGIN END;
  SELECT Activo,Rol_idRol INTO vActivo,vRol FROM Usuario WHERE idUsuario=pDoctor FOR UPDATE;
  IF vActivo IS NULL OR vActivo<>1 OR vRol<>3 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='El odontologo no esta activo.';
  END IF;
  IF pDia IS NULL OR pHora IS NULL OR TIMESTAMP(pDia,pHora)<(UTC_TIMESTAMP()-INTERVAL 5 HOUR) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='No se admite una fecha u hora pasada.';
  END IF;
  IF DAYOFWEEK(pDia)=1 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='No hay atencion los domingos.';
  END IF;
  -- R-11: feriados y vacaciones bloquean la agenda del odontologo o de toda la clinica.
  IF EXISTS(SELECT 1 FROM BloqueoAgenda b WHERE (b.Usuario_idUsuario IS NULL OR b.Usuario_idUsuario=pDoctor)
    AND pDia BETWEEN b.Desde AND b.Hasta) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='La agenda esta bloqueada para esa fecha.';
  END IF;
  IF NOT EXISTS(SELECT 1 FROM Usuario_Horario uh JOIN Horario h ON h.idHorario=uh.Horario_idHorario
    JOIN Usuario_Servicio us ON us.idUsuario=uh.Usuario_idUsuario AND us.idServicio=pServicio
    JOIN Servicio se ON se.idServicio=us.idServicio AND se.Activo=1
    WHERE uh.Usuario_idUsuario=pDoctor AND us.Disponibilidad=1
      AND LOWER(h.DiaSemana)=ELT(WEEKDAY(pDia)+1,'lunes','martes','miercoles','jueves','viernes','sabado','domingo')
      AND pHora>=h.HoraInicio AND ADDTIME(pHora,'00:45:00')<=h.HoraFinal) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='La cita completa debe estar dentro del turno y servicio del odontologo.';
  END IF;
  SELECT idCita INTO vConflicto FROM Cita WHERE Odontologo_idUsuario=pDoctor AND FechaCita=pDia
    AND idCita<>pCita AND Estado_idEstado NOT IN(5,6,7)
    AND HoraCita<ADDTIME(pHora,'00:45:00') AND ADDTIME(HoraCita,'00:45:00')>pHora
    LIMIT 1 FOR UPDATE;
  IF vConflicto IS NOT NULL THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='El odontologo ya tiene una cita en ese horario. Elija otro horario.';
  END IF;
END;;
DELIMITER ;

SHOW TABLES LIKE 'BloqueoAgenda';
