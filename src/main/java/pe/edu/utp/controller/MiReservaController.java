package pe.edu.utp.controller;

import java.io.IOException;
import java.sql.SQLException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import pe.edu.utp.daoImpl.GestionCitaDao;
import pe.edu.utp.utils.FormToken;

/**
 * R-10: el paciente cancela o reprograma su propia reserva desde "Mi reserva".
 *
 * No hay sesión de personal: la reserva se identificó antes con código + DNI
 * (PagoController) y el DNI validado queda en la sesión. El DNI nunca se toma
 * del formulario, y las 24 horas se validan otra vez dentro del procedimiento.
 */
@WebServlet("/MiReserva")
public class MiReservaController extends HttpServlet {

    private final GestionCitaDao gestion;
    public MiReservaController() { this(new GestionCitaDao()); }
    MiReservaController(GestionCitaDao dao) { this.gestion = dao; }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws IOException {
        res.sendRedirect(req.getContextPath() + "/consultareserva.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        HttpSession sesion = req.getSession(false);
        if (sesion == null || !FormToken.valido(req)) {
            res.sendRedirect(req.getContextPath() + "/consultareserva.jsp?error=permiso");
            return;
        }
        String accion = req.getParameter("accion");
        int id;
        try {
            id = Integer.parseInt(req.getParameter("idCita"));
        } catch (RuntimeException e) {
            res.sendError(400);
            return;
        }
        Object dniGuardado = sesion.getAttribute("reservaDni:" + id);
        if (dniGuardado == null) {
            res.sendRedirect(req.getContextPath() + "/consultareserva.jsp?error=permiso");
            return;
        }
        String dni = String.valueOf(dniGuardado);
        String codigo = String.format(java.util.Locale.ROOT, "ART-RES-%05d", id);
        String volver = req.getContextPath() + "/PagoController?action=consultar&codigo=" + codigo + "&dni=" + dni;
        try {
            if ("cancelar".equals(accion)) {
                gestion.cancelarReservaPaciente(id, dni);
                res.sendRedirect(volver + "&ok=cancelada");
            } else if ("reprogramar".equals(accion)) {
                String fecha = texto(req.getParameter("fecha"));
                String hora = texto(req.getParameter("hora"));
                if (!fecha.matches("\\d{4}-\\d{2}-\\d{2}") || !hora.matches("([01]\\d|2[0-3]):[0-5]\\d")) {
                    res.sendRedirect(volver + "&error=formato");
                    return;
                }
                gestion.reprogramarReservaPaciente(id, dni, fecha, hora);
                res.sendRedirect(volver + "&ok=reprogramada");
            } else {
                res.sendError(400);
            }
        } catch (SQLException e) {
            if ("45000".equals(e.getSQLState())) {
                String mensaje = e.getMessage() == null ? "No se pudo completar la operación." : e.getMessage();
                res.sendRedirect(volver + "&error=regla&detalle=" + java.net.URLEncoder.encode(mensaje, "UTF-8"));
            } else {
                java.util.logging.Logger.getLogger(getClass().getName())
                        .log(java.util.logging.Level.SEVERE, "No se pudo modificar la reserva del paciente", e);
                res.sendRedirect(volver + "&error=general");
            }
        }
    }

    private static String texto(String valor) {
        return valor == null ? "" : valor.trim();
    }
}
