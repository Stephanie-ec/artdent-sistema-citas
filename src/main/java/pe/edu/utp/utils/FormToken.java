package pe.edu.utp.utils;
import javax.servlet.http.*;
public final class FormToken {
    private FormToken() { }
    public static String obtener(HttpServletRequest req) {
        HttpSession s=req.getSession();synchronized(s) {
            String token=(String)s.getAttribute("formToken");
            if(token==null){token=java.util.UUID.randomUUID().toString();s.setAttribute("formToken",token);}return token;
        }
    }
    public static boolean valido(HttpServletRequest req) {
        HttpSession s=req.getSession(false);Object esperado=s==null?null:s.getAttribute("formToken");
        return esperado!=null&&esperado.equals(req.getParameter("formToken"));
    }
}
