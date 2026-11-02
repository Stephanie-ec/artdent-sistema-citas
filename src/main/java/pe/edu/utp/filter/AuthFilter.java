package pe.edu.utp.filter;

import java.io.IOException;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;
import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 * CR-04 / D-10: control de acceso centralizado por sesión y rol (RNF03, RNF09).
 *
 * Cada solicitud directa del navegador pasa por este filtro antes de llegar a un
 * Servlet o JSP. Las páginas públicas (sitio, reserva web, pago en línea, boleta,
 * asistente e inicio de sesión) quedan libres; el resto exige sesión y el rol
 * indicado en la matriz de roles y permisos del documento.
 */
@WebFilter(filterName = "AuthFilter", urlPatterns = {"/*"})
public class AuthFilter implements Filter {

    private static final String ADMIN = "Administrador";
    private static final String SECRETARIA = "Secretaria";
    private static final String ODONTOLOGO = "Odontologo";

    /** Páginas JSP del sitio público. */
    private static final Set<String> PAGINAS_PUBLICAS = new HashSet<>(Arrays.asList(
            "", "/", "/index.jsp", "/servicios.jsp", "/DetalleServicio.jsp", "/nosotros.jsp",
            "/faq.jsp", "/reserva.jsp", "/reservapersonal.jsp", "/formularioreserva.jsp",
            "/citareservada.jsp", "/boleta.jsp", "/iniciosesion.jsp", "/iniciosesionerror.jsp",
            "/error.jsp", "/header.jsp", "/footer.jsp"));

    /** Servlets públicos (los que validan el rol internamente también se listan aquí). */
    private static final Set<String> SERVLETS_PUBLICOS = new HashSet<>(Arrays.asList(
            "/InicioSesionController", "/CerrarSesionController", "/api/chatbot", "/CitaController"));

    /** Acciones públicas de ServicioController (catálogo y formulario de reserva). */
    private static final Set<String> ACCIONES_SERVICIO_PUBLICAS = new HashSet<>(Arrays.asList(
            "listar", "cargar", "formreservaa", "formreserva", "cargarDoctores", "view"));

    @Override
    public void init(FilterConfig filterConfig) {
    }

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest request = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) res;

        String ruta = request.getServletPath();
        if (ruta == null) {
            ruta = "";
        }

        if (esPublica(request, ruta)) {
            chain.doFilter(req, res);
            return;
        }

        HttpSession sesion = request.getSession(false);
        String rol = (sesion != null && sesion.getAttribute("TipoRol") != null)
                ? sesion.getAttribute("TipoRol").toString() : null;

        // Sin sesión: se pide iniciar sesión (RNF09)
        if (rol == null) {
            response.sendRedirect(request.getContextPath() + "/iniciosesion.jsp");
            return;
        }

        // Con sesión pero sin permiso para esta función: acceso denegado (403)
        if (!rolAutorizado(request, ruta, rol)) {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            request.setAttribute("error", "Acceso denegado: su rol (" + rol + ") no tiene permiso para esta función.");
            request.getRequestDispatcher("/error.jsp").forward(request, response);
            return;
        }

        // Páginas restringidas: no se guardan en caché, así "Atrás" no las muestra tras cerrar sesión
        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0);

        chain.doFilter(req, res);
    }

    private boolean esPublica(HttpServletRequest request, String ruta) {
        if (ruta.startsWith("/css/") || ruta.startsWith("/img/") || ruta.startsWith("/js/")
                || ruta.startsWith("/favicon")) {
            return true;
        }
        if (PAGINAS_PUBLICAS.contains(ruta) || SERVLETS_PUBLICOS.contains(ruta)) {
            return true;
        }
        String accion = accion(request);
        switch (ruta) {
            case "/ServicioController":
                return accion != null && ACCIONES_SERVICIO_PUBLICAS.contains(accion);
            case "/PagoController":
                // Ver boleta y pagar en línea son del paciente; el pago en efectivo es de la Secretaria
                return "GET".equalsIgnoreCase(request.getMethod()) || "pagarEnLinea".equals(accion);
            case "/ReservaController":
                // POST = registro de reserva "En espera"; los listados (GET) son del personal
                return "POST".equalsIgnoreCase(request.getMethod());
            default:
                return false;
        }
    }

    /** Matriz de roles y permisos (APF2, 5.2). */
    private boolean rolAutorizado(HttpServletRequest request, String ruta, String rol) {
        boolean admin = ADMIN.equalsIgnoreCase(rol);
        boolean secretaria = SECRETARIA.equalsIgnoreCase(rol);
        boolean odontologo = ODONTOLOGO.equalsIgnoreCase(rol);

        // Funciones exclusivas del Administrador (incluye reportes, RF08)
        if (ruta.startsWith("/ADMP") || ruta.equals("/UsuarioController") || ruta.equals("/DashboardController")
                || ruta.equals("/ServicioController") || ruta.equals("/MenuController")
                || ruta.startsWith("/resources") || ruta.equals("/ReporteController")
                || ruta.equals("/PDCReportes.jsp")) {
            return admin;
        }
        // Registro de pago en efectivo: Secretaria (o Administrador)
        if (ruta.equals("/PagoController")) {
            return secretaria || admin;
        }
        // Resto del panel clínico (PDC*, historial, reportes, reprogramación, agenda):
        // cualquier rol del personal; cada controlador aplica sus reglas finas
        return admin || secretaria || odontologo;
    }

    private String accion(HttpServletRequest request) {
        String accion = request.getParameter("action");
        if (accion == null) {
            accion = request.getParameter("accion");
        }
        return accion;
    }

    @Override
    public void destroy() {
    }
}
