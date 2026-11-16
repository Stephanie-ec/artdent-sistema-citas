package pe.edu.utp.controller;

import java.io.IOException;
import javax.json.Json;
import javax.json.JsonObjectBuilder;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import pe.edu.utp.daoImpl.PacienteDaoImpl;
import pe.edu.utp.entity.Paciente;
import pe.edu.utp.utils.ReniecService;

/**
 * Botón de búsqueda (lupa) junto al DNI en los formularios de reserva.
 *
 * - Personal autenticado: busca primero al paciente registrado y, si no existe, consulta RENIEC.
 * - Paciente sin sesión: solo consulta RENIEC (nombres y apellidos). Nunca se devuelven
 *   teléfono ni correo de pacientes registrados (Ley N.° 29733).
 * Se limita a 15 consultas por sesión para evitar el uso abusivo.
 */
@WebServlet(name = "ConsultaDniController", urlPatterns = {"/ConsultaDniController"})
public class ConsultaDniController extends HttpServlet {

    private static final int LIMITE_POR_SESION = 15;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json;charset=UTF-8");
        String dni = request.getParameter("dni") != null ? request.getParameter("dni").trim() : "";
        JsonObjectBuilder json = Json.createObjectBuilder();

        if (!dni.matches("\\d{8}")) {
            response.getWriter().write(json.add("estado", "INVALIDO").add("mensaje", "Ingrese un DNI de 8 dígitos.").build().toString());
            return;
        }

        HttpSession sesion = request.getSession();

        // Verificación temprana: ¿el DNI ya pertenece a otro paciente? (no revela datos a visitantes)
        if ("1".equals(request.getParameter("verificar"))) {
            response.getWriter().write(verificar(dni, request.getParameter("nombre"), request.getParameter("apellido"),
                    sesion.getAttribute("TipoRol") != null).toString());
            return;
        }

        Integer usadas = (Integer) sesion.getAttribute("consultasDni");
        usadas = usadas == null ? 1 : usadas + 1;
        sesion.setAttribute("consultasDni", usadas);
        if (usadas > LIMITE_POR_SESION) {
            response.getWriter().write(json.add("estado", "LIMITE").add("mensaje", "Se alcanzó el límite de consultas. Complete los datos manualmente.").build().toString());
            return;
        }

        boolean esPersonal = sesion.getAttribute("TipoRol") != null;
        if (esPersonal) {
            Paciente p = new PacienteDaoImpl().obtenerPacientePorDNI(dni);
            if (p != null && p.getIdPaciente() > 0) {
                json.add("estado", "PACIENTE").add("mensaje", "Paciente registrado encontrado.")
                        .add("nombre", n(p.getNombre())).add("apellido", n(p.getApellido()))
                        .add("telefono", p.getTelefono() > 0 ? String.valueOf(p.getTelefono()) : "")
                        .add("correo", n(p.getCorreo()));
                response.getWriter().write(json.build().toString());
                return;
            }
        }

        ReniecService.Resultado r = ReniecService.consultar(dni);
        switch (r.estado) {
            case ENCONTRADO:
                json.add("estado", "RENIEC").add("mensaje", "DNI verificado en RENIEC.")
                        .add("nombre", r.nombres).add("apellido", r.apellidos);
                break;
            case NO_EXISTE:
                json.add("estado", "NO_EXISTE").add("mensaje", "El DNI no figura en RENIEC. Verifique el número.");
                break;
            case NO_CONFIGURADO:
                json.add("estado", "NO_CONFIGURADO").add("mensaje", esPersonal
                        ? "Paciente nuevo. La verificación con RENIEC no está activada; complete los datos."
                        : "Complete sus datos para continuar.");
                break;
            default:
                json.add("estado", "ERROR").add("mensaje", "No se pudo verificar en RENIEC en este momento. Complete los datos manualmente.");
        }
        response.getWriter().write(json.build().toString());
    }

    /**
     * NUEVO: el DNI no está registrado. COINCIDE: registrado con esos mismos nombres.
     * NO_COINCIDE: registrado a nombre de otra persona (el personal ve el nombre; el visitante no).
     */
    static javax.json.JsonObject verificar(String dni, String nombre, String apellido, boolean esPersonal) {
        JsonObjectBuilder json = Json.createObjectBuilder();
        Paciente p = new PacienteDaoImpl().obtenerPacientePorDNI(dni);
        if (p == null || p.getIdPaciente() <= 0) {
            return json.add("estado", "NUEVO").add("mensaje", "").build();
        }
        boolean coincide = normalizar(p.getNombre()).equals(normalizar(nombre))
                && normalizar(p.getApellido()).equals(normalizar(apellido));
        if (coincide) {
            return json.add("estado", "COINCIDE").add("mensaje", "DNI ya registrado en la clínica; se usará su ficha.").build();
        }
        String msg = esPersonal
                ? "Este DNI ya está registrado a nombre de " + n(p.getNombre()) + " " + n(p.getApellido()) + ". Use la lupa para cargar sus datos o corrija el DNI."
                : "Este DNI ya está registrado con otros nombres. Verifique su DNI; si es suyo, escriba sus nombres tal como están en su documento.";
        return json.add("estado", "NO_COINCIDE").add("mensaje", msg).build();
    }

    private static String normalizar(String s) {
        if (s == null) return "";
        String t = java.text.Normalizer.normalize(s.trim().toLowerCase(java.util.Locale.ROOT), java.text.Normalizer.Form.NFD);
        return t.replaceAll("\\p{M}", "").replaceAll("\\s+", " ");
    }

    private static String n(String s) {
        return s == null ? "" : s;
    }
}
