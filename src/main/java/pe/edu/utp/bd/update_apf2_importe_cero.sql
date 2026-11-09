-- Delta no destructivo. Seleccione la BD correcta con USE antes de ejecutarlo.
-- Solo redefine rutinas de lectura: no altera datos ni tablas.
-- Motivo: las citas heredadas con Cita.Importe = 0 hacian que el listado y el
-- modal de cobro mostraran importes incorrectos. El pago ya usa el costo real.
DELIMITER ;;
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
      COALESCE(NULLIF(c.Importe,0), s.Costo) AS Importe,
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
      COALESCE(NULLIF(c.Importe,0), s.Costo) AS Importe,
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

DROP PROCEDURE IF EXISTS `sp_ListarReservasReporte`;;
CREATE PROCEDURE `sp_ListarReservasReporte`(IN p_idUsuario INT)
BEGIN
  SELECT
    c.idCita AS idReserva,
    c.FechaCita AS DiaReserva,
    c.HoraCita AS HoraReserva,
    c.Descripcion,
    COALESCE(NULLIF(c.Importe,0), s.Costo) AS Importe,
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

DROP PROCEDURE IF EXISTS `sp_ListarReservasReporteAd`;;
CREATE PROCEDURE `sp_ListarReservasReporteAd`()
BEGIN
  SELECT
    c.idCita AS idReserva,
    c.FechaCita AS DiaReserva,
    c.HoraCita AS HoraReserva,
    c.Descripcion,
    COALESCE(NULLIF(c.Importe,0), s.Costo) AS Importe,
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
DELIMITER ;
