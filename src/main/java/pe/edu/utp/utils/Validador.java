package pe.edu.utp.utils;

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
        if (dni == null || !dni.trim().matches("\\d{8}")) {
            return "El DNI debe tener exactamente 8 dígitos numéricos.";
        }
        if (telefono == null || !telefono.trim().matches("9\\d{8}")) {
            return "El celular debe tener 9 dígitos y empezar con 9.";
        }
        if (correo == null || !correo.trim().matches("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$")) {
            return "Ingrese un correo electrónico válido.";
        }
        if (vacio(fecha) || vacio(hora)) {
            return "Seleccione la fecha y la hora de la cita.";
        }
        return null;
    }

    private static boolean vacio(String s) {
        return s == null || s.trim().isEmpty();
    }
}
