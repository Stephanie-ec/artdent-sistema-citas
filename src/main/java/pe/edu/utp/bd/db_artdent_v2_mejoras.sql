-- script v2 art dent (correr despues de db_artdent_apf2_completo.sql)
-- cambiar la clave de artdent_app antes de ejecutar

USE db_artdent_apf2;

-- revisar datos antes de agregar los checks
UPDATE Usuario SET Apellido = 'Ipanaqué Vásquez' WHERE DNI = '75121424' AND Apellido = 'IPv5';

SELECT 'Paciente' AS tabla, idPaciente AS id, Nombre, Apellido, DNI, Telefono FROM Paciente
 WHERE DNI NOT REGEXP '^[0-9]{8}$' OR Telefono NOT REGEXP '^9[0-9]{8}$'
    OR Nombre REGEXP '[0-9]' OR Apellido REGEXP '[0-9]'
UNION ALL
SELECT 'Usuario', idUsuario, Nombre, Apellido, DNI, Telefono FROM Usuario
 WHERE DNI NOT REGEXP '^[0-9]{8}$' OR Telefono NOT REGEXP '^9[0-9]{8}$'
    OR Nombre REGEXP '[0-9]' OR Apellido REGEXP '[0-9]';

SELECT idServicio, CHAR_LENGTH(Lema) AS lema, CHAR_LENGTH(Descripcion) AS descripcion,
       CHAR_LENGTH(Respuesta) AS respuesta, CHAR_LENGTH(img) AS img, Costo
  FROM Servicio
 WHERE CHAR_LENGTH(Lema) > 200 OR CHAR_LENGTH(Descripcion) > 600
    OR CHAR_LENGTH(Respuesta) > 600 OR CHAR_LENGTH(img) > 500 OR Costo <= 0;

-- tamaños de los textos de servicio
ALTER TABLE Servicio
  MODIFY Lema        VARCHAR(200) NOT NULL,
  MODIFY Descripcion VARCHAR(600) NOT NULL,
  MODIFY Respuesta   VARCHAR(600) NOT NULL,
  MODIFY img         VARCHAR(500) NOT NULL;

-- validaciones
ALTER TABLE Paciente
  ADD CONSTRAINT chk_Paciente_DNI      CHECK (DNI REGEXP '^[0-9]{8}$'),
  ADD CONSTRAINT chk_Paciente_Telefono CHECK (Telefono REGEXP '^9[0-9]{8}$'),
  ADD CONSTRAINT chk_Paciente_Correo   CHECK (Correo LIKE '%_@_%._%'),
  ADD CONSTRAINT chk_Paciente_Nombre   CHECK (Nombre NOT REGEXP '[0-9]' AND Apellido NOT REGEXP '[0-9]');

ALTER TABLE Usuario
  ADD CONSTRAINT chk_Usuario_DNI      CHECK (DNI REGEXP '^[0-9]{8}$'),
  ADD CONSTRAINT chk_Usuario_Telefono CHECK (Telefono REGEXP '^9[0-9]{8}$'),
  ADD CONSTRAINT chk_Usuario_Intentos CHECK (IntentosFallidos BETWEEN 0 AND 10),
  ADD CONSTRAINT chk_Usuario_Nombre   CHECK (Nombre NOT REGEXP '[0-9]' AND Apellido NOT REGEXP '[0-9]');

ALTER TABLE Servicio    ADD CONSTRAINT chk_Servicio_Costo  CHECK (Costo > 0);
ALTER TABLE Pago        ADD CONSTRAINT chk_Pago_Monto      CHECK (Monto > 0);
ALTER TABLE Cita        ADD CONSTRAINT chk_Cita_Importe    CHECK (Importe IS NULL OR Importe >= 0);
ALTER TABLE Comprobante ADD CONSTRAINT chk_Comprobante_DNI CHECK (DNICliente REGEXP '^[0-9]{8}$');

-- usuario de la app
CREATE USER IF NOT EXISTS 'artdent_app'@'localhost' IDENTIFIED BY 'CambiarEstaClave_2026';
GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE ON db_artdent_apf2.* TO 'artdent_app'@'localhost';
FLUSH PRIVILEGES;

