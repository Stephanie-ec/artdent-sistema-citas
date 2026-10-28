/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package pe.edu.utp.controller;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import pe.edu.utp.daoImpl.CitaDaoImpl;
import pe.edu.utp.daoImpl.ServicioDaoImpl;
import pe.edu.utp.daoImpl.UsuarioDaoImpl;
import pe.edu.utp.entity.Cita;
import pe.edu.utp.entity.Paciente;
import pe.edu.utp.entity.Servicio;
import pe.edu.utp.entity.Usuario;
import pe.edu.utp.entity.Venta;
import pe.edu.utp.utils.EmailService;

/**
 *
 * @author Andrea
 */
@WebServlet(name = "CitaController", urlPatterns = {"/CitaController"})
public class CitaController extends HttpServlet {

    private CitaDaoImpl citaDao = new CitaDaoImpl();

    /**
     * Processes requests for both HTTP <code>GET</code> and <code>POST</code>
     * methods.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            /* TODO output your page here. You may use following sample code. */
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Servlet CitaController</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet CitaController at " + request.getContextPath() + "</h1>");
            out.println("</body>");
            out.println("</html>");
        }
    }

    // <editor-fold defaultstate="collapsed" desc="HttpServlet methods. Click on the + sign on the left to edit the code.">
    /**
     * Handles the HTTP <code>GET</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String accion = request.getParameter("accion");
        if (accion == null) {
            accion = request.getParameter("action");
        }

        if ("formPresencial".equalsIgnoreCase(accion)) {
            // Verificar rol secretaria o administrador
            Object rolObj = request.getSession().getAttribute("TipoRol");
            if (rolObj == null) {
                response.sendRedirect("iniciosesionerror.jsp");
                return;
            }
            String tipoRol = rolObj.toString();
            if (!tipoRol.equalsIgnoreCase("Secretaria") && !tipoRol.equalsIgnoreCase("Administrador")) {
                response.sendRedirect("iniciosesionerror.jsp");
                return;
            }

            request.setAttribute("servicios", new ServicioDaoImpl().listarServicios());
            request.setAttribute("odontologos", new UsuarioDaoImpl().obtenerMedicosDisponibles());
            request.getRequestDispatcher("reservapresencial.jsp").forward(request, response);
            return;
        }

        processRequest(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        // Obtener los datos del formulario
        String dniStr = request.getParameter("dni");
        int dni = (dniStr != null && !dniStr.trim().isEmpty()) ? Integer.parseInt(dniStr.trim()) : 0;
        String nombre = request.getParameter("nombre");
        String apellido = request.getParameter("apellido");
        String correo = request.getParameter("correo");
        if (correo == null || correo.trim().isEmpty()) {
            correo = request.getParameter("email");
        }
        String telefonoStr = request.getParameter("telefono");
        int telefono = (telefonoStr != null && !telefonoStr.trim().isEmpty()) ? Integer.parseInt(telefonoStr.trim()) : 0;
        
        double precio_servicio = 0.0;
        String precioStr = request.getParameter("precio_consulta");
        if (precioStr != null && !precioStr.trim().isEmpty()) {
            try {
                precio_servicio = Double.parseDouble(precioStr.trim());
            } catch (NumberFormatException e) {
                precio_servicio = 0.0;
            }
        }

        int idServicio = 1;
        String idServicioStr = request.getParameter("idServicio");
        if (idServicioStr != null && !idServicioStr.trim().isEmpty()) {
            try {
                idServicio = Integer.parseInt(idServicioStr.trim());
            } catch (NumberFormatException e) {
                idServicio = 1;
            }
        }

        String fecha = request.getParameter("fecha");
        String hora = request.getParameter("hora");
        String descripcion = request.getParameter("descripcion");
        if (descripcion == null || descripcion.trim().isEmpty()) {
            descripcion = "Reserva Web - En espera";
        }

        // Medico asignado dinámicamente desde el formulario
        int idOdontologo = 4; // Odontólogo por defecto
        String medicoStr = request.getParameter("medico");
        if (medicoStr != null && !medicoStr.trim().isEmpty()) {
            try {
                idOdontologo = Integer.parseInt(medicoStr.trim());
            } catch (NumberFormatException e) {
                idOdontologo = 4;
            }
        }

        int x = citaDao.verificarExistencia(dni);
        Paciente paciente = new Paciente(x, nombre, apellido, dni, telefono, correo);

        String accion = request.getParameter("accion");
        String origen = request.getParameter("origen");
        boolean esPresencial = "registrarPresencial".equalsIgnoreCase(accion) || "Presencial".equalsIgnoreCase(origen);

        if (esPresencial) {
            // RF03: Cita presencial registrada por Secretaría / Administrador
            Object rolObj = request.getSession().getAttribute("TipoRol");
            if (rolObj == null) {
                response.sendRedirect("iniciosesionerror.jsp");
                return;
            }
            String tipoRol = rolObj.toString();
            if (!tipoRol.equalsIgnoreCase("Secretaria") && !tipoRol.equalsIgnoreCase("Administrador")) {
                response.sendRedirect("iniciosesionerror.jsp");
                return;
            }

            int idSecretaria = 0;
            Object idUserObj = request.getSession().getAttribute("idUsuario");
            if (idUserObj instanceof Integer) {
                idSecretaria = (Integer) idUserObj;
            } else if (idUserObj != null) {
                try {
                    idSecretaria = Integer.parseInt(idUserObj.toString());
                } catch (NumberFormatException ignored) {}
            }

            // Cita con estado 3 ('Confirmado') y origen Presencial
            Cita cita = new Cita(0, fecha, hora, idServicio, x, 3, idOdontologo);
            int idCitaGenerada = citaDao.createCitaPresencial(paciente, cita, precio_servicio, descripcion, idSecretaria);
            String codigoReserva = (idCitaGenerada > 0) ? String.format("ART-RES-%05d", idCitaGenerada) : "ART-RES-00001";

            // RF03 / RF09: Registrar notificación de cita presencial
            if (idCitaGenerada > 0) {
                citaDao.registrarNotificacion("Cita Presencial Registrada", 3, idCitaGenerada);
                if (correo != null && !correo.trim().isEmpty()) {
                    EmailService.sendEmail(correo, "Cita Presencial Confirmada - ArtDent",
                            "Estimado(a) " + nombre + " " + apellido + ",\n\n" +
                            "Su cita presencial ha sido registrada con éxito en el Centro Odontológico ArtDent.\n" +
                            "Código de Cita: " + codigoReserva + "\n" +
                            "Fecha: " + fecha + "\n" +
                            "Hora: " + hora + "\n\n" +
                            "Gracias por su preferencia.");
                }
            }

            response.sendRedirect("ReservaController?accion=listarCitas&msg=presencialOk&codigo=" + codigoReserva);
            return;
        }

        // Cita con estado 1 ('En espera'), origen Web y el odontólogo seleccionado
        Cita cita = new Cita(0, fecha, hora, idServicio, x, 1, idOdontologo);

        // RF01 / RF02: Se registra la reserva web y se obtiene el ID generado
        int idCitaGenerada = citaDao.createReservaWeb(paciente, cita, precio_servicio, descripcion);
        String codigoReserva = (idCitaGenerada > 0) ? String.format("ART-RES-%05d", idCitaGenerada) : "ART-RES-00001";

        // Obtener nombre del servicio y del odontólogo para el voucher
        String nombreServicio = request.getParameter("nombreServicio");
        if (nombreServicio == null || nombreServicio.trim().isEmpty()) {
            pe.edu.utp.entity.Servicio serv = new pe.edu.utp.daoImpl.ServicioDaoImpl().obtenerServicioPorId(idServicio);
            if (serv != null && serv.getTipoServicio() != null) {
                nombreServicio = serv.getTipoServicio();
            } else {
                nombreServicio = "Servicio Dental";
            }
        }

        pe.edu.utp.entity.Usuario doc = new pe.edu.utp.daoImpl.UsuarioDaoImpl().obtenerUsuarioPorId(idOdontologo);
        String nombreDoctor = (doc != null && doc.getNombre() != null) ? (doc.getNombre() + " " + doc.getApellido()) : "Dr. Especialista";

        // Guardar datos en sesión para mostrar el voucher detallado en citareservada.jsp
        request.getSession().setAttribute("reservaCodigo", codigoReserva);
        request.getSession().setAttribute("reservaIdCita", String.valueOf(idCitaGenerada));
        request.getSession().setAttribute("reservaNombre", nombre + " " + apellido);
        request.getSession().setAttribute("reservaDni", String.valueOf(dni));
        request.getSession().setAttribute("reservaTelefono", String.valueOf(telefono));
        request.getSession().setAttribute("reservaCorreo", correo);
        request.getSession().setAttribute("reservaFecha", fecha);
        request.getSession().setAttribute("reservaHora", hora);
        request.getSession().setAttribute("reservaServicio", nombreServicio);
        request.getSession().setAttribute("reservaDoctor", nombreDoctor);
        request.getSession().setAttribute("reservaPrecio", String.format(java.util.Locale.US, "%.2f", precio_servicio));
        request.getSession().setAttribute("reservaEstado", "En espera");

        // Redireccionar a la vista de confirmación
        response.sendRedirect("citareservada.jsp");
    }

    /**
     * Returns a short description of the servlet.
     *
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>

}
