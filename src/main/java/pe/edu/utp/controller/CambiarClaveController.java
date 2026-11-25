package pe.edu.utp.controller;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import pe.edu.utp.dao.UsuarioDao;
import pe.edu.utp.daoImpl.UsuarioDaoImpl;
import pe.edu.utp.entity.Usuario;
import pe.edu.utp.utils.ClaveTemporal;
import pe.edu.utp.utils.FormToken;
import pe.edu.utp.utils.SecurityUtils;

/**
 * R-08: el usuario cambia su propia contraseña pidiendo la actual.
 * También es la pantalla obligatoria cuando el administrador restableció la
 * clave y dejó una contraseña temporal.
 */
@WebServlet("/CambiarClaveController")
public class CambiarClaveController extends HttpServlet {

    private final UsuarioDao usuarioDao;

    public CambiarClaveController() {
        this(new UsuarioDaoImpl());
    }

    CambiarClaveController(UsuarioDao dao) {
        this.usuarioDao = dao;
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (request.getSession(false) == null || request.getSession(false).getAttribute("idUsuario") == null) {
            response.sendRedirect("iniciosesion.jsp");
            return;
        }
        request.setAttribute("formToken", FormToken.obtener(request));
        request.getRequestDispatcher("cambiarClave.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession sesion = request.getSession(false);
        if (sesion == null || sesion.getAttribute("idUsuario") == null) {
            response.sendRedirect("iniciosesion.jsp");
            return;
        }
        request.setAttribute("formToken", FormToken.obtener(request));
        if (!FormToken.valido(request)) {
            request.setAttribute("error", "La solicitud expiró. Recargue la página e intente nuevamente.");
            request.getRequestDispatcher("cambiarClave.jsp").forward(request, response);
            return;
        }

        String actual = request.getParameter("actual");
        String nueva = request.getParameter("nueva");
        String repetir = request.getParameter("repetir");

        int idUsuario = Integer.parseInt(String.valueOf(sesion.getAttribute("idUsuario")));
        Usuario usuario = usuarioDao.obtenerUsuarioPorId(idUsuario);
        if (usuario == null) {
            response.sendRedirect("CerrarSesionController");
            return;
        }
        if (!SecurityUtils.verifyPassword(actual, usuario.getClave())) {
            request.setAttribute("error", "La contraseña actual no es correcta.");
            request.getRequestDispatcher("cambiarClave.jsp").forward(request, response);
            return;
        }
        String error = ClaveTemporal.validar(nueva, repetir);
        if (error == null && actual != null && actual.equals(nueva)) {
            error = "La nueva contraseña debe ser diferente a la actual.";
        }
        if (error != null) {
            request.setAttribute("error", error);
            request.getRequestDispatcher("cambiarClave.jsp").forward(request, response);
            return;
        }
        if (!usuarioDao.cambiarClave(idUsuario, SecurityUtils.hashPassword(nueva))) {
            request.setAttribute("error", "No se pudo guardar la nueva contraseña. Intente nuevamente.");
            request.getRequestDispatcher("cambiarClave.jsp").forward(request, response);
            return;
        }

        sesion.setAttribute("DebeCambiarClave", false);
        String rol = String.valueOf(sesion.getAttribute("TipoRol"));
        if ("Administrador".equalsIgnoreCase(rol)) {
            response.sendRedirect("DashboardController?action=dashboard&msg=claveActualizadaOk");
        } else if ("Secretaria".equalsIgnoreCase(rol)) {
            response.sendRedirect("ReservaController?accion=listar&msg=claveActualizadaOk");
        } else {
            response.sendRedirect("ReservaController?accion=listarReservasPorDia&msg=claveActualizadaOk");
        }
    }
}
