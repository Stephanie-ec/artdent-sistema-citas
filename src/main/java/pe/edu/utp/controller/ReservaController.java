package pe.edu.utp.controller;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.temporal.WeekFields;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import pe.edu.utp.dao.CitaDao;
import pe.edu.utp.dao.ServicioDao;

import pe.edu.utp.dao.ReservaDao;
import pe.edu.utp.daoImpl.CitaDaoImpl;
import pe.edu.utp.entity.Reserva;

import pe.edu.utp.entity.Paciente;
import pe.edu.utp.daoImpl.ReservaDaoImpl;
import pe.edu.utp.daoImpl.ServicioDaoImpl;
import pe.edu.utp.entity.Servicio;
import pe.edu.utp.entity.VerCita;
import pe.edu.utp.entity.VerReserva;

@WebServlet(name = "ReservaController", urlPatterns = {"/ReservaController"})
public class ReservaController extends HttpServlet {

    ReservaDao reservaDao = new ReservaDaoImpl();
    CitaDao citaDao = new CitaDaoImpl();

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

    }
    private ServicioDao servicioDAO;

    @Override
    public void init() {
        servicioDAO = new ServicioDaoImpl();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String accion = request.getParameter("accion");

        try {
            switch (accion) {
                case "listar":
                    listarReservas(request, response);
                    break;
                case "listarCitas":
                    listarCitas(request, response);
                    break;
                case "hoy":
                    request.getSession().removeAttribute("semanaActual");
                    listarReservasPorSemana(request, response);
                    break;
                case "listarReservasPorDia":
                    listarReservasPorSemana(request, response);
                    break;
                case "semanaAnterior":
                    cambiarSemanaYListarReservasPorSemana(request, response, -1);
                    break;
                case "semanaSiguiente":
                    cambiarSemanaYListarReservasPorSemana(request, response, 1);
                    break;
                case "formcita":
                    formcita(request, response);
                    break;
                default:
                    request.getRequestDispatcher("PDCCalendario.jsp").forward(request, response);
            }
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Error al listar reservas: " + e.getMessage());
            request.getRequestDispatcher("error.jsp").forward(request, response);
        }
    }

// Método para listar todas las reservas
    private void listarReservas(HttpServletRequest request, HttpServletResponse response) throws SQLException, ServletException, IOException {
        int idUsuario = (int) request.getSession().getAttribute("idUsuario"); // Obtener ID del usuario desde la sesión
        List<VerReserva> VerReserva = reservaDao.listarReservas(idUsuario);  // Método que debes implementar en tu ReservaDao
        request.setAttribute("VerReserva", VerReserva);  // Enviamos la lista de reservas a la JSP
        request.setAttribute("tipoLista", "reserva"); // Agregar tipo de lista
        request.getRequestDispatcher("PDCSolicitudes.jsp").forward(request, response);
    }

