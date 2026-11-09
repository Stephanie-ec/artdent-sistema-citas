package pe.edu.utp.controller;

import java.lang.reflect.Proxy;
import java.util.HashMap;
import java.util.Map;
import javax.servlet.RequestDispatcher;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.junit.Test;
import static org.junit.Assert.*;

/** Comportamiento del servlet real con dobles HTTP; no inicia servidor ni BD. */
public class CitaFechaTest {
    @Test public void postPasadoDevuelve400AntesDeConsultarServiciosExternos() throws Exception {
        verificarRechazo("2000-01-03", "10:00", "pasada");
    }

    @Test public void postDomingoDevuelve400() throws Exception {
        verificarRechazo("2099-01-04", "10:00", "domingos");
    }

    @Test public void postFechaImposibleDevuelve400() throws Exception {
        verificarRechazo("2099-02-30", "10:00", "válidas");
    }

    @Test public void postHoraImposibleDevuelve400() throws Exception {
        verificarRechazo("2099-01-05", "25:00", "válidas");
    }

    private void verificarRechazo(String fecha, String hora, String mensaje) throws Exception {
        Map<String, String> parametros = new HashMap<>();
        parametros.put("dni", "12345678");
        parametros.put("nombre", "Ana");
        parametros.put("apellido", "Perez");
        parametros.put("telefono", "987654321");
        parametros.put("correo", "ana@example.test");
        parametros.put("fecha", fecha);
        parametros.put("hora", hora);
        Map<String, Object> atributos = new HashMap<>();
        int[] estado = {200};
        boolean[] reenviado = {false};
        RequestDispatcher dispatcher = new RequestDispatcher() {
            @Override public void forward(ServletRequest req, ServletResponse res) {
                reenviado[0] = true;
            }
            @Override public void include(ServletRequest req, ServletResponse res) {
                fail("No corresponde incluir una vista");
            }
        };
        HttpServletRequest req = (HttpServletRequest) Proxy.newProxyInstance(
                getClass().getClassLoader(), new Class<?>[]{HttpServletRequest.class}, (p, m, args) -> {
                    switch (m.getName()) {
                        case "setCharacterEncoding": return null;
                        case "getParameter": return parametros.get(args[0]);
                        case "setAttribute": atributos.put((String) args[0], args[1]); return null;
                        case "getRequestDispatcher": assertEquals("error.jsp", args[0]); return dispatcher;
                        default: throw new AssertionError("Acceso inesperado antes del rechazo: " + m.getName());
                    }
                });
        HttpServletResponse res = (HttpServletResponse) Proxy.newProxyInstance(
                getClass().getClassLoader(), new Class<?>[]{HttpServletResponse.class}, (p, m, args) -> {
                    switch (m.getName()) {
                        case "setCharacterEncoding": return null;
                        case "setStatus": estado[0] = (Integer) args[0]; return null;
                        default: throw new AssertionError("Respuesta inesperada: " + m.getName());
                    }
                });
        new CitaController().doPost(req, res);
        assertEquals(400, estado[0]);
        assertTrue("Debe mostrar la vista de error", reenviado[0]);
        assertTrue(String.valueOf(atributos.get("error")).contains(mensaje));
    }
}
