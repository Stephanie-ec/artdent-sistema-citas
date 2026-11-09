-- Delta no destructivo. Seleccione la BD correcta con USE antes de ejecutarlo.
-- Detener la aplicacion y hacer respaldo antes de cambiar rutinas. No contiene datos demo.
DELIMITER ;;
DROP PROCEDURE IF EXISTS sp_artdent_migrarActivo;;
CREATE PROCEDURE sp_artdent_migrarActivo()
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'Usuario' AND COLUMN_NAME = 'Activo') THEN
    ALTER TABLE Usuario ADD COLUMN Activo TINYINT(1) NOT NULL DEFAULT 1;
  END IF;
END;;
CALL sp_artdent_migrarActivo();;
DROP PROCEDURE sp_artdent_migrarActivo;;
DELIMITER ;
CREATE TABLE IF NOT EXISTS CorrelativoComprobante (
 Serie CHAR(4) NOT NULL PRIMARY KEY,
 Ultimo INT NOT NULL DEFAULT 0
) ENGINE=InnoDB;
INSERT INTO CorrelativoComprobante(Serie,Ultimo)
SELECT Serie, COALESCE(MAX(CAST(Numero AS UNSIGNED)),0) FROM Comprobante GROUP BY Serie
ON DUPLICATE KEY UPDATE Ultimo=GREATEST(Ultimo,VALUES(Ultimo));
INSERT IGNORE INTO CorrelativoComprobante VALUES('B001',0);

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
  -- Lectura actual, no snapshot de REPEATABLE READ, despues de obtener el mutex.
  SELECT idCita INTO vConflicto FROM Cita WHERE Odontologo_idUsuario=pDoctor AND FechaCita=pDia
    AND idCita<>pCita AND Estado_idEstado NOT IN(5,6)
    AND HoraCita<ADDTIME(pHora,'00:45:00') AND ADDTIME(HoraCita,'00:45:00')>pHora
    LIMIT 1 FOR UPDATE;
  IF vConflicto IS NOT NULL THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='El odontologo ya tiene una cita en ese horario. Elija otro horario.';
  END IF;
END;;

DROP PROCEDURE IF EXISTS `sp_artdent_crearCita`;;
CREATE PROCEDURE sp_artdent_crearCita(IN pDia DATE, IN pHora TIME, IN pDesc TEXT, IN pImporte DECIMAL(10,2),
 IN pOrigen VARCHAR(15), IN pUsuario INT, IN pPaciente INT, IN pServicio INT, IN pEstado INT, IN pDoctor INT)
BEGIN
  DECLARE vImporte DECIMAL(10,2);
  DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; RESIGNAL; END;
  START TRANSACTION;
  CALL sp_artdent_validarAgenda(0,pDoctor,pServicio,pDia,pHora);
  IF pOrigen NOT IN('Web','Presencial') OR (pOrigen='Web' AND pEstado<>1) OR (pOrigen='Presencial' AND pEstado<>3) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Estado inicial no permitido.';
  END IF;
  SELECT Costo INTO vImporte FROM Servicio WHERE idServicio=pServicio FOR SHARE;
  INSERT INTO Cita(FechaCita,HoraCita,Descripcion,Importe,Origen,Usuario_idUsuario,Paciente_idPaciente,
    Servicio_idServicio,Estado_idEstado,Odontologo_idUsuario)
    VALUES(pDia,pHora,pDesc,vImporte,pOrigen,pUsuario,pPaciente,pServicio,pEstado,pDoctor);
  COMMIT;
END;;

DROP PROCEDURE IF EXISTS `sp_artdent_reprogramarCita`;;
CREATE PROCEDURE sp_artdent_reprogramarCita(IN pCita INT, IN pDia DATE, IN pHora TIME, IN pOrigen VARCHAR(15))
BEGIN
  DECLARE vDoctor INT DEFAULT NULL;
  DECLARE vServicio INT;
  DECLARE vEstado INT;
  DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; RESIGNAL; END;
  START TRANSACTION;
  SELECT Odontologo_idUsuario,Servicio_idServicio INTO vDoctor,vServicio FROM Cita WHERE idCita=pCita AND Origen=pOrigen;
  IF vDoctor IS NULL THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='La cita no existe.'; END IF;
  CALL sp_artdent_validarAgenda(pCita,vDoctor,vServicio,pDia,pHora);
  SELECT Estado_idEstado INTO vEstado FROM Cita WHERE idCita=pCita FOR UPDATE;
  IF vEstado NOT IN(1,3,4) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Solo se pueden reprogramar citas activas.'; END IF;
  UPDATE Cita SET FechaCita=pDia,HoraCita=pHora,Estado_idEstado=IF(vEstado=1,1,4) WHERE idCita=pCita;
  COMMIT;
