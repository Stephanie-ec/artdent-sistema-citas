package pe.edu.utp.integration;

import java.sql.SQLException;
import java.sql.Statement;
import java.time.LocalTime;
import java.util.List;
import org.junit.Test;
import pe.edu.utp.daoImpl.UsuarioDaoImpl;
import pe.edu.utp.entity.Usuario;
import static org.junit.Assert.*;

/** R-11: un bloqueo excluye al odontologo (o a toda la clinica) de la agenda. */
public class BloqueoAgendaIT extends DbFixture {

    private void bloquear(Integer usuarioId, String motivo) throws SQLException {
        try (Statement s = db.createStatement()) {
            s.executeUpdate("INSERT INTO BloqueoAgenda(Desde,Hasta,Usuario_idUsuario,Motivo,Actor_idUsuario) VALUES('" + fecha
                    + "','" + fecha + "'," + (usuarioId == null ? "NULL" : usuarioId) + ",'" + motivo + "'," + doctor + ")");
        }
    }

    private void desbloquear(String motivo) throws SQLException {
        try (Statement s = db.createStatement()) {
            s.executeUpdate("DELETE FROM BloqueoAgenda WHERE Motivo='" + motivo + "'");
        }
    }

    private List<Usuario> disponibles() {
        return new UsuarioDaoImpl().obtenerMedicosPorServicioYDisponibilidad(1, fecha, LocalTime.of(10, 0));
    }

    private boolean apareceElDoctor(List<Usuario> lista) {
        for (Usuario u : lista) {
            if (u.getIdUsuario() == doctor) return true;
        }
        return false;
    }

    @Test public void sinBloqueoElOdontologoEstaDisponible() {
        assertTrue(apareceElDoctor(disponibles()));
    }

    @Test public void elBloqueoDelOdontologoLoRetiraDeLaBusqueda() throws Exception {
        String motivo = "BLOQUEO-IT-" + doctor;
        try {
            bloquear(doctor, motivo);
            assertFalse(apareceElDoctor(disponibles()));
        } finally {
            desbloquear(motivo);
        }
        assertTrue(apareceElDoctor(disponibles()));
    }

    @Test public void elBloqueoDeOtroOdontologoNoAfecta() throws Exception {
        String motivo = "BLOQUEO-OTRO-" + doctor;
        try {
            // Otro odontologo real: el bloqueo ajeno no debe afectar al de la cita
            bloquear(numero("SELECT MIN(idUsuario) FROM Usuario WHERE Rol_idRol=3 AND idUsuario<>" + doctor), motivo);
            assertTrue(apareceElDoctor(disponibles()));
        } finally {
            desbloquear(motivo);
        }
    }

    @Test public void elBloqueoDeTodaLaClinicaRetiraATodos() throws Exception {
        String motivo = "BLOQUEO-GLOBAL-" + doctor;
        try {
            bloquear(null, motivo);
            assertTrue(disponibles().isEmpty());
        } finally {
            desbloquear(motivo);
        }
        assertTrue(apareceElDoctor(disponibles()));
    }

    @Test public void laValidacionDeAgendaRechazaElDiaBloqueado() throws Exception {
        String motivo = "BLOQUEO-VAL-" + doctor;
        try {
            bloquear(doctor, motivo);
            SQLException error = assertThrows(SQLException.class,
                    () -> new pe.edu.utp.daoImpl.GestionCitaDao().reprogramar(cita(3, "Presencial", "09:00"), fecha.toString(), "10:00", false));
            assertEquals("45000", error.getSQLState());
        } finally {
            desbloquear(motivo);
        }
    }
}
