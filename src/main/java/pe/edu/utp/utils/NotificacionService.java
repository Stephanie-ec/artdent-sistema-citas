package pe.edu.utp.utils;

import pe.edu.utp.daoImpl.CitaDaoImpl;

/**
 * RF09: registra el evento y encola entregas al paciente, titular y secretaría.
 * CorreoPendiente registra el resultado real por destinatario; encolar no es entregar.
 */
public final class NotificacionService {

    /** Resultado del último envío en este hilo, para informarlo en la pantalla. */
    private static final ThreadLocal<Boolean> ULTIMO_ENVIO = new ThreadLocal<>();

    private NotificacionService() {
    }

    /** Parámetro para la URL de retorno: &correo=1 si se envió, &correo=0 si falló. */
    public static String sufijoCorreo() {
        Boolean ok = ULTIMO_ENVIO.get();
        ULTIMO_ENVIO.remove();
        return ok == null ? "" : (ok ? "&correo=1" : "&correo=0");
    }

    /**
     * @param idCita   cita o reserva notificada
     * @param idEstado estado que origina el correo (3 Confirmado, 2 Completado,
     *                 4 Reprogramado, 5 Cancelado, 6 Rechazado)
     * @param asunto   asunto del correo (se registra en Notificacion)
     * @param correo   correo del paciente; si está vacío se registra como no enviado
     * @param mensaje  cuerpo del correo
     * @return false: la entrega es asíncrona y se consulta en CorreoController
     */
    public static boolean notificar(int idCita, int idEstado, String asunto, String correo, String mensaje) {
        // La cita ya está confirmada en BD. SMTP se procesa fuera de la solicitud y de su transacción.
        ULTIMO_ENVIO.remove();
        try {
            new pe.edu.utp.daoImpl.CorreoDao().encolar(idCita,idEstado,asunto,mensaje);
            new CitaDaoImpl().registrarNotificacion(asunto,idEstado,idCita,false);
        } catch(java.sql.SQLException|RuntimeException e) {
            ULTIMO_ENVIO.set(false);
            java.util.logging.Logger.getLogger(NotificacionService.class.getName()).log(java.util.logging.Level.WARNING,"Cambio guardado; no se pudo encolar la notificación",e);
        }
        return false; // Encolado nunca equivale a entrega confirmada.
    }
}
