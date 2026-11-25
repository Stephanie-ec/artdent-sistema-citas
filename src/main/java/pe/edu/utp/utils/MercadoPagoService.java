package pe.edu.utp.utils;

import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.math.BigDecimal;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.LinkedHashMap;
import java.util.Map;

/**
 * R-01: pago en línea con Checkout Pro de Mercado Pago.
 *
 * El monto nunca se toma del navegador: la preferencia se construye con el
 * precio del servicio y, al volver del checkout, el importe pagado se compara
 * contra el costo vigente antes de registrar la boleta. El estado del pago se
 * consulta siempre a la API con el access token del servidor; el navegador solo
 * aporta el identificador del pago.
 */
public final class MercadoPagoService {

    public static final String API = "https://api.mercadopago.com";
    private static final int TIMEOUT_MS = 15000;

    private MercadoPagoService() {
    }

    /** Activo solo con credenciales presentes y la clave habilitada. */
    public static boolean habilitado() {
        return "true".equalsIgnoreCase(ConfigLoader.getProperty("mp.enabled")) && tokenNoVacio();
    }

    private static boolean tokenNoVacio() {
        String token = ConfigLoader.getProperty("mp.access.token");
        return token != null && token.trim().length() > 20 && !token.contains("tu_access_token");
    }

    /** URL base de la API; configurable solo para pruebas locales. */
    static String api() {
        String url = ConfigLoader.getProperty("mp.api.url");
        return url == null || url.trim().isEmpty() ? API : url.trim().replaceAll("/+$", "");
    }

    private static String token() {
        String token = ConfigLoader.getProperty("mp.access.token");
        if (token == null || token.trim().isEmpty()) {
            throw new IllegalStateException("Mercado Pago no está configurado");
        }
        return token.trim();
    }

    /** Cuerpo JSON de la preferencia (sin red, para poder probarlo). */
    public static String construirPreferencia(int idCita, String titulo, double monto,
            String nombreTitular, String dni, String correo, String urlRetorno, String urlNotificacion) {
        JsonObject item = new JsonObject();
        item.addProperty("id", "cita-" + idCita);
        item.addProperty("title", titulo);
        item.addProperty("description", "Reserva ART-RES-" + String.format(java.util.Locale.ROOT, "%05d", idCita));
        item.addProperty("quantity", 1);
        item.addProperty("currency_id", "PEN");
        item.addProperty("unit_price", monto);

        JsonArray items = new JsonArray();
        items.add(item);

        JsonObject preferencia = new JsonObject();
        preferencia.add("items", items);
        preferencia.addProperty("external_reference", String.valueOf(idCita));
        preferencia.addProperty("statement_descriptor", "ART DENT");
        preferencia.addProperty("binary_mode", false);
        // Mercado Pago solo acepta back_urls y auto_return con HTTPS; en local
        // (http://localhost) las ignora, así que se omiten para no recibir 400.
        if (urlRetorno != null && urlRetorno.startsWith("https://")) {
            JsonObject backUrls = new JsonObject();
            backUrls.addProperty("success", urlRetorno);
            backUrls.addProperty("pending", urlRetorno);
            backUrls.addProperty("failure", urlRetorno);
            preferencia.add("back_urls", backUrls);
            preferencia.addProperty("auto_return", "approved");
            preferencia.addProperty("notification_url", urlNotificacion);
        }

        if (nombreTitular != null && !nombreTitular.trim().isEmpty()) {
            String[] partes = nombreTitular.trim().split("\\s+", 2);
            JsonObject payer = new JsonObject();
            payer.addProperty("name", partes[0]);
            if (partes.length > 1) {
                payer.addProperty("surname", partes[1]);
            }
            if (dni != null && dni.matches("\\d{8}")) {
                JsonObject identificacion = new JsonObject();
                identificacion.addProperty("type", "DNI");
                identificacion.addProperty("number", dni);
                payer.add("identification", identificacion);
            }
            if (correo != null && correo.matches("[^@\\s]+@[^@\\s]+\\.[A-Za-z]{2,}")) {
                payer.addProperty("email", correo);
            }
            preferencia.add("payer", payer);
        }
        return preferencia.toString();
    }

