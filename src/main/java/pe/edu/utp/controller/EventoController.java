package pe.edu.utp.controller;

import java.io.IOException;
import java.sql.SQLException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import pe.edu.utp.daoImpl.EventoDao;
import pe.edu.utp.utils.EventoService;
import pe.edu.utp.utils.FormToken;

/**
 * R-15: pantalla "Eventos" del administrador.
 * Lista con filtro por nivel, muestra la alerta pendiente y permite marcarla
 * como atendida con la acción tomada, el usuario y la fecha.
 */
@WebServlet("/EventoController")
public class EventoController extends HttpServlet {

    private final EventoDao eventoDao;

    public EventoController() {
        this(new EventoDao());
    }

    EventoController(EventoDao dao) {
        this.eventoDao = dao;
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            String nivel = request.getParameter("nivel");
            boolean pendientes = "1".equals(request.getParameter("pendientes"));
            request.setAttribute("eventos", eventoDao.listar(nivel, pendientes));
            request.setAttribute("nivelFiltro", nivel == null ? "" : nivel);
            request.setAttribute("soloPendientes", pendientes);
            request.setAttribute("formToken", FormToken.obtener(request));
            request.getRequestDispatcher("ADMPEventos.jsp").forward(request, response);
        } catch (SQLException e) {
            request.setAttribute("error", "No se pudo consultar el registro de eventos.");
            request.getRequestDispatcher("error.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        if (!FormToken.valido(request)) {
            response.sendRedirect("EventoController?error=token");
            return;
        }
        String accion = request.getParameter("accionTomada");
        int id;
        try {
            id = Integer.parseInt(request.getParameter("idEvento"));
        } catch (NumberFormatException e) {
            response.sendRedirect("EventoController?error=id");
            return;
        }
        if (accion == null || accion.trim().length() < 5) {
            response.sendRedirect("EventoController?error=accion");
            return;
        }
        Object idUsuario = request.getSession().getAttribute("idUsuario");
        try {
            boolean ok = eventoDao.atender(id, Integer.parseInt(String.valueOf(idUsuario)), accion.trim());
            if (ok) {
                EventoService.info("Operación", "Alerta " + id + " atendida por el administrador");
            }
            response.sendRedirect("EventoController?msg=" + (ok ? "atendido" : "sinCambios"));
        } catch (SQLException e) {
            response.sendRedirect("EventoController?error=bd");
        }
    }
}
