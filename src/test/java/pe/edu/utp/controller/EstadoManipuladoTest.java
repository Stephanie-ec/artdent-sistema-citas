package pe.edu.utp.controller;
import java.sql.SQLException;
import javax.servlet.RequestDispatcher;
import javax.servlet.http.*;
import pe.edu.utp.dao.*;
import pe.edu.utp.daoImpl.GestionCitaDao;
import org.junit.Test;
import static org.mockito.Mockito.*;

public class EstadoManipuladoTest {
    @Test public void estadoDelFormularioNoEvitaExigirPago() throws Exception {
        HttpServletRequest req=mock(HttpServletRequest.class); HttpServletResponse res=mock(HttpServletResponse.class);
        HttpSession session=mock(HttpSession.class); GestionCitaDao gestion=mock(GestionCitaDao.class);
        when(req.getSession(false)).thenReturn(session); when(session.getAttribute("TipoRol")).thenReturn("Secretaria");
        when(session.getAttribute("idUsuario")).thenReturn(2);
        when(req.getParameter("accion")).thenReturn("updateEstadoConfirmar");
        when(req.getParameter("idReserva")).thenReturn("18");
        when(req.getParameter("estado")).thenReturn("Reprogramado");
        doThrow(new SQLException("sinPago","45000")).when(gestion).cambiarEstado(18,3,2,true);
        new ReprogramacionController(gestion,mock(CitaDao.class),mock(ReservaDao.class)).doPost(req,res);
        verify(res).sendRedirect("ReservaController?accion=listar&error=sinPago");
        verify(req,never()).getParameter("estado");
    }
    @Test public void identificadorInvalidoDaError400Contextual() throws Exception {
        HttpServletRequest req=mock(HttpServletRequest.class); HttpServletResponse res=mock(HttpServletResponse.class);
        HttpSession session=mock(HttpSession.class); when(req.getSession(false)).thenReturn(session);
        when(session.getAttribute("TipoRol")).thenReturn("Secretaria");
        when(req.getParameter("accion")).thenReturn("deleteReserva"); when(req.getParameter("idReserva")).thenReturn("abc");
        RequestDispatcher vista=mock(RequestDispatcher.class); when(req.getRequestDispatcher("error.jsp")).thenReturn(vista);
        GestionCitaDao gestion=mock(GestionCitaDao.class);
        new ReprogramacionController(gestion,mock(CitaDao.class),mock(ReservaDao.class)).doPost(req,res);
        verify(res).setStatus(400); verify(vista).forward(req,res); verifyNoInteractions(gestion);
    }
}
