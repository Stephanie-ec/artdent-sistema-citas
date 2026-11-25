package pe.edu.utp.controller;

import java.io.IOException;
import java.time.LocalDate;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import pe.edu.utp.daoImpl.BloqueoDao;
import pe.edu.utp.daoImpl.UsuarioDaoImpl;
import pe.edu.utp.utils.EventoService;
import pe.edu.utp.utils.FormToken;

/** R-11: el administrador registra feriados o vacaciones y la agenda los excluye. */
@WebServlet("/Bloqueos")
public class BloqueoController extends HttpServlet {

    private final BloqueoDao bloqueos;
    public BloqueoController() { this(new BloqueoDao()); }
    BloqueoController(BloqueoDao dao) { this.bloqueos = dao; }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        req.setAttribute("bloqueos", bloqueos.listar());
        req.setAttribute("odontologos", new UsuarioDaoImpl().obtenerMedicosDisponibles());
        req.setAttribute("formToken", FormToken.obtener(req));
        req.getRequestDispatcher("ADMPBloqueos.jsp").forward(req, res);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        if (!FormToken.valido(req)) {
            res.sendRedirect("Bloqueos?error=" + java.net.URLEncoder.encode("La solicitud expiró. Recargue la página.", "UTF-8"));
            return;
        }
        String accion = req.getParameter("accion");
        try {
            int actor = Integer.parseInt(String.valueOf(req.getSession().getAttribute("idUsuario")));
            if ("eliminar".equals(accion)) {
                int id = Integer.parseInt(req.getParameter("id"));
                if (!bloqueos.eliminar(id)) {
                    res.sendRedirect("Bloqueos?error=" + java.net.URLEncoder.encode("No se encontró el bloqueo.", "UTF-8"));
                    return;
                }
                EventoService.info("Agenda", "Bloqueo de agenda eliminado por el administrador (id " + id + ")");
                res.sendRedirect("Bloqueos?msg=eliminadoOk");
                return;
            }
            if (!"crear".equals(accion)) {
                res.sendError(400);
                return;
            }
            String desde = texto(req.getParameter("desde"));
            String hasta = texto(req.getParameter("hasta"));
            String motivo = texto(req.getParameter("motivo"));
            String usuario = texto(req.getParameter("usuarioId"));
            LocalDate inicio = LocalDate.parse(desde);
            LocalDate fin = hasta.isEmpty() ? inicio : LocalDate.parse(hasta);
            if (fin.isBefore(inicio)) {
                res.sendRedirect("Bloqueos?error=" + java.net.URLEncoder.encode("La fecha final no puede ser anterior a la inicial.", "UTF-8"));
                return;
            }
            if (motivo.length() < 3 || motivo.length() > 200) {
                res.sendRedirect("Bloqueos?error=" + java.net.URLEncoder.encode("Indique un motivo de 3 a 200 caracteres.", "UTF-8"));
                return;
            }
            Integer usuarioId = usuario.isEmpty() ? null : Integer.valueOf(usuario);
            if (!bloqueos.crear(inicio.toString(), fin.toString(), usuarioId, motivo, actor)) {
                res.sendRedirect("Bloqueos?error=" + java.net.URLEncoder.encode("No se pudo registrar el bloqueo.", "UTF-8"));
                return;
            }
            EventoService.info("Agenda", "Bloqueo de agenda registrado del " + inicio + " al " + fin
                    + (usuarioId == null ? " para toda la clínica" : " para el odontólogo id " + usuarioId));
            res.sendRedirect("Bloqueos?msg=creadoOk");
        } catch (java.time.format.DateTimeParseException | NumberFormatException e) {
            res.sendRedirect("Bloqueos?error=" + java.net.URLEncoder.encode("Revise las fechas y el odontólogo seleccionado.", "UTF-8"));
        } catch (IllegalStateException e) {
            res.sendError(503, "No se pudo guardar el bloqueo. Intente nuevamente.");
        }
    }

    private static String texto(String valor) {
        return valor == null ? "" : valor.trim();
    }
}
