package pe.edu.utp.controller;
import com.google.gson.Gson;
import java.io.IOException;
import java.util.*;
import java.util.function.Supplier;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import pe.edu.utp.entity.Servicio;
import pe.edu.utp.utils.AsistenteDental;

@WebServlet("/api/chatbot")
public class ChatbotServlet extends HttpServlet {
    private final Supplier<List<Servicio>> catalogo;
    private final Gson json=new Gson(); // El escape HTML de Gson permanece activado.
    public ChatbotServlet(){this(() -> new pe.edu.utp.daoImpl.ServicioDaoImpl().listarServicios());}
    ChatbotServlet(Supplier<List<Servicio>> catalogo){this.catalogo=catalogo;}
    @Override protected void doPost(HttpServletRequest req,HttpServletResponse res) throws ServletException,IOException {
        req.setCharacterEncoding("UTF-8");res.setContentType("application/json;charset=UTF-8");
        String pregunta=req.getParameter("pregunta");Map<String,Object> salida;
        if(pregunta==null||pregunta.trim().isEmpty()||pregunta.length()>1000) {
            res.setStatus(400);salida=Collections.singletonMap("mensaje","Escribe una consulta dental de hasta 1000 caracteres.");
        } else if(!AsistenteDental.esDental(pregunta)) {
            salida=Collections.singletonMap("mensaje",AsistenteDental.ALCANCE);
        } else {
            try {salida=pe.edu.utp.utils.AsistenteIA.responder(pregunta,catalogo.get(),pe.edu.utp.utils.AsistenteIA::gemini);}
            catch(IllegalStateException e) {
                res.setStatus(503);salida=Collections.singletonMap("mensaje","No pude cargar el catálogo. Intente nuevamente o comuníquese con ArtDent.");
            }
        }
        res.getWriter().write(json.toJson(salida));
    }
}
