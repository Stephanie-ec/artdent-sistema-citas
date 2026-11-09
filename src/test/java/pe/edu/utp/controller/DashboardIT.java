package pe.edu.utp.controller;
import java.math.BigDecimal;
import javax.servlet.RequestDispatcher;
import javax.servlet.http.*;
import org.junit.Test;
import static org.junit.Assert.*;
import static org.mockito.Mockito.*;
import pe.edu.utp.integration.DbFixture;

public class DashboardIT extends DbFixture {
    @Test public void dashboardYReporteRealesExponenElMismoTotalExacto() throws Exception {
        int id=cita(1,"Web","10:00");pago(id);
        HttpServletRequest dashboard=mock(HttpServletRequest.class),reportes=mock(HttpServletRequest.class);
        HttpServletResponse res=mock(HttpServletResponse.class);HttpSession session=mock(HttpSession.class);
        when(dashboard.getRequestDispatcher("ADMPInicio.jsp")).thenReturn(mock(RequestDispatcher.class));
        when(reportes.getRequestDispatcher("PDCReportes.jsp")).thenReturn(mock(RequestDispatcher.class));
        when(reportes.getSession()).thenReturn(session);when(session.getAttribute("TipoRol")).thenReturn("Administrador");
        when(reportes.getParameter("accion")).thenReturn("reportead");
        new DashboardController().doGet(dashboard,res);new ReporteController().doGet(reportes,res);
        org.mockito.ArgumentCaptor<Object> total=org.mockito.ArgumentCaptor.forClass(Object.class),kpi=org.mockito.ArgumentCaptor.forClass(Object.class);
        verify(dashboard).setAttribute(eq("totalIngresos"),total.capture());verify(reportes).setAttribute(eq("kpiIngresos"),kpi.capture());
        assertTrue(total.getValue() instanceof BigDecimal);assertEquals(0,((BigDecimal)total.getValue()).compareTo((BigDecimal)kpi.getValue()));
    }
}
