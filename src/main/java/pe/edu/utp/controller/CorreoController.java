package pe.edu.utp.controller;
import java.io.IOException;
import java.sql.SQLException;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import pe.edu.utp.daoImpl.CorreoDao;
import pe.edu.utp.utils.FormToken;
@WebServlet("/CorreoController")
public class CorreoController extends HttpServlet {
    private boolean permitido(HttpServletRequest req){HttpSession s=req.getSession(false);Object rol=s==null?null:s.getAttribute("TipoRol");return "Administrador".equals(rol)||"Secretaria".equals(rol);}
    @Override protected void doGet(HttpServletRequest req,HttpServletResponse res) throws ServletException,IOException {
        if(!permitido(req)){res.sendError(403);return;}
        try{req.setAttribute("correos",new CorreoDao().listar());FormToken.obtener(req);req.getRequestDispatcher("/WEB-INF/correos.jsp").forward(req,res);}
        catch(SQLException|IllegalStateException e){res.sendError(503,"No se pudo consultar la cola de correo.");}
    }
    @Override protected void doPost(HttpServletRequest req,HttpServletResponse res) throws IOException {
        if(!permitido(req)||!FormToken.valido(req)){res.sendError(403);return;}
        try {new CorreoDao().reintentar(Long.parseLong(req.getParameter("id")));res.sendRedirect("CorreoController");}
        catch(NumberFormatException e){res.sendError(400);}catch(SQLException|IllegalStateException e){res.sendError(503,"No se pudo reintentar.");}
    }
}