// Método para listar todas las citas
    private void listarCitas(HttpServletRequest request, HttpServletResponse response) throws SQLException, ServletException, IOException {
        int idUsuario = (int) request.getSession().getAttribute("idUsuario"); // Obtener ID del usuario desde la sesión
        List<VerCita> VerCita = citaDao.listarCitas(idUsuario);  // Método que debes implementar en tu ReservaDao
        request.setAttribute("VerCita", VerCita);  // Enviamos la lista de citas a la JSP
        request.setAttribute("tipoLista", "cita"); // Agregar tipo de lista
        request.getRequestDispatcher("PDCSolicitudes.jsp").forward(request, response);
    }

    private void listarReservasPorSemana(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, ServletException, IOException {
        Integer semanaActual = (Integer) request.getSession().getAttribute("semanaActual");
        if (semanaActual == null) {
            semanaActual = LocalDate.now().get(WeekFields.ISO.weekOfYear());
            request.getSession().setAttribute("semanaActual", semanaActual);
        }

        String[] diasSemana = {"Lunes", "Martes", "Miércoles", "Jueves", "Viernes", "Sábado", "Domingo"};
        Map<String, List<VerReserva>> reservasPorDia = new HashMap<>();
        Map<String, List<VerCita>> citasPorDia = new HashMap<>();

        String tipoRol = (String) request.getSession().getAttribute("TipoRol");
        String nombreDoc = (String) request.getSession().getAttribute("Nombre");
        String apellidoDoc = (String) request.getSession().getAttribute("Apellido");
        boolean esOdontologo = tipoRol != null && tipoRol.equalsIgnoreCase("Odontologo");

        for (String dia : diasSemana) {
            List<VerCita> citas = citaDao.listarCitasPorDiaSemana(dia, semanaActual);
            List<VerReserva> reservas = reservaDao.listarReservasPorDiaSemana(dia, semanaActual);

            if (esOdontologo && nombreDoc != null && apellidoDoc != null) {
                // RF04: Filtrar estrictamente citas y reservas del odontólogo en sesión
                final String nDoc = nombreDoc.trim().toLowerCase();
                final String aDoc = apellidoDoc.trim().toLowerCase();

                List<VerCita> citasFiltradas = new ArrayList<>();
                for (VerCita c : citas) {
                    String cNom = (c.getNombreUsuario() != null) ? c.getNombreUsuario().trim().toLowerCase() : "";
                    String cApe = (c.getApellidoUsuario() != null) ? c.getApellidoUsuario().trim().toLowerCase() : "";
                    if ((cNom.contains(nDoc) || nDoc.contains(cNom)) && (cApe.contains(aDoc) || aDoc.contains(cApe))) {
                        citasFiltradas.add(c);
                    }
                }
                citas = citasFiltradas;

                List<VerReserva> reservasFiltradas = new ArrayList<>();
                for (VerReserva r : reservas) {
                    String rNom = (r.getNombreUsuario() != null) ? r.getNombreUsuario().trim().toLowerCase() : "";
                    String rApe = (r.getApellidoUsuario() != null) ? r.getApellidoUsuario().trim().toLowerCase() : "";
                    if ((rNom.contains(nDoc) || nDoc.contains(rNom)) && (rApe.contains(aDoc) || aDoc.contains(rApe))) {
                        reservasFiltradas.add(r);
                    }
                }
                reservas = reservasFiltradas;
            }

            citasPorDia.put(dia, citas);
            reservasPorDia.put(dia, reservas);
        }

        request.setAttribute("reservasPorDia", reservasPorDia);
        request.setAttribute("citasPorDia", citasPorDia);
        request.setAttribute("tipoListaCitas", "citas");
        request.setAttribute("tipoListaReservas", "reservas");
        request.setAttribute("semanaActual", semanaActual); // Add this line to pass the current week to the JSP

        request.getRequestDispatcher("PDCCalendario.jsp").forward(request, response);
    }

    private void cambiarSemanaYListarReservasPorSemana(HttpServletRequest request, HttpServletResponse response, int cambio)
            throws SQLException, ServletException, IOException {
        Integer semanaActual = (Integer) request.getSession().getAttribute("semanaActual");
        if (semanaActual == null) {
            semanaActual = 1;
        }
        semanaActual += cambio;
        request.getSession().setAttribute("semanaActual", semanaActual);

        listarReservasPorSemana(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        // Datos de Usuario
        String nombre = request.getParameter("nombre");
        String apellido = request.getParameter("apellido");
        String dniStr = request.getParameter("dni");
        int dni = (dniStr != null && !dniStr.trim().isEmpty()) ? Integer.parseInt(dniStr.trim()) : 0;
        String telefonoStr = request.getParameter("telefono");
        int telefono = (telefonoStr != null && !telefonoStr.trim().isEmpty()) ? Integer.parseInt(telefonoStr.trim()) : 0;
        String correo = request.getParameter("correo");
        if (correo == null || correo.trim().isEmpty()) {
            correo = request.getParameter("email");
        }

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

        int id_odontologo = 4;
        String medicoStr = request.getParameter("medico");
        if (medicoStr != null && !medicoStr.trim().isEmpty()) {
            try {
                id_odontologo = Integer.parseInt(medicoStr.trim());
            } catch (NumberFormatException e) {
                id_odontologo = 4;
            }
        }

        // Datos de Reserva
        String fecha = request.getParameter("fecha");
        String hora = request.getParameter("hora");
        String descripcion = request.getParameter("descripcion");
        if (descripcion == null || descripcion.trim().isEmpty()) {
            descripcion = "Reserva Web - En espera";
        }

        int Usuario_idUsuario = 0;
        String idUserStr = request.getParameter("idUsuario");
        if (idUserStr != null && !idUserStr.trim().isEmpty() && !idUserStr.equals("null")) {
            try {
                Usuario_idUsuario = Integer.parseInt(idUserStr.trim());
            } catch (NumberFormatException e) {
                Usuario_idUsuario = 0;
            }
        }

        int estadoId = 1;  // 1: 'En espera'
        Paciente paciente = new Paciente(0, nombre, apellido, dni, telefono, correo);
        Reserva reserva = new Reserva(0, fecha, hora, descripcion, precio_servicio, Usuario_idUsuario, estadoId, idServicio, id_odontologo);
        int x = reservaDao.verificarExistencia(dni);
        if (x == 0) {
            reservaDao.createReserva(paciente, reserva);
        } else {
            reserva.setUsuario_idUsuario(x); // Pasamos idPaciente existente
            reservaDao.createReservaPacex(paciente, reserva);
        }

        // Guardar en sesión para el voucher de citareservada.jsp
        request.getSession().setAttribute("reservaNombre", nombre + " " + apellido);
        request.getSession().setAttribute("reservaDni", String.valueOf(dni));
        request.getSession().setAttribute("reservaFecha", fecha);
        request.getSession().setAttribute("reservaHora", hora);
        request.getSession().setAttribute("reservaServicio", request.getParameter("motivo"));
        request.getSession().setAttribute("reservaPrecio", String.format("%.2f", precio_servicio));

        response.sendRedirect("citareservada.jsp");
    }

    private void formcita(HttpServletRequest request, HttpServletResponse response) throws SQLException, ServletException, IOException {
        List<Servicio> servicios = servicioDAO.listarServicios();

        request.setAttribute("servicios", servicios);
        request.getRequestDispatcher("reservacita.jsp").forward(request, response);
    }

    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>

}
