/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package pe.edu.utp.controller;

import java.io.IOException;
import java.sql.SQLException;
import java.util.Collections;
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

import pe.edu.utp.entity.VerReserva;
import pe.edu.utp.entity.VerCita;


@WebServlet(name = "NotificacionesController", urlPatterns = {"/NotificacionesController"})
public class NotificacionesController extends HttpServlet {

    ReservaDao reservaDao = new ReservaDaoImpl();
    CitaDao citaDao = new CitaDaoImpl();

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String accion = request.getParameter("accion");

        try {
            if ("listarReservas".equals(accion)) {
                listarNotificacionesReservas(request, response);  // Método para listar todas las reservas
            } else if("listarCitas".equals(accion)){
                listarNotificacionesCitas(request, response);  // Método para listar todas las reservas
            }else{
                request.getRequestDispatcher("PDCNotificaciones.jsp").forward(request, response); // Página principal
            }

        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Error al listar notificaciones: " + e.getMessage());
            request.getRequestDispatcher("error.jsp").forward(request, response);
        }

    }

    // Método para listar todas las reservas
    private void listarNotificacionesReservas(HttpServletRequest request, HttpServletResponse response) throws SQLException, ServletException, IOException {
        int idUsuario = (int) request.getSession().getAttribute("idUsuario"); // Obtener ID del usuario desde la sesión
        List<VerReserva> VerReserva = reservaDao.listarTodasReservas(idUsuario);  // Método que debes implementar en tu ReservaDao

        Collections.reverse(VerReserva);
        request.setAttribute("VerReserva", VerReserva);  // Enviamos la lista de reservas a la JSP
        request.setAttribute("tipoLista", "reserva");  // Enviamos la lista de reservas a la JSP
        request.getRequestDispatcher("PDCNotificaciones.jsp").forward(request, response);
    }
    // Método para listar todas las reservas
    private void listarNotificacionesCitas(HttpServletRequest request, HttpServletResponse response) throws SQLException, ServletException, IOException {
        int idUsuario = (int) request.getSession().getAttribute("idUsuario"); // Obtener ID del usuario desde la sesión
        List<VerCita> VerCita = citaDao.listarTodasCitas(idUsuario);  // Método que debes implementar en tu ReservaDao
        Collections.reverse(VerCita);
        request.setAttribute("VerCita", VerCita);  // Enviamos la lista de reservas a la JSP
        request.setAttribute("tipoLista", "cita");  // Enviamos la lista de reservas a la JSP
        request.getRequestDispatcher("PDCNotificaciones.jsp").forward(request, response);
    }
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>

}
