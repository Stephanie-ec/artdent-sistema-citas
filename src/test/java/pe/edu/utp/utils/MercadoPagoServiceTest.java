package pe.edu.utp.utils;

import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import java.math.BigDecimal;
import org.junit.Test;
import static org.junit.Assert.*;

/** R-01: cuerpo de la preferencia y lectura del pago confirmado por la API. */
public class MercadoPagoServiceTest {

    @Test
    public void preferenciaUsaMontoDelServidorYReferenciaDeLaCita() {
        String json = MercadoPagoService.construirPreferencia(14, "Art Dent - Limpieza Dental", 40.0,
                "Rosa Elena Huaman Flores", "41236587", "rosa.huaman@gmail.com",
                "https://artdent.example/PagoEnLinea?accion=retorno",
                "https://artdent.example/PagoEnLinea?accion=notificacion");
        JsonObject objeto = JsonParser.parseString(json).getAsJsonObject();
        assertEquals("14", objeto.get("external_reference").getAsString());
        JsonObject item = objeto.getAsJsonArray("items").get(0).getAsJsonObject();
        assertEquals("PEN", item.get("currency_id").getAsString());
        assertEquals(40.0, item.get("unit_price").getAsDouble(), 0.001);
        assertEquals("https://artdent.example/PagoEnLinea?accion=retorno",
                objeto.getAsJsonObject("back_urls").get("success").getAsString());
        assertEquals("https://artdent.example/PagoEnLinea?accion=notificacion",
                objeto.get("notification_url").getAsString());
        JsonObject payer = objeto.getAsJsonObject("payer");
        assertEquals("DNI", payer.getAsJsonObject("identification").get("type").getAsString());
        assertEquals("41236587", payer.getAsJsonObject("identification").get("number").getAsString());
    }

    @Test
    public void sinHttpsNoSeEnvianRetornosQueMercadoPagoRechaza() {
        String json = MercadoPagoService.construirPreferencia(14, "Art Dent", 40.0, "Rosa", "41236587", null,
                "http://localhost:8080/ArtDent/PagoEnLinea?accion=retorno",
                "http://localhost:8080/ArtDent/PagoEnLinea?accion=notificacion");
        JsonObject objeto = JsonParser.parseString(json).getAsJsonObject();
        assertFalse(objeto.has("back_urls"));
        assertFalse(objeto.has("auto_return"));
        assertEquals(40.0, objeto.getAsJsonArray("items").get(0).getAsJsonObject()
                .get("unit_price").getAsDouble(), 0.001);
    }

    @Test
    public void pagoAprobadoSeReconoceConSuImporteYReferencia() {
        MercadoPagoService.Pago pago = MercadoPagoService.leerPago("{\"status\":\"approved\","
                + "\"status_detail\":\"accredited\",\"external_reference\":\"14\","
                + "\"transaction_amount\":40.0,\"payment_method_id\":\"master\"}");
        assertTrue(pago.aprobado());
        assertFalse(pago.pendiente());
        assertEquals("14", pago.referencia);
        assertEquals(0, new BigDecimal("40.0").compareTo(pago.importe));
    }

    @Test
    public void pagoPendienteNoSeConsideraAprobado() {
        MercadoPagoService.Pago pago = MercadoPagoService.leerPago("{\"status\":\"pending\","
                + "\"status_detail\":\"pending_contingency\",\"external_reference\":\"14\","
                + "\"transaction_amount\":\"40.00\"}");
        assertFalse(pago.aprobado());
        assertTrue(pago.pendiente());
        assertEquals(0, new BigDecimal("40.00").compareTo(pago.importe));
    }
}
