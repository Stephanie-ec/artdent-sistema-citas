package pe.edu.utp.utils;

import static org.junit.Assert.*;

import java.io.IOException;
import java.nio.file.Path;
import org.junit.After;
import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;
import org.junit.rules.TemporaryFolder;

/** La carpeta de comprobantes debe ser portable entre máquinas y quedar fuera del sitio público. */
public class ComprobanteAdjuntoTest {

    @Rule public TemporaryFolder tmp = new TemporaryFolder();
    private String datosDirPrevio, adjuntosPrevio;

    @Before public void recordar() {
        datosDirPrevio = System.getProperty("artdent.datos.dir");
        adjuntosPrevio = System.getProperty("artdent.pagos.adjuntos.dir");
    }

    @After public void restaurar() {
        restaurar("artdent.datos.dir", datosDirPrevio);
        restaurar("artdent.pagos.adjuntos.dir", adjuntosPrevio);
    }

    private static void restaurar(String clave, String valor) {
        if (valor == null) System.clearProperty(clave); else System.setProperty(clave, valor);
    }

    @Test public void resuelveRutaRelativaBajoDatosDir() throws Exception {
        Path base = tmp.newFolder("datos").toPath();
        System.setProperty("artdent.datos.dir", base.toString());
        System.setProperty("artdent.pagos.adjuntos.dir", "comprobantes-pagos");

        assertEquals(base.toRealPath().resolve("comprobantes-pagos"), ComprobanteAdjunto.directorio(null));
    }

    @Test public void aceptaRutaAbsolutaFueraDelSitioPublico() throws Exception {
        Path web = tmp.newFolder("webapp").toPath();
        Path privada = tmp.newFolder("privada").toPath();
        System.setProperty("artdent.pagos.adjuntos.dir", privada.toString());

        assertEquals(privada.toRealPath(), ComprobanteAdjunto.directorio(web.toString()));
    }

    @Test public void rechazaCarpetaDentroDelSitioPublico() throws Exception {
        Path web = tmp.newFolder("webapp").toPath();
        System.setProperty("artdent.pagos.adjuntos.dir", web.resolve("uploads").toString());
        try {
            ComprobanteAdjunto.directorio(web.toString());
            fail("No debe aceptar almacenamiento público");
        } catch (IOException esperado) {
            assertTrue(esperado.getMessage().contains("fuera del sitio público"));
        }
    }

    @Test public void rechazaConfiguracionVacia() {
        System.setProperty("artdent.pagos.adjuntos.dir", "");
        try {
            ComprobanteAdjunto.directorio(null);
            fail("Sin carpeta configurada no se puede guardar");
        } catch (IOException esperado) {
            assertTrue(esperado.getMessage().contains("no está configurado"));
        }
    }
}
