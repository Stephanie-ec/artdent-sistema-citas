-- =====================================================================
-- Base de datos: db_artdent_apf2 (Modelo Físico APF2 - 13 Tablas)
-- Adaptada con 36 Stored Procedures y Vistas de Compatibilidad para Java EE
-- MySQL 8.0 / InnoDB / utf8mb4
-- =====================================================================

DROP DATABASE IF EXISTS db_artdent_apf2;
CREATE DATABASE db_artdent_apf2 CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE db_artdent_apf2;

-- ---------------------------------------------------------------------
-- 1. Tablas catálogo
-- ---------------------------------------------------------------------
CREATE TABLE Rol (
  idRol      INT NOT NULL AUTO_INCREMENT,
  TipoRol    VARCHAR(20) NOT NULL,
  PRIMARY KEY (idRol)
) ENGINE=InnoDB;

CREATE TABLE Estado (
  idEstado   INT NOT NULL AUTO_INCREMENT,
  TipoEstado VARCHAR(50) NOT NULL,
  PRIMARY KEY (idEstado)
) ENGINE=InnoDB;

CREATE TABLE MetodoPago (
  idMetodo     INT NOT NULL AUTO_INCREMENT,
  NombreMetodo VARCHAR(20) NOT NULL,
  PRIMARY KEY (idMetodo)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 2. Horarios, servicios y personal
-- ---------------------------------------------------------------------
CREATE TABLE Horario (
  idHorario  INT NOT NULL AUTO_INCREMENT,
  HoraInicio TIME NOT NULL,
  HoraFinal  TIME NOT NULL,
  DiaSemana  VARCHAR(15) NOT NULL,
  PRIMARY KEY (idHorario),
  CONSTRAINT chk_Horario_Horas CHECK (HoraFinal > HoraInicio)
) ENGINE=InnoDB;

CREATE TABLE Servicio (
  idServicio   INT NOT NULL AUTO_INCREMENT,
  TipoServicio VARCHAR(100) NOT NULL,
  Lema         TEXT NOT NULL,
  Descripcion  TEXT NOT NULL,
  Respuesta    TEXT NOT NULL,
  Costo        DECIMAL(10,2) NOT NULL,
  img          TEXT NOT NULL,
  Activo       TINYINT(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (idServicio)
) ENGINE=InnoDB;

CREATE TABLE Usuario (
  idUsuario         INT NOT NULL AUTO_INCREMENT,
  Nombre            VARCHAR(50) NOT NULL,
  Apellido          VARCHAR(50) NOT NULL,
  DNI               CHAR(8) NOT NULL,
  Telefono          CHAR(9) NOT NULL,
  CorreoElectronico VARCHAR(100) NOT NULL,
  Direccion         VARCHAR(100) NOT NULL,
  FechaNacimiento   DATE NOT NULL,
  Clave             VARCHAR(255) NOT NULL,          -- Soporta SHA-256 (64), BCrypt (60) y texto plano
  IntentosFallidos  TINYINT NOT NULL DEFAULT 0,
  BloqueadoHasta    DATETIME NULL,
  Rol_idRol         INT NOT NULL,
  PRIMARY KEY (idUsuario),
  UNIQUE KEY DNI_UNIQUE (DNI),
  KEY fk_Usuario_Rol_idx (Rol_idRol),
  CONSTRAINT fk_Usuario_Rol FOREIGN KEY (Rol_idRol) REFERENCES Rol (idRol)
) ENGINE=InnoDB;

CREATE TABLE Usuario_Servicio (
  idUsuario      INT NOT NULL,
  idServicio     INT NOT NULL,
  Disponibilidad TINYINT(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (idUsuario, idServicio),
  KEY fk_US_Servicio_idx (idServicio),
  CONSTRAINT fk_US_Usuario  FOREIGN KEY (idUsuario)  REFERENCES Usuario (idUsuario),
  CONSTRAINT fk_US_Servicio FOREIGN KEY (idServicio) REFERENCES Servicio (idServicio)
) ENGINE=InnoDB;

CREATE TABLE Usuario_Horario (
  idUsuario_Horario INT NOT NULL AUTO_INCREMENT,
  Usuario_idUsuario INT NOT NULL,
  Horario_idHorario INT NOT NULL,
  PRIMARY KEY (idUsuario_Horario),
  UNIQUE KEY Usuario_Horario_UNIQUE (Usuario_idUsuario, Horario_idHorario),
  KEY fk_UH_Horario_idx (Horario_idHorario),
  CONSTRAINT fk_UH_Usuario FOREIGN KEY (Usuario_idUsuario) REFERENCES Usuario (idUsuario),
  CONSTRAINT fk_UH_Horario FOREIGN KEY (Horario_idHorario) REFERENCES Horario (idHorario)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 3. Pacientes y citas (Citas presenciales y reservas web en una sola tabla)
-- ---------------------------------------------------------------------
CREATE TABLE Paciente (
  idPaciente INT NOT NULL AUTO_INCREMENT,
  Nombre     VARCHAR(50) NOT NULL,
  Apellido   VARCHAR(50) NOT NULL,
  DNI        CHAR(8) NOT NULL,
  Telefono   CHAR(9) NOT NULL,
  Correo     VARCHAR(100) NOT NULL,
  PRIMARY KEY (idPaciente),
  UNIQUE KEY DNI_UNIQUE (DNI)
) ENGINE=InnoDB;

CREATE TABLE Cita (
  idCita               INT NOT NULL AUTO_INCREMENT,
  FechaCita            DATE NOT NULL,
  HoraCita             TIME NOT NULL,
  Descripcion          TEXT NULL,
  Importe              DECIMAL(10,2) NULL,           -- Garantiza vista mono-tabla actualizable para reserva
  FechaRegistro        DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  Origen               VARCHAR(15) NOT NULL DEFAULT 'Web',
  Usuario_idUsuario    INT NULL,                     -- Secretaria/personal que gestiona o cliente
  Paciente_idPaciente  INT NOT NULL,
  Servicio_idServicio  INT NOT NULL,
  Estado_idEstado      INT NOT NULL,
  Odontologo_idUsuario INT NOT NULL,
  PRIMARY KEY (idCita),
  KEY fk_Cita_Usuario_idx (Usuario_idUsuario),
  KEY fk_Cita_Paciente_idx (Paciente_idPaciente),
  KEY fk_Cita_Servicio_idx (Servicio_idServicio),
  KEY fk_Cita_Estado_idx (Estado_idEstado),
  KEY fk_Cita_Odontologo_idx (Odontologo_idUsuario),
  CONSTRAINT chk_Cita_Origen CHECK (Origen IN ('Web','Presencial')),
  CONSTRAINT fk_Cita_Usuario    FOREIGN KEY (Usuario_idUsuario)    REFERENCES Usuario (idUsuario),
  CONSTRAINT fk_Cita_Paciente   FOREIGN KEY (Paciente_idPaciente)  REFERENCES Paciente (idPaciente),
  CONSTRAINT fk_Cita_Servicio   FOREIGN KEY (Servicio_idServicio)  REFERENCES Servicio (idServicio),
  CONSTRAINT fk_Cita_Estado     FOREIGN KEY (Estado_idEstado)      REFERENCES Estado (idEstado),
  CONSTRAINT fk_Cita_Odontologo FOREIGN KEY (Odontologo_idUsuario) REFERENCES Usuario (idUsuario)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 4. Pagos, comprobantes y notificaciones
-- ---------------------------------------------------------------------
CREATE TABLE Pago (
  idPago              INT NOT NULL AUTO_INCREMENT,
  Monto               DECIMAL(10,2) NOT NULL,
  FechaPago           DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CodigoTransaccion   VARCHAR(50) NULL,
  MetodoPago_idMetodo INT NOT NULL,
  Cita_idCita         INT NOT NULL,
  PRIMARY KEY (idPago),
  UNIQUE KEY Cita_UNIQUE (Cita_idCita),
  KEY fk_Pago_Metodo_idx (MetodoPago_idMetodo),
  CONSTRAINT fk_Pago_Metodo FOREIGN KEY (MetodoPago_idMetodo) REFERENCES MetodoPago (idMetodo),
  CONSTRAINT fk_Pago_Cita   FOREIGN KEY (Cita_idCita)         REFERENCES Cita (idCita)
) ENGINE=InnoDB;

CREATE TABLE Comprobante (
  idComprobante INT NOT NULL AUTO_INCREMENT,
  Serie         CHAR(4) NOT NULL,
  Numero        CHAR(8) NOT NULL,
  FechaEmision  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  NombreCliente VARCHAR(100) NOT NULL,
  DNICliente    CHAR(8) NOT NULL,
  Pago_idPago   INT NOT NULL,
  PRIMARY KEY (idComprobante),
  UNIQUE KEY Serie_Numero_UNIQUE (Serie, Numero),
  UNIQUE KEY Pago_UNIQUE (Pago_idPago),
  CONSTRAINT fk_Comprobante_Pago FOREIGN KEY (Pago_idPago) REFERENCES Pago (idPago)
) ENGINE=InnoDB;

CREATE TABLE Notificacion (
  idNotificacion  INT NOT NULL AUTO_INCREMENT,
  Asunto          VARCHAR(100) NOT NULL,
  FechaEnvio      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  Enviado         TINYINT(1) NOT NULL DEFAULT 0,
  Estado_idEstado INT NOT NULL,
  Cita_idCita     INT NOT NULL,
  PRIMARY KEY (idNotificacion),
  KEY fk_Notif_Estado_idx (Estado_idEstado),
  KEY fk_Notif_Cita_idx (Cita_idCita),
  CONSTRAINT fk_Notif_Estado FOREIGN KEY (Estado_idEstado) REFERENCES Estado (idEstado),
  CONSTRAINT fk_Notif_Cita   FOREIGN KEY (Cita_idCita)     REFERENCES Cita (idCita)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 5. Vistas de compatibilidad Mono-Tabla (Updatable / Deletable)
-- ---------------------------------------------------------------------
CREATE OR REPLACE VIEW reserva AS
SELECT 
  idCita AS idReserva,
  FechaCita AS DiaReserva,
  HoraCita AS HoraReserva,
  Descripcion,
  Importe,
  FechaRegistro AS FechaHoraPago,
  Usuario_idUsuario,
  Paciente_idPaciente,
  Estado_idEstado,
  Servicio_idServicio,
  Odontologo_idUsuario
FROM Cita
WHERE Origen = 'Web';

CREATE OR REPLACE VIEW venta AS
SELECT 
  idPago AS idVenta,
  Monto AS Importe,
  FechaPago AS FechaHoraPago,
  Cita_idCita
FROM Pago;

-- =====================================================================
-- 6. Datos Semilla Iniciales
-- =====================================================================
INSERT INTO Rol (idRol, TipoRol) VALUES 
  (1, 'Administrador'), 
  (2, 'Secretaria'), 
  (3, 'Odontologo');

-- IMPORTANTE: Estados preservando el orden original exacto de IDs para Java
INSERT INTO Estado (idEstado, TipoEstado) VALUES
  (1, 'En espera'),
  (2, 'Completado'),
  (3, 'Confirmado'),
  (4, 'Reprogramado'),
  (5, 'Cancelado'),
  (6, 'Rechazado');

INSERT INTO MetodoPago (idMetodo, NombreMetodo) VALUES 
  (1, 'En línea'), 
  (2, 'Efectivo');

INSERT INTO Horario (idHorario, HoraInicio, HoraFinal, DiaSemana) VALUES
  (1, '08:00:00', '18:30:00', 'Lunes'),
  (2, '08:00:00', '18:30:00', 'Martes'),
  (3, '08:00:00', '18:30:00', 'Miércoles'),
  (4, '08:00:00', '18:30:00', 'Jueves'),
  (5, '08:00:00', '18:30:00', 'Viernes');

INSERT INTO Servicio (idServicio, TipoServicio, Lema, Descripcion, Respuesta, Costo, img, Activo) VALUES 
  (1,'Limpieza Dental','Elimina el sarro y previene caries y enfermedades de las encías.','Profilaxis dental profesional para prevenir caries, gingivitis y sarro acumulado.','Recomendada cada seis meses o ante presencia de sarro y sangrado de encías.',40.00,'https://img.freepik.com/foto-gratis/proceso-limpieza-dental-profesional-primer-plano_23-2149174154.jpg',1),
  (2,'Ortodoncia','Corrige la posición de los dientes y la mandíbula.','Tratamiento para alinear dientes y corregir la mordida mejorando estética y masticación.','Indicado ante dientes apiñados, mordida cruzada o espacios entre dientes.',50.00,'https://img.freepik.com/foto-gratis/sonrisa-frenillos-primer-plano-brackets-dentales-dientes-mujer-joven_23-2149174125.jpg',1),
  (3,'Cirugía Oral','Tratamiento quirúrgico de dientes, encías y maxilares.','Extracción de terceras molares impactadas y resolución de afecciones orales complejas.','Recomendada ante muelas del juicio dolorosas o lesiones que requieran intervención.',250.00,'https://img.freepik.com/foto-gratis/primer-plano-dentista-trabajando-dientes-paciente_23-2149174151.jpg',1),
  (4,'Blanqueamiento Dental','Aclara el tono de tus dientes para una sonrisa radiante.','Procedimiento cosmético seguro que remueve manchas y aclara el esmalte dental.','Indicado para personas con manchas por café, té o tabaco que buscan estética dental.',100.00,'https://img.freepik.com/foto-gratis/procedimiento-blanqueamiento-dental-lampara-uv_23-2149174148.jpg',1),
  (5,'Tratamiento de caries','Protege tu sonrisa tratando las caries a tiempo.','Eliminación del tejido cariado y reconstrucción estética con resinas compuestas de alta resistencia.','Indicado ante dolor al frío/calor, sensibilidad o manchas oscuras visibles.',80.00,'https://img.freepik.com/foto-gratis/dentista-examinando-dientes-femeninos-espejo-bucal_23-2149174142.jpg',1),
  (6,'Prótesis dentales','Recupera la funcionalidad y estética de tus piezas dentales.','Dispositivos fijos y removibles a medida para sustituir dientes perdidos.','Indicado ante la pérdida de una o más piezas dentales para recuperar la masticación.',200.00,'https://img.freepik.com/foto-gratis/modelo-mandibula-humana-protesis-dental_23-2149174138.jpg',1),
  (7,'Endodoncia','Salva tu pieza dental tratando la pulpa infectada.','Tratamiento de conducto radicular para desinfectar y sellar conductos ante pulpitis.','Indicado ante dolor dental agudo, inflamación o traumatismos profundos.',100.00,'https://img.freepik.com/foto-gratis/dentista-revisando-conducto-radicular-paciente_23-2149174135.jpg',1);

-- Usuarios con claves (compatibles con SHA-256 de SecurityUtils y fallback en texto plano)
INSERT INTO Usuario (idUsuario, Nombre, Apellido, DNI, Telefono, CorreoElectronico, Direccion, FechaNacimiento, Clave, Rol_idRol) VALUES 
  (1, 'Juan David', 'Fernández Gomez', '48223344', '987101222', 'ana.fernandez@artdent.com', 'Calle Lima 123', '2000-09-30', '123', 1),
  (2, 'Ethelvina Georgina', 'Soto Vergara', '78223344', '987115982', 'ethelvina.soto@artdent.com', 'Calle Pacasmayo 486', '2004-09-30', '1234', 2),
  (4, 'Ruben', 'Cuadros', '70096374', '999999999', 'ruben.cuadros@artdent.com', 'Av. Lima Sur 250', '2000-12-01', '1234', 3),
  (5, 'Andrea', 'IPv5', '75121424', '912384007', 'ipv5@gmail.com', 'Cono este', '2004-02-19', '1234', 1);

-- Horarios asignados al odontólogo (idUsuario = 4) de Lunes a Viernes
INSERT INTO Usuario_Horario (Usuario_idUsuario, Horario_idHorario) VALUES 
  (4, 1), (4, 2), (4, 3), (4, 4), (4, 5);

-- Servicios asignados al odontólogo (idUsuario = 4)
INSERT INTO Usuario_Servicio (idUsuario, idServicio, Disponibilidad) VALUES 
  (4, 1, 1), (4, 2, 1), (4, 3, 1), (4, 4, 1), (4, 5, 1), (4, 6, 1), (4, 7, 1);

-- Pacientes iniciales
INSERT INTO Paciente (idPaciente, Nombre, Apellido, DNI, Telefono, Correo) VALUES 
  (1, 'Carlos Gilberto', 'Pérez Gómez', '48915516', '987655321', 'carlos.perez@gmail.com'),
  (2, 'Jessica', 'Parra Bautista', '23634231', '975337264', 'jessica.parra@gmail.com'),
  (3, 'José Alberto', 'Quiñones Miroquesada', '74815956', '987456159', 'jose.quinones@gmail.com');

-- Citas iniciales (Presenciales y Web unificadas)
-- Cita 1: Presencial completada
INSERT INTO Cita (idCita, FechaCita, HoraCita, Descripcion, Importe, Origen, Usuario_idUsuario, Paciente_idPaciente, Servicio_idServicio, Estado_idEstado, Odontologo_idUsuario) VALUES
  (1, '2026-10-06', '09:00:00', 'Atención en consultorio', 40.00, 'Presencial', 2, 3, 1, 2, 4);

-- Cita 2: Web confirmada (con pago en línea)
INSERT INTO Cita (idCita, FechaCita, HoraCita, Descripcion, Importe, Origen, Usuario_idUsuario, Paciente_idPaciente, Servicio_idServicio, Estado_idEstado, Odontologo_idUsuario) VALUES
  (2, '2026-10-21', '11:30:00', 'Dolor al masticar', 50.00, 'Web', 1, 2, 2, 3, 4);

-- Cita 3: Web en espera
INSERT INTO Cita (idCita, FechaCita, HoraCita, Descripcion, Importe, Origen, Usuario_idUsuario, Paciente_idPaciente, Servicio_idServicio, Estado_idEstado, Odontologo_idUsuario) VALUES
  (3, '2026-10-20', '10:00:00', 'Primera consulta web', 40.00, 'Web', 1, 1, 1, 1, 4);

-- Pagos iniciales
INSERT INTO Pago (idPago, Monto, CodigoTransaccion, MetodoPago_idMetodo, Cita_idCita) VALUES
  (1, 40.00, 'EFEC-20261006001', 2, 1),
  (2, 50.00, 'TXN-20261021-0002', 1, 2);

-- Comprobantes iniciales
INSERT INTO Comprobante (idComprobante, Serie, Numero, NombreCliente, DNICliente, Pago_idPago) VALUES
  (1, 'B001', '00000001', 'José Alberto Quiñones Miroquesada', '74815956', 1),
  (2, 'B001', '00000002', 'Jessica Parra Bautista', '23634231', 2);

-- Notificaciones iniciales
INSERT INTO Notificacion (idNotificacion, Asunto, Enviado, Estado_idEstado, Cita_idCita) VALUES
  (1, 'Su cita fue registrada exitosamente', 1, 2, 1),
  (2, 'Su reserva web fue confirmada', 1, 3, 2);


-- =====================================================================
-- 7. Los 36 Stored Procedures Adaptados
-- =====================================================================

DELIMITER ;;

-- 1. sp_iniciosesion
DROP PROCEDURE IF EXISTS `sp_iniciosesion`;;
CREATE PROCEDURE `sp_iniciosesion`(IN i_DNI VARCHAR(100), IN i_clave VARCHAR(255))
BEGIN
  SELECT u.idUsuario, u.Nombre, u.Apellido, u.DNI, r.TipoRol 
  FROM Usuario u 
  INNER JOIN Rol r ON u.Rol_idRol = r.idRol 
  WHERE u.DNI = i_DNI AND u.Clave = i_clave;
END;;

-- 2. sp_insertarUsuario
DROP PROCEDURE IF EXISTS `sp_insertarUsuario`;;
CREATE PROCEDURE `sp_insertarUsuario`(
  IN pNombre VARCHAR(50),
  IN pApellido VARCHAR(50),
  IN pDNI CHAR(8),
  IN pTelefono CHAR(9),
  IN pCorreo VARCHAR(100),
  IN pDireccion VARCHAR(100),
  IN pFechaNacimiento DATE,
  IN pClave VARCHAR(255),
  IN pRol INT
)
BEGIN
  INSERT INTO Usuario (Nombre, Apellido, DNI, Telefono, CorreoElectronico, Direccion, FechaNacimiento, Clave, Rol_idRol, IntentosFallidos)
  VALUES (pNombre, pApellido, pDNI, pTelefono, pCorreo, pDireccion, pFechaNacimiento, pClave, pRol, 0);
END;;

-- 3. sp_actualizarUsuario
DROP PROCEDURE IF EXISTS `sp_actualizarUsuario`;;
CREATE PROCEDURE `sp_actualizarUsuario`(
  IN pIdUsuario INT,
  IN pNombre VARCHAR(50),
  IN pApellido VARCHAR(50),
  IN pDNI VARCHAR(8),
  IN pTelefono VARCHAR(9),
  IN pCorreoElectronico VARCHAR(100),
  IN pDireccion VARCHAR(100),
  IN pFechaNacimiento DATE,
  IN pClave VARCHAR(255),
  IN pRol INT
)
BEGIN
  UPDATE Usuario
  SET Nombre = pNombre,
      Apellido = pApellido,
      DNI = pDNI,
      Telefono = pTelefono,
      CorreoElectronico = pCorreoElectronico,
      Direccion = pDireccion,
      FechaNacimiento = pFechaNacimiento,
      Clave = pClave,
      Rol_idRol = pRol
  WHERE idUsuario = pIdUsuario;
END;;

-- 4. sp_eliminarUsuario (Borrado en Cascada Jerárquico Seguro para APF2)
DROP PROCEDURE IF EXISTS `sp_eliminarUsuario`;;
CREATE PROCEDURE `sp_eliminarUsuario`(IN pIdUsuario INT)
BEGIN
  -- 1. Eliminar comprobantes vinculados a citas del odontólogo
  DELETE FROM Comprobante 
  WHERE Pago_idPago IN (
    SELECT p.idPago FROM Pago p 
    INNER JOIN Cita c ON p.Cita_idCita = c.idCita 
    WHERE c.Odontologo_idUsuario = pIdUsuario
  );

  -- 2. Eliminar pagos de las citas del odontólogo
  DELETE FROM Pago 
  WHERE Cita_idCita IN (SELECT idCita FROM Cita WHERE Odontologo_idUsuario = pIdUsuario);

  -- 3. Eliminar notificaciones de las citas
  DELETE FROM Notificacion 
  WHERE Cita_idCita IN (SELECT idCita FROM Cita WHERE Odontologo_idUsuario = pIdUsuario);

  -- 4. Eliminar las citas/reservas del odontólogo
  DELETE FROM Cita WHERE Odontologo_idUsuario = pIdUsuario;

  -- 5. Eliminar horarios y servicios asignados al usuario
  DELETE FROM Usuario_Horario WHERE Usuario_idUsuario = pIdUsuario;
  DELETE FROM Usuario_Servicio WHERE idUsuario = pIdUsuario;

  -- 6. Finalmente eliminar el usuario
  DELETE FROM Usuario WHERE idUsuario = pIdUsuario;
END;;

-- 5. sp_listarUsuarios
DROP PROCEDURE IF EXISTS `sp_listarUsuarios`;;
CREATE PROCEDURE `sp_listarUsuarios`()
BEGIN
  SELECT u.*, r.TipoRol AS RolN
  FROM Usuario u 
  INNER JOIN Rol r ON u.Rol_idRol = r.idRol;
END;;

-- 6. sp_obtenerUsuarioPorId
DROP PROCEDURE IF EXISTS `sp_obtenerUsuarioPorId`;;
CREATE PROCEDURE `sp_obtenerUsuarioPorId`(IN pIp INT)
BEGIN
  SELECT u.*, r.TipoRol AS RolN
  FROM Usuario u 
  INNER JOIN Rol r ON u.Rol_idRol = r.idRol 
  WHERE u.idUsuario = pIp;
END;;

-- 7. sp_listarservicios
DROP PROCEDURE IF EXISTS `sp_listarservicios`;;
CREATE PROCEDURE `sp_listarservicios`()
BEGIN
  SELECT * FROM Servicio WHERE Activo = 1;
END;;

-- 8. sp_obtenerServicioPorId
DROP PROCEDURE IF EXISTS `sp_obtenerServicioPorId`;;
CREATE PROCEDURE `sp_obtenerServicioPorId`(IN p_idServicio INT)
BEGIN
  SELECT * FROM Servicio WHERE idServicio = p_idServicio;
END;;

-- 9. sp_insertarServicio
DROP PROCEDURE IF EXISTS `sp_insertarServicio`;;
CREATE PROCEDURE `sp_insertarServicio`(
  IN p_TipoServicio TEXT, 
  IN p_Lema TEXT, 
  IN p_Descripcion TEXT, 
  IN p_Respuesta TEXT, 
  IN p_Costo DECIMAL(10,2), 
  IN p_img TEXT
)
BEGIN
  INSERT INTO Servicio (TipoServicio, Lema, Descripcion, Respuesta, Costo, img, Activo)
  VALUES (p_TipoServicio, p_Lema, p_Descripcion, p_Respuesta, p_Costo, p_img, 1);
END;;

-- 10. sp_actualizarServicio
DROP PROCEDURE IF EXISTS `sp_actualizarServicio`;;
CREATE PROCEDURE `sp_actualizarServicio`(
  IN p_idServicio INT,
  IN p_TipoServicio VARCHAR(100),
  IN p_Lema TEXT,
  IN p_Descripcion TEXT,
  IN p_Respuesta TEXT,
  IN p_Costo DECIMAL(10,2),
  IN p_img TEXT
)
BEGIN
  UPDATE Servicio
  SET TipoServicio = p_TipoServicio,
      Lema = p_Lema,
      Descripcion = p_Descripcion,
      Respuesta = p_Respuesta,
      Costo = p_Costo,
      img = p_img
  WHERE idServicio = p_idServicio;
END;;

-- 11. sp_eliminarServicio (Borrado Lógico)
DROP PROCEDURE IF EXISTS `sp_eliminarServicio`;;
CREATE PROCEDURE `sp_eliminarServicio`(IN p_idServicio INT)
BEGIN
  UPDATE Servicio SET Activo = 0 WHERE idServicio = p_idServicio;
END;;

-- 12. sp_registrarusuario (Inserta Paciente)
DROP PROCEDURE IF EXISTS `sp_registrarusuario`;;
CREATE PROCEDURE `sp_registrarusuario`(
  IN p_Nombre VARCHAR(50),
  IN p_Apellido VARCHAR(50),
  IN p_DNI VARCHAR(8),
  IN p_Telefono VARCHAR(9),
  IN p_Correo VARCHAR(100)
)
BEGIN
  INSERT INTO Paciente (Nombre, Apellido, DNI, Telefono, Correo)
  VALUES (p_Nombre, p_Apellido, p_DNI, p_Telefono, p_Correo);
END;;

-- 13. sp_registrarcita
DROP PROCEDURE IF EXISTS `sp_registrarcita`;;
CREATE PROCEDURE `sp_registrarcita`(
  IN p_dia_reserva DATE,
  IN p_hora_reserva TIME,
  IN p_id_servicio INT,
  IN p_id_paciente CHAR(8),
  IN p_id_estado INT,
  IN p_idOdontologo_idUsuario INT
)
BEGIN
  INSERT INTO Cita (FechaCita, HoraCita, Servicio_idServicio, Paciente_idPaciente, Estado_idEstado, Odontologo_idUsuario, Origen) 
  VALUES (p_dia_reserva, p_hora_reserva, p_id_servicio, p_id_paciente, p_id_estado, p_idOdontologo_idUsuario, 'Presencial');
END;;

-- 14. sp_registrarprimeracita
DROP PROCEDURE IF EXISTS `sp_registrarprimeracita`;;
CREATE PROCEDURE `sp_registrarprimeracita`(
  IN p_diareserva DATE, 
  IN p_horareserva TIME, 
  IN p_idservicio INT, 
  IN p_idestado INT, 
  IN p_Odontologo_idUsuario INT
)
BEGIN
  DECLARE lastPacienteId INT;
  SELECT idPaciente INTO lastPacienteId FROM Paciente ORDER BY idPaciente DESC LIMIT 1;

  INSERT INTO Cita (FechaCita, HoraCita, Servicio_idServicio, Paciente_idPaciente, Estado_idEstado, Odontologo_idUsuario, Origen)
  VALUES (p_diareserva, p_horareserva, p_idservicio, lastPacienteId, p_idestado, p_Odontologo_idUsuario, 'Presencial');
END;;

-- 15. ps_ReprogramarCita
DROP PROCEDURE IF EXISTS `ps_ReprogramarCita`;;
CREATE PROCEDURE `ps_ReprogramarCita`(
  IN p_idCita INT,
  IN p_nuevaFecha DATE,
  IN p_nuevaHora TIME
)
BEGIN
  UPDATE Cita
  SET FechaCita = p_nuevaFecha, 
      HoraCita = p_nuevaHora,
      Estado_idEstado = 4
  WHERE idCita = p_idCita;
END;;

-- 16. sp_ventas (Inserta en Pago con método Efectivo = 2)
DROP PROCEDURE IF EXISTS `sp_ventas`;;
CREATE PROCEDURE `sp_ventas`(IN p_importe DECIMAL(10,2))
BEGIN
  DECLARE id_Cita INT;
  SELECT idCita INTO id_Cita FROM Cita ORDER BY idCita DESC LIMIT 1;
  INSERT INTO Pago (Monto, CodigoTransaccion, MetodoPago_idMetodo, Cita_idCita) 
  VALUES (p_importe, CONCAT('EFEC-', DATE_FORMAT(NOW(), '%Y%m%d%H%i%s')), 2, id_Cita);
END;;

-- 17. sp_DetalleCita
DROP PROCEDURE IF EXISTS `sp_DetalleCita`;;
CREATE PROCEDURE `sp_DetalleCita`(IN p_idCita INT)
BEGIN
  SELECT 
    c.idCita, 
    c.FechaCita AS DiaReserva, 
    c.HoraCita AS HoraReserva, 
    s.TipoServicio, 
    s.Costo, 
    p.Nombre AS NombrePaciente, 
    p.Apellido AS ApellidoPaciente, 
    e.TipoEstado AS Estado, 
    od.Nombre AS NombreOdontologo, 
    od.Apellido AS ApellidoOdontologo
  FROM Cita c
  INNER JOIN Servicio s ON c.Servicio_idServicio = s.idServicio
  INNER JOIN Paciente p ON c.Paciente_idPaciente = p.idPaciente
  INNER JOIN Estado e ON c.Estado_idEstado = e.idEstado
  INNER JOIN Usuario od ON c.Odontologo_idUsuario = od.idUsuario
  WHERE c.idCita = p_idCita;
END;;

-- 18. sp_ListarCitasPorUsuario
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
    WHERE c.Origen = 'Presencial' AND c.Estado_idEstado IN (1, 3);
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
    WHERE c.Odontologo_idUsuario = p_idUsuario AND c.Origen = 'Presencial' AND c.Estado_idEstado IN (1, 3);
  END IF;
END;;

-- 19. sp_ListarHisotialCitas
DROP PROCEDURE IF EXISTS `sp_ListarHisotialCitas`;;
CREATE PROCEDURE `sp_ListarHisotialCitas`(IN p_idUsuario INT)
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
    WHERE c.Origen = 'Presencial' AND c.Estado_idEstado NOT IN (1, 3);
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
    WHERE c.Odontologo_idUsuario = p_idUsuario AND c.Origen = 'Presencial' AND c.Estado_idEstado NOT IN (1, 3);
  END IF;
END;;

-- 20. sp_ListarTodasCitas
DROP PROCEDURE IF EXISTS `sp_ListarTodasCitas`;;
CREATE PROCEDURE `sp_ListarTodasCitas`(IN p_idUsuario INT)
BEGIN
  SELECT
    c.idCita,
    c.FechaCita AS DiaReserva,
    c.HoraCita AS HoraReserva,
    s.TipoServicio,
    p.Nombre AS NombrePaciente,
    p.Apellido AS ApellidoPaciente,
    e.TipoEstado AS Estado,
    od.Nombre AS NombreOdontologo,
    od.Apellido AS ApellidoOdontologo
  FROM Cita c
  INNER JOIN Servicio s ON c.Servicio_idServicio = s.idServicio
  INNER JOIN Paciente p ON c.Paciente_idPaciente = p.idPaciente
  INNER JOIN Estado e ON c.Estado_idEstado = e.idEstado
  INNER JOIN Usuario od ON c.Odontologo_idUsuario = od.idUsuario
  WHERE c.Odontologo_idUsuario = p_idUsuario AND c.Origen = 'Presencial';
END;;

-- 21. sp_ListarTodasCitasAd
DROP PROCEDURE IF EXISTS `sp_ListarTodasCitasAd`;;
CREATE PROCEDURE `sp_ListarTodasCitasAd`()
BEGIN
  SELECT
    c.idCita,
    c.FechaCita AS DiaReserva,
    c.HoraCita AS HoraReserva,
    s.TipoServicio,
    p.Nombre AS NombrePaciente,
    p.Apellido AS ApellidoPaciente,
    e.TipoEstado AS Estado,
    od.Nombre AS NombreOdontologo,
    od.Apellido AS ApellidoOdontologo
  FROM Cita c
  INNER JOIN Servicio s ON c.Servicio_idServicio = s.idServicio
  INNER JOIN Paciente p ON c.Paciente_idPaciente = p.idPaciente
  INNER JOIN Estado e ON c.Estado_idEstado = e.idEstado
  INNER JOIN Usuario od ON c.Odontologo_idUsuario = od.idUsuario
  WHERE c.Origen = 'Presencial';
END;;

-- 22. sp_listarCitasRecientes
DROP PROCEDURE IF EXISTS `sp_listarCitasRecientes`;;
CREATE PROCEDURE `sp_listarCitasRecientes`()
BEGIN
  SELECT
    c.idCita,
    c.FechaCita AS DiaReserva,
    c.HoraCita AS HoraReserva,
    CONCAT(p.Nombre, ' ', p.Apellido) AS NombrePaciente,
    s.TipoServicio AS NombreServicio,
    e.TipoEstado AS EstadoNombre
  FROM Cita c
  INNER JOIN Paciente p ON c.Paciente_idPaciente = p.idPaciente
  INNER JOIN Servicio s ON c.Servicio_idServicio = s.idServicio
  INNER JOIN Estado e ON c.Estado_idEstado = e.idEstado
  WHERE c.Origen = 'Presencial'
  ORDER BY c.FechaCita DESC, c.HoraCita DESC
  LIMIT 5;
END;;

-- 23. ListarCitasPorDiaSemana
DROP PROCEDURE IF EXISTS `ListarCitasPorDiaSemana`;;
CREATE PROCEDURE `ListarCitasPorDiaSemana`(IN diasemana VARCHAR(10), IN semanaActual INT)
BEGIN
  DECLARE fechaInicio DATE;
  DECLARE fechaFin DATE;

  SET fechaInicio = DATE_ADD(DATE_SUB(CURDATE(), INTERVAL WEEKDAY(CURDATE()) DAY), INTERVAL (semanaActual - WEEK(CURDATE(), 1)) WEEK);
  SET fechaFin = DATE_ADD(fechaInicio, INTERVAL 6 DAY);

  CREATE TEMPORARY TABLE IF NOT EXISTS TempCitas (
    idCita INT,
    DiaReserva DATE,
    HoraReserva TIME,
    Descripcion TEXT,
    NombrePaciente VARCHAR(100),
    ApellidoPaciente VARCHAR(100),
    EstadoReserva VARCHAR(50),
    TipoServicio VARCHAR(100),
    Costo DECIMAL(10,2),
    Importe DECIMAL(10,2),
    NombreOdontologo VARCHAR(100),
    ApellidoOdontologo VARCHAR(100),
    orden_row INT,
    color CHAR(7)
  );

  INSERT INTO TempCitas (idCita, DiaReserva, HoraReserva, Descripcion, NombrePaciente, ApellidoPaciente, 
                         EstadoReserva, TipoServicio, Costo, Importe, NombreOdontologo, ApellidoOdontologo, orden_row, color)
  SELECT c.idCita, 
         c.FechaCita, 
         c.HoraCita, 
         COALESCE(c.Descripcion, '') AS Descripcion,
         p.Nombre AS NombrePaciente, 
         p.Apellido AS ApellidoPaciente, 
         e.TipoEstado AS EstadoReserva, 
         s.TipoServicio, s.Costo,
         COALESCE(c.Importe, s.Costo) AS Importe,
         od.Nombre AS NombreOdontologo, 
         od.Apellido AS ApellidoOdontologo,
         CASE 
           WHEN TIME(c.HoraCita) < TIME('08:00:00') THEN 0
           WHEN TIME(c.HoraCita) = TIME('08:00:00') THEN 2
           ELSE 2 + FLOOR(TIMESTAMPDIFF(MINUTE, TIME('08:00:00'), TIME(c.HoraCita)) / 15)
         END AS orden_row,
         CASE e.TipoEstado
           WHEN 'Confirmado' THEN '#30a4c6'
           WHEN 'Completado' THEN '#9fcc3a'
           WHEN 'Reprogramado' THEN '#212529'
           ELSE '#b4ddc2'
         END AS color
  FROM Cita c
  INNER JOIN Paciente p ON c.Paciente_idPaciente = p.idPaciente
  INNER JOIN Estado e ON c.Estado_idEstado = e.idEstado
  INNER JOIN Servicio s ON c.Servicio_idServicio = s.idServicio
  INNER JOIN Usuario od ON c.Odontologo_idUsuario = od.idUsuario
  WHERE c.Origen = 'Presencial'
    AND c.Estado_idEstado IN (2, 3, 4) 
    AND c.FechaCita BETWEEN fechaInicio AND fechaFin
    AND DAYOFWEEK(c.FechaCita) = CASE diasemana
          WHEN 'Domingo' THEN 1
          WHEN 'Lunes' THEN 2
          WHEN 'Martes' THEN 3
          WHEN 'Miércoles' THEN 4
          WHEN 'Jueves' THEN 5
          WHEN 'Viernes' THEN 6
          WHEN 'Sábado' THEN 7
        END;

  SELECT * FROM TempCitas;
  DROP TEMPORARY TABLE IF EXISTS TempCitas;
END;;

-- 24. ListarCitasSemanaActual
DROP PROCEDURE IF EXISTS `ListarCitasSemanaActual`;;
CREATE PROCEDURE `ListarCitasSemanaActual`(IN diasemana VARCHAR(10))
BEGIN
  DECLARE fechaInicio DATE;
  DECLARE fechaFin DATE;

  SET fechaInicio = DATE_SUB(CURDATE(), INTERVAL WEEKDAY(CURDATE()) DAY);
  SET fechaFin = DATE_ADD(fechaInicio, INTERVAL 6 DAY);

  CREATE TEMPORARY TABLE IF NOT EXISTS TempCitasSemana (
    idCita INT,
    DiaReserva DATE,
    HoraReserva TIME,
    Descripcion TEXT,
    NombrePaciente VARCHAR(100),
    ApellidoPaciente VARCHAR(100),
    EstadoReserva VARCHAR(50),
    TipoServicio VARCHAR(100),
    Costo DECIMAL(10,2),
    Importe DECIMAL(10,2),
    NombreOdontologo VARCHAR(100),
    ApellidoOdontologo VARCHAR(100),
    orden_row INT,
    color CHAR(7)
  );

  INSERT INTO TempCitasSemana (idCita, DiaReserva, HoraReserva, Descripcion, NombrePaciente, ApellidoPaciente, 
                               EstadoReserva, TipoServicio, Costo, Importe, NombreOdontologo, ApellidoOdontologo, orden_row, color)
  SELECT c.idCita, 
         c.FechaCita, 
         c.HoraCita, 
         COALESCE(c.Descripcion, '') AS Descripcion,
         p.Nombre AS NombrePaciente, 
         p.Apellido AS ApellidoPaciente, 
         e.TipoEstado AS EstadoReserva, 
         s.TipoServicio, s.Costo,
         COALESCE(c.Importe, s.Costo) AS Importe,
         od.Nombre AS NombreOdontologo, 
         od.Apellido AS ApellidoOdontologo,
         CASE 
           WHEN TIME(c.HoraCita) < TIME('08:00:00') THEN 0
           WHEN TIME(c.HoraCita) = TIME('08:00:00') THEN 2
           ELSE 2 + FLOOR(TIMESTAMPDIFF(MINUTE, TIME('08:00:00'), TIME(c.HoraCita)) / 15)
         END AS orden_row,
         CASE e.TipoEstado
           WHEN 'Confirmado' THEN '#30a4c6'
           WHEN 'Completado' THEN '#9fcc3a'
           WHEN 'Reprogramado' THEN '#212529'
           ELSE '#b4ddc2'
         END AS color
  FROM Cita c
  INNER JOIN Paciente p ON c.Paciente_idPaciente = p.idPaciente
  INNER JOIN Estado e ON c.Estado_idEstado = e.idEstado
  INNER JOIN Servicio s ON c.Servicio_idServicio = s.idServicio
  INNER JOIN Usuario od ON c.Odontologo_idUsuario = od.idUsuario
  WHERE c.Origen = 'Presencial'
    AND c.Estado_idEstado IN (2, 3, 4) 
    AND c.FechaCita BETWEEN fechaInicio AND fechaFin
    AND DAYOFWEEK(c.FechaCita) = CASE diasemana
          WHEN 'Domingo' THEN 1
          WHEN 'Lunes' THEN 2
          WHEN 'Martes' THEN 3
          WHEN 'Miércoles' THEN 4
          WHEN 'Jueves' THEN 5
          WHEN 'Viernes' THEN 6
          WHEN 'Sábado' THEN 7
        END;

  SELECT * FROM TempCitasSemana;
  DROP TEMPORARY TABLE IF EXISTS TempCitasSemana;
END;;

-- 25. sp_crearreserva (Inserta en Cita con Origen='Web' y opcionalmente en Pago)
DROP PROCEDURE IF EXISTS `sp_crearreserva`;;
CREATE PROCEDURE `sp_crearreserva`(
  IN p_DiaReserva DATE,
  IN p_HoraReserva TIME,
  IN p_Descripcion TEXT,
  IN p_Importe DECIMAL(10,2),
  IN p_Usuario_idUsuario INT,
  IN p_Estado_idEstado INT,
  IN p_Servicio_idServicio INT,
  IN p_Odontologo_idUsuario INT
)
BEGIN
  DECLARE v_PacienteID INT;

  -- Soporte inteligente: Si p_Usuario_idUsuario corresponde a un paciente existente, asociarlo directamente
  IF EXISTS (SELECT 1 FROM Paciente WHERE idPaciente = p_Usuario_idUsuario) THEN
    SET v_PacienteID = p_Usuario_idUsuario;
  ELSE
    SELECT MAX(idPaciente) INTO v_PacienteID FROM Paciente;
  END IF;

  INSERT INTO Cita (
    FechaCita, HoraCita, Descripcion, Importe, Origen,
    Usuario_idUsuario, Paciente_idPaciente, Estado_idEstado, 
    Servicio_idServicio, Odontologo_idUsuario
  )
  VALUES (
    p_DiaReserva, p_HoraReserva, p_Descripcion, p_Importe, 'Web',
    NULL, v_PacienteID, p_Estado_idEstado, 
    p_Servicio_idServicio, p_Odontologo_idUsuario
  );

  -- En RF01, el pago está desacoplado de la reserva y se realiza por separado (RF10).
  -- La reserva queda 'En espera' con el importe referencial en Cita.Importe sin registro en Pago.
END;;

-- 26. ps_ReprogramarReserva
DROP PROCEDURE IF EXISTS `ps_ReprogramarReserva`;;
CREATE PROCEDURE `ps_ReprogramarReserva`(
  IN p_idReserva INT,
  IN p_nuevaFecha DATE,
  IN p_nuevaHora TIME
)
BEGIN
  UPDATE Cita
  SET FechaCita = p_nuevaFecha, 
      HoraCita = p_nuevaHora,
      Estado_idEstado = 4
  WHERE idCita = p_idReserva AND Origen = 'Web';
END;;

-- 27. sp_DetalleReserva
DROP PROCEDURE IF EXISTS `sp_DetalleReserva`;;
CREATE PROCEDURE `sp_DetalleReserva`(IN p_idReserva INT)
BEGIN
  SELECT 
    c.idCita AS idReserva, 
    c.FechaCita AS DiaReserva, 
    c.HoraCita AS HoraReserva, 
    c.Descripcion, 
    c.Importe, 
    s.TipoServicio, 
    p.Nombre AS NombrePaciente, 
    p.Apellido AS ApellidoPaciente, 
    e.TipoEstado AS EstadoReserva, 
    od.Nombre AS NombreOdontologo, 
    od.Apellido AS ApellidoOdontologo
  FROM Cita c
  INNER JOIN Servicio s ON c.Servicio_idServicio = s.idServicio
  INNER JOIN Paciente p ON c.Paciente_idPaciente = p.idPaciente
  INNER JOIN Estado e ON c.Estado_idEstado = e.idEstado
  INNER JOIN Usuario od ON c.Odontologo_idUsuario = od.idUsuario
  WHERE c.idCita = p_idReserva AND c.Origen = 'Web';
END;;

-- 28. sp_ListarHistorialReservas
DROP PROCEDURE IF EXISTS `sp_ListarHistorialReservas`;;
CREATE PROCEDURE `sp_ListarHistorialReservas`(IN p_idUsuario INT)
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
    WHERE c.Origen = 'Web' AND c.Estado_idEstado NOT IN (1, 3);
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
    WHERE c.Odontologo_idUsuario = p_idUsuario AND c.Origen = 'Web' AND c.Estado_idEstado NOT IN (1, 3);
  END IF;
END;;

-- 29. sp_ListarReservasPorUsuario
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
    WHERE c.Origen = 'Web' AND c.Estado_idEstado IN (1, 3);
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
    WHERE c.Odontologo_idUsuario = p_idUsuario AND c.Origen = 'Web' AND c.Estado_idEstado IN (1, 3);
  END IF;
END;;

-- 30. sp_ListarReservasReporte
DROP PROCEDURE IF EXISTS `sp_ListarReservasReporte`;;
CREATE PROCEDURE `sp_ListarReservasReporte`(IN p_idUsuario INT)
BEGIN
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
  WHERE c.Odontologo_idUsuario = p_idUsuario AND c.Origen = 'Web';
END;;

-- 31. sp_ListarReservasReporteAd
DROP PROCEDURE IF EXISTS `sp_ListarReservasReporteAd`;;
CREATE PROCEDURE `sp_ListarReservasReporteAd`()
BEGIN
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
  WHERE c.Origen = 'Web';
END;;

-- 32. sp_listarReservasRecientes
DROP PROCEDURE IF EXISTS `sp_listarReservasRecientes`;;
CREATE PROCEDURE `sp_listarReservasRecientes`()
BEGIN
  SELECT
    c.idCita AS idReserva,
    c.FechaCita AS DiaReserva,
    c.HoraCita AS HoraReserva,
    CONCAT(p.Nombre, ' ', p.Apellido) AS NombrePaciente,
    s.TipoServicio AS NombreServicio,
    e.TipoEstado AS EstadoNombre
  FROM Cita c
  INNER JOIN Paciente p ON c.Paciente_idPaciente = p.idPaciente
  INNER JOIN Servicio s ON c.Servicio_idServicio = s.idServicio
  INNER JOIN Estado e ON c.Estado_idEstado = e.idEstado
  WHERE c.Origen = 'Web'
  ORDER BY c.FechaCita DESC, c.HoraCita DESC
  LIMIT 5;
END;;

-- 33. ListarReservasPorDiaSemana
DROP PROCEDURE IF EXISTS `ListarReservasPorDiaSemana`;;
CREATE PROCEDURE `ListarReservasPorDiaSemana`(IN diasemana VARCHAR(10), IN semanaActual INT)
BEGIN
  DECLARE fechaInicio DATE;
  DECLARE fechaFin DATE;

  SET fechaInicio = DATE_ADD(DATE_SUB(CURDATE(), INTERVAL WEEKDAY(CURDATE()) DAY), INTERVAL (semanaActual - WEEK(CURDATE(), 1)) WEEK);
  SET fechaFin = DATE_ADD(fechaInicio, INTERVAL 6 DAY);

  CREATE TEMPORARY TABLE IF NOT EXISTS TempReservas (
    idReserva INT,
    DiaReserva DATE,
    HoraReserva TIME,
    Descripcion TEXT,
    NombrePaciente VARCHAR(100),
    ApellidoPaciente VARCHAR(100),
    EstadoReserva VARCHAR(50),
    TipoServicio VARCHAR(100),
    Costo DECIMAL(10,2),
    Importe DECIMAL(10,2),
    NombreOdontologo VARCHAR(100),
    ApellidoOdontologo VARCHAR(100),
    orden_row INT,
    color CHAR(7)
  );

  INSERT INTO TempReservas (idReserva, DiaReserva, HoraReserva, Descripcion, NombrePaciente, ApellidoPaciente, 
                            EstadoReserva, TipoServicio, Costo, Importe, NombreOdontologo, ApellidoOdontologo, orden_row, color)
  SELECT c.idCita, 
         c.FechaCita, 
         c.HoraCita, 
         COALESCE(c.Descripcion, '') AS Descripcion,
         p.Nombre AS NombrePaciente, 
         p.Apellido AS ApellidoPaciente, 
         e.TipoEstado AS EstadoReserva, 
         s.TipoServicio, s.Costo,
         COALESCE(c.Importe, s.Costo) AS Importe,
         od.Nombre AS NombreOdontologo, 
         od.Apellido AS ApellidoOdontologo,
         CASE 
           WHEN TIME(c.HoraCita) < TIME('08:00:00') THEN 0
           WHEN TIME(c.HoraCita) = TIME('08:00:00') THEN 2
           ELSE 2 + FLOOR(TIMESTAMPDIFF(MINUTE, TIME('08:00:00'), TIME(c.HoraCita)) / 15)
         END AS orden_row,
         CASE e.TipoEstado
           WHEN 'Confirmado' THEN '#30a4c6'
           WHEN 'Completado' THEN '#9fcc3a'
           WHEN 'Reprogramado' THEN '#212529'
           ELSE '#b4ddc2'
         END AS color
  FROM Cita c
  INNER JOIN Paciente p ON c.Paciente_idPaciente = p.idPaciente
  INNER JOIN Estado e ON c.Estado_idEstado = e.idEstado
  INNER JOIN Servicio s ON c.Servicio_idServicio = s.idServicio
  INNER JOIN Usuario od ON c.Odontologo_idUsuario = od.idUsuario
  WHERE c.Origen = 'Web'
    AND c.Estado_idEstado IN (2, 3, 4) 
    AND c.FechaCita BETWEEN fechaInicio AND fechaFin
    AND DAYOFWEEK(c.FechaCita) = CASE diasemana
          WHEN 'Domingo' THEN 1
          WHEN 'Lunes' THEN 2
          WHEN 'Martes' THEN 3
          WHEN 'Miércoles' THEN 4
          WHEN 'Jueves' THEN 5
          WHEN 'Viernes' THEN 6
          WHEN 'Sábado' THEN 7
        END;

  SELECT * FROM TempReservas;
  DROP TEMPORARY TABLE IF EXISTS TempReservas;
END;;

-- 34. ListarReservasSemanaActual
DROP PROCEDURE IF EXISTS `ListarReservasSemanaActual`;;
CREATE PROCEDURE `ListarReservasSemanaActual`(IN diasemana VARCHAR(10))
BEGIN
  DECLARE fechaInicio DATE;
  DECLARE fechaFin DATE;

  SET fechaInicio = DATE_SUB(CURDATE(), INTERVAL WEEKDAY(CURDATE()) DAY);
  SET fechaFin = DATE_ADD(fechaInicio, INTERVAL 6 DAY);

  CREATE TEMPORARY TABLE IF NOT EXISTS TempReservasSemana (
    idReserva INT,
    DiaReserva DATE,
    HoraReserva TIME,
    Descripcion TEXT,
    NombrePaciente VARCHAR(100),
    ApellidoPaciente VARCHAR(100),
    EstadoReserva VARCHAR(50),
    TipoServicio VARCHAR(100),
    Costo DECIMAL(10,2),
    Importe DECIMAL(10,2),
    NombreOdontologo VARCHAR(100),
    ApellidoOdontologo VARCHAR(100),
    orden_row INT,
    color CHAR(7)
  );

  INSERT INTO TempReservasSemana (idReserva, DiaReserva, HoraReserva, Descripcion, NombrePaciente, ApellidoPaciente, 
                                  EstadoReserva, TipoServicio, Costo, Importe, NombreOdontologo, ApellidoOdontologo, orden_row, color)
  SELECT c.idCita, 
         c.FechaCita, 
         c.HoraCita, 
         COALESCE(c.Descripcion, '') AS Descripcion,
         p.Nombre AS NombrePaciente, 
         p.Apellido AS ApellidoPaciente, 
         e.TipoEstado AS EstadoReserva, 
         s.TipoServicio, s.Costo,
         COALESCE(c.Importe, s.Costo) AS Importe,
         od.Nombre AS NombreOdontologo, 
         od.Apellido AS ApellidoOdontologo,
         CASE 
           WHEN TIME(c.HoraCita) < TIME('08:00:00') THEN 0
           WHEN TIME(c.HoraCita) = TIME('08:00:00') THEN 2
           ELSE 2 + FLOOR(TIMESTAMPDIFF(MINUTE, TIME('08:00:00'), TIME(c.HoraCita)) / 15)
         END AS orden_row,
         CASE e.TipoEstado
           WHEN 'Confirmado' THEN '#30a4c6'
           WHEN 'Completado' THEN '#9fcc3a'
           WHEN 'Reprogramado' THEN '#212529'
           ELSE '#b4ddc2'
         END AS color
  FROM Cita c
  INNER JOIN Paciente p ON c.Paciente_idPaciente = p.idPaciente
  INNER JOIN Estado e ON c.Estado_idEstado = e.idEstado
  INNER JOIN Servicio s ON c.Servicio_idServicio = s.idServicio
  INNER JOIN Usuario od ON c.Odontologo_idUsuario = od.idUsuario
  WHERE c.Origen = 'Web'
    AND c.Estado_idEstado IN (2, 3, 4) 
    AND c.FechaCita BETWEEN fechaInicio AND fechaFin
    AND DAYOFWEEK(c.FechaCita) = CASE diasemana
          WHEN 'Domingo' THEN 1
          WHEN 'Lunes' THEN 2
          WHEN 'Martes' THEN 3
          WHEN 'Miércoles' THEN 4
          WHEN 'Jueves' THEN 5
          WHEN 'Viernes' THEN 6
          WHEN 'Sábado' THEN 7
        END;

  SELECT * FROM TempReservasSemana;
  DROP TEMPORARY TABLE IF EXISTS TempReservasSemana;
END;;

-- 35. verificarDisponibilidad
DROP PROCEDURE IF EXISTS `verificarDisponibilidad`;;
CREATE PROCEDURE `verificarDisponibilidad`(IN idUsuario INT, IN fecha DATE, IN hora TIME, OUT disponible BOOLEAN)
BEGIN
  DECLARE countReservas INT;
  SELECT COUNT(*) INTO countReservas
  FROM Cita
  WHERE Odontologo_idUsuario = idUsuario AND FechaCita = fecha AND HoraCita = hora;
  SET disponible = (countReservas = 0);
END;;

-- 36. sp_obtenerMedicosPorServicioYDisponibilidad
DROP PROCEDURE IF EXISTS `sp_obtenerMedicosPorServicioYDisponibilidad`;;
CREATE PROCEDURE `sp_obtenerMedicosPorServicioYDisponibilidad`(IN p_idServicio INT, IN p_fecha DATE, IN p_hora TIME)
BEGIN
  SELECT u.*
  FROM Usuario u
  JOIN Usuario_Servicio us ON u.idUsuario = us.idUsuario
  LEFT JOIN Cita c ON u.idUsuario = c.Odontologo_idUsuario AND c.FechaCita = p_fecha AND c.HoraCita = p_hora
  WHERE us.idServicio = p_idServicio
    AND u.Rol_idRol = 3
    AND c.idCita IS NULL;
END;;

DELIMITER ;
