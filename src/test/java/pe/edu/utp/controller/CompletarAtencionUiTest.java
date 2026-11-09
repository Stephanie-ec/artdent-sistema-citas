package pe.edu.utp.controller;

import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import org.junit.Test;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;

/**
 * F-02 / F-07: finalizar una cita exige registrar la ficha clínica.
 * El SQL rechaza el cambio directo al estado 2, así que la lista de solicitudes
 * debe abrir AtencionController y no ReprogramacionController.
 */
public class CompletarAtencionUiTest {

    private static String solicitudes() throws Exception {
        return new String(Files.readAllBytes(Paths.get("src/main/webapp/PDCSolicitudes.jsp")),
                StandardCharsets.UTF_8);
    }

    @Test
    public void completarAtencionAbreLaFichaEnAmbasListas() throws Exception {
        String jsp = solicitudes();
        assertFalse("El cambio directo de estado ya no finaliza citas: use la ficha",
                jsp.contains("value=\"updateEstadoCompletado\"")
                || jsp.contains("value=\"updateEstadoCompletadoCita\""));
        assertEquals("Solicitudes Web y presenciales deben abrir la ficha",
                2, jsp.split("action=\"AtencionController\"", -1).length - 1);
    }

    @Test
    public void cobroNoInventaUnImporteFijo() throws Exception {
        String jsp = solicitudes();
        assertFalse("El modal no debe mostrar S/ 100 cuando el importe guardado es 0",
                jsp.contains("'100.00'"));
        assertTrue("El monto del cobro se muestra desde el servidor y no se edita",
                jsp.contains("value=\"${reserva.importe}\" readonly")
                && jsp.contains("value=\"${cita.costo}\" readonly"));
    }

    @Test
    public void formulariosDeFichaUsanElParametroCita() throws Exception {
        String jsp = solicitudes();
        assertTrue(jsp.contains("name=\"cita\" value=\"${reserva.idReserva}\""));
        assertTrue(jsp.contains("name=\"cita\" value=\"${cita.idCita}\""));
    }
}
