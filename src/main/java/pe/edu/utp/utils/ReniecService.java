package pe.edu.utp.utils;

import java.io.InputStream;
import java.io.StringReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.text.Normalizer;
import javax.json.Json;
import javax.json.JsonObject;
import javax.json.JsonReader;
import javax.json.JsonValue;

/**
 * CR-06: consulta de identidad por DNI en RENIEC mediante un proveedor externo.
 *
 * La URL y el token se leen de config.properties (reniec.api.url y reniec.api.token),
 * por lo que el proveedor se puede cambiar sin tocar el código. Si no hay token
 * configurado, la consulta queda desactivada y el sistema sigue funcionando.
 */
public final class ReniecService {

    public enum Estado { ENCONTRADO, NO_EXISTE, NO_CONFIGURADO, ERROR }

    public static final class Resultado {
        public final Estado estado;
        public final String nombres;
        public final String apellidos;

        Resultado(Estado estado, String nombres, String apellidos) {
            this.estado = estado;
            this.nombres = nombres;
            this.apellidos = apellidos;
        }
    }

    private static final String URL_POR_DEFECTO = "https://api.decolecta.com/v1/reniec/dni?numero={dni}";

    private ReniecService() {
    }

    public static boolean configurado() {
        String token = ConfigLoader.getProperty("reniec.api.token");
        return token != null && !token.trim().isEmpty() && !token.contains("TU_TOKEN");
    }

    public static Resultado consultar(String dni) {
        if (!configurado()) {
            return new Resultado(Estado.NO_CONFIGURADO, null, null);
        }
        if (dni == null || !dni.matches("\\d{8}")) {
            return new Resultado(Estado.NO_EXISTE, null, null);
        }
        String plantilla = ConfigLoader.getProperty("reniec.api.url");
        if (plantilla == null || plantilla.trim().isEmpty()) {
            plantilla = URL_POR_DEFECTO;
        }
        HttpURLConnection con = null;
        try {
            con = (HttpURLConnection) new URL(plantilla.trim().replace("{dni}", dni)).openConnection();
            con.setRequestMethod("GET");
            con.setConnectTimeout(4000);
            con.setReadTimeout(5000);
            con.setRequestProperty("Accept", "application/json");
            con.setRequestProperty("Authorization", "Bearer " + ConfigLoader.getProperty("reniec.api.token").trim());

            int codigo = con.getResponseCode();
            if (codigo == 404 || codigo == 422 || codigo == 400) {
                return new Resultado(Estado.NO_EXISTE, null, null);
            }
            if (codigo != 200) {
                System.err.println("[RENIEC] Respuesta HTTP " + codigo);
                return new Resultado(Estado.ERROR, null, null);
            }
            String cuerpo;
            try (InputStream in = con.getInputStream()) {
                cuerpo = new String(leerTodo(in), StandardCharsets.UTF_8);
            }
            JsonObject json;
            try (JsonReader r = Json.createReader(new StringReader(cuerpo))) {
                json = r.readObject();
            }
            if (json.containsKey("data") && json.get("data").getValueType() == JsonValue.ValueType.OBJECT) {
                json = json.getJsonObject("data");
            }
            // Los proveedores usan nombres de campo distintos; se aceptan los más comunes
            String nombres = texto(json, "nombres", "first_name", "names");
            String paterno = texto(json, "apellidoPaterno", "apellido_paterno", "first_last_name");
            String materno = texto(json, "apellidoMaterno", "apellido_materno", "second_last_name");
            if (nombres.isEmpty() && paterno.isEmpty()) {
                return new Resultado(Estado.NO_EXISTE, null, null);
            }
            return new Resultado(Estado.ENCONTRADO, capitalizar(nombres), capitalizar((paterno + " " + materno).trim()));
        } catch (Exception e) {
            System.err.println("[RENIEC] No se pudo consultar: " + e.getMessage());
            return new Resultado(Estado.ERROR, null, null);
        } finally {
            if (con != null) {
                con.disconnect();
            }
        }
    }

    /**
     * Valida que el DNI exista y que el nombre y el primer apellido coincidan con RENIEC.
     * Devuelve null si es válido o si la consulta no está disponible (no bloquea la atención).
     */
    public static String validarIdentidad(String dni, String nombre, String apellido) {
        Resultado r = consultar(dni);
        if (r.estado == Estado.NO_EXISTE) {
            return "El DNI ingresado no figura en RENIEC. Verifique el número.";
        }
        if (r.estado != Estado.ENCONTRADO) {
            return null;
        }
        String primerNombre = primeraPalabra(nombre);
        String primerApellido = primeraPalabra(apellido);
        if (!normalizar(r.nombres).contains(primerNombre) || !normalizar(r.apellidos).startsWith(primerApellido)) {
            return "El nombre o el apellido no coinciden con el DNI registrado en RENIEC.";
        }
        return null;
    }

    private static String texto(JsonObject o, String... claves) {
        for (String k : claves) {
            if (o.containsKey(k) && o.get(k).getValueType() == JsonValue.ValueType.STRING) {
                return o.getString(k).trim();
            }
        }
        return "";
    }

    private static String primeraPalabra(String s) {
        String n = normalizar(s);
        int i = n.indexOf(' ');
        return i > 0 ? n.substring(0, i) : n;
    }

    private static String normalizar(String s) {
        if (s == null) {
            return "";
        }
        String sinTildes = Normalizer.normalize(s, Normalizer.Form.NFD).replaceAll("\\p{M}", "");
        return sinTildes.trim().toUpperCase().replaceAll("\\s+", " ");
    }

    private static String capitalizar(String s) {
        StringBuilder sb = new StringBuilder();
        for (String p : s.toLowerCase().split("\\s+")) {
            if (!p.isEmpty()) {
                sb.append(Character.toUpperCase(p.charAt(0))).append(p.substring(1)).append(' ');
            }
        }
        return sb.toString().trim();
    }

    private static byte[] leerTodo(InputStream in) throws java.io.IOException {
        java.io.ByteArrayOutputStream out = new java.io.ByteArrayOutputStream();
        byte[] buf = new byte[4096];
        int n;
        while ((n = in.read(buf)) != -1) {
            out.write(buf, 0, n);
        }
        return out.toByteArray();
    }
}
