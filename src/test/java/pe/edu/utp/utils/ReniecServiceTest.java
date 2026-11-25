package pe.edu.utp.utils;

import java.lang.reflect.Constructor;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import static org.junit.Assert.*;

/** R-04: mensajes distintos para DNI inexistente, nombre que no coincide y proveedor caído. */
public class ReniecServiceTest {

    private String modoAnterior;

    @Before public void modoObligatorio() {
        modoAnterior = System.getProperty("artdent.reniec.mode");
        System.setProperty("artdent.reniec.mode", "required");
    }

    @After public void restaurar() {
        // Se restaura el valor previo: limpiarlo dejaba a las demás clases sin el modo demo de surefire.
        if (modoAnterior == null) {
            System.clearProperty("artdent.reniec.mode");
        } else {
            System.setProperty("artdent.reniec.mode", modoAnterior);
        }
    }

    private ReniecService.Resultado resultado(ReniecService.Estado estado, String nombres, String apellidos) throws Exception {
        Constructor<ReniecService.Resultado> c = ReniecService.Resultado.class
                .getDeclaredConstructor(ReniecService.Estado.class, String.class, String.class);
        c.setAccessible(true);
        return c.newInstance(estado, nombres, apellidos);
    }

    @Test public void nombreYApellidoQueCoincidenNoDevuelvenError() throws Exception {
        assertNull(ReniecService.validarResultado(
                resultado(ReniecService.Estado.ENCONTRADO, "Ana María", "Pérez Gómez"), "ANA MARIA", "perez gomez"));
    }

    @Test public void nombreQueNoCoincideSeRechaza() throws Exception {
        String error = ReniecService.validarResultado(
                resultado(ReniecService.Estado.ENCONTRADO, "Ana María", "Pérez Gómez"), "Otra", "Persona");
        assertNotNull(error);
        assertTrue(error.contains("no coinciden"));
        assertFalse(ReniecService.esIndisponibilidad(error));
    }

    @Test public void dniInexistenteSeRechazaConSuPropioMensaje() throws Exception {
        String error = ReniecService.validarResultado(resultado(ReniecService.Estado.NO_EXISTE, null, null), "Ana", "Pérez");
        assertTrue(error.contains("no figura en RENIEC"));
        assertFalse(ReniecService.esIndisponibilidad(error));
    }

    @Test public void proveedorCaidoDevuelveElMensajeDeIndisponibilidad() throws Exception {
        String error = ReniecService.validarResultado(resultado(ReniecService.Estado.ERROR, null, null), "Ana", "Pérez");
        assertEquals(ReniecService.MENSAJE_SIN_RESPUESTA, error);
        assertTrue(ReniecService.esIndisponibilidad(error));
    }

    @Test public void enModoDemoNoBloquea() throws Exception {
        System.setProperty("artdent.reniec.mode", "demo");
        assertNull(ReniecService.validarResultado(resultado(ReniecService.Estado.ERROR, null, null), "Ana", "Pérez"));
    }
}
