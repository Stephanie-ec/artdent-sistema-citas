-- =====================================================================
-- Actualización de cierre - R-09 ("No asistió")
-- Se aplica sobre una base existente sin borrar datos.
-- Es idempotente: puede ejecutarse varias veces.
-- =====================================================================
USE db_artdent_apf2;

INSERT INTO Estado (idEstado, TipoEstado) VALUES (7, 'No asistió')
ON DUPLICATE KEY UPDATE TipoEstado = VALUES(TipoEstado);

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
  IF NOT EXISTS(SELECT 1 FROM Usuario_Horario uh JOIN Horario h ON h.idHorario=uh.Horario_idHorario
    JOIN Usuario_Servicio us ON us.idUsuario=uh.Usuario_idUsuario AND us.idServicio=pServicio
    JOIN Servicio se ON se.idServicio=us.idServicio AND se.Activo=1
    WHERE uh.Usuario_idUsuario=pDoctor AND us.Disponibilidad=1
      AND LOWER(h.DiaSemana)=ELT(WEEKDAY(pDia)+1,'lunes','martes','miercoles','jueves','viernes','sabado','domingo')
      AND pHora>=h.HoraInicio AND ADDTIME(pHora,'00:45:00')<=h.HoraFinal) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='La cita completa debe estar dentro del turno y servicio del odontologo.';
  END IF;
  -- R-09: una cita marcada "No asistió" libera el horario, igual que cancelada o rechazada.
  SELECT idCita INTO vConflicto FROM Cita WHERE Odontologo_idUsuario=pDoctor AND FechaCita=pDia
    AND idCita<>pCita AND Estado_idEstado NOT IN(5,6,7)
    AND HoraCita<ADDTIME(pHora,'00:45:00') AND ADDTIME(HoraCita,'00:45:00')>pHora
    LIMIT 1 FOR UPDATE;
  IF vConflicto IS NOT NULL THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='El odontologo ya tiene una cita en ese horario. Elija otro horario.';
  END IF;
END;;

DROP PROCEDURE IF EXISTS `sp_artdent_cambiarEstado`;;
CREATE PROCEDURE sp_artdent_cambiarEstado(IN pCita INT, IN pDestino INT, IN pActor INT, IN pOrigen VARCHAR(15))
BEGIN
  DECLARE vEstado INT DEFAULT NULL; DECLARE vOrigen VARCHAR(15);
  DECLARE vRol INT DEFAULT NULL; DECLARE vPago INT DEFAULT NULL;
  DECLARE vDoctor INT DEFAULT NULL; DECLARE vInicio DATETIME DEFAULT NULL;
  DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; RESIGNAL; END;
  START TRANSACTION;
  SELECT Estado_idEstado,Origen,Odontologo_idUsuario,TIMESTAMP(FechaCita,HoraCita)
    INTO vEstado,vOrigen,vDoctor,vInicio FROM Cita WHERE idCita=pCita FOR UPDATE;
  SELECT Rol_idRol INTO vRol FROM Usuario WHERE idUsuario=pActor AND Activo=1;
  IF vEstado IS NULL OR vOrigen<>pOrigen THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='La cita no existe.'; END IF;
  IF pDestino=2 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Registre la ficha clinica para finalizar la atencion.';
  ELSEIF pDestino=7 THEN
    -- R-09: inasistencia solo despues de la hora y por secretaria, administrador o el titular.
    IF vRol IS NULL OR vRol NOT IN(1,2,3) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Su rol no permite esta operacion.'; END IF;
    IF vRol=3 AND vDoctor<>pActor THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Solo el odontologo de la cita puede marcar la inasistencia.'; END IF;
    IF vEstado NOT IN(3,4) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Solo se marca inasistencia de citas confirmadas o reprogramadas.'; END IF;
    IF vInicio>(UTC_TIMESTAMP()-INTERVAL 5 HOUR) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Solo se marca la inasistencia despues de la hora de la cita.'; END IF;
  ELSE
    IF vRol IS NULL OR vRol NOT IN(1,2) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Su rol no permite esta operacion.'; END IF;
    IF (pDestino=3 AND vEstado<>1) OR (pDestino IN(5,6) AND vEstado NOT IN(1,3,4))
      OR pDestino NOT IN(3,5,6) OR (pDestino=6 AND vOrigen<>'Web') THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Transicion de estado no permitida.';
    END IF;
  END IF;
  SELECT idPago INTO vPago FROM Pago WHERE Cita_idCita=pCita LIMIT 1 FOR UPDATE;
  IF vOrigen='Web' AND pDestino IN(2,3) AND vPago IS NULL THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='sinPago';
  END IF;
  UPDATE Cita SET Estado_idEstado=pDestino WHERE idCita=pCita;
  IF pDestino IN(5,6) AND vPago IS NOT NULL THEN
    INSERT INTO Notificacion(Asunto,Enviado,Estado_idEstado,Cita_idCita)
      VALUES('Devolucion pendiente: contactar al paciente',0,pDestino,pCita);
  ELSEIF pDestino=7 THEN
    INSERT INTO Notificacion(Asunto,Enviado,Estado_idEstado,Cita_idCita)
      VALUES('Paciente no asistio: contactar para reprogramar',0,7,pCita);
  END IF;
  COMMIT;
END;;
DELIMITER ;

SELECT idEstado, TipoEstado FROM Estado ORDER BY idEstado;
