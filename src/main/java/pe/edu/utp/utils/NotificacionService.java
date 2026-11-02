package pe.edu.utp.utils;

import pe.edu.utp.dao.CitaDao;
import pe.edu.utp.daoImpl.CitaDaoImpl;

/**
 * RF09: envía el correo al paciente y registra la notificación en la tabla
 * Notificacion con el resultado real del envío (Enviado = 1 o 0).
 */
public final class NotificacionService {

    private NotificacionService() {
    }

    /**
     * @param idCita   cita o reserva notificada
     * @param idEstado estado que origina el correo (3 Confirmado, 2 Completado,
     *                 4 Reprogramado, 5 Cancelado, 6 Rechazado)
     * @param asunto   asunto del correo (se registra en Notificacion)
     * @param correo   correo del paciente; si está vacío se registra como no enviado
     * @param mensaje  cuerpo del correo
     * @return true si el correo se envió
     */
    public static boolean notificar(int idCita, int idEstado, String asunto, String correo, String mensaje) {
        boolean enviado = false;
        if (correo != null && !correo.trim().isEmpty()) {
            enviado = EmailService.sendEmail(correo.trim(), asunto + " - ArtDent", mensaje);
        }
        CitaDao citaDao = new CitaDaoImpl();
        citaDao.registrarNotificacion(asunto, idEstado, idCita, enviado);
        return enviado;
    }
}
