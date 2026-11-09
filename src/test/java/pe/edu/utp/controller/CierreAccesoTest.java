package pe.edu.utp.controller;
import javax.servlet.http.*;
import org.junit.Test;
import static org.mockito.Mockito.*;
import pe.edu.utp.utils.FormToken;
import static org.junit.Assert.*;

public class CierreAccesoTest {
    @Test public void noOfreceTransferirDeNuevoEnPagadasAnuladasOPendientesDeRevision() {
        for(Integer estado:new Integer[]{null,2,5,6})assertFalse(PagoManualController.admiteSolicitud(estado,false,false));
        for(int estado:new int[]{1,3,4}) {
            assertTrue(PagoManualController.admiteSolicitud(estado,false,false));
            assertFalse(PagoManualController.admiteSolicitud(estado,true,false));
            assertFalse(PagoManualController.admiteSolicitud(estado,false,true));
        }
    }
    @Test public void sinTitularidadNoPuedeConsultarComprobantesNiSolicitudes() throws Exception {
        for(String accion:new String[]{null,"adjunto"}) {
            HttpServletRequest req=mock(HttpServletRequest.class);HttpServletResponse res=mock(HttpServletResponse.class);
            when(req.getParameter("accion")).thenReturn(accion);
            new PagoManualController().doGet(req,res);verify(res).sendError(403);
        }
    }
    @Test public void formulariosSinTokenNoPuedenModificarPagosNiFicha() throws Exception {
        HttpServletRequest req=mock(HttpServletRequest.class);HttpServletResponse res=mock(HttpServletResponse.class);
        new PagoManualController().doPost(req,res);verify(res).sendError(403);
        res=mock(HttpServletResponse.class);new AtencionController().doPost(req,res);verify(res).sendError(403);
    }
    @Test public void secretariaNoAccedeAFichaClinicaYOdontologoNoReintentaCorreos() throws Exception {
        HttpServletRequest req=mock(HttpServletRequest.class);HttpServletResponse res=mock(HttpServletResponse.class);HttpSession s=mock(HttpSession.class);
        when(req.getSession(false)).thenReturn(s);when(s.getAttribute("TipoRol")).thenReturn("Secretaria");
        new AtencionController().doGet(req,res);verify(res).sendError(403);
        when(s.getAttribute("TipoRol")).thenReturn("Odontologo");res=mock(HttpServletResponse.class);
        new CorreoController().doGet(req,res);verify(res).sendError(403);
    }
    @Test public void tokenDebeCoincidirConSesion() {
        HttpServletRequest req=mock(HttpServletRequest.class);HttpSession s=mock(HttpSession.class);when(req.getSession(false)).thenReturn(s);
        when(s.getAttribute("formToken")).thenReturn("token-sesion");when(req.getParameter("formToken")).thenReturn("otro");assertFalse(FormToken.valido(req));
        when(req.getParameter("formToken")).thenReturn("token-sesion");assertTrue(FormToken.valido(req));
    }
}
