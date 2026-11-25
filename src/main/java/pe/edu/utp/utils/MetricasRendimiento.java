package pe.edu.utp.utils;

import java.util.ArrayDeque;
import java.util.Deque;

/**
 * R-14: indicador 2 (p95 de la reserva ≤ 2 s) medido sobre las últimas
 * peticiones reales al formulario de reserva, sin dependencias externas.
 */
public final class MetricasRendimiento {

    private static final int MUESTRAS = 200;
    private static final Deque<Long> DURACIONES = new ArrayDeque<>();

    private MetricasRendimiento() {
    }

    public static synchronized void registrarReserva(long milisegundos) {
        if (milisegundos < 0) {
            return;
        }
        DURACIONES.addLast(milisegundos);
        while (DURACIONES.size() > MUESTRAS) {
            DURACIONES.removeFirst();
        }
    }

    /** Percentil 95 (0 si todavía no hay muestras). */
    public static synchronized long p95Reserva() {
        if (DURACIONES.isEmpty()) {
            return 0;
        }
        long[] valores = new long[DURACIONES.size()];
        int i = 0;
        for (long d : DURACIONES) {
            valores[i++] = d;
        }
        java.util.Arrays.sort(valores);
        int indice = (int) Math.ceil(valores.length * 0.95) - 1;
        return valores[Math.max(0, Math.min(indice, valores.length - 1))];
    }

    public static synchronized int muestras() {
        return DURACIONES.size();
    }

    public static synchronized void limpiar() {
        DURACIONES.clear();
    }
}
