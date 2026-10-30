/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package pe.edu.utp.controller;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import pe.edu.utp.dao.CitaDao;
import pe.edu.utp.dao.ReservaDao;
import pe.edu.utp.daoImpl.CitaDaoImpl;
import pe.edu.utp.daoImpl.ReservaDaoImpl;
import pe.edu.utp.entity.Cita;
import pe.edu.utp.entity.VerCita;
import pe.edu.utp.entity.VerReserva;
import pe.edu.utp.dao.PagoDao;
import pe.edu.utp.daoImpl.PagoDaoImpl;
import pe.edu.utp.utils.NotificacionService;

/**
 *
 * @author AMD
 */
public class ReprogramacionController extends HttpServlet {

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            /* TODO output your page here. You may use following sample code. */
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Servlet ReprogramacionController</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet ReprogramacionController at " + request.getContextPath() + "</h1>");
            out.println("</body>");
            out.println("</html>");
        }
    }

    ReservaDao reservaDao = new ReservaDaoImpl();
    CitaDao citaDao = new CitaDaoImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String accion = request.getParameter("accion");

        try {
            if ("VerReproRe".equals(accion)) {
                ReproRe(request, response);
            } else if ("VerReproCi".equals(accion)) {
                ReproCi(request, response);
            } else {
                request.getRequestDispatcher("PDCCalendario.jsp").forward(request, response); // Página principal
            }

        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Error al listar reservas: " + e.getMessage());
            request.getRequestDispatcher("error.jsp").forward(request, response);
        }

    }

    private void ReproRe(HttpServletRequest request, HttpServletResponse response) throws SQLException, ServletException, IOException {
        int idReserva = Integer.parseInt(request.getParameter("id"));
        List<VerReserva> VerReserva = reservaDao.DetalleReserva(idReserva);  // Método que debes implementar en tu ReservaDao
        request.setAttribute("VerReserva", VerReserva);  // Enviamos la lista de reservas a la JSP
        request.setAttribute("tipoLista", "DetRe"); // Agregar tipo de lista
        request.getRequestDispatcher("Reprogramacion.jsp").forward(request, response);
    }

    private void ReproCi(HttpServletRequest request, HttpServletResponse response) throws SQLException, ServletException, IOException {
        int idCita = Integer.parseInt(request.getParameter("id"));
        List<VerCita> VerCita = citaDao.DetalleCita(idCita);
        request.setAttribute("VerCita", VerCita);
        request.setAttribute("tipoLista", "DetCi");
        request.getRequestDispatcher("Reprogramacion.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String accion = request.getParameter("accion");
        try {
            if ("UpdateReserva".equals(accion)) {
                UpdateReserva(request, response);
            } else if ("UpdateCita".equals(accion)) {
                UpdateCita(request, response);
            } else if ("updateEstadoConfirmar".equals(accion)) {
                UpdateReservaEstado(request, response);
            } else if ("updateEstadoCompletado".equals(accion)) {
                UpdateReservaEstado(request, response);
            } else if ("updateEstadoConfirmarCita".equals(accion)) {
                UpdateCitaEstado(request, response);
            } else if ("updateEstadoCompletadoCita".equals(accion)) {
                UpdateCitaEstado(request, response);
            } else if ("updateEstadoCancelar".equals(accion)) {
                UpdateReservaCancelado(request, response);
            } else if ("updateEstadoCanceladoCita".equals(accion)) {
                UpdateCitaCancelado(request, response);
            } else if ("deleteReserva".equals(accion)) {
                DeleteReserva(request, response);
            } else if ("deleteCita".equals(accion)) {
                DeleteCita(request, response);
            } else if ("rechazarReservaWeb".equals(accion)) {
                RechazarReservaWeb(request, response);
            } else {
                request.getRequestDispatcher("PDCCalendario.jsp").forward(request, response);
            }
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Error al modificar: " + e.getMessage());
            request.getRequestDispatcher("error.jsp").forward(request, response);
        }

    }

    private void UpdateCita(HttpServletRequest request, HttpServletResponse response) throws SQLException, ServletException, IOException {
        // Obtener los parámetros del formulario
        int idCita = Integer.parseInt(request.getParameter("idCita"));
        String nuevaFecha = request.getParameter("new-date");
        String nuevaHora = request.getParameter("new-time");

        // Crear una instancia de CitaDaoImpl
        CitaDao citaDao = new CitaDaoImpl();

        int resultado = citaDao.updateCita(idCita, nuevaFecha, nuevaHora);

        if (resultado > 0) {
            // RF03 / RF09: correo y registro de la notificación de reprogramación
            String correo = citaDao.getEmailPacienteByCitaId(idCita);
            NotificacionService.notificar(idCita, 4, "Cita Reprogramada", correo,
                    "Estimado paciente, su cita ha sido reprogramada para la fecha: " + nuevaFecha + " a las " + nuevaHora + ".");
            request.getRequestDispatcher("PDCCalendario.jsp").forward(request, response); // Redirige a la página principal
        } else {
            // Si hubo un error en la actualización
            request.getRequestDispatcher("error.jsp").forward(request, response); // Redirige a la página de error
        }
    }

    private void UpdateReserva(HttpServletRequest request, HttpServletResponse response) throws SQLException, ServletException, IOException {
        // Obtener los parámetros del formulario
        int idReserva = Integer.parseInt(request.getParameter("idReserva"));
        String nuevaFecha = request.getParameter("new-date");
        String nuevaHora = request.getParameter("new-time");

        ReservaDao reservaDao = new ReservaDaoImpl();

        int resultado = reservaDao.updateReserva(idReserva, nuevaFecha, nuevaHora);

        if (resultado > 0) {
            String correo = reservaDao.getEmailPacienteByReservaId(idReserva);
            NotificacionService.notificar(idReserva, 4, "Reserva Reprogramada", correo,
                    "Estimado paciente, su reserva ha sido reprogramada para la fecha: " + nuevaFecha + " a las " + nuevaHora + ".");
            request.getRequestDispatcher("PDCCalendario.jsp").forward(request, response); // Redirige a la página principal
        } else {
            request.getRequestDispatcher("error.jsp").forward(request, response); // Redirige a la página de error
        }
    }

    private void UpdateReservaEstado(HttpServletRequest request, HttpServletResponse response) throws SQLException, ServletException, IOException {
        int idReserva = Integer.parseInt(request.getParameter("idReserva"));
        String estadoActual = request.getParameter("estado");
        System.out.println("id " + idReserva);
        System.out.println("estado " + estadoActual);

        // D-14: completar (Confirmado -> Completado) solo lo hace el Odontólogo (RF16);
        // aprobar o confirmar lo hace la Secretaria (RF14)
        boolean completar = "Confirmado".equalsIgnoreCase(estadoActual);
        if (!rolPermitido(request, completar)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Acción no permitida para su rol.");
            return;
        }

        // RF14: Solo puede aprobar una reserva web que tenga un pago registrado previamente
        if ("En espera".equalsIgnoreCase(estadoActual)) {
            PagoDao pagoDao = new PagoDaoImpl();
            if (!pagoDao.tienePago(idReserva)) {
                response.sendRedirect("ReservaController?accion=listar&error=sinPago");
                return;
            }
        }

        ReservaDao reservaDao = new ReservaDaoImpl();
        int resultado = reservaDao.updateEstadoReserv(idReserva, estadoActual);
        if (resultado > 0) {
            // RF09: correo y registro de la notificación con el resultado real del envío
            String correo = reservaDao.getEmailPacienteByReservaId(idReserva);
            if (completar) {
                NotificacionService.notificar(idReserva, 2, "Atención Completada", correo,
                        "Estimado paciente, su atención en el Centro Odontológico ArtDent ha sido registrada como completada. Gracias por su visita.");
            } else if ("En espera".equalsIgnoreCase(estadoActual)) {
                NotificacionService.notificar(idReserva, 3, "Reserva Web Confirmada", correo,
                        "Estimado paciente, su reserva web ha sido APROBADA y confirmada por la secretaría tras verificar su pago.");
            } else {
                NotificacionService.notificar(idReserva, 3, "Reserva Confirmada", correo,
                        "Estimado paciente, su reserva ha sido confirmada.");
            }
            String rol = (request.getSession() != null && request.getSession().getAttribute("TipoRol") != null) 
                    ? request.getSession().getAttribute("TipoRol").toString() : "";
            if (rol.equalsIgnoreCase("Odontologo")) {
                response.sendRedirect("ReservaController?accion=listarReservasPorDia&msg=completadoOk");
            } else {
                response.sendRedirect("ReservaController?accion=listar&msg=aprobadoOk");
            }
        } else {
            request.getRequestDispatcher("error.jsp").forward(request, response);
        }
    }

    private void RechazarReservaWeb(HttpServletRequest request, HttpServletResponse response) throws SQLException, ServletException, IOException {
        int idReserva = Integer.parseInt(request.getParameter("idReserva"));
        String motivo = request.getParameter("motivo");
        if (motivo == null || motivo.trim().isEmpty()) {
            motivo = "No especificado";
        }
        motivo = motivo.trim();

        ReservaDao reservaDao = new ReservaDaoImpl();
        int resultado = reservaDao.rechazarReserva(idReserva);
        if (resultado > 0) {
            // RF09: correo y registro de la notificación (estado 6 = Rechazado)
            String correo = reservaDao.getEmailPacienteByReservaId(idReserva);
            NotificacionService.notificar(idReserva, 6, "Reserva Rechazada", correo,
                    "Estimado paciente, lamentamos informarle que su reserva web ha sido rechazada por el siguiente motivo: " + motivo + ".");
            response.sendRedirect("ReservaController?accion=listar&msg=rechazadoOk");
        } else {
            request.getRequestDispatcher("error.jsp").forward(request, response);
        }
    }

    private void UpdateCitaEstado(HttpServletRequest request, HttpServletResponse response) throws SQLException, ServletException, IOException {
        int idCita = Integer.parseInt(request.getParameter("idCita"));
        String estadoActual = request.getParameter("estado");
        System.out.println("id " + idCita);
        System.out.println("estado " + estadoActual);
        // D-14: completar (Confirmado -> Completado) solo lo hace el Odontólogo (RF16)
        boolean completar = "Confirmado".equalsIgnoreCase(estadoActual);
        if (!rolPermitido(request, completar)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Acción no permitida para su rol.");
            return;
        }
        CitaDao CitaDao = new CitaDaoImpl();
        int resultado = CitaDao.updateEstadoCita(idCita, estadoActual);
        if (resultado > 0) {
            String correo = CitaDao.getEmailPacienteByCitaId(idCita);
            if (completar) {
                NotificacionService.notificar(idCita, 2, "Atención Completada", correo,
                        "Estimado paciente, su atención en el Centro Odontológico ArtDent ha sido registrada como completada. Gracias por su visita.");
            } else {
                NotificacionService.notificar(idCita, 3, "Cita Confirmada", correo,
                        "Estimado paciente, su cita ha sido confirmada.");
            }
            String rol = (request.getSession() != null && request.getSession().getAttribute("TipoRol") != null) 
                    ? request.getSession().getAttribute("TipoRol").toString() : "";
            if (rol.equalsIgnoreCase("Odontologo")) {
                response.sendRedirect("ReservaController?accion=listarReservasPorDia&msg=completadoOk");
            } else {
                response.sendRedirect("ReservaController?accion=listar");
            }
        } else {
            request.getRequestDispatcher("error.jsp").forward(request, response);
        }
    }

    private void UpdateReservaCancelado(HttpServletRequest request, HttpServletResponse response) throws SQLException, ServletException, IOException {
        int idReserva = Integer.parseInt(request.getParameter("idReserva"));
        System.out.println("id " + idReserva);
        
        int resultado = reservaDao.updateEstadoCancelado(idReserva);
        if (resultado > 0) {
            String correo = reservaDao.getEmailPacienteByReservaId(idReserva);
            NotificacionService.notificar(idReserva, 5, "Reserva Cancelada", correo,
                    "Estimado paciente, su reserva ha sido cancelada.");
            request.getRequestDispatcher("PDCCalendario.jsp").forward(request, response);
        } else {
            request.getRequestDispatcher("error.jsp").forward(request, response);
        }
    }
    
    private void UpdateCitaCancelado(HttpServletRequest request, HttpServletResponse response) throws SQLException, ServletException, IOException {
        int idCita = Integer.parseInt(request.getParameter("idCita"));
        System.out.println("id " + idCita);
        CitaDao CitaDao = new CitaDaoImpl();
        int resultado = CitaDao.updateEstadoCitaCancelado(idCita);
        if (resultado > 0) {
            // RF03 / RF09: correo y registro de la notificación de cancelación
            String correo = CitaDao.getEmailPacienteByCitaId(idCita);
            NotificacionService.notificar(idCita, 5, "Cita Cancelada", correo,
                    "Estimado paciente, su cita ha sido cancelada.");
            request.getRequestDispatcher("PDCCalendario.jsp").forward(request, response);
        } else {
            request.getRequestDispatcher("error.jsp").forward(request, response);
        }
    }
    
    private void DeleteReserva(HttpServletRequest request, HttpServletResponse response) throws SQLException, ServletException, IOException {
        int idReserva = Integer.parseInt(request.getParameter("idReserva"));
        System.out.println("id " + idReserva);
        ReservaDao reservaDao = new ReservaDaoImpl();
        int resultado = reservaDao.deleteReserva(idReserva);
        if (resultado > 0) {
            request.getRequestDispatcher("PDCCalendario.jsp").forward(request, response);
        } else {
            request.getRequestDispatcher("error.jsp").forward(request, response);
        }
    }
    
    private void DeleteCita(HttpServletRequest request, HttpServletResponse response) throws SQLException, ServletException, IOException {
        int idCita = Integer.parseInt(request.getParameter("idCita"));
        System.out.println("id " + idCita);
        CitaDao CitaDao = new CitaDaoImpl();
        int resultado = CitaDao.DeleteCita(idCita);
        if (resultado > 0) {
            request.getRequestDispatcher("PDCCalendario.jsp").forward(request, response);
        } else {
            System.out.println("Error al eliminar la reserva");
            request.getRequestDispatcher("error.jsp").forward(request, response);
        }
    }

    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>


    /**
     * D-14: completar una atención es exclusivo del Odontólogo; aprobar, confirmar
     * o reprogramar corresponde a la Secretaria (o al Administrador).
     */
    private boolean rolPermitido(HttpServletRequest request, boolean completar) {
        Object rolObj = request.getSession(false) != null ? request.getSession(false).getAttribute("TipoRol") : null;
        String rol = rolObj != null ? rolObj.toString() : "";
        if (completar) {
            return rol.equalsIgnoreCase("Odontologo");
        }
        return rol.equalsIgnoreCase("Secretaria") || rol.equalsIgnoreCase("Administrador");
    }
}
