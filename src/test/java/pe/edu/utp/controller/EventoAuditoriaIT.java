package pe.edu.utp.controller;

import java.sql.Statement;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import org.junit.Test;
import pe.edu.utp.dao.UsuarioDao;
import pe.edu.utp.integration.DbFixture;
import static org.junit.Assert.*;
import static org.mockito.Mockito.*;

/** R-08: desbloquear una cuenta deja rastro de quién lo hizo y a quién afectó. */
public class EventoAuditoriaIT extends DbFixture {

    private HttpServletRequest peticion() {
        HttpServletRequest req = mock(HttpServletRequest.class);
        HttpServletResponse res = mock(HttpServletResponse.class);
        HttpSession sesion = mock(HttpSession.class);
        when(req.getParameter("action")).thenReturn("desbloquear");
        when(req.getParameter("id")).thenReturn("4242");
        when(req.getParameter("formToken")).thenReturn("token-prueba");
        when(req.getSession()).thenReturn(sesion);
        when(req.getSession(false)).thenReturn(sesion);
        when(sesion.getAttribute("formToken")).thenReturn("token-prueba");
        when(sesion.getAttribute("idUsuario")).thenReturn(77);
        return req;
    }

    @Test public void desbloquearRegistraElEventoConActorYAfectado() throws Exception {
        UsuarioDao dao = mock(UsuarioDao.class);
        when(dao.resetearBloqueo(4242)).thenReturn(true);
        int antes = numero("SELECT COALESCE(MAX(idEvento),0) FROM Evento");
        try {
            new UsuarioController(dao).doPost(peticion(), mock(HttpServletResponse.class));
            assertEquals(1, numero("SELECT COUNT(*) FROM Evento WHERE idEvento>" + antes
                    + " AND Origen='Seguridad' AND Mensaje LIKE '%Cuenta desbloqueada%' "
                    + "AND Mensaje LIKE '%77%' AND Mensaje LIKE '%4242%'"));
        } finally {
            try (Statement s = db.createStatement()) {
                s.executeUpdate("DELETE FROM Evento WHERE idEvento>" + antes);
            }
        }
    }

    @Test public void siLaCuentaNoSeDesbloqueaNoSeAnunciaExito() throws Exception {
        UsuarioDao dao = mock(UsuarioDao.class);
        when(dao.resetearBloqueo(4242)).thenReturn(false);
        HttpServletResponse res = mock(HttpServletResponse.class);
        int antes = numero("SELECT COALESCE(MAX(idEvento),0) FROM Evento");
        new UsuarioController(dao).doPost(peticion(), res);
        verify(res, never()).sendRedirect(contains("usuarioDesbloqueadoOk"));
        assertEquals(0, numero("SELECT COUNT(*) FROM Evento WHERE idEvento>" + antes + " AND Mensaje LIKE '%Cuenta desbloqueada%'"));
    }
}
