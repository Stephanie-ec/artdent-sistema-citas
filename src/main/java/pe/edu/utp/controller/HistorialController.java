/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package pe.edu.utp.controller;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import pe.edu.utp.dao.CitaDao;
import pe.edu.utp.dao.ReservaDao;
import pe.edu.utp.daoImpl.CitaDaoImpl;
import pe.edu.utp.daoImpl.ReservaDaoImpl;
import pe.edu.utp.entity.VerCita;
import pe.edu.utp.entity.VerReserva;

/**
 *
 * @author AMD
 */
public class HistorialController extends HttpServlet {
    
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            /* TODO output your page here. You may use following sample code. */
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Servlet HistorialController</title>");            
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet HistorialController at " + request.getContextPath() + "</h1>");
            out.println("</body>");
            out.println("</html>");
        }
    }
    
    ReservaDao reservaDao = new ReservaDaoImpl();
    CitaDao citaDao = new CitaDaoImpl();
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
    String accion = request.getParameter("accion");

        try {
            if ("ListarHistorialReservas".equals(accion)) {
                listarHistorialRe(request, response);  // Método para listar todas las reservas
            } else if ("ListarHistorialCitas".equals(accion)) {
                listarHistorialCi(request, response); // Método para listar todas las citas
            } else if("VerDetalleRe".equals(accion)){
                VerDetalleRe(request, response);
            }else if("VerDetalleCi".equals(accion)){
                VerDetalleCi(request, response);
            }else{
                request.getRequestDispatcher("PDCCalendario.jsp").forward(request, response); // Página principal
            }    
            
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Error al listar reservas: " + e.getMessage());
            request.getRequestDispatcher("error.jsp").forward(request, response);
        }

    }
    
    // Método para listar todas las reservas
    private void listarHistorialRe(HttpServletRequest request, HttpServletResponse response) throws SQLException, ServletException, IOException {
        int idUsuario = (int) request.getSession().getAttribute("idUsuario"); // Obtener ID del usuario desde la sesión
        List<VerReserva> VerReserva = reservaDao.listarHistorialReservas(idUsuario);  // Método que debes implementar en tu ReservaDao
        request.setAttribute("VerReserva", VerReserva);  // Enviamos la lista de reservas a la JSP
        request.setAttribute("tipoLista", "hisRe"); // Agregar tipo de lista
        request.getRequestDispatcher("PDCHistorial.jsp").forward(request, response);
    }

    private void listarHistorialCi(HttpServletRequest request, HttpServletResponse response) throws SQLException, ServletException, IOException {
        int idUsuario = (int) request.getSession().getAttribute("idUsuario"); 
        List<VerCita> VerCita = citaDao.listarHistorialCitas(idUsuario); 
        String pacienteNom = request.getParameter("pacienteNom");
        if (pacienteNom != null && !pacienteNom.trim().isEmpty() && VerCita != null) {
            String q = pacienteNom.trim().toLowerCase();
            VerCita.removeIf(c -> c.getNombrePaciente() == null || !(c.getNombrePaciente() + " " + c.getApellidoPaciente()).toLowerCase().contains(q));
            request.setAttribute("filtroPaciente", pacienteNom.trim());
        }
        request.setAttribute("VerCita", VerCita);  
        request.setAttribute("tipoLista", "hisCi"); 
        request.getRequestDispatcher("PDCHistorial.jsp").forward(request, response);
    }
    
    private void VerDetalleRe(HttpServletRequest request, HttpServletResponse response) throws SQLException, ServletException, IOException {
        int idReserva = Integer.parseInt(request.getParameter("id"));
        List<VerReserva> VerReserva = reservaDao.DetalleReserva(idReserva);  // Método que debes implementar en tu ReservaDao
        request.setAttribute("VerReserva", VerReserva);  // Enviamos la lista de reservas a la JSP
        request.setAttribute("tipoLista", "DetRe"); // Agregar tipo de lista
        request.getRequestDispatcher("DetallesHistorial.jsp").forward(request, response);
    }
    
    private void VerDetalleCi(HttpServletRequest request, HttpServletResponse response) throws SQLException, ServletException, IOException {
        int idCita = Integer.parseInt(request.getParameter("id"));
        List<VerCita> VerCita = citaDao.DetalleCita(idCita); 
        request.setAttribute("VerCita", VerCita);  
        request.setAttribute("tipoLista", "DetCi"); 
        request.getRequestDispatcher("DetallesHistorial.jsp").forward(request, response);
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