END;;

DROP PROCEDURE IF EXISTS `sp_artdent_cambiarEstado`;;
CREATE PROCEDURE sp_artdent_cambiarEstado(IN pCita INT, IN pDestino INT, IN pActor INT, IN pOrigen VARCHAR(15))
BEGIN
  DECLARE vEstado INT DEFAULT NULL; DECLARE vOrigen VARCHAR(15);
  DECLARE vRol INT DEFAULT NULL; DECLARE vPago INT DEFAULT NULL;
  DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; RESIGNAL; END;
  START TRANSACTION;
  SELECT Estado_idEstado,Origen INTO vEstado,vOrigen FROM Cita WHERE idCita=pCita FOR UPDATE;
  SELECT Rol_idRol INTO vRol FROM Usuario WHERE idUsuario=pActor AND Activo=1;
  IF vEstado IS NULL OR vOrigen<>pOrigen THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='La cita no existe.'; END IF;
  IF pDestino=2 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Registre la ficha clinica para finalizar la atencion.';
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
  END IF;
  COMMIT;
END;;

DROP PROCEDURE IF EXISTS `sp_artdent_eliminarCita`;;
CREATE PROCEDURE sp_artdent_eliminarCita(IN pCita INT, IN pActor INT, IN pOrigen VARCHAR(15))
BEGIN
  DECLARE vEstado INT DEFAULT NULL; DECLARE vOrigen VARCHAR(15); DECLARE vRol INT DEFAULT NULL; DECLARE vPago INT DEFAULT NULL;
  DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; RESIGNAL; END;
  START TRANSACTION;
  SELECT Estado_idEstado,Origen INTO vEstado,vOrigen FROM Cita WHERE idCita=pCita FOR UPDATE;
  SELECT Rol_idRol INTO vRol FROM Usuario WHERE idUsuario=pActor AND Activo=1;
  IF vRol IS NULL OR vRol NOT IN(1,2) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Su rol no permite eliminar citas.'; END IF;
  IF vEstado IS NULL OR vOrigen<>pOrigen THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='La cita no existe.'; END IF;
  SELECT idPago INTO vPago FROM Pago WHERE Cita_idCita=pCita LIMIT 1 FOR UPDATE;
  IF vPago IS NOT NULL THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='No se puede eliminar una cita con pago registrado. Utilice Cancelar.'; END IF;
  IF vEstado NOT IN(5,6) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Solo se eliminan citas canceladas o rechazadas sin pago.'; END IF;
  DELETE FROM Notificacion WHERE Cita_idCita=pCita;
  DELETE FROM Cita WHERE idCita=pCita;
  COMMIT;
END;;

DROP PROCEDURE IF EXISTS `sp_iniciosesion`;;
CREATE PROCEDURE `sp_iniciosesion`(IN i_DNI VARCHAR(100), IN i_clave VARCHAR(255))
BEGIN
  SELECT u.idUsuario, u.Nombre, u.Apellido, u.DNI, r.TipoRol 
  FROM Usuario u 
  INNER JOIN Rol r ON u.Rol_idRol = r.idRol 
  WHERE u.DNI = i_DNI AND u.Clave = i_clave AND u.Activo = 1;
END;;

DROP PROCEDURE IF EXISTS `sp_eliminarUsuario`;;
CREATE PROCEDURE `sp_eliminarUsuario`(IN pIdUsuario INT)
BEGIN
  DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; RESIGNAL; END;
  START TRANSACTION;
  UPDATE Usuario SET Activo = 0 WHERE idUsuario = pIdUsuario;
  UPDATE Usuario_Servicio SET Disponibilidad = 0 WHERE idUsuario = pIdUsuario;
  COMMIT;
END;;

DROP PROCEDURE IF EXISTS `sp_listarUsuarios`;;
CREATE PROCEDURE `sp_listarUsuarios`()
BEGIN
  SELECT u.*, r.TipoRol AS RolN
  FROM Usuario u 
  INNER JOIN Rol r ON u.Rol_idRol = r.idRol WHERE u.Activo = 1;
END;;