    /** Crea la preferencia y devuelve id e init_point. */
    public static Map<String, String> crearPreferencia(String cuerpoJson) throws IOException {
        HttpURLConnection con = (HttpURLConnection) new URL(api() + "/checkout/preferences").openConnection();
        con.setRequestMethod("POST");
        con.setConnectTimeout(TIMEOUT_MS);
        con.setReadTimeout(TIMEOUT_MS);
        con.setDoOutput(true);
        con.setRequestProperty("Authorization", "Bearer " + token());
        con.setRequestProperty("Content-Type", "application/json");
        byte[] datos = cuerpoJson.getBytes(StandardCharsets.UTF_8);
        con.setFixedLengthStreamingMode(datos.length);
        try (OutputStream out = con.getOutputStream()) {
            out.write(datos);
        }
        int estado = con.getResponseCode();
        String respuesta = leer(estado >= 400 ? con.getErrorStream() : con.getInputStream());
        if (estado != 200 && estado != 201) {
            throw new IOException("Mercado Pago respondió " + estado + ": " + resumir(respuesta));
        }
        JsonObject objeto = JsonParser.parseString(respuesta).getAsJsonObject();
        Map<String, String> salida = new LinkedHashMap<>();
        salida.put("id", texto(objeto, "id"));
        salida.put("init_point", texto(objeto, "init_point"));
        if (salida.get("init_point").isEmpty()) {
            throw new IOException("Mercado Pago no devolvió init_point");
        }
        return salida;
    }

    /** Consulta autoritativa del pago por su identificador. */
    public static Pago consultarPago(String idPago) throws IOException {
        if (idPago == null || !idPago.matches("\\d{1,20}")) {
            throw new IOException("Identificador de pago no válido");
        }
        HttpURLConnection con = (HttpURLConnection) new URL(api() + "/v1/payments/" + idPago).openConnection();
        con.setRequestMethod("GET");
        con.setConnectTimeout(TIMEOUT_MS);
        con.setReadTimeout(TIMEOUT_MS);
        con.setRequestProperty("Authorization", "Bearer " + token());
        int estado = con.getResponseCode();
        String respuesta = leer(estado >= 400 ? con.getErrorStream() : con.getInputStream());
        if (estado == 404) {
            return null;
        }
        if (estado != 200) {
            throw new IOException("Mercado Pago respondió " + estado + ": " + resumir(respuesta));
        }
        return leerPago(respuesta);
    }

    /** Datos del pago que usa la aplicación (sin datos sensibles de la tarjeta). */
    public static Pago leerPago(String json) {
        JsonObject objeto = JsonParser.parseString(json).getAsJsonObject();
        String referencia = "";
        if (objeto.has("external_reference") && !objeto.get("external_reference").isJsonNull()) {
            referencia = objeto.get("external_reference").getAsString();
        }
        BigDecimal importe = null;
        if (objeto.has("transaction_amount") && !objeto.get("transaction_amount").isJsonNull()) {
            try {
                importe = objeto.get("transaction_amount").getAsBigDecimal();
            } catch (RuntimeException e) {
                importe = null;
            }
        }
        String metodo = "";
        if (objeto.has("payment_method_id") && !objeto.get("payment_method_id").isJsonNull()) {
            metodo = objeto.get("payment_method_id").getAsString();
        }
        return new Pago(texto(objeto, "status"), texto(objeto, "status_detail"), referencia, importe, metodo);
    }

    private static String texto(JsonObject objeto, String clave) {
        JsonElement valor = objeto.get(clave);
        return valor == null || valor.isJsonNull() ? "" : valor.getAsString();
    }

    private static String leer(InputStream in) throws IOException {
        if (in == null) {
            return "";
        }
        try (InputStream entrada = in; ByteArrayOutputStream salida = new ByteArrayOutputStream()) {
            byte[] buffer = new byte[4096];
            int leidos;
            while ((leidos = entrada.read(buffer)) != -1) {
                salida.write(buffer, 0, leidos);
                if (salida.size() > 65536) {
                    break;
                }
            }
            return new String(salida.toByteArray(), StandardCharsets.UTF_8);
        }
    }

    /** Recorta el mensaje del proveedor: nunca contiene el token, pero no hace falta completo. */
    private static String resumir(String cuerpo) {
        if (cuerpo == null) {
            return "";
        }
        String limpio = cuerpo.replaceAll("\\s+", " ").trim();
        return limpio.length() > 300 ? limpio.substring(0, 300) : limpio;
    }

    public static final class Pago {

        public final String estado;
        public final String detalle;
        public final String referencia;
        public final BigDecimal importe;
        public final String metodo;

        Pago(String estado, String detalle, String referencia, BigDecimal importe, String metodo) {
            this.estado = estado;
            this.detalle = detalle;
            this.referencia = referencia;
            this.importe = importe;
            this.metodo = metodo;
        }

        public boolean aprobado() {
            return "approved".equalsIgnoreCase(estado);
        }

        public boolean pendiente() {
            return "pending".equalsIgnoreCase(estado) || "in_process".equalsIgnoreCase(estado)
                    || "authorized".equalsIgnoreCase(estado);
        }
    }
}
