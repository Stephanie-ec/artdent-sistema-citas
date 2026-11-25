package pe.edu.utp.utils;

/** Versión desplegada, usada por el estado del servicio (R-14) y el arranque (R-15). */
public final class AppVersion {

    private AppVersion() {
    }

    public static String numero() {
        String v = AppVersion.class.getPackage() == null ? null
                : AppVersion.class.getPackage().getImplementationVersion();
        return v == null || v.trim().isEmpty() ? "1.0-SNAPSHOT" : v.trim();
    }

    public static String completa() {
        return "ArtDent " + numero();
    }
}
