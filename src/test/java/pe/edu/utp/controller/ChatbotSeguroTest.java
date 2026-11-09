package pe.edu.utp.controller;
import java.io.*;
import java.math.BigDecimal;
import java.util.*;
import javax.servlet.http.*;
import org.junit.Test;
import static org.junit.Assert.*;
import static org.mockito.Mockito.*;
import pe.edu.utp.utils.AsistenteDental;
import pe.edu.utp.entity.Servicio;

public class ChatbotSeguroTest {
    @Test public void reconoceErroresFrecuentesSinRecomendarServiciosParaLaCasa() {
        Servicio limpieza=new Servicio();limpieza.setIdServicio(1);limpieza.setTipoServicio("Limpieza Dental");limpieza.setCosto(new BigDecimal("40"));
        assertTrue("ensias debe orientar sobre salud bucal",AsistenteDental.responder("me sangran las ensias",Arrays.asList(limpieza)).containsKey("servicio"));
        assertFalse(AsistenteDental.responder("me duele el pie",Arrays.asList(limpieza)).containsKey("servicio"));
    }
    @Test public void reconoceCariezComoConsultaDental(){assertTrue("cariez debe entenderse como consulta dental",AsistenteDental.esDental("tengo cariez"));}
    @Test public void noRecomiendaServiciosParaLimpiezaDeCasa(){assertFalse("limpieza de casa no es dental",AsistenteDental.responder("limpieza de casa",Collections.emptyList()).get("mensaje").toString().contains("síntomas"));}
    @Test public void falloDelCatalogoDevuelveJSON503SinDetallesInternos() throws Exception {
        HttpServletRequest req=mock(HttpServletRequest.class);HttpServletResponse res=mock(HttpServletResponse.class);StringWriter out=new StringWriter();
        when(req.getParameter("pregunta")).thenReturn("limpieza dental");when(res.getWriter()).thenReturn(new PrintWriter(out));
        new ChatbotServlet(()->{throw new IllegalStateException("detalle interno");}).doPost(req,res);
        verify(res).setStatus(503);assertFalse(out.toString().contains("detalle interno"));assertTrue(out.toString().contains("mensaje"));
    }
    @Test public void consultasAjenasNoAccedenABaseNiRecomiendanLimpieza() throws Exception {
        for(String pregunta:new String[]{"me duele el pie","me duele la rodilla","problemas de motor","dolor de estómago","me duele la cabeza","2+2"}) {
            HttpServletRequest req=mock(HttpServletRequest.class);HttpServletResponse res=mock(HttpServletResponse.class);StringWriter out=new StringWriter();
            when(req.getParameter("pregunta")).thenReturn(pregunta);when(res.getWriter()).thenReturn(new PrintWriter(out));
            new ChatbotServlet(()->{throw new AssertionError("No debe consultar el catalogo para una pregunta ajena");}).doPost(req,res);
            assertTrue(out.toString().contains("salud bucal"));assertFalse(out.toString().contains("Limpieza"));
        }
    }
    @Test public void noConfundePiezaConPieYNoDiagnostica() {
        assertFalse(AsistenteDental.esDental("limpieza de motor"));
        assertTrue(AsistenteDental.esDental("perdí una pieza dental"));
        Map<String,Object> r=AsistenteDental.responder("me duele una muela",Collections.emptyList());
        assertFalse(r.containsKey("servicio"));assertTrue(r.get("mensaje").toString().contains("no es un diagnóstico"));
    }
    @Test public void payloadYCatalogoMaliciosoNoGeneranHTML() throws Exception {
        Servicio s=new Servicio();s.setIdServicio(1);s.setTipoServicio("Limpieza <img src=x onerror=alert(1)>");s.setCosto(new BigDecimal("50"));
        HttpServletRequest req=mock(HttpServletRequest.class);HttpServletResponse res=mock(HttpServletResponse.class);StringWriter out=new StringWriter();
        when(req.getParameter("pregunta")).thenReturn("limpieza dental <script>alert(1)</script>");when(res.getWriter()).thenReturn(new PrintWriter(out));
        new ChatbotServlet(()->Arrays.asList(s)).doPost(req,res);
        assertFalse(out.toString().contains("<"));assertFalse(out.toString().contains("<script>"));
        assertTrue(out.toString().contains("\\u003cimg"));
    }
}
