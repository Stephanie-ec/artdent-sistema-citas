-- =====================================================================
-- Actualización de cierre - R-10 (el paciente cancela o reprograma)
-- Se aplica sobre una base existente sin borrar datos.
-- Es idempotente: puede ejecutarse varias veces.
-- El paciente no tiene sesión de personal: el procedimiento valida el DNI
-- de la reserva y la regla de 24 horas.
-- =====================================================================
USE db_artdent_apf2;

DELIMITER ;;

DROP PROCEDURE IF EXISTS `sp_artdent_cancelarReservaPaciente`;;
CREATE PROCEDURE sp_artdent_cancelarReservaPaciente(IN pCita INT, IN pDni CHAR(8))
BEGIN
  DECLARE vEstado INT DEFAULT NULL; DECLARE vInicio DATETIME; DECLARE vDni CHAR(8);
  DECLARE vPago INT DEFAULT NULL;
  DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; RESIGNAL; END;
  START TRANSACTION;
  SELECT c.Estado_idEstado,TIMESTAMP(c.FechaCita,c.HoraCita),p.DNI
    INTO vEstado,vInicio,vDni
    FROM Cita c JOIN Paciente p ON p.idPaciente=c.Paciente_idPaciente
    WHERE c.idCita=pCita AND c.Origen='Web' FOR UPDATE;
  IF vEstado IS NULL OR vDni<>pDni THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='La reserva no existe.'; END IF;
  IF vEstado NOT IN(1,3,4) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Esta reserva ya no se puede cancelar.'; END IF;
  IF vInicio < DATE_ADD(UTC_TIMESTAMP()-INTERVAL 5 HOUR, INTERVAL 24 HOUR) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Comuniquese con la clinica: faltan menos de 24 horas para su cita.';
  END IF;
  SELECT idPago INTO vPago FROM Pago WHERE Cita_idCita=pCita LIMIT 1 FOR UPDATE;
  UPDATE Cita SET Estado_idEstado=5 WHERE idCita=pCita;
  INSERT INTO Notificacion(Asunto,Enviado,Estado_idEstado,Cita_idCita)
    VALUES('Reserva cancelada por el paciente',0,5,pCita);
  IF vPago IS NOT NULL THEN
    INSERT IGNORE INTO Devolucion(Pago_idPago) VALUES(vPago);
    INSERT INTO Notificacion(Asunto,Enviado,Estado_idEstado,Cita_idCita)
      VALUES('Devolucion pendiente: contactar al paciente',0,5,pCita);
  END IF;
  COMMIT;
END;;

DROP PROCEDURE IF EXISTS `sp_artdent_reprogramarReservaPaciente`;;
CREATE PROCEDURE sp_artdent_reprogramarReservaPaciente(IN pCita INT, IN pDni CHAR(8), IN pDia DATE, IN pHora TIME)
BEGIN
  DECLARE vEstado INT DEFAULT NULL; DECLARE vInicio DATETIME; DECLARE vDni CHAR(8);
  DECLARE vDoctor INT; DECLARE vServicio INT;
  DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; RESIGNAL; END;
  START TRANSACTION;
  SELECT c.Estado_idEstado,TIMESTAMP(c.FechaCita,c.HoraCita),p.DNI,c.Odontologo_idUsuario,c.Servicio_idServicio
    INTO vEstado,vInicio,vDni,vDoctor,vServicio
    FROM Cita c JOIN Paciente p ON p.idPaciente=c.Paciente_idPaciente
    WHERE c.idCita=pCita AND c.Origen='Web' FOR UPDATE;
  IF vEstado IS NULL OR vDni<>pDni THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='La reserva no existe.'; END IF;
  IF vEstado NOT IN(1,3,4) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Esta reserva ya no se puede reprogramar.'; END IF;
  IF vInicio < DATE_ADD(UTC_TIMESTAMP()-INTERVAL 5 HOUR, INTERVAL 24 HOUR) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Comuniquese con la clinica: faltan menos de 24 horas para su cita.';
  END IF;
  CALL sp_artdent_validarAgenda(pCita,vDoctor,vServicio,pDia,pHora);
  UPDATE Cita SET FechaCita=pDia,HoraCita=pHora,Estado_idEstado=IF(vEstado=1,1,4) WHERE idCita=pCita;
  COMMIT;
END;;
DELIMITER ;

SELECT ROUTINE_NAME FROM information_schema.ROUTINES
 WHERE ROUTINE_SCHEMA=DATABASE() AND ROUTINE_NAME LIKE 'sp_artdent_%ReservaPaciente';