-- datos de prueba
DROP PROCEDURE IF EXISTS sp_cargar_demo;
DELIMITER ;;
CREATE PROCEDURE sp_cargar_demo()
BEGIN
  DECLARE vOdo2 INT;
  IF NOT EXISTS (SELECT 1 FROM Cita WHERE Descripcion LIKE '[demo]%') THEN

    INSERT IGNORE INTO Usuario (Nombre, Apellido, DNI, Telefono, CorreoElectronico, Direccion, FechaNacimiento, Clave, Rol_idRol)
    VALUES ('Lucía', 'Herrera Campos', '71458236', '956321478', 'lucia.herrera@artdent.com', 'Av. Arequipa 1450', '1992-05-14', '1234', 3);
    SELECT idUsuario INTO vOdo2 FROM Usuario WHERE DNI = '71458236';
    INSERT IGNORE INTO Usuario_Horario (Usuario_idUsuario, Horario_idHorario)
    SELECT vOdo2, idHorario FROM Horario;
    INSERT IGNORE INTO Usuario_Servicio (idUsuario, idServicio, Disponibilidad)
    SELECT vOdo2, idServicio, 1 FROM Servicio WHERE idServicio IN (1, 4, 5, 7);

    INSERT IGNORE INTO Paciente (Nombre, Apellido, DNI, Telefono, Correo) VALUES
      ('María Fernanda', 'Rojas Quispe',   '45872136', '912345678', 'maria.rojas@gmail.com'),
      ('Luis Alberto',   'Salas Mendoza',  '40123987', '923456789', 'luis.salas@gmail.com'),
      ('Ana Lucía',      'Torres Vega',    '72569841', '934567890', 'ana.torres@gmail.com'),
      ('Pedro Pablo',    'Castillo Ramos', '46985231', '945678901', 'pedro.castillo@gmail.com'),
      ('Rosa Elena',     'Huamán Flores',  '41236587', '956789012', 'rosa.huaman@gmail.com'),
      ('Diego Armando',  'Paredes Luna',   '73654128', '967890123', 'diego.paredes@gmail.com');

    CALL sp_demo_cita('2026-10-12', '09:00:00', '[demo] Limpieza de control',          1, 2, 'Presencial', 4,     '45872136', 2);
    CALL sp_demo_cita('2026-10-14', '10:30:00', '[demo] Dolor al tomar frío',          5, 2, 'Web',        vOdo2, '40123987', 1);
    CALL sp_demo_cita('2026-10-19', '15:00:00', '[demo] Manchas por café',             4, 2, 'Web',        vOdo2, '72569841', 1);
    CALL sp_demo_cita('2026-10-22', '11:00:00', '[demo] Muela del juicio',             3, 2, 'Presencial', 4,     '46985231', 2);
    CALL sp_demo_cita('2026-10-27', '16:30:00', '[demo] Dolor intenso en molar',       7, 2, 'Web',        vOdo2, '41236587', 1);
    CALL sp_demo_cita('2026-10-29', '09:30:00', '[demo] Evaluación de brackets',       2, 5, 'Web',        4,     '73654128', NULL);
    CALL sp_demo_cita('2026-11-04', '10:00:00', '[demo] Control de ortodoncia',        2, 3, 'Web',        4,     '45872136', 1);
    CALL sp_demo_cita('2026-11-05', '12:00:00', '[demo] Sensibilidad dental',          5, 3, 'Presencial', vOdo2, '72569841', 2);
    CALL sp_demo_cita('2026-11-06', '17:00:00', '[demo] Reprogramada por el paciente', 1, 4, 'Web',        vOdo2, '40123987', 1);
    CALL sp_demo_cita('2026-11-10', '08:30:00', '[demo] Pieza perdida',                6, 1, 'Web',        4,     '46985231', NULL);
    CALL sp_demo_cita('2026-11-11', '14:00:00', '[demo] Primera consulta',             1, 1, 'Web',        vOdo2, '41236587', NULL);
    CALL sp_demo_cita('2026-11-12', '11:30:00', '[demo] Datos no confirmados',         4, 6, 'Web',        vOdo2, '73654128', NULL);
  END IF;