DROP PROCEDURE IF EXISTS `sp_ListarCitasPorUsuario`;;
CREATE PROCEDURE `sp_ListarCitasPorUsuario`(IN p_idUsuario INT)
BEGIN
  DECLARE p_idRol INT;
  SELECT Rol_idRol INTO p_idRol FROM Usuario WHERE idUsuario = p_idUsuario;

  IF p_idRol = 2 OR p_idRol = 1 THEN
    SELECT
      c.idCita,
      c.FechaCita AS DiaReserva,
      c.HoraCita AS HoraReserva,
      s.TipoServicio,
      p.Nombre AS NombrePaciente,
      p.Apellido AS ApellidoPaciente,
      e.TipoEstado AS Estado
    FROM Cita c
    INNER JOIN Servicio s ON c.Servicio_idServicio = s.idServicio
    INNER JOIN Paciente p ON c.Paciente_idPaciente = p.idPaciente
    INNER JOIN Estado e ON c.Estado_idEstado = e.idEstado
    WHERE c.Origen = 'Presencial' AND c.Estado_idEstado IN (1, 3, 4);
  ELSEIF p_idRol = 3 THEN
    SELECT
      c.idCita,
      c.FechaCita AS DiaReserva,
      c.HoraCita AS HoraReserva,
      s.TipoServicio,
      p.Nombre AS NombrePaciente,
      p.Apellido AS ApellidoPaciente,
      e.TipoEstado AS Estado
    FROM Cita c
    INNER JOIN Servicio s ON c.Servicio_idServicio = s.idServicio
    INNER JOIN Paciente p ON c.Paciente_idPaciente = p.idPaciente
    INNER JOIN Estado e ON c.Estado_idEstado = e.idEstado
    WHERE c.Odontologo_idUsuario = p_idUsuario AND c.Origen = 'Presencial' AND c.Estado_idEstado IN (1, 3, 4);
  END IF;
END;;

DROP PROCEDURE IF EXISTS `sp_ListarReservasPorUsuario`;;
CREATE PROCEDURE `sp_ListarReservasPorUsuario`(IN p_idUsuario INT)
BEGIN
  DECLARE p_idRol INT;
  SELECT Rol_idRol INTO p_idRol FROM Usuario WHERE idUsuario = p_idUsuario;

  IF p_idRol = 2 OR p_idRol = 1 THEN
    SELECT
      c.idCita AS idReserva,
      c.FechaCita AS DiaReserva,
      c.HoraCita AS HoraReserva,
      c.Descripcion,
      c.Importe,
      p.Nombre AS NombrePaciente,
      p.Apellido AS ApellidoPaciente,
      e.TipoEstado AS EstadoReserva,
      s.TipoServicio,
      od.Nombre AS NombreOdontologo,
      od.Apellido AS ApellidoOdontologo
    FROM Cita c
    INNER JOIN Paciente p ON c.Paciente_idPaciente = p.idPaciente
    INNER JOIN Estado e ON c.Estado_idEstado = e.idEstado
    INNER JOIN Servicio s ON c.Servicio_idServicio = s.idServicio
    INNER JOIN Usuario od ON c.Odontologo_idUsuario = od.idUsuario
    WHERE c.Origen = 'Web' AND c.Estado_idEstado IN (1, 3, 4);
  ELSEIF p_idRol = 3 THEN
    SELECT
      c.idCita AS idReserva,
      c.FechaCita AS DiaReserva,
      c.HoraCita AS HoraReserva,
      c.Descripcion,
      c.Importe,
      p.Nombre AS NombrePaciente,
      p.Apellido AS ApellidoPaciente,
      e.TipoEstado AS EstadoReserva,
      s.TipoServicio,
      od.Nombre AS NombreOdontologo,
      od.Apellido AS ApellidoOdontologo
    FROM Cita c
    INNER JOIN Paciente p ON c.Paciente_idPaciente = p.idPaciente
    INNER JOIN Estado e ON c.Estado_idEstado = e.idEstado
    INNER JOIN Servicio s ON c.Servicio_idServicio = s.idServicio
    INNER JOIN Usuario od ON c.Odontologo_idUsuario = od.idUsuario
    WHERE c.Odontologo_idUsuario = p_idUsuario AND c.Origen = 'Web' AND c.Estado_idEstado IN (1, 3, 4);
  END IF;
END;;

DROP PROCEDURE IF EXISTS `sp_crearreserva`;;
CREATE PROCEDURE sp_crearreserva(IN pDia DATE, IN pHora TIME, IN pDesc TEXT,
 IN pImporte DECIMAL(10,2), IN pPaciente INT, IN pEstado INT, IN pServicio INT, IN pDoctor INT)
