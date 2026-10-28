package pe.edu.utp.components;

import java.time.LocalDate;
import java.util.HashMap;
import java.util.Map;

public class DiasNumericosDeLaSemana {

    public Map<Integer, Integer> obtenerDiasNumericosDeEstaSemana(int init) {
        Map<Integer, Integer> dias = new HashMap<>();
        for (int i = 0; i < 7; i++) {
            dias.put(i + 1, init + i); 
        }
        return dias;
    }

    public Map<Integer, Integer> obtenerDiasNumericosDeEstaSemana(LocalDate inicioSemana) {
        Map<Integer, Integer> dias = new HashMap<>();
        if (inicioSemana == null) {
            inicioSemana = LocalDate.now();
        }
        for (int i = 0; i < 7; i++) {
            dias.put(i + 1, inicioSemana.plusDays(i).getDayOfMonth());
        }
        return dias;
    }
}
