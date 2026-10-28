/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package pe.edu.utp.controller;

import pe.edu.utp.dao.CitaDao;
import pe.edu.utp.dao.ReservaDao;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;
import pe.edu.utp.daoImpl.CitaDaoImpl;
import pe.edu.utp.daoImpl.ReservaDaoImpl;
import pe.edu.utp.entity.Cita;
import pe.edu.utp.entity.Reserva;


/**
 *
 * @author alex0
 */
@WebServlet("/DashboardController")
public class DashboardController extends HttpServlet {
    private CitaDao citaDao = new CitaDaoImpl();
    private ReservaDao reservaDao = new ReservaDaoImpl();
    

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        if (action == null) {
            action = "dashboard";
        }

        switch (action) {
            case "dashboard":
                showDashboard(request, response);
                break;
            // Add other cases as needed
            default:
                showDashboard(request, response);
                break;
        }
    }

    private void showDashboard(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        List<Cita> citasRecientes = citaDao.listarCitasRecientes();
        List<Reserva> reservasRecientes = reservaDao.listarReservasRecientes();
        int totalCitasReservas = citaDao.obtenerTotalCitasReservas(); // Implementar en el DAO
    double totalIngresos = reservaDao.obtenerTotalIngresos();
    
        request.setAttribute("totalCitasReservas", totalCitasReservas);
    request.setAttribute("totalIngresos", totalIngresos);
        request.setAttribute("citasRecientes", citasRecientes);
        request.setAttribute("reservasRecientes", reservasRecientes);

        request.getRequestDispatcher("ADMPInicio.jsp").forward(request, response);
    }
}