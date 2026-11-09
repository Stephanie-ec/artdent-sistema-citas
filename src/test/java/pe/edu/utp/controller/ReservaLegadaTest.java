package pe.edu.utp.controller;

import javax.servlet.RequestDispatcher;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.junit.Test;
import static org.mockito.Mockito.*;

public class ReservaLegadaTest {
    @Test public void postLegadoPasaAlControladorOficialSinEscribirDatos() throws Exception {
        HttpServletRequest req = mock(HttpServletRequest.class);
        HttpServletResponse res = mock(HttpServletResponse.class);
        RequestDispatcher dispatcher = mock(RequestDispatcher.class);
        when(req.getRequestDispatcher("/CitaController")).thenReturn(dispatcher);
        when(req.getRequestDispatcher("error.jsp")).thenReturn(mock(RequestDispatcher.class));
        new ReservaController().doPost(req, res);
        verify(dispatcher).forward(req, res);
        verifyNoInteractions(res);
    }
}
