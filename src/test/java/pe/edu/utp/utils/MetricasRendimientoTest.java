package pe.edu.utp.utils;

import org.junit.After;
import org.junit.Test;
import static org.junit.Assert.*;

/** R-14: el p95 se calcula sobre las muestras reales de la reserva. */
public class MetricasRendimientoTest {

    @After public void limpiar() {
        MetricasRendimiento.limpiar();
    }

    @Test public void sinMuestrasElP95EsCero() {
        assertEquals(0, MetricasRendimiento.p95Reserva());
        assertEquals(0, MetricasRendimiento.muestras());
    }

    @Test public void calculaElPercentil95() {
        for (int i = 1; i <= 100; i++) {
            MetricasRendimiento.registrarReserva(i * 10);
        }
        assertEquals(100, MetricasRendimiento.muestras());
        assertEquals(950, MetricasRendimiento.p95Reserva());
    }

    @Test public void conservaSoloLasUltimasMuestrasYDescartaNegativas() {
        MetricasRendimiento.registrarReserva(-5);
        assertEquals(0, MetricasRendimiento.muestras());
        for (int i = 0; i < 250; i++) {
            MetricasRendimiento.registrarReserva(100);
        }
        assertEquals(200, MetricasRendimiento.muestras());
        assertEquals(100, MetricasRendimiento.p95Reserva());
    }
}
