package pe.edu.utp.filter;
import javax.servlet.*;
import javax.servlet.http.*;
import org.junit.*;
import static org.mockito.Mockito.*;

public class AuthFilterTest {
    @Test public void paginaLegadaDeReservaPuedeRedirigirAlFormularioPublico() throws Exception {
        HttpServletRequest req=mock(HttpServletRequest.class);HttpServletResponse res=mock(HttpServletResponse.class);FilterChain chain=mock(FilterChain.class);
        when(req.getServletPath()).thenReturn("/reservacita.jsp");
        new AuthFilter(id->{throw new AssertionError("No hay sesion de personal");}).doFilter(req,res,chain);
        verify(chain).doFilter(req,res);verify(res,never()).sendRedirect(anyString());
    }
    @Test public void recursosPublicosNoDependenDeLaBaseDeDatos() throws Exception {
        HttpServletRequest req=mock(HttpServletRequest.class);HttpServletResponse res=mock(HttpServletResponse.class);FilterChain chain=mock(FilterChain.class);
        when(req.getServletPath()).thenReturn("/js/session-guard.js");
        new AuthFilter(id->{throw new AssertionError("No debe consultar la BD por un script publico");}).doFilter(req,res,chain);
        verify(chain).doFilter(req,res);verifyNoInteractions(res);
    }
    private HttpServletRequest req;private HttpServletResponse res;private FilterChain chain;
    @Before public void preparar(){req=mock(HttpServletRequest.class);res=mock(HttpServletResponse.class);chain=mock(FilterChain.class);when(req.getServletPath()).thenReturn("/ADMPInicio.jsp");when(req.getContextPath()).thenReturn("/ArtDent");}
    @Test public void sinSesionRedirigeYProhibeCache() throws Exception {
        new AuthFilter(id->"Administrador").doFilter(req,res,chain);
        verify(res).setHeader("Cache-Control","no-cache, no-store, must-revalidate, max-age=0");
        verify(res).sendRedirect("/ArtDent/iniciosesion.jsp");verifyNoInteractions(chain);
    }
    @Test public void usuarioDesactivadoPierdeSesionYAcceso() throws Exception {
        HttpSession session=mock(HttpSession.class);when(req.getSession(false)).thenReturn(session);
        when(session.getAttribute("TipoRol")).thenReturn("Administrador");when(session.getAttribute("idUsuario")).thenReturn(1);
        new AuthFilter(id->null).doFilter(req,res,chain);verify(session).invalidate();verifyNoInteractions(chain);
    }
    @Test public void cambioDeRolEnBDRevocaPermisoAnterior() throws Exception {
        HttpSession session=mock(HttpSession.class);when(req.getSession(false)).thenReturn(session);
        when(session.getAttribute("TipoRol")).thenReturn("Administrador");when(session.getAttribute("idUsuario")).thenReturn(1);
        when(req.getRequestDispatcher("/error.jsp")).thenReturn(mock(RequestDispatcher.class));
        new AuthFilter(id->"Odontologo").doFilter(req,res,chain);verify(res).setStatus(403);verifyNoInteractions(chain);
    }
    @Test public void personalActivoEntraConRolActual() throws Exception {
        HttpSession session=mock(HttpSession.class);when(req.getSession(false)).thenReturn(session);
        when(session.getAttribute("TipoRol")).thenReturn("Administrador");when(session.getAttribute("idUsuario")).thenReturn(1);
        new AuthFilter(id->"Administrador").doFilter(req,res,chain);verify(chain).doFilter(req,res);
    }
}