BEGIN
  CALL sp_artdent_crearCita(pDia,pHora,pDesc,pImporte,'Web',NULL,pPaciente,pServicio,1,pDoctor);
END;;

DROP PROCEDURE IF EXISTS `sp_registrarcita`;;
CREATE PROCEDURE sp_registrarcita(IN pDia DATE, IN pHora TIME, IN pServicio INT,
 IN pPaciente CHAR(8), IN pEstado INT, IN pDoctor INT)
BEGIN
  DECLARE vImporte DECIMAL(10,2);
  SELECT Costo INTO vImporte FROM Servicio WHERE idServicio=pServicio;
  CALL sp_artdent_crearCita(pDia,pHora,'Cita Presencial',vImporte,'Presencial',NULL,pPaciente,pServicio,3,pDoctor);
END;;

DROP PROCEDURE IF EXISTS `ps_ReprogramarReserva`;;
CREATE PROCEDURE ps_ReprogramarReserva(IN p_idReserva INT, IN p_nuevaFecha DATE, IN p_nuevaHora TIME)
BEGIN
  CALL sp_artdent_reprogramarCita(p_idReserva,p_nuevaFecha,p_nuevaHora,'Web');
END;;

DROP PROCEDURE IF EXISTS `ps_ReprogramarCita`;;
CREATE PROCEDURE ps_ReprogramarCita(IN p_idCita INT, IN p_nuevaFecha DATE, IN p_nuevaHora TIME)
BEGIN
  CALL sp_artdent_reprogramarCita(p_idCita,p_nuevaFecha,p_nuevaHora,'Presencial');
END;;
DELIMITER ;

