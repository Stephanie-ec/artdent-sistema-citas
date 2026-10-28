package pe.edu.utp.controller;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import pe.edu.utp.dao.CitaDao;
import pe.edu.utp.dao.ReservaDao;
import pe.edu.utp.daoImpl.CitaDaoImpl;
import pe.edu.utp.daoImpl.ReservaDaoImpl;
import pe.edu.utp.entity.ReporteEstado;
import pe.edu.utp.entity.ReporteMensual; // Asegúrate de tener la clase ReporteMensual

@WebServlet(name = "ReporteController", urlPatterns = {"/ReporteController"})
public class ReporteController extends HttpServlet {

    ReservaDao reservaDao = new ReservaDaoImpl();
    CitaDao citaDao = new CitaDaoImpl();
    GeneradorDeReporte generadorDeReporte = new GeneradorDeReporte(reservaDao, citaDao); // Instancia del generador de reporte

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Puedes mantener este método vacío si no lo necesitas
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String accion = request.getParameter("accion");
        javax.servlet.http.HttpSession ss = request.getSession();
        String rol = (ss != null && ss.getAttribute("TipoRol") != null) ? ss.getAttribute("TipoRol").toString() : "";

        try {
            if ("reportead".equals(accion) || (accion == null && rol.equalsIgnoreCase("Administrador"))) {
                generarReporteMensualAdmin(request, response);
            } else if ("reporte".equals(accion) || (accion == null && rol.equalsIgnoreCase("Secretaria"))) {
                generarReporteMensual(request, response);
            } else {
                generarReporteMensualAdmin(request, response);
            }

        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Error al generar reportes: " + e.getMessage());
            request.getRequestDispatcher("error.jsp").forward(request, response);
        }

    }

    private void calcularKpis(HttpServletRequest request, List<ReporteMensual> reporteMensual) {
        double totalIngresos = 0;
        int totalCompletadas = 0;
        int totalCanceladas = 0;
        int totalCitasGeneral = 0;
        if (reporteMensual != null) {
            for (ReporteMensual rm : reporteMensual) {
                totalIngresos += rm.getTotalIngresos();
                totalCompletadas += (rm.getCitasCompletadas() + rm.getReservasCompletadas());
                totalCanceladas += (rm.getCitasCanceladas() + rm.getReservasCanceladas());
                totalCitasGeneral += (rm.getTotalCitas() + rm.getTotalReservas());
            }
        }
        request.setAttribute("kpiIngresos", totalIngresos);
        request.setAttribute("kpiCompletadas", totalCompletadas);
        request.setAttribute("kpiCanceladas", totalCanceladas);
        request.setAttribute("kpiTotal", totalCitasGeneral);
    }

    private void generarReporteMensual(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, ServletException, IOException {
        Object idObj = request.getSession().getAttribute("idUsuario");
        int idUsuario = idObj != null ? (int) idObj : 1;
        List<ReporteMensual> reporteMensual = generadorDeReporte.generarReporte(idUsuario);
        calcularKpis(request, reporteMensual);
        request.setAttribute("reporteMensual", reporteMensual);
        request.getRequestDispatcher("PDCReportes.jsp").forward(request, response);
    }

    private void generarReporteMensualAdmin(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, ServletException, IOException {
        List<ReporteMensual> reporteMensual = generadorDeReporte.generarReporteAd();
        calcularKpis(request, reporteMensual);
        request.setAttribute("reporteMensual", reporteMensual);
        request.getRequestDispatcher("PDCReportes.jsp").forward(request, response);
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    @Override
    public String getServletInfo() {
        return "Short description";
    }
}
