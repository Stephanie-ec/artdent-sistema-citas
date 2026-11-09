package pe.edu.utp.controller;
import javax.servlet.http.*;
import pe.edu.utp.dao.UsuarioDao;
import pe.edu.utp.entity.Usuario;
import org.junit.*;
import static org.mockito.Mockito.*;
import static org.junit.Assert.*;

public class UsuarioGestionTest {
    private UsuarioDao dao; private HttpServletRequest req; private HttpServletResponse res;
    @Before public void preparar() {
        dao=mock(UsuarioDao.class);req=mock(HttpServletRequest.class);res=mock(HttpServletResponse.class);
        when(req.getParameter("nombre")).thenReturn("Ana");when(req.getParameter("apellido")).thenReturn("Perez");
        when(req.getParameter("dni")).thenReturn("12345678");when(req.getParameter("telefono")).thenReturn("987654321");
        when(req.getParameter("email")).thenReturn("ana@example.test");when(req.getParameter("direccion")).thenReturn("Calle Prueba");
        when(req.getParameter("fechanacimiento")).thenReturn("1990-01-01");when(req.getParameter("clave")).thenReturn("123456");
        when(req.getParameter("rol")).thenReturn("3");when(req.getParameter("action")).thenReturn("add");
    }
    @Test public void dniDuplicadoInformaYNoGuarda() throws Exception {
        when(dao.existeDni("12345678",0)).thenReturn(true);
        new UsuarioController(dao).doPost(req,res);
        verify(res).sendRedirect(contains("error=El+DNI+ya+se+encuentra+registrado"));
        verify(dao,never()).registrarUsuario(any());
    }
    @Test public void odontologoCreadoVaADisponibilidadConIdGenerado() throws Exception {
        when(dao.registrarUsuario(any())).thenAnswer(inv -> {((Usuario)inv.getArgument(0)).setIdUsuario(42);return true;});
        new UsuarioController(dao).doPost(req,res);
        verify(res).sendRedirect("UsuarioController?action=disponibilidad&id=42&msg=configureDisponibilidad");
    }
    @Test public void actualizacionExcluyeAlMismoUsuario() throws Exception {
        when(req.getParameter("action")).thenReturn("update");when(req.getParameter("id")).thenReturn("42");
        when(req.getParameter("clave")).thenReturn("");when(dao.actualizarUsuario(any())).thenReturn(true);
        new UsuarioController(dao).doPost(req,res);
        verify(dao).existeDni("12345678",42);
        verify(res).sendRedirect("UsuarioController?action=list&msg=usuarioActualizadoOk");
    }
    @Test public void falloDeEscrituraNoSeAnunciaComoExito() throws Exception {
        new UsuarioController(dao).doPost(req,res);
        verify(res).sendRedirect(contains("error="));
    }
    @Test public void fechaInexistenteNoLlegaAlDao() throws Exception {
        when(req.getParameter("fechanacimiento")).thenReturn("1990-02-30");
        new UsuarioController(dao).doPost(req,res);verifyNoInteractions(dao);
        verify(res).sendRedirect(contains("error="));
    }
}
