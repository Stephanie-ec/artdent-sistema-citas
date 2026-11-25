package pe.edu.utp.controller;

import java.io.IOException;
import java.io.PrintWriter;
import java.lang.management.ManagementFactory;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import pe.edu.utp.config.Conexion;
import pe.edu.utp.daoImpl.CorreoDao;
import pe.edu.utp.utils.AppVersion;

/**
 * R-14: /salud es público y responde JSON sin datos personales.
 * Devuelve 503 cuando la base de datos no responde, para que un monitor
 * externo (por ejemplo UptimeRobot) pueda alertar.
 */
@WebServlet("/salud")
public class SaludController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json;charset=UTF-8");
        response.setHeader("Cache-Control", "no-store");

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

        int pendientes = -1;
        int fallidos = -1;
        if (bdOk) {
            try {
                CorreoDao correoDao = new CorreoDao();
                pendientes = correoDao.contarPendientes();
                fallidos = correoDao.contarFallidos();
            } catch (SQLException e) {
                pendientes = -1;
                fallidos = -1;
            }
        }

        long uptime = ManagementFactory.getRuntimeMXBean().getUptime() / 1000L;
        StringBuilder json = new StringBuilder(256);
        json.append('{')
                .append("\"estado\":\"").append(bdOk ? "ok" : "degradado").append("\",")
                .append("\"version\":\"").append(AppVersion.completa()).append("\",")
                .append("\"uptimeSegundos\":").append(uptime).append(',')
                .append("\"baseDatos\":{\"estado\":\"").append(bdOk ? "ok" : "sinConexion").append("\",")
                .append("\"latenciaMs\":").append(latencia).append("},")
                .append("\"correos\":{\"pendientes\":").append(pendientes)
                .append(",\"fallidos\":").append(fallidos).append("},")
                .append("\"pool\":{\"activas\":").append(Conexion.poolActivas())
                .append(",\"inactivas\":").append(Conexion.poolInactivas())
                .append(",\"total\":").append(Conexion.poolTotal()).append("},")
                .append("\"marcaTiempo\":\"").append(java.time.OffsetDateTime.now()).append("\"")
                .append('}');

        if (!bdOk) {
            response.setStatus(HttpServletResponse.SC_SERVICE_UNAVAILABLE);
        }
        PrintWriter out = response.getWriter();
        out.write(json.toString());
    }
}
