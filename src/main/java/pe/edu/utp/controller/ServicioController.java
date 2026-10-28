package pe.edu.utp.controller;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;
import java.util.List;
import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import pe.edu.utp.dao.ServicioDao;
import pe.edu.utp.dao.UsuarioDao;
import pe.edu.utp.daoImpl.ServicioDaoImpl;
import pe.edu.utp.daoImpl.UsuarioDaoImpl;
import pe.edu.utp.entity.Servicio;
import pe.edu.utp.entity.Usuario;
import java.time.LocalDate;
import java.time.LocalTime;
import java.math.BigDecimal;

@WebServlet(name = "ServicioController", urlPatterns = {"/ServicioController"})
public class ServicioController extends HttpServlet {

    private ServicioDao servicioDao;
    private UsuarioDao usuarioDao;

    @Override
    public void init() {
        servicioDao = new ServicioDaoImpl();
        usuarioDao = new UsuarioDaoImpl();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        if (action == null) {
            action = "list";
        }

        try {
            switch (action) {
                case "new":
                    showNewForm(request, response);
                    break;
                case "insert":
                    insertServicio(request, response);
                    break;
                case "delete":
                    deleteServicio(request, response);
                    break;
                case "reactivar":
                    reactivarServicio(request, response);
                    break;
                case "edit":
                    showEditForm(request, response);
                    break;
                case "update":
                    updateServicio(request, response);
                    break;
                case "list":
                    listServicio(request, response);
                    break;
                case "view":
                    viewServicio(request, response);
                    break;
                case "formreserva":
                    showReservaForm(request, response);
                    break;
                case "cargarDoctores":
                    cargarDoctores(request, response);
                    break;
                case "listar":
                    listServiciop(request, response);
                    break;
                case "cargar":
                    cargarServicio(request, response);
                break;
                case "formreservaa":
                    formreserva(request, response); 
                    break;
                default:
                    listServiciop(request, response);
                    break;
            }
        } catch (SQLException ex) {
            throw new ServletException(ex);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
    private void formreserva(HttpServletRequest request, HttpServletResponse response) throws SQLException, ServletException, IOException {
        List<Servicio> servicios = servicioDao.listarServicios();

        request.setAttribute("servicios", servicios);
        request.getRequestDispatcher("reservapersonal.jsp").forward(request, response);
    }
private void cargarServicio(HttpServletRequest request, HttpServletResponse response) throws SQLException, ServletException, IOException {
        int idServicio = Integer.parseInt(request.getParameter("id"));
        Servicio servicio = servicioDao.ListService(idServicio);

        if (servicio != null) {
            request.setAttribute("servicio", servicio);  // Enviamos el servicio específico a la JSP
            request.getRequestDispatcher("DetalleServicio.jsp").forward(request, response);
        } else {
            request.setAttribute("error", "Servicio no encontrado");
            request.getRequestDispatcher("error.jsp").forward(request, response);
        }
    }
    private void listServiciop(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        List<Servicio> listServicio = servicioDao.listarServicios();
        request.setAttribute("listServicio", listServicio);
        System.out.println("lista serv: "+listServicio);
        RequestDispatcher dispatcher = request.getRequestDispatcher("servicios.jsp");
        dispatcher.forward(request, response);
    }
    
    private void listServicio(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, IOException, ServletException {
        List<Servicio> listServicio = servicioDao.listarTodosLosServicios();
        request.setAttribute("listServicio", listServicio);
        RequestDispatcher dispatcher = request.getRequestDispatcher("ADMPServicios.jsp");
        dispatcher.forward(request, response);
    }

    private void showNewForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        RequestDispatcher dispatcher = request.getRequestDispatcher("ADMPServicios.jsp");
        dispatcher.forward(request, response);
    }

    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, ServletException, IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        Servicio existingServicio = servicioDao.obtenerServicioPorId(id);
        RequestDispatcher dispatcher = request.getRequestDispatcher("ADMPeditarServicios.jsp");
        request.setAttribute("servicio", existingServicio);
        dispatcher.forward(request, response);
    }

    private void insertServicio(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, IOException {
        String tipoServicio = request.getParameter("tipoServicio");
        String lema = request.getParameter("lema");
        String descripcion = request.getParameter("descripcion");
        String respuesta = request.getParameter("respuesta");
        BigDecimal costo = new BigDecimal(request.getParameter("costo"));
        String img = request.getParameter("img");

        Servicio newServicio = new Servicio(0, tipoServicio, lema, descripcion, respuesta, costo, img);
        servicioDao.insertarServicio(newServicio);
        response.sendRedirect("ServicioController?action=list");
    }

    private void updateServicio(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        String tipoServicio = request.getParameter("tipoServicio");
        String lema = request.getParameter("lema");
        String descripcion = request.getParameter("descripcion");
        String respuesta = request.getParameter("respuesta");
        BigDecimal costo = new BigDecimal(request.getParameter("costo"));
        String img = request.getParameter("img");

        Servicio servicio = new Servicio(id, tipoServicio, lema, descripcion, respuesta, costo, img);
        servicioDao.actualizarServicio(servicio);
        response.sendRedirect("ServicioController?action=list");
    }

    private void deleteServicio(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        servicioDao.eliminarServicio(id);
        response.sendRedirect("ServicioController?action=list");
    }

    private void reactivarServicio(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        servicioDao.reactivarServicio(id);
        response.sendRedirect("ServicioController?action=list");
    }

    private void viewServicio(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, ServletException, IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        Servicio servicio = servicioDao.obtenerServicioPorId(id);
        request.setAttribute("servicio", servicio);
        RequestDispatcher dispatcher = request.getRequestDispatcher("DetalleServicio.jsp");
        dispatcher.forward(request, response);
    }

    private void showReservaForm(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, ServletException, IOException {
        List<Servicio> servicios = servicioDao.listarServicios();
        request.setAttribute("servicios", servicios);
        request.getRequestDispatcher("reservapersonal.jsp").forward(request, response);
    }

    private void cargarDoctores(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, IOException {
        int idServicio = Integer.parseInt(request.getParameter("motivo"));
        String hora = request.getParameter("hora");
        String fecha = request.getParameter("fecha");
        
        LocalDate fechaConv = LocalDate.parse(fecha);
        LocalTime horaObj = LocalTime.parse(hora);

        List<Usuario> medicos = usuarioDao.obtenerMedicosPorServicioYDisponibilidad(idServicio, fechaConv, horaObj);

        response.setContentType("text/html");
        response.setCharacterEncoding("UTF-8");

        try (PrintWriter out = response.getWriter()) {
            for (Usuario e : medicos) {
                out.println("<option value=\"" + e.getIdUsuario() + "\">" + e.getNombre() + " " + e.getApellido() + "</option>");
            }
        }
    }
}