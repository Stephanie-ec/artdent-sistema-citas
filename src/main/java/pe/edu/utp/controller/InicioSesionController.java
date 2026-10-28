/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package pe.edu.utp.controller;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import pe.edu.utp.dao.UsuarioDao;
import pe.edu.utp.daoImpl.UsuarioDaoImpl;
import pe.edu.utp.dto.InicioSesionDTO;
import pe.edu.utp.dto.LoginResultDTO;

/**
 *
 * @author Christhian
 */
public class InicioSesionController extends HttpServlet {

    private UsuarioDao udao = new UsuarioDaoImpl();

    /**
     * Processes requests for both HTTP <code>GET</code> and <code>POST</code>
     * methods.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");

        String dni = request.getParameter("document");
        String clave = request.getParameter("password");
        if (dni != null) {
            dni = dni.trim();
        }
        if (clave != null) {
            clave = clave.trim();
        }

        HttpSession sesion = request.getSession();
        LoginResultDTO resultado = udao.autenticar(dni, clave);
        if (resultado != null && resultado.isExito() && resultado.getUsuario() != null) {
            InicioSesionDTO user = resultado.getUsuario();
            sesion.setAttribute("idUsuario", user.getIdUsuario());
            sesion.setAttribute("Nombre", user.getNombre());
            sesion.setAttribute("Apellido", user.getApellido());
            sesion.setAttribute("Dni", user.getDni());
            sesion.setAttribute("TipoRol", user.getTipoRol());
            String rol = user.getTipoRol();
            if ("Administrador".equalsIgnoreCase(rol)) {
                response.sendRedirect("DashboardController?action=dashboard");
            } else if ("Odontologo".equalsIgnoreCase(rol)) {
                response.sendRedirect("ReservaController?accion=listarReservasPorDia");
            } else if ("Secretaria".equalsIgnoreCase(rol)) {
                response.sendRedirect("ReservaController?accion=listar");
            } else {
                response.sendRedirect("ReservaController?accion=listarReservasPorDia");
            }

        } else {
            request.setAttribute("errorMensaje", resultado != null ? resultado.getMensaje() : "Usuario y/o contraseña incorrectos.");
            request.setAttribute("bloqueado", resultado != null && resultado.isBloqueado());
            request.setAttribute("intentosRestantes", resultado != null ? resultado.getIntentosRestantes() : 5);
            request.setAttribute("minutosRestantes", resultado != null ? resultado.getMinutosRestantes() : 0);
            request.getRequestDispatcher("iniciosesionerror.jsp").forward(request, response);
        }
    }

    // <editor-fold defaultstate="collapsed" desc="HttpServlet methods. Click on the + sign on the left to edit the code.">
    /**
     * Handles the HTTP <code>GET</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    /**
     * Handles the HTTP <code>POST</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    /**
     * Returns a short description of the servlet.
     *
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>

}
