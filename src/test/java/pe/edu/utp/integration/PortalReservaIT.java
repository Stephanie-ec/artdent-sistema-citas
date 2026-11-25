package pe.edu.utp.integration;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import org.junit.Test;
import pe.edu.utp.daoImpl.GestionCitaDao;
import static org.junit.Assert.*;

/** R-10: el paciente cancela o reprograma con código + DNI y la regla de 24 horas. */
public class PortalReservaIT extends DbFixture {

    private String dniPaciente() throws SQLException {
        try (Statement s = db.createStatement();
             ResultSet r = s.executeQuery("SELECT DNI FROM Paciente WHERE idPaciente=" + paciente)) {
            r.next();
            return r.getString(1);
        }
    }

    private void citaEnHoras(int id, int horas) throws SQLException {
        try (Statement s = db.createStatement()) {
            s.executeUpdate("UPDATE Cita SET FechaCita=DATE_ADD(NOW(), INTERVAL " + horas + " HOUR) WHERE idCita=" + id);
        }
    }

    @Test public void conMasDe24HorasCancelaYDejaDevolucionPendiente() throws Exception {
        int id = cita(3, "Web", "10:00");
        pago(id);
        new GestionCitaDao().cancelarReservaPaciente(id, dniPaciente());
        assertEquals(5, numero("SELECT Estado_idEstado FROM Cita WHERE idCita=" + id));
        assertEquals(1, numero("SELECT COUNT(*) FROM Devolucion WHERE Pago_idPago IN (SELECT idPago FROM Pago WHERE Cita_idCita=" + id + ")"));
        assertEquals(1, numero("SELECT COUNT(*) FROM Notificacion WHERE Cita_idCita=" + id
                + " AND Asunto LIKE 'Reserva cancelada%'"));
        assertEquals(1, numero("SELECT COUNT(*) FROM Notificacion WHERE Cita_idCita=" + id
                + " AND Asunto LIKE 'Devolucion pendiente%'"));
    }

    @Test public void conMenosDe24HorasPideLlamarALaClinica() throws Exception {
        int id = cita(3, "Web", "10:00");
        citaEnHoras(id, 12);
        SQLException error = assertThrows(SQLException.class,
                () -> new GestionCitaDao().cancelarReservaPaciente(id, dniPaciente()));
        assertEquals("45000", error.getSQLState());
        assertTrue(error.getMessage().toLowerCase().contains("comun"));
        assertEquals(3, numero("SELECT Estado_idEstado FROM Cita WHERE idCita=" + id));
    }

    @Test public void unDniAjenoNoPuedeCancelar() throws Exception {
        int id = cita(3, "Web", "10:00");
        assertThrows(SQLException.class, () -> new GestionCitaDao().cancelarReservaPaciente(id, "00000000"));
        assertEquals(3, numero("SELECT Estado_idEstado FROM Cita WHERE idCita=" + id));
    }

    @Test public void reprogramaSuPropiaReservaAUnHorarioLibre() throws Exception {
        int id = cita(3, "Web", "10:00");
        new GestionCitaDao().reprogramarReservaPaciente(id, dniPaciente(), fecha.plusDays(1).toString(), "11:00");
        assertEquals(11, numero("SELECT HOUR(HoraCita) FROM Cita WHERE idCita=" + id));
        assertEquals(4, numero("SELECT Estado_idEstado FROM Cita WHERE idCita=" + id));
        assertEquals(fecha.plusDays(1).toString(), texto("SELECT DATE_FORMAT(FechaCita,'%Y-%m-%d') FROM Cita WHERE idCita=" + id));
    }

    @Test public void noPuedeReprogramarSobreUnHorarioOcupado() throws Exception {
        int ocupada = cita(3, "Web", "10:00");
        int movil = cita(3, "Web", "15:00");
        assertThrows(SQLException.class,
                () -> new GestionCitaDao().reprogramarReservaPaciente(movil, dniPaciente(), fecha.toString(), "10:00"));
        assertEquals(10, numero("SELECT HOUR(HoraCita) FROM Cita WHERE idCita=" + ocupada));
        assertEquals(15, numero("SELECT HOUR(HoraCita) FROM Cita WHERE idCita=" + movil));
    }

    private String texto(String sql) throws SQLException {
        try (Statement s = db.createStatement(); ResultSet r = s.executeQuery(sql)) {
            r.next();
            return r.getString(1);
        }
    }
}
