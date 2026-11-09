package pe.edu.utp.controller;
import java.util.*;
import javax.servlet.RequestDispatcher;
import javax.servlet.http.*;
import org.junit.Test;
import static org.mockito.Mockito.*;
import pe.edu.utp.dao.PagoDao;

public class PortalReservaTest {
    @Test public void reservaPagadaMuestraPortalSinRedirigirALaBoleta() throws Exception {
        HttpServletRequest req=mock(HttpServletRequest.class);HttpServletResponse res=mock(HttpServletResponse.class);
        HttpSession session=mock(HttpSession.class);RequestDispatcher vista=mock(RequestDispatcher.class);
        PagoDao dao=mock(PagoDao.class);
        Map<String,Object> r=new HashMap<>();r.put("pagado",true);r.put("idCita",18);r.put("estadoId",5);
        when(req.getParameter("action")).thenReturn("consultar");when(req.getParameter("codigo")).thenReturn("ART-RES-00018");
        when(req.getParameter("dni")).thenReturn("12345678");when(req.getSession()).thenReturn(session);
        when(req.getRequestDispatcher("consultareserva.jsp")).thenReturn(vista);when(dao.consultarReserva(18,"12345678")).thenReturn(r);
        new PagoController(dao).doGet(req,res);
        verify(req).setAttribute("reserva",r);verify(vista).forward(req,res);verify(res,never()).sendRedirect(anyString());
    }
    @Test public void pagoCanceladoDevuelve409SinRegistrar() throws Exception {
        HttpServletRequest req=mock(HttpServletRequest.class);HttpServletResponse res=mock(HttpServletResponse.class);
        RequestDispatcher vista=mock(RequestDispatcher.class);PagoDao dao=mock(PagoDao.class);
        when(req.getParameter("action")).thenReturn("registrarPagoEfectivo");when(req.getParameter("idCita")).thenReturn("18");
        when(req.getRequestDispatcher("error.jsp")).thenReturn(vista);when(dao.obtenerEstadoCita(18)).thenReturn(5);
        new PagoController(dao).doPost(req,res);verify(res).setStatus(409);verify(dao,never()).registrarPagoYComprobante(any(),any());
    }
}
