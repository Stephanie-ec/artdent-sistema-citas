package pe.edu.utp.controller;

import java.math.BigDecimal;
import java.util.Arrays;
import java.util.List;
import org.junit.Test;
import pe.edu.utp.entity.ReporteMensual;
import static org.junit.Assert.*;

/** R-12: el CSV abre en Excel con tildes y cuadra con la pantalla. */
public class ReporteCsvTest {

    private ReporteMensual mes(String nombre, int citas, int reservas, String ingresos) {
        ReporteMensual r = new ReporteMensual(nombre, 0, citas, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
        r.setTotalReservas(reservas);
        r.setCitasNoAsistio(1);
        r.setReservasNoAsistio(2);
        r.setTotalIngresos(new BigDecimal(ingresos));
        return r;
    }

    @Test public void elArchivoEmpiezaConBomYUsaPuntoYComa() {
        List<ReporteMensual> filas = Arrays.asList(mes("Noviembre", 3, 2, "150.00"));
        String csv = ReporteController.construirCsv(filas);
        assertTrue(csv.startsWith("\uFEFF"));
        assertTrue(csv.contains("Mes;Ingresos (S/);Citas completadas"));
        assertTrue(csv.contains("\r\n"));
        assertTrue(csv.contains("\"Noviembre\""));
    }

    @Test public void losNoAsistioYLosTotalesSeSuman() {
        String csv = ReporteController.construirCsv(Arrays.asList(
                mes("Octubre", 1, 1, "100.50"), mes("Noviembre", 2, 3, "99.50")));
        String total = null;
        for (String linea : csv.split("\r\n")) {
            if (linea.startsWith("TOTAL;")) {
                total = linea;
            }
        }
        assertNotNull(total);
        assertEquals("TOTAL;200.00;0;0;6;;;7;", total);
    }
}
