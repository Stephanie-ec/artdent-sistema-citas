package pe.edu.utp.controller;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import pe.edu.utp.dao.PacienteDao;
import pe.edu.utp.daoImpl.PacienteDaoImpl;
import pe.edu.utp.entity.Paciente;

@WebServlet(name = "PacienteController", urlPatterns = {"/PacienteController"})
public class PacienteController extends HttpServlet {

    private PacienteDao pacienteDAO = new PacienteDaoImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        if (action == null) {
            action = request.getParameter("accion");
        }

        // Caso 1: Búsqueda rápida por AJAX (DNI)
        String dniParam = request.getParameter("dni");
        if (dniParam != null && (action == null || "complet".equals(action) || "buscarDni".equals(action))) {
            responderDniJson(request, response, dniParam.trim());
            return;
        }

        // Para acciones de gestión, validar sesión de Secretaria o Administrador
        HttpSession session = request.getSession();
        String rol = (session != null && session.getAttribute("TipoRol") != null) ? session.getAttribute("TipoRol").toString() : "";
        if (!rol.equalsIgnoreCase("Secretaria") && !rol.equalsIgnoreCase("Administrador") && !rol.equalsIgnoreCase("Odontologo")) {
            response.sendRedirect("iniciosesionerror.jsp");
            return;
        }

        if ("edit".equalsIgnoreCase(action)) {
            int id = Integer.parseInt(request.getParameter("id"));
            Paciente p = pacienteDAO.obtenerPacientePorId(id);
            request.setAttribute("pacienteEditar", p);
            request.setAttribute("listaPacientes", pacienteDAO.listarPacientes());
            request.getRequestDispatcher("PDCPacientes.jsp").forward(request, response);
            return;
        }

        if ("search".equalsIgnoreCase(action)) {
            String criterio = request.getParameter("criterio");
            List<Paciente> lista = (criterio != null && !criterio.trim().isEmpty()) 
                    ? pacienteDAO.buscarPacientes(criterio.trim()) 
                    : pacienteDAO.listarPacientes();
            request.setAttribute("listaPacientes", lista);
            request.setAttribute("criterioBusqueda", criterio);
            request.getRequestDispatcher("PDCPacientes.jsp").forward(request, response);
            return;
        }

        // Por defecto: listar todos los pacientes (RF05)
        request.setAttribute("listaPacientes", pacienteDAO.listarPacientes());
        request.getRequestDispatcher("PDCPacientes.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession();
        String rol = (session != null && session.getAttribute("TipoRol") != null) ? session.getAttribute("TipoRol").toString() : "";
        // Solo la Secretaria (o Administrador) puede modificar datos de pacientes (RF05)
        if (!rol.equalsIgnoreCase("Secretaria") && !rol.equalsIgnoreCase("Administrador")) {
            response.sendRedirect("iniciosesionerror.jsp");
            return;
        }

        String action = request.getParameter("action");
        if (action == null) {
            action = request.getParameter("accion");
        }

        if ("update".equalsIgnoreCase(action)) {
            int idPaciente = Integer.parseInt(request.getParameter("idPaciente"));
            String nombre = request.getParameter("nombre");
            String apellido = request.getParameter("apellido");
            String telefonoStr = request.getParameter("telefono");
            String correo = request.getParameter("correo");
            int telefono = (telefonoStr != null && !telefonoStr.trim().isEmpty()) ? Integer.parseInt(telefonoStr.trim()) : 0;

            Paciente p = new Paciente(idPaciente, nombre, apellido, 0, telefono, correo);
            boolean ok = pacienteDAO.actualizarPaciente(p);
            if (ok) {
                response.sendRedirect("PacienteController?action=list&msg=updateOk");
            } else {
                response.sendRedirect("PacienteController?action=list&msg=error");
            }
            return;
        }

        if ("create".equalsIgnoreCase(action)) {
            String dniStr = request.getParameter("dni");
            int dni = (dniStr != null && !dniStr.trim().isEmpty()) ? Integer.parseInt(dniStr.trim()) : 0;
            String nombre = request.getParameter("nombre");
            String apellido = request.getParameter("apellido");
            String telefonoStr = request.getParameter("telefono");
            int telefono = (telefonoStr != null && !telefonoStr.trim().isEmpty()) ? Integer.parseInt(telefonoStr.trim()) : 0;
            String correo = request.getParameter("correo");

            Paciente p = new Paciente(0, nombre, apellido, dni, telefono, correo);
            boolean ok = pacienteDAO.registrarPaciente(p);
            if (ok) {
                response.sendRedirect("PacienteController?action=list&msg=createOk");
            } else {
                response.sendRedirect("PacienteController?action=list&msg=error");
            }
            return;
        }

        response.sendRedirect("PacienteController?action=list");
    }

    private void responderDniJson(HttpServletRequest request, HttpServletResponse response, String dni) throws IOException {
        response.setContentType("application/json;charset=UTF-8");
        Paciente paciente = pacienteDAO.obtenerPacientePorDNI(dni);
        try (PrintWriter out = response.getWriter()) {
            if (paciente != null) {
                out.print(String.format(
                    "{\"existe\":true,\"idPaciente\":%d,\"nombre\":\"%s\",\"apellido\":\"%s\",\"telefono\":%d,\"correo\":\"%s\"}",
                    paciente.getIdPaciente(),
                    escaparJson(paciente.getNombre()),
                    escaparJson(paciente.getApellido()),
                    paciente.getTelefono(),
                    escaparJson(paciente.getCorreo())
                ));
            } else {
                out.print("{\"existe\":false}");
            }
            out.flush();
        }
    }

    private String escaparJson(String s) {
        if (s == null) return "";
        return s.replace("\"", "\\\"").replace("\n", " ").replace("\r", "");
    }
}
