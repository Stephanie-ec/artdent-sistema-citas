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
        // Lo más reciente primero, para que la última reserva se vea arriba
        VerReserva.sort((a, b) -> Integer.compare(b.getIdReserva(), a.getIdReserva()));
        request.setAttribute("VerReserva", VerReserva);  // Enviamos la lista de reservas a la JSP
        request.setAttribute("tipoLista", "reserva"); // Agregar tipo de lista
        request.getRequestDispatcher("PDCSolicitudes.jsp").forward(request, response);
    }

// Método para listar todas las citas
    private void listarCitas(HttpServletRequest request, HttpServletResponse response) throws SQLException, ServletException, IOException {
        int idUsuario = (int) request.getSession().getAttribute("idUsuario"); // Obtener ID del usuario desde la sesión
        List<VerCita> VerCita = citaDao.listarCitas(idUsuario);  // Método que debes implementar en tu ReservaDao
        VerCita.sort((a, b) -> Integer.compare(b.getIdCita(), a.getIdCita()));
        request.setAttribute("VerCita", VerCita);  // Enviamos la lista de citas a la JSP
        request.setAttribute("tipoLista", "cita"); // Agregar tipo de lista
        request.getRequestDispatcher("PDCSolicitudes.jsp").forward(request, response);
    }

    private static final int DURACION_CITA_MIN = 45;

    private static boolean esCancelada(String estado) {
        return estado != null && estado.equalsIgnoreCase("Cancelado");
    }

    /** true si la hora dada se cruza (citas de 45 min) con alguna de las horas activas. */
    private static boolean seCruza(String hora, List<String> horasActivas) {
        int inicio = minutos(hora);
        if (inicio < 0) return false;
        for (String h : horasActivas) {
            int otra = minutos(h);
            if (otra >= 0 && Math.abs(inicio - otra) < DURACION_CITA_MIN) return true;
        }
        return false;
    }

    private static int minutos(String hora) {
        try {
            String[] p = hora.trim().split(":");
            return Integer.parseInt(p[0]) * 60 + Integer.parseInt(p[1]);
        } catch (Exception e) {
            return -1;
        }
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
        boolean esOdontologo = tipoRol != null && tipoRol.equalsIgnoreCase("Odontologo");

        // RF04: el odontólogo ve solo sus citas, filtradas por su id (antes se comparaban nombres)
        java.util.Set<Integer> idsPropios = null;
        if (esOdontologo) {
            Object idObj = request.getSession().getAttribute("idUsuario");
            int idOdontologo = (idObj instanceof Integer) ? (Integer) idObj : -1;
            idsPropios = citaDao.idsCitasDeOdontologo(idOdontologo);
        }

        for (String dia : diasSemana) {
            List<VerCita> citas = citaDao.listarCitasPorDiaSemana(dia, semanaActual);
            List<VerReserva> reservas = reservaDao.listarReservasPorDiaSemana(dia, semanaActual);

            if (idsPropios != null) {
                List<VerCita> citasFiltradas = new ArrayList<>();
                for (VerCita c : citas) {
                    if (idsPropios.contains(c.getIdCita())) {
                        citasFiltradas.add(c);
                    }
                }
                citas = citasFiltradas;

                List<VerReserva> reservasFiltradas = new ArrayList<>();
                for (VerReserva r : reservas) {
                    if (idsPropios.contains(r.getIdReserva())) {
                        reservasFiltradas.add(r);
                    }
                }
                reservas = reservasFiltradas;
            }

            // Una cita cancelada se oculta si otra cita del mismo día se cruza con su horario
            List<String> horasActivas = new ArrayList<>();
            for (VerCita c : citas) {
                if (!esCancelada(c.getEstado())) horasActivas.add(c.getHoraReserva());
            }
            for (VerReserva r : reservas) {
                if (!esCancelada(r.getEstado())) horasActivas.add(r.getHoraReserva());
            }
            citas.removeIf(c -> esCancelada(c.getEstado()) && seCruza(c.getHoraReserva(), horasActivas));
            reservas.removeIf(r -> esCancelada(r.getEstado()) && seCruza(r.getHoraReserva(), horasActivas));

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

        // F-16: preservar POST y parametros; ejecutar una sola ruta de negocio.
        request.getRequestDispatcher("/CitaController").forward(request, response);
    }

    private void formcita(HttpServletRequest request, HttpServletResponse response) throws SQLException, ServletException, IOException {
        List<Servicio> servicios = servicioDAO.listarServicios();

        request.setAttribute("servicios", servicios);
        // Se usa el formulario oficial de reserva (CitaController), que guarda y valida correctamente
        response.sendRedirect("ServicioController?action=formreservaa");
    }

    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>

}