END;;

DROP PROCEDURE IF EXISTS sp_demo_cita;;
CREATE PROCEDURE sp_demo_cita(IN pFecha DATE, IN pHora TIME, IN pDesc VARCHAR(100), IN pServ INT,
                              IN pEstado INT, IN pOrigen VARCHAR(15), IN pOdo INT, IN pDni CHAR(8), IN pMetodo INT)
BEGIN
  DECLARE vPac INT; DECLARE vCita INT; DECLARE vPago INT; DECLARE vCosto DECIMAL(10,2);
  DECLARE vNom VARCHAR(100); DECLARE vNum INT;
  SELECT idPaciente, CONCAT(Nombre, ' ', Apellido) INTO vPac, vNom FROM Paciente WHERE DNI = pDni;
  SELECT Costo INTO vCosto FROM Servicio WHERE idServicio = pServ;
  INSERT INTO Cita (FechaCita, HoraCita, Descripcion, Importe, Origen, Usuario_idUsuario,
                    Paciente_idPaciente, Servicio_idServicio, Estado_idEstado, Odontologo_idUsuario)
  VALUES (pFecha, pHora, pDesc, vCosto, pOrigen, 2, vPac, pServ, pEstado, pOdo);
  SET vCita = LAST_INSERT_ID();
  IF pMetodo IS NOT NULL THEN
    INSERT INTO Pago (Monto, FechaPago, CodigoTransaccion, MetodoPago_idMetodo, Cita_idCita)
    VALUES (vCosto, TIMESTAMP(DATE_SUB(pFecha, INTERVAL 2 DAY), '10:00:00'),
            CONCAT(IF(pMetodo = 1, 'TXN-', 'EFEC-'), DATE_FORMAT(pFecha, '%Y%m%d'), '-', LPAD(vCita, 4, '0')),
            pMetodo, vCita);
    SET vPago = LAST_INSERT_ID();
    SELECT COALESCE(MAX(CAST(Numero AS UNSIGNED)), 0) + 1 INTO vNum FROM Comprobante WHERE Serie = 'B001';
    INSERT INTO Comprobante (Serie, Numero, FechaEmision, NombreCliente, DNICliente, Pago_idPago)
    VALUES ('B001', LPAD(vNum, 8, '0'), TIMESTAMP(DATE_SUB(pFecha, INTERVAL 2 DAY), '10:00:00'), vNom, pDni, vPago);
  END IF;
  IF pEstado IN (2, 3, 4, 5, 6) THEN
    INSERT INTO Notificacion (Asunto, FechaEnvio, Enviado, Estado_idEstado, Cita_idCita)
    VALUES (CASE pEstado WHEN 2 THEN 'Gracias por su visita'
                         WHEN 3 THEN 'Su reserva fue confirmada'
                         WHEN 4 THEN 'Su cita fue reprogramada'
                         WHEN 5 THEN 'Su cita fue cancelada'
                         ELSE 'Su reserva fue rechazada' END,
            TIMESTAMP(DATE_SUB(pFecha, INTERVAL 1 DAY), '09:00:00'), 1, pEstado, vCita);
  END IF;
END;;
DELIMITER ;

CALL sp_cargar_demo();
DROP PROCEDURE IF EXISTS sp_cargar_demo;
DROP PROCEDURE IF EXISTS sp_demo_cita;

SELECT e.TipoEstado, COUNT(*) AS citas FROM Cita c JOIN Estado e ON e.idEstado = c.Estado_idEstado GROUP BY e.TipoEstado;
SELECT CONSTRAINT_NAME, TABLE_NAME FROM information_schema.TABLE_CONSTRAINTS
 WHERE TABLE_SCHEMA = 'db_artdent_apf2' AND CONSTRAINT_TYPE = 'CHECK' ORDER BY TABLE_NAME;
