package pe.edu.utp.utils;

import org.junit.Test;
import static org.junit.Assert.*;

/** R-06: la casilla solo cuenta como aceptada con valores de casilla marcada. */
public class ConsentimientoTest {

    @Test public void aceptaValoresDeCasillaMarcada() {
        assertTrue(Consentimiento.aceptado("on"));
        assertTrue(Consentimiento.aceptado("ON"));
        assertTrue(Consentimiento.aceptado("true"));
        assertTrue(Consentimiento.aceptado("1"));
        assertTrue(Consentimiento.aceptado("si"));
        assertTrue(Consentimiento.aceptado("sí"));
        assertTrue(Consentimiento.aceptado("  on  "));
    }

    @Test public void rechazaAusenciaOValoresFalsos() {
        assertFalse(Consentimiento.aceptado(null));
        assertFalse(Consentimiento.aceptado(""));
        assertFalse(Consentimiento.aceptado("   "));
        assertFalse(Consentimiento.aceptado("off"));
        assertFalse(Consentimiento.aceptado("false"));
        assertFalse(Consentimiento.aceptado("0"));
        assertFalse(Consentimiento.aceptado("no"));
    }
}
