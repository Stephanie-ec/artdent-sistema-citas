package pe.edu.utp.utils;

import java.time.LocalDate;
import java.time.Clock;
import java.time.Instant;
import java.time.ZoneId;
import org.junit.Test;
import static org.junit.Assert.*;

/** Pruebas de comportamiento: invocan el validador real, sin MySQL ni HTTP. */
public class ValidadorFechaTest {
    // Lunes 05/01/2026, 10:30 en Lima.
    private static final Clock RELOJ = Clock.fixed(
            Instant.parse("2026-01-05T15:30:00Z"), ZoneId.of("UTC"));

    private String validar(String fecha, String hora) {
        return Validador.validarDatosPaciente("12345678", "Ana", "Perez",
                "987654321", "ana@example.test", fecha, hora);
    }

    @Test public void rechazaFechaPasada() {
        assertNotNull("F-08: no se puede aceptar una reserva pasada",
                validar("2000-01-03", "10:00"));
    }

    @Test public void rechazaDomingo() {
        LocalDate domingo = LocalDate.of(2099, 1, 4);
        assertEquals(java.time.DayOfWeek.SUNDAY, domingo.getDayOfWeek());
        assertNotNull("F-08: no se atiende los domingos", validar(domingo.toString(), "10:00"));
    }

    @Test public void rechazaFechaInexistente() {
        assertNotNull("F-08: no se puede aceptar el 30 de febrero", validar("2099-02-30", "10:00"));
    }

    @Test public void rechazaHoraInvalida() {
        assertNotNull("F-08: no se puede aceptar 25:00", validar("2099-01-05", "25:00"));
    }

    @Test public void aceptaDiaLaborableFuturo() {
        assertNull(validar("2099-01-05", "10:00"));
    }

    @Test public void rechazaHoraPasadaHoy() {
        assertNotNull(Validador.validarFechaHora("2026-01-05", "10:29", RELOJ));
    }

    @Test public void aceptaHoraFuturaHoy() {
        assertNull(Validador.validarFechaHora("2026-01-05", "10:31", RELOJ));
    }

    @Test public void aceptaInstanteExactoSegunReglaNoPasado() {
        assertNull(Validador.validarFechaHora("2026-01-05", "10:30:00", RELOJ));
    }

    @Test public void rechazaSegundoAnterior() {
        assertNotNull(Validador.validarFechaHora("2026-01-05", "10:29:59", RELOJ));
    }

    @Test public void usaLimaAunqueElRelojSeaUTC() {
        // A las 02:00 UTC del martes sigue siendo lunes 21:00 en Lima.
        Clock medianocheUTC = Clock.fixed(Instant.parse("2026-01-06T02:00:00Z"), ZoneId.of("UTC"));
        assertNull(Validador.validarFechaHora("2026-01-05", "21:01", medianocheUTC));
        assertNotNull(Validador.validarFechaHora("2026-01-05", "20:59", medianocheUTC));
    }

    @Test public void rechazaDomingoFuturoConRelojFijo() {
        assertNotNull(Validador.validarFechaHora("2026-01-11", "10:00", RELOJ));
    }

    @Test public void aceptaSabadoFuturo() {
        assertNull(Validador.validarFechaHora("2026-01-10", "10:00", RELOJ));
    }

    @Test public void rechazaEntradasVaciasYMalformadas() {
        String[][] invalidas = {
            {null, "10:00"}, {"", "10:00"}, {"   ", "10:00"},
            {"2026-01-06", null}, {"2026-01-06", ""}, {"2026-01-06", "   "},
            {"06/01/2026", "10:00"}, {"2026-13-01", "10:00"},
            {"2026-02-29", "10:00"}, {"2026-01-06", "24:00"},
            {"2026-01-06", "10:60"}, {"2026-01-06", "texto"},
            {"+10000-01-04", "10:00"}, {"2026-01-06", "10:00:00.123"}
        };
        for (String[] entrada : invalidas) {
            assertNotNull("Debe rechazar: " + java.util.Arrays.toString(entrada),
                    Validador.validarFechaHora(entrada[0], entrada[1], RELOJ));
        }
    }

    @Test public void aceptaFechaBisiestaRealYSegundos() {
        assertNull(Validador.validarFechaHora("2028-02-29", "10:00:00", RELOJ));
    }
}
