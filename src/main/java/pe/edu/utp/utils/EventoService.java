package pe.edu.utp.utils;

import java.util.List;
import java.util.Locale;
import java.util.logging.Level;
import java.util.logging.Logger;
import pe.edu.utp.daoImpl.EventoDao;

/**
 * R-15: registro de eventos y alertas.
 *
 * Es "best-effort" a propósito: si la base está caída o el INSERT falla, el
 * evento queda en el log del servidor y la operación del usuario continúa.
 * Nunca propaga excepciones ni escribe contraseñas o datos clínicos.
 */
public final class EventoService {

    private static final Logger LOG = Logger.getLogger("pe.edu.utp.eventos");
    private static final ThreadLocal<Boolean> EN_CURSO = new ThreadLocal<>();
    private static final ThreadLocal<Boolean> ALERTANDO = new ThreadLocal<>();
    private static volatile long ultimaAlerta = 0L;
    private static volatile long ultimaLimpieza = 0L;
    public static final int RETENCION_DIAS = 90;
    private static final String ALERTA_BLOQUEOS = "cuentas bloqueadas";

    private EventoService() {
    }

    public static String normalizarNivel(String nivel) {
        if (nivel == null) {
            return "INFO";
        }
        String v = nivel.trim().toUpperCase(Locale.ROOT);
        return "ADVERTENCIA".equals(v) || "ERROR".equals(v) ? v : "INFO";
    }

    public static void info(String origen, String mensaje) {
        registrar("INFO", origen, mensaje);
    }

    public static void advertencia(String origen, String mensaje) {
        registrar("ADVERTENCIA", origen, mensaje);
    }

    public static void error(String origen, String mensaje) {
        registrar("ERROR", origen, mensaje);
    }

    public static void registrar(String nivel, String origen, String mensaje) {
        String n = normalizarNivel(nivel);
        LOG.log(nivelLog(n), "[{0}] {1}", new Object[]{origen, mensaje});
        if (Boolean.TRUE.equals(EN_CURSO.get())) {
            return;
        }
        if ("false".equalsIgnoreCase(System.getProperty("artdent.eventos.enabled"))) {
            return;
        }
        EN_CURSO.set(Boolean.TRUE);
        try {
            EventoDao dao = new EventoDao();
            dao.insertar(n, origen, mensaje);
            if ("ERROR".equals(n)) {
                enviarAlerta(origen, mensaje);
            }
            limpiarSiCorresponde(dao);
        } catch (Exception e) {
            LOG.log(Level.WARNING, "No se pudo guardar el evento en la base de datos; queda en el log", e);
        } finally {
            EN_CURSO.remove();
        }
    }

    /** Alerta = evento ERROR, que además notifica por correo a los administradores. */
    public static void alertar(String origen, String mensaje) {
        registrar("ERROR", origen, mensaje);
    }

    /**
     * R-15: todo evento ERROR avisa una sola vez por minuto a los administradores.
     * El límite evita correos en cadena cuando la causa se repite (por ejemplo, BD caída).
     * Nunca se alerta desde el envío de alertas, para no entrar en recursión.
     */
    private static void enviarAlerta(String origen, String mensaje) {
        if (Boolean.TRUE.equals(ALERTANDO.get())) {
            return;
        }
        if (!"true".equalsIgnoreCase(ConfigLoader.getProperty("mail.enabled"))) {
            return;
        }
        long ahora = System.currentTimeMillis();
        if (ahora - ultimaAlerta < 60_000L) {
            return;
        }
        ultimaAlerta = ahora;
        ALERTANDO.set(Boolean.TRUE);
        try {
            List<String> correos = new EventoDao().correosAdministradores();
            String asunto = "Alerta Art Dent: " + origen;
            for (String correo : correos) {
                EmailService.sendEmail(correo, asunto, mensaje);
            }
        } catch (Exception e) {
            LOG.log(Level.WARNING, "No se pudo enviar la alerta por correo", e);
        } finally {
            ALERTANDO.remove();
        }
    }

    /**
     * R-15: cada bloqueo de cuenta es un ERROR; cinco bloqueos en una hora
     * generan una única alerta adicional para el administrador.
     */
    public static void registrarBloqueoCuenta(int idUsuario) {
        registrar("ERROR", "Seguridad", "Cuenta bloqueada tras 5 intentos fallidos (usuario id " + idUsuario + ")");
        try {
            EventoDao dao = new EventoDao();
            if (dao.contarBloqueosUltimaHora() >= 5 && !dao.existeAlertaSimilar(ALERTA_BLOQUEOS, 60)) {
                alertar("Seguridad", "Posible ataque: 5 o más cuentas bloqueadas en la última hora. Revise el registro de eventos.");
            }
        } catch (Exception e) {
            LOG.log(Level.WARNING, "No se pudo evaluar la alerta de bloqueos", e);
        }
    }

    private static void limpiarSiCorresponde(EventoDao dao) {
        long ahora = System.currentTimeMillis();
        if (ahora - ultimaLimpieza < 24L * 60L * 60L * 1000L) {
            return;
        }
        ultimaLimpieza = ahora;
        try {
            dao.limpiarAntiguos(RETENCION_DIAS);
        } catch (Exception e) {
            LOG.log(Level.FINE, "No se pudieron depurar eventos antiguos", e);
        }
    }

    private static Level nivelLog(String nivel) {
        if ("ERROR".equals(nivel)) {
            return Level.SEVERE;
        }
        return "ADVERTENCIA".equals(nivel) ? Level.WARNING : Level.INFO;
    }
}
