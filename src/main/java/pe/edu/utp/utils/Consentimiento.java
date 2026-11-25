package pe.edu.utp.utils;

/**
 * R-06 / Ley 29733: consentimiento informado para el tratamiento de datos personales.
 *
 * La casilla del formulario es obligatoria en el navegador, pero la decisión se
 * vuelve a validar en el servidor: un POST manual sin consentimiento no registra
 * ningún dato personal ni ninguna cita.
 */
public final class Consentimiento {

    public static final String MENSAJE_OBLIGATORIO =
            "Debe aceptar el tratamiento de sus datos personales según la Política de privacidad para continuar.";

    private Consentimiento() {
    }

    /** Valores que un formulario HTML envía para una casilla marcada. */
    public static boolean aceptado(String valor) {
        if (valor == null) {
            return false;
        }
        String v = valor.trim();
        return v.equalsIgnoreCase("on") || v.equalsIgnoreCase("true") || v.equals("1")
                || v.equalsIgnoreCase("si") || v.equalsIgnoreCase("sí");
    }
}
