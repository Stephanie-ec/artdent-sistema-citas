package pe.edu.utp.utils;

import java.time.Clock;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.ZoneId;
import java.time.format.DateTimeParseException;

/**
 * Validación de datos de entrada en el servidor (RNF03, O-18).
 * Devuelve null si los datos son válidos o el mensaje para el usuario.
 */
public final class Validador {

    private Validador() {
    }

    public static String validarDatosPaciente(String dni, String nombre, String apellido,
            String telefono, String correo, String fecha, String hora) {
        if (vacio(nombre) || vacio(apellido)) {
            return "Ingrese el nombre y el apellido del paciente.";
        }
        String errorNombre = validarNombreApellido(nombre, apellido);
        if (errorNombre != null) {
            return errorNombre;
        }
        if (dni == null || !dni.trim().matches("\\d{8}")) {
            return "El DNI debe tener exactamente 8 dígitos numéricos.";
        }
        if (telefono == null || !telefono.trim().matches("9\\d{8}")) {
            return "El celular debe tener 9 dígitos y empezar con 9.";
        }
        if (correo == null || !correo.trim().matches("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$")) {
            return "Ingrese un correo electrónico válido.";
        }
        return validarFechaHora(fecha, hora);
    }

    private static final ZoneId ZONA_CLINICA = ZoneId.of("America/Lima");

    /** F-08: la fecha se valida antes de consultar RENIEC o escribir en la BD. */
    public static String validarFechaHora(String fecha, String hora) {
        return validarFechaHora(fecha, hora, Clock.system(ZONA_CLINICA));
    }

    // El reloj inyectable permite probar límites de día/hora sin depender de la PC.
    static String validarFechaHora(String fecha, String hora, Clock reloj) {
        if (vacio(fecha) || vacio(hora)) {
            return "Seleccione la fecha y la hora de la cita.";
        }
        try {
            if(!fecha.trim().matches("\\d{4}-\\d{2}-\\d{2}") || !hora.trim().matches("\\d{2}:\\d{2}(:\\d{2})?")) {
                return "Ingrese una fecha y una hora válidas para la cita.";
            }
            LocalDate dia = LocalDate.parse(fecha.trim());
            LocalTime inicio = LocalTime.parse(hora.trim());
            LocalDateTime ahora = LocalDateTime.now(reloj.withZone(ZONA_CLINICA));
            if (LocalDateTime.of(dia, inicio).isBefore(ahora)) {
                return "No se puede reservar una cita en una fecha u hora pasada.";
            }
            if (dia.getDayOfWeek() == DayOfWeek.SUNDAY) {
                return "No hay atención los domingos. Seleccione otro día.";
            }
            return null;
        } catch (DateTimeParseException e) {
            return "Ingrese una fecha y una hora válidas para la cita.";
        }
    }

    /** Nombres y apellidos: solo letras (con tildes y ñ), espacios, apóstrofo y guion. */
    private static final String PATRON_NOMBRE = "^[A-Za-zÁÉÍÓÚÜÑáéíóúüñ][A-Za-zÁÉÍÓÚÜÑáéíóúüñ' -]{1,49}$";

    public static String validarNombreApellido(String nombre, String apellido) {
        if (vacio(nombre) || !nombre.trim().matches(PATRON_NOMBRE)) {
            return "El nombre solo admite letras (sin números ni símbolos).";
        }
        if (vacio(apellido) || !apellido.trim().matches(PATRON_NOMBRE)) {
            return "El apellido solo admite letras (sin números ni símbolos).";
        }
        return null;
    }

    /** DNI de 8 dígitos y celular de 9 dígitos que empieza con 9. */
    public static String validarDniTelefono(String dni, String telefono) {
        if (dni != null && !dni.trim().matches("\\d{8}")) {
            return "El DNI debe tener exactamente 8 dígitos numéricos.";
        }
        if (telefono == null || !telefono.trim().matches("9\\d{8}")) {
            return "El celular debe tener 9 dígitos y empezar con 9.";
        }
        return null;
    }

    /** Nombre del servicio: solo letras y espacios. */
    private static final String PATRON_NOMBRE_SERVICIO = "^[A-Za-zÁÉÍÓÚÜÑáéíóúüñ][A-Za-zÁÉÍÓÚÜÑáéíóúüñ ]{2,99}$";
    /** Lema, descripción y respuesta: letras, espacios y signos de puntuación, sin números. */
    private static final String PATRON_TEXTO_SERVICIO = "^[A-Za-zÁÉÍÓÚÜÑáéíóúüñ .,;:¡!¿?()\"'/\\r\\n-]+$";

    public static String validarServicio(String nombre, String lema, String descripcion, String respuesta) {
        if (vacio(nombre) || !nombre.trim().matches(PATRON_NOMBRE_SERVICIO)) {
            return "El nombre del servicio solo admite letras y espacios (sin números ni símbolos).";
        }
        String error = validarTextoServicio(lema, "El lema", 200);
        if (error == null) error = validarTextoServicio(descripcion, "La descripción", 600);
        if (error == null) error = validarTextoServicio(respuesta, "La respuesta del asistente", 600);
        return error;
    }

    private static String validarTextoServicio(String texto, String campo, int max) {
        if (vacio(texto) || texto.trim().length() < 3) {
            return campo + " es obligatorio (mínimo 3 letras).";
        }
        if (texto.trim().length() > max) {
            return campo + " admite como máximo " + max + " caracteres.";
        }
        if (!texto.trim().matches(PATRON_TEXTO_SERVICIO)) {
            return campo + " solo admite letras y signos de puntuación (sin números).";
        }
        return null;
    }

    private static boolean vacio(String s) {
        return s == null || s.trim().isEmpty();
    }
}