-- Cierre adicional al delta F-01 a F-18. Ejecutable nuevamente sin borrar datos.
CREATE TABLE IF NOT EXISTS SolicitudPago (
 idSolicitud INT AUTO_INCREMENT PRIMARY KEY,
 Cita_idCita INT NOT NULL,
 Canal VARCHAR(4) NOT NULL,
 CodigoOperacion VARCHAR(40) NOT NULL,
 Archivo CHAR(40) NOT NULL,
 Monto DECIMAL(10,2) NOT NULL,
 NombreCliente VARCHAR(100) NOT NULL,
 DNICliente CHAR(8) NOT NULL,
 Estado VARCHAR(10) NOT NULL DEFAULT 'PENDIENTE',
 Motivo VARCHAR(300) NULL,
 Creada DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
 Revisada DATETIME NULL,
 Revisor_idUsuario INT NULL,
 Pago_idPago INT NULL UNIQUE,
 OperacionAprobada VARCHAR(46) GENERATED ALWAYS AS
   (CASE WHEN Estado='APROBADA' THEN CONCAT(Canal,':',CodigoOperacion) ELSE NULL END) STORED,
 UNIQUE KEY OperacionAprobada_UNIQUE (OperacionAprobada),
 KEY Solicitud_Cita (Cita_idCita),
 FOREIGN KEY (Cita_idCita) REFERENCES Cita(idCita),
 FOREIGN KEY (Revisor_idUsuario) REFERENCES Usuario(idUsuario),
 FOREIGN KEY (Pago_idPago) REFERENCES Pago(idPago),
 CHECK (Canal IN ('YAPE','PLIN') AND Monto>0),
 CHECK (Estado IN ('PENDIENTE','APROBADA','RECHAZADA'))
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS Devolucion (
 Pago_idPago INT PRIMARY KEY,
 Estado VARCHAR(10) NOT NULL DEFAULT 'PENDIENTE',
 Referencia VARCHAR(100) NULL,
 Realizada DATETIME NULL,
 Actor_idUsuario INT NULL,
 FOREIGN KEY (Pago_idPago) REFERENCES Pago(idPago),
 FOREIGN KEY (Actor_idUsuario) REFERENCES Usuario(idUsuario),
 CHECK (Estado IN ('PENDIENTE','REALIZADA'))
) ENGINE=InnoDB;
INSERT IGNORE INTO Devolucion(Pago_idPago)
 SELECT p.idPago FROM Pago p JOIN Cita c ON c.idCita=p.Cita_idCita WHERE c.Estado_idEstado IN(5,6);

CREATE TABLE IF NOT EXISTS Atencion (
 Cita_idCita INT PRIMARY KEY,
 Diagnostico VARCHAR(2000) NOT NULL,
 Tratamiento VARCHAR(2000) NOT NULL,
 Observaciones VARCHAR(2000) NOT NULL,
 Autor_idUsuario INT NOT NULL,
 Registrada DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
 FOREIGN KEY (Cita_idCita) REFERENCES Cita(idCita),
 FOREIGN KEY (Autor_idUsuario) REFERENCES Usuario(idUsuario)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS CorreoPendiente (
 idCorreo BIGINT AUTO_INCREMENT PRIMARY KEY,
 Cita_idCita INT NOT NULL,
 Evento CHAR(64) NOT NULL,
 Destinatario VARCHAR(100) NOT NULL,
 Asunto VARCHAR(150) NOT NULL,
 Mensaje TEXT NOT NULL,
 Estado VARCHAR(10) NOT NULL DEFAULT 'PENDIENTE',
 Intentos INT NOT NULL DEFAULT 0,
 Proximo DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
 UltimoError VARCHAR(100) NULL,
 UNIQUE KEY Evento_Destino (Evento,Destinatario),
 FOREIGN KEY (Cita_idCita) REFERENCES Cita(idCita) ON DELETE CASCADE,
 CHECK (Estado IN ('PENDIENTE','ENVIANDO','ENVIADO'))
) ENGINE=InnoDB;

DELIMITER ;;
DROP TRIGGER IF EXISTS tr_artdent_devolucion;;
CREATE TRIGGER tr_artdent_devolucion AFTER UPDATE ON Cita FOR EACH ROW
BEGIN
 IF NEW.Estado_idEstado IN(5,6) AND OLD.Estado_idEstado NOT IN(5,6) THEN
   INSERT IGNORE INTO Devolucion(Pago_idPago) SELECT idPago FROM Pago WHERE Cita_idCita=NEW.idCita;
 END IF;
END;;
DROP PROCEDURE IF EXISTS sp_artdent_registrarAtencion;;
CREATE PROCEDURE sp_artdent_registrarAtencion(IN pCita INT, IN pActor INT, IN pDiagnostico TEXT, IN pTratamiento TEXT, IN pObservaciones TEXT)
BEGIN
 DECLARE vDoctor INT DEFAULT NULL; DECLARE vEstado INT; DECLARE vInicio DATETIME; DECLARE vOrigen VARCHAR(15); DECLARE vRol INT DEFAULT NULL;
 DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; RESIGNAL; END;
 START TRANSACTION;
 SELECT Odontologo_idUsuario,Estado_idEstado,TIMESTAMP(FechaCita,HoraCita),Origen
   INTO vDoctor,vEstado,vInicio,vOrigen FROM Cita WHERE idCita=pCita FOR UPDATE;
 SELECT Rol_idRol INTO vRol FROM Usuario WHERE idUsuario=pActor AND Activo=1;
 IF vDoctor IS NULL OR vRol IS NULL OR (vRol<>1 AND (vRol<>3 OR vDoctor<>pActor)) THEN
   SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Solo el titular o administrador puede registrar la atencion.';
 END IF;
 IF vEstado NOT IN(3,4) OR vInicio>(UTC_TIMESTAMP()-INTERVAL 5 HOUR) THEN
   SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Solo se finalizan citas confirmadas o reprogramadas que ya comenzaron.';
 END IF;
 IF vOrigen='Web' AND NOT EXISTS(SELECT 1 FROM Pago WHERE Cita_idCita=pCita) THEN
   SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='sinPago';
 END IF;
 IF pDiagnostico IS NULL OR CHAR_LENGTH(TRIM(pDiagnostico)) NOT BETWEEN 1 AND 2000
   OR pTratamiento IS NULL OR CHAR_LENGTH(TRIM(pTratamiento)) NOT BETWEEN 1 AND 2000
   OR pObservaciones IS NULL OR CHAR_LENGTH(pObservaciones)>2000 THEN
   SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Complete diagnostico y tratamiento (maximo 2000 caracteres por campo).';
 END IF;
 INSERT INTO Atencion(Cita_idCita,Diagnostico,Tratamiento,Observaciones,Autor_idUsuario)
   VALUES(pCita,TRIM(pDiagnostico),TRIM(pTratamiento),TRIM(pObservaciones),pActor);
 UPDATE Cita SET Estado_idEstado=2 WHERE idCita=pCita;
 COMMIT;
END;;
DELIMITER ;
