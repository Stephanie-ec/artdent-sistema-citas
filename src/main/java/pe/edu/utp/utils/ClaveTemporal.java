package pe.edu.utp.utils;

import java.security.SecureRandom;

/**
 * R-08: clave temporal generada por el administrador y reglas de la nueva clave.
 *
 * La clave temporal se muestra una sola vez al administrador y se guarda
 * únicamente como hash BCrypt. El alfabeto excluye caracteres confundibles
 * (0/O, 1/l/I) porque se dicta o se copia a mano.
 */
public final class ClaveTemporal {

    private static final String ALFABETO = "ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz23456789";
    private static final SecureRandom RANDOM = new SecureRandom();
    public static final int LONGITUD = 8;
    public static final int MINIMO = 6;
    public static final int MAXIMO = 30;

    private ClaveTemporal() {
    }

    public static String generar() {
        StringBuilder sb = new StringBuilder(LONGITUD);
        for (int i = 0; i < LONGITUD; i++) {
            sb.append(ALFABETO.charAt(RANDOM.nextInt(ALFABETO.length())));
        }
        return sb.toString();
    }

    /** Reglas de R-08: nueva clave de 6 a 30 caracteres y confirmación idéntica. */
    public static String validar(String nueva, String repetir) {
        if (nueva == null || nueva.trim().isEmpty()) {
            return "Ingrese la nueva contraseña.";
        }
        if (nueva.length() < MINIMO || nueva.length() > MAXIMO) {
            return "La contraseña debe tener entre " + MINIMO + " y " + MAXIMO + " caracteres.";
        }
        if (!nueva.equals(repetir)) {
            return "La confirmación no coincide con la nueva contraseña.";
        }
        return null;
    }
}
