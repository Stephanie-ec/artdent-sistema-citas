package pe.edu.utp.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.LinkedHashMap;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import pe.edu.utp.config.Conexion;
import pe.edu.utp.daoImpl.CorreoDao;
import pe.edu.utp.daoImpl.EventoDao;
import pe.edu.utp.utils.AppVersion;
import pe.edu.utp.utils.MetricasRendimiento;

/**
 * R-14: página /estado, solo para el administrador. Muestra los indicadores
 * del servicio con su valor actual, el objetivo y el semáforo.
 */
@WebServlet("/estado")
public class EstadoController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        boolean bdOk = false;
        long latencia = -1;
        try {
            long inicio = System.nanoTime();
            try (Connection c = Conexion.getConection();
                 PreparedStatement s = c.prepareStatement("SELECT 1");
                 ResultSet r = s.executeQuery()) {
                r.next();
            }
            latencia = (System.nanoTime() - inicio) / 1_000_000L;
            bdOk = true;
        } catch (SQLException | IllegalStateException e) {
            bdOk = false;
        }

        int pendientes = -1, fallidosCola = -1, caidasBd = -1, fallosLogin = -1, exitosLogin = -1;
        if (bdOk) {
            try {
                CorreoDao correoDao = new CorreoDao();
                pendientes = correoDao.contarPendientes();
                fallidosCola = correoDao.contarFallidos();
                EventoDao eventoDao = new EventoDao();
                caidasBd = eventoDao.contarPorMensaje("No se pudo obtener una conexión", 24);
                fallosLogin = eventoDao.contarPorMensaje("Inicio de sesión fallido", 24);
                exitosLogin = eventoDao.contarPorMensaje("Inicio de sesión exitoso", 24);
            } catch (SQLException e) {
                pendientes = -1;
            }
        }

        int intentos = Math.max(0, fallosLogin) + Math.max(0, exitosLogin);
        double tasaFallos = intentos == 0 ? 0.0 : (Math.max(0, fallosLogin) * 100.0 / intentos);

        Map<String, Object> salud = new LinkedHashMap<>();
        salud.put("baseDatosOk", bdOk);
        salud.put("latenciaMs", latencia);
        salud.put("disponibilidad", caidasBd <= 0 ? "100 %" : "revisar");
        salud.put("caidas24h", Math.max(0, caidasBd));
        salud.put("p95ReservaMs", MetricasRendimiento.p95Reserva());
        salud.put("muestrasReserva", MetricasRendimiento.muestras());
        salud.put("correosPendientes", pendientes);
        salud.put("correosFallidos", fallidosCola);
        salud.put("tasaFallosLogin", tasaFallos);
        salud.put("intentosLogin", intentos);
        salud.put("uptimeSegundos", java.lang.management.ManagementFactory.getRuntimeMXBean().getUptime() / 1000L);
        salud.put("version", AppVersion.completa());
        salud.put("poolActivas", Conexion.poolActivas());
        salud.put("poolInactivas", Conexion.poolInactivas());
        salud.put("poolTotal", Conexion.poolTotal());

        request.setAttribute("salud", salud);
        request.getRequestDispatcher("ADMPEstado.jsp").forward(request, response);
    }
}
