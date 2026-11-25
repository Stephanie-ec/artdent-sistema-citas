package pe.edu.utp.utils;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.Duration;
import java.time.LocalDateTime;
import java.util.logging.Level;
import java.util.logging.Logger;
import pe.edu.utp.config.Conexion;
import pe.edu.utp.daoImpl.CorreoDao;

/**
 * R-03: recordatorio de la cita 24 horas antes.
 *
 * La tarea puede ejecutarse cada hora: la cola usa la clave
 * "recordatorio-{idCita}", por lo que cada cita recibe un único correo.
 * Encola aunque el envío SMTP esté apagado si se activa recordatorios.enabled,
 * para poder verificar el comportamiento sin credenciales.
 */
public final class RecordatorioService {

    private static final Logger LOG = Logger.getLogger(RecordatorioService.class.getName());
    private static final String SQL =
            "SELECT c.idCita, c.FechaCita, c.HoraCita, s.TipoServicio, "
            + "CONCAT(od.Nombre,' ',od.Apellido) AS Odontologo "
            + "FROM Cita c "
            + "JOIN Servicio s ON s.idServicio=c.Servicio_idServicio "
            + "JOIN Usuario od ON od.idUsuario=c.Odontologo_idUsuario "
            + "WHERE c.Estado_idEstado IN (3,4) "
            + "AND TIMESTAMP(c.FechaCita,c.HoraCita) BETWEEN DATE_ADD(NOW(), INTERVAL 23 HOUR) "
            + "AND DATE_ADD(NOW(), INTERVAL 25 HOUR)";

    private RecordatorioService() {
    }

    /** Ventana de 23 a 25 horas: cubre los desfases de una tarea horaria. */
    public static boolean enVentana(LocalDateTime cita, LocalDateTime ahora) {
        if (cita == null || ahora == null) {
            return false;
        }
        long minutos = Duration.between(ahora, cita).toMinutes();
        return minutos >= 23L * 60L && minutos <= 25L * 60L;
    }

    public static boolean habilitado() {
        return "true".equalsIgnoreCase(ConfigLoader.getProperty("mail.enabled"))
                || "true".equalsIgnoreCase(ConfigLoader.getProperty("recordatorios.enabled"));
    }

    /** Encola los recordatorios de las citas que caen en la ventana. Devuelve cuántos procesó. */
    public static int procesar() {
        int procesados = 0;
        CorreoDao correoDao = new CorreoDao();
        try (Connection c = Conexion.getConection();
             PreparedStatement s = c.prepareStatement(SQL);
             ResultSet r = s.executeQuery()) {
            while (r.next()) {
                int idCita = r.getInt("idCita");
                String asunto = "Recordatorio: su cita es mañana";
                String mensaje = "Le recordamos su cita en el Centro Odontológico Art Dent."
                        + "\nFecha: " + r.getString("FechaCita")
                        + "\nHora: " + r.getString("HoraCita")
                        + "\nServicio: " + r.getString("TipoServicio")
                        + "\nOdontólogo: " + r.getString("Odontologo")
                        + "\nSede: Jr. Chiclayo 268, Chosica"
                        + "\nCódigo de reserva: " + String.format("ART-RES-%05d", idCita)
                        + "\n\nSi no puede asistir, comuníquese con la clínica.";
                correoDao.encolarRecordatorio(idCita, asunto, mensaje);
                procesados++;
            }
        } catch (SQLException e) {
            LOG.log(Level.WARNING, "No se pudieron encolar los recordatorios", e);
            return procesados;
        }
        if (procesados > 0) {
            EventoService.info("Recordatorios", "Se encolaron " + procesados
                    + " recordatorio(s) de citas para las próximas 24 horas");
        }
        return procesados;
    }
}
