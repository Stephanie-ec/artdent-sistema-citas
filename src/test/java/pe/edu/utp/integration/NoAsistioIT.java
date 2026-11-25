package pe.edu.utp.integration;

import java.sql.SQLException;
import java.sql.Statement;
import org.junit.Test;
import static org.junit.Assert.*;

/** R-09: "No asistió" solo después de la hora y libera el horario. */
public class NoAsistioIT extends DbFixture {

    private void pasado(int id) throws SQLException {
        try (Statement s = db.createStatement()) {
            s.executeUpdate("UPDATE Cita SET FechaCita='2000-01-03' WHERE idCita=" + id);
        }
    }

    @Test public void estadoSieteExisteConSuNombre() throws Exception {
        assertEquals(1, numero("SELECT COUNT(*) FROM Estado WHERE idEstado=7 AND TipoEstado='No asistió'"));
    }

    @Test public void noSeMarcaAntesDeLaHora() throws Exception {
        int id = cita(3, "Presencial", "10:00");
        SQLException error = assertThrows(SQLException.class,
                () -> new pe.edu.utp.daoImpl.GestionCitaDao().cambiarEstado(id, 7, 2, false));
        assertEquals("45000", error.getSQLState());
        assertEquals(3, numero("SELECT Estado_idEstado FROM Cita WHERE idCita=" + id));
    }

    @Test public void soloDesdeConfirmadaOReprogramada() throws Exception {
        int id = cita(1, "Presencial", "10:00");
        pasado(id);
        assertThrows(SQLException.class,
                () -> new pe.edu.utp.daoImpl.GestionCitaDao().cambiarEstado(id, 7, 2, false));
    }

    @Test public void soloElTitularPuedeMarcarla() throws Exception {
        int otro = insertar("INSERT INTO Usuario(Nombre,Apellido,DNI,Telefono,CorreoElectronico,Direccion,FechaNacimiento,Clave,Rol_idRol,Activo) "
                + "VALUES('Otro','Doctor','" + (70000000 + doctor) + "','987654321','otro@example.test','Prueba','1990-01-01','123456',3,1)");
        try {
            int id = cita(3, "Presencial", "10:00");
            pasado(id);
            // Un odontologo ajeno a la cita no puede marcarla
            assertThrows(SQLException.class,
                    () -> new pe.edu.utp.daoImpl.GestionCitaDao().cambiarEstado(id, 7, otro, false));
            assertEquals(3, numero("SELECT Estado_idEstado FROM Cita WHERE idCita=" + id));
            // El odontologo titular si puede
            new pe.edu.utp.daoImpl.GestionCitaDao().cambiarEstado(id, 7, doctor, false);
            assertEquals(7, numero("SELECT Estado_idEstado FROM Cita WHERE idCita=" + id));
        } finally {
            try (Statement s = db.createStatement()) {
                s.executeUpdate("DELETE FROM Usuario WHERE idUsuario=" + otro);
            }
        }
    }

    @Test public void laInasistenciaLiberaElHorarioYDejaAviso() throws Exception {
        int bloqueada = cita(3, "Presencial", "10:00");
        int otra = cita(3, "Presencial", "10:30");
        // Mientras la cita existe, el horario está ocupado
        assertThrows(SQLException.class, () -> validarAgenda(otra, "10:00"));
        // Una cita en estado "No asistió" deja de ocupar el horario
        try (Statement s = db.createStatement()) {
            s.executeUpdate("UPDATE Cita SET Estado_idEstado=7 WHERE idCita=" + bloqueada);
        }
        validarAgenda(otra, "10:00");
        new pe.edu.utp.daoImpl.GestionCitaDao().reprogramar(otra, fecha.toString(), "10:00", false);
        assertEquals(10, numero("SELECT HOUR(HoraCita) FROM Cita WHERE idCita=" + otra));
    }

    @Test public void marcarLaInasistenciaDejaElAvisoParaReprogramar() throws Exception {
        int id = cita(3, "Presencial", "10:00");
        pasado(id);
        new pe.edu.utp.daoImpl.GestionCitaDao().cambiarEstado(id, 7, doctor, false);
        assertEquals(7, numero("SELECT Estado_idEstado FROM Cita WHERE idCita=" + id));
        assertEquals(1, numero("SELECT COUNT(*) FROM Notificacion WHERE Cita_idCita=" + id
                + " AND Estado_idEstado=7 AND Asunto LIKE 'Paciente no asistio%'"));
    }

    private void validarAgenda(int citaId, String hora) throws SQLException {
        try (java.sql.CallableStatement s = db.prepareCall("{call sp_artdent_validarAgenda(?,?,?,?,?)}")) {
            s.setInt(1, citaId);
            s.setInt(2, doctor);
            s.setInt(3, 1);
            s.setDate(4, java.sql.Date.valueOf(fecha));
            s.setString(5, hora);
            s.execute();
        }
    }
}
