package pe.edu.utp.integration;
import java.sql.CallableStatement;
import org.junit.Test;
import static org.junit.Assert.*;

public class BajaLogicaIT extends DbFixture {
    @Test public void desactivarConservaCitaPagoYComprobante() throws Exception {
        int id = cita(3, "Web", "10:00");
        pago(id);
        try (CallableStatement s = db.prepareCall("{call sp_eliminarUsuario(?)}")) { s.setInt(1, doctor); s.execute(); }
        assertEquals("F-04: debe conservar la cita", 1, numero("SELECT COUNT(*) FROM Cita WHERE idCita=" + id));
        assertEquals(1, numero("SELECT COUNT(*) FROM Pago WHERE Cita_idCita=" + id));
        assertEquals(1, numero("SELECT COUNT(*) FROM Comprobante WHERE Pago_idPago IN(SELECT idPago FROM Pago WHERE Cita_idCita=" + id + ")"));
        assertEquals(0, numero("SELECT Activo FROM Usuario WHERE idUsuario=" + doctor));
        assertEquals(0, numero("SELECT Disponibilidad FROM Usuario_Servicio WHERE idUsuario=" + doctor));
        assertFalse(new pe.edu.utp.daoImpl.UsuarioDaoImpl().autenticar(
                String.valueOf(numero("SELECT DNI FROM Usuario WHERE idUsuario=" + doctor)), "123456").isExito());
    }
}
