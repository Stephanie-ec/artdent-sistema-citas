package pe.edu.utp.utils;

import java.time.LocalDateTime;
import org.junit.Test;
import static org.junit.Assert.*;

/** R-03: solo las citas entre 23 y 25 horas adelante reciben recordatorio. */
public class RecordatorioServiceTest {

    private final LocalDateTime ahora = LocalDateTime.of(2026, 11, 22, 9, 0);

    @Test public void aceptaLaVentanaDe23A25Horas() {
        assertTrue(RecordatorioService.enVentana(ahora.plusHours(23), ahora));
        assertTrue(RecordatorioService.enVentana(ahora.plusHours(24), ahora));
        assertTrue(RecordatorioService.enVentana(ahora.plusHours(25), ahora));
    }

    @Test public void rechazaFueraDeLaVentana() {
        assertFalse(RecordatorioService.enVentana(ahora.plusHours(22).plusMinutes(59), ahora));
        assertFalse(RecordatorioService.enVentana(ahora.plusHours(25).plusMinutes(1), ahora));
        assertFalse(RecordatorioService.enVentana(ahora.plusHours(48), ahora));
        assertFalse(RecordatorioService.enVentana(ahora.minusHours(2), ahora));
    }

    @Test public void valoresNulosNoSonVentana() {
        assertFalse(RecordatorioService.enVentana(null, ahora));
        assertFalse(RecordatorioService.enVentana(ahora, null));
    }
}
