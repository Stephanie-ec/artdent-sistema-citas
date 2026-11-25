package pe.edu.utp.utils;

import org.junit.Test;
import static org.junit.Assert.*;

/** R-15: solo se aceptan los tres niveles previstos; el resto cae a INFO. */
public class EventoServiceTest {

    @Test public void normalizaLosTresNiveles() {
        assertEquals("INFO", EventoService.normalizarNivel("info"));
        assertEquals("ADVERTENCIA", EventoService.normalizarNivel(" advertencia "));
        assertEquals("ERROR", EventoService.normalizarNivel("Error"));
    }

    @Test public void valoresDesconocidosONulosSonInfo() {
        assertEquals("INFO", EventoService.normalizarNivel(null));
        assertEquals("INFO", EventoService.normalizarNivel(""));
        assertEquals("INFO", EventoService.normalizarNivel("CRITICO"));
    }

    @Test public void laVersionSiempreEsInformable() {
        assertNotNull(AppVersion.numero());
        assertTrue(AppVersion.completa().startsWith("ArtDent "));
    }
}
