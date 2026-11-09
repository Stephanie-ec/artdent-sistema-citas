package pe.edu.utp.controller;
import java.io.IOException;
import java.sql.SQLException;
import java.util.Map;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import pe.edu.utp.daoImpl.AtencionDao;
import pe.edu.utp.utils.*;

@WebServlet("/AtencionController")
public class AtencionController extends HttpServlet {
    private final AtencionDao dao=new AtencionDao();
    private int actor(HttpServletRequest req) {
        HttpSession s=req.getSession(false);String rol=s==null?"":String.valueOf(s.getAttribute("TipoRol"));
        if(!"Administrador".equals(rol)&&!"Odontologo".equals(rol))return 0;
        return Integer.parseInt(String.valueOf(s.getAttribute("idUsuario")));
    }
    @Override protected void doGet(HttpServletRequest req,HttpServletResponse res) throws ServletException,IOException {
        try {
            int actor=actor(req);if(actor==0){res.sendError(403);return;}
            int cita=Integer.parseInt(req.getParameter("cita"));Map<String,Object> ficha=dao.consultar(cita,actor);
            if(ficha==null){res.sendError(403);return;}
            req.setAttribute("ficha",ficha);FormToken.obtener(req);req.getRequestDispatcher("/WEB-INF/atencion.jsp").forward(req,res);
        } catch(NumberFormatException e){res.sendError(400);}
          catch(SQLException|IllegalStateException e){error(req,res,503,"No se pudo consultar la atención.");}
    }
    @Override protected void doPost(HttpServletRequest req,HttpServletResponse res) throws ServletException,IOException {
        req.setCharacterEncoding("UTF-8");
        try {
            if(!FormToken.valido(req)||actor(req)==0){res.sendError(403);return;}
            int cita=Integer.parseInt(req.getParameter("cita"));
            dao.registrar(cita,actor(req),req.getParameter("diagnostico"),req.getParameter("tratamiento"),req.getParameter("observaciones"));
            NotificacionService.notificar(cita,2,"Atención completada",null,"Su atención ha finalizado. Gracias por confiar en ArtDent.");
            res.sendRedirect("AtencionController?cita="+cita+"&guardado=1");
        } catch(NumberFormatException e){res.sendError(400);}
          catch(SQLException e){error(req,res,"45000".equals(e.getSQLState())?409:503,"45000".equals(e.getSQLState())?e.getMessage():"No se pudo registrar la atención. Consulte la ficha antes de reintentar.");}
          catch(IllegalStateException e){error(req,res,503,"No se pudo guardar. Consulte la ficha antes de reintentar.");}
    }
    private void error(HttpServletRequest req,HttpServletResponse res,int status,String mensaje) throws ServletException,IOException {
        res.setStatus(status);req.setAttribute("error",mensaje);req.setAttribute("volverUrl","ReservaController?accion=listarReservasPorDia");req.getRequestDispatcher("/error.jsp").forward(req,res);
    }
}
