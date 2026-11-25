package pe.edu.utp.integration;

import java.sql.SQLException;
import java.sql.Statement;
import org.junit.Test;
import static org.junit.Assert.*;

/** R-01: el pago de la pasarela se registra una sola vez. */
public class PagoIdempotenteIT extends DbFixture {

    @Test public void existeElMetodoMercadoPago() throws Exception {
        assertEquals(1, numero("SELECT COUNT(*) FROM MetodoPago WHERE idMetodo=3 AND NombreMetodo='Mercado Pago'"));
    }

    @Test public void elCodigoDeTransaccionNoSePuedeRepetir() throws Exception {
        int primera = cita(1, "Web", "10:00");
        int segunda = cita(1, "Web", "11:00");
        insertar("INSERT INTO Pago(Monto,CodigoTransaccion,MetodoPago_idMetodo,Cita_idCita) VALUES(100,'MP:12345',3," + primera + ")");
        SQLException error = assertThrows(SQLException.class, () ->
                insertar("INSERT INTO Pago(Monto,CodigoTransaccion,MetodoPago_idMetodo,Cita_idCita) VALUES(100,'MP:12345',3," + segunda + ")"));
        assertEquals("23000", error.getSQLState());
        assertEquals(1, numero("SELECT COUNT(*) FROM Pago WHERE CodigoTransaccion='MP:12345'"));
        assertEquals(0, numero("SELECT COUNT(*) FROM Pago WHERE Cita_idCita=" + segunda));
    }

    @Test public void elEfectivoSinCodigoSiguePermitidoVariasVeces() throws Exception {
        // NULL no participa del índice único: dos cobros en efectivo conviven
        int uno = cita(1, "Presencial", "12:00");
        int dos = cita(1, "Presencial", "13:00");
        try (Statement s = db.createStatement()) {
            s.executeUpdate("INSERT INTO Pago(Monto,MetodoPago_idMetodo,Cita_idCita) VALUES(100,2," + uno + ")");
            s.executeUpdate("INSERT INTO Pago(Monto,MetodoPago_idMetodo,Cita_idCita) VALUES(100,2," + dos + ")");
        }
        assertEquals(2, numero("SELECT COUNT(*) FROM Pago WHERE Cita_idCita IN (" + uno + "," + dos + ")"));
    }
}
