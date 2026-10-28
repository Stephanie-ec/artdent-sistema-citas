package pe.edu.utp.controller;

import java.sql.SQLException;
import java.util.List;
import java.util.Map;
import java.util.HashMap;
import java.util.ArrayList;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.format.TextStyle;
import java.util.Locale;
import pe.edu.utp.dao.CitaDao;
import pe.edu.utp.dao.ReservaDao;
import pe.edu.utp.entity.ReporteMensual;
import pe.edu.utp.entity.VerCita;
import pe.edu.utp.entity.VerReserva;

public class GeneradorDeReporte {

    private ReservaDao reservaDao; // DAO para las reservas
    private CitaDao citaDao; // DAO para las citas

    public GeneradorDeReporte(ReservaDao reservaDao, CitaDao citaDao) {
        this.reservaDao = reservaDao;
        this.citaDao = citaDao;
    }

    public List<ReporteMensual> generarReporte(int idUsuario) throws SQLException {
        List<VerReserva> reservas = reservaDao.listarTodasReservas(idUsuario); // Obtener reservas del DAO
        List<VerCita> citas = citaDao.listarTodasCitas(idUsuario); // Obtener citas del DAO

        Map<String, ReporteMensual> reportePorMes = new HashMap<>();
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");

        // Procesar las reservas
        for (VerReserva reserva : reservas) {
            LocalDate fecha = LocalDate.parse(reserva.getDiaReserva(), formatter);
            String mes = obtenerMes(fecha);
            ReporteMensual reporte = reportePorMes.getOrDefault(mes, new ReporteMensual(mes, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0));
            switch (reserva.getEstado()) {
                case "Completado": // Reprogramada
                    reporte.setReservasCompletadas(reporte.getReservasCompletadas() + 1);
                    reporte.setTotalIngresos(reporte.getTotalIngresos() + reserva.getImporte());
                    break;
                case "En espera": // Reprogramada
                    reporte.setReservasEnEspera(reporte.getReservasEnEspera() + 1);
                    break;
                case "Confirmado": // Reprogramada
                    reporte.setReservasConfirmadas(reporte.getReservasConfirmadas() + 1);
                    break;
                case "Reprogramado": // Reprogramada
                    reporte.setReservasReprogramadas(reporte.getReservasReprogramadas() + 1);
                    break;
                case "Cancelado": // Cancelada
                    reporte.setReservasCanceladas(reporte.getReservasCanceladas() + 1);
                    break;
            }
            reporte.setTotalReservas(reporte.getTotalReservas() + 1);
            reportePorMes.put(mes, reporte);
        }

        // Procesar las citas
        for (VerCita cita : citas) {
            LocalDate fecha = LocalDate.parse(cita.getDiaReserva(), formatter);
            String mes = obtenerMes(fecha);
            ReporteMensual reporte = reportePorMes.getOrDefault(mes, new ReporteMensual(mes, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0));

            // Incrementar contadores según el estado de la cita
            switch (cita.getEstado()) {
                case "Completado": // Confirmada
                    reporte.setCitasCompletadas(reporte.getCitasCompletadas() + 1);
                    reporte.setTotalIngresos(reporte.getTotalIngresos() + cita.getCosto());
                    break;
                case "En espera": // Reprogramada
                    reporte.setCitasEnEspera(reporte.getCitasEnEspera() + 1);
                    break;
                case "Confirmado": // Reprogramada
                    reporte.setCitasConfirmadas(reporte.getCitasConfirmadas() + 1);
                    break;
                case "Reprogramado": // Reprogramada
                    reporte.setCitasReprogramadas(reporte.getCitasReprogramadas() + 1);
                    break;
                case "Cancelado": // Cancelada
                    reporte.setCitasCanceladas(reporte.getCitasCanceladas() + 1);
                    break;

            }
            reporte.setTotalCitas(reporte.getTotalCitas() + 1);
            reportePorMes.put(mes, reporte);
        }

        return new ArrayList<>(reportePorMes.values());
    }

    public List<ReporteMensual> generarReporteAd() throws SQLException {
        List<VerReserva> reservas = reservaDao.listarTodasReservasAd(); // Obtener reservas del DAO
        List<VerCita> citas = citaDao.listarTodasCitasAd(); // Obtener citas del DAO

        Map<String, ReporteMensual> reportePorMes = new HashMap<>();
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");

        // Procesar las reservas
        for (VerReserva reserva : reservas) {
            LocalDate fecha = LocalDate.parse(reserva.getDiaReserva(), formatter);
            String mes = obtenerMes(fecha);
            ReporteMensual reporte = reportePorMes.getOrDefault(mes, new ReporteMensual(mes, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0));
            switch (reserva.getEstado()) {
                case "Completado": // Reprogramada
                    reporte.setReservasCompletadas(reporte.getReservasCompletadas() + 1);
                    reporte.setTotalIngresos(reporte.getTotalIngresos() + reserva.getImporte());
                    break;
                case "En espera": // Reprogramada
                    reporte.setReservasEnEspera(reporte.getReservasEnEspera() + 1);
                    break;
                case "Confirmado": // Reprogramada
                    reporte.setReservasConfirmadas(reporte.getReservasConfirmadas() + 1);
                    break;
                case "Reprogramado": // Reprogramada
                    reporte.setReservasReprogramadas(reporte.getReservasReprogramadas() + 1);
                    break;
                case "Cancelado": // Cancelada
                    reporte.setReservasCanceladas(reporte.getReservasCanceladas() + 1);
                    break;
            }
            reporte.setTotalReservas(reporte.getTotalReservas() + 1);
            reportePorMes.put(mes, reporte);
        }

        // Procesar las citas
        for (VerCita cita : citas) {
            LocalDate fecha = LocalDate.parse(cita.getDiaReserva(), formatter);
            String mes = obtenerMes(fecha);
            ReporteMensual reporte = reportePorMes.getOrDefault(mes, new ReporteMensual(mes, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0));

            // Incrementar contadores según el estado de la cita
            switch (cita.getEstado()) {
                case "Completado": // Confirmada
                    reporte.setCitasCompletadas(reporte.getCitasCompletadas() + 1);
                    reporte.setTotalIngresos(reporte.getTotalIngresos() + cita.getCosto());
                    break;
                case "En espera": // Reprogramada
                    reporte.setCitasEnEspera(reporte.getCitasEnEspera() + 1);
                    break;
                case "Confirmado": // Reprogramada
                    reporte.setCitasConfirmadas(reporte.getCitasConfirmadas() + 1);
                    break;
                case "Reprogramado": // Reprogramada
                    reporte.setCitasReprogramadas(reporte.getCitasReprogramadas() + 1);
                    break;
                case "Cancelado": // Cancelada
                    reporte.setCitasCanceladas(reporte.getCitasCanceladas() + 1);
                    break;

            }
            reporte.setTotalCitas(reporte.getTotalCitas() + 1);
            reportePorMes.put(mes, reporte);
        }

        return new ArrayList<>(reportePorMes.values());
    }

    // Método para obtener el mes en formato "MMMM yyyy" a partir de una fecha
    private String obtenerMes(LocalDate fecha) {
        return fecha.getMonth().getDisplayName(TextStyle.FULL, new Locale("es", "ES")) + " " + fecha.getYear();
    }
}
