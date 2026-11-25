package pe.edu.utp.utils;

import java.util.HashSet;
import java.util.Set;
import org.junit.Test;
import static org.junit.Assert.*;

/** R-08: generación de claves temporales y reglas de la nueva contraseña. */
public class ClaveTemporalTest {

    @Test public void generaClavesDeLongitudFijaYSinCaracteresAmbiguos() {
        Set<String> vistas = new HashSet<>();
        for (int i = 0; i < 200; i++) {
            String clave = ClaveTemporal.generar();
            assertEquals(ClaveTemporal.LONGITUD, clave.length());
            assertTrue(clave.matches("[A-Za-z2-9]+"));
            assertFalse("No debe contener caracteres confundibles", clave.matches(".*[01OIl].*"));
            vistas.add(clave);
        }
        assertTrue("Debe generar claves distintas", vistas.size() > 190);
    }

    @Test public void exigeEntreSeisYTreintaCaracteres() {
        assertEquals("La contraseña debe tener entre 6 y 30 caracteres.", ClaveTemporal.validar("12345", "12345"));
        assertNull(ClaveTemporal.validar("123456", "123456"));
        assertNull(ClaveTemporal.validar("123456789012345678901234567890", "123456789012345678901234567890"));
        assertNotNull(ClaveTemporal.validar("1234567890123456789012345678901", "1234567890123456789012345678901"));
    }

    @Test public void exigeConfirmacionYClaveNoVacia() {
        assertNotNull(ClaveTemporal.validar(null, null));
        assertNotNull(ClaveTemporal.validar("   ", "   "));
        assertNotNull(ClaveTemporal.validar("abcdef", "abcdeg"));
        assertNull(ClaveTemporal.validar("abcdef", "abcdef"));
    }
}
