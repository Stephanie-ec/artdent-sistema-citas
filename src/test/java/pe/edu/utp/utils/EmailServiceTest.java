package pe.edu.utp.utils;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertNull;
import static org.junit.Assert.assertTrue;

import org.junit.Test;

/**
 * R-02: la contraseña de aplicación de Gmail se pega con espacios ("xxxx xxxx xxxx xxxx").
 * El servidor SMTP solo acepta las 16 letras, así que se normaliza antes de autenticar.
 */
public class EmailServiceTest {

    @Test
    public void quitaLosEspaciosDeLaContrasenaDeAplicacion() {
        assertEquals("abcdwxyzzxywdcba", EmailService.sinEspacios("abcd wxyz zxyw dcba"));
    }

    @Test
    public void recortaSaltosDeLineaYEspaciosExtremos() {
        assertEquals("abcdefghijklmnop", EmailService.sinEspacios("  abcdefghijklmnop\r\n"));
    }

    @Test
    public void conservaUnaContrasenaSinEspaciosYAdmiteNulo() {
        assertEquals("ClaveSegura.2026", EmailService.sinEspacios("ClaveSegura.2026"));
        assertNull(EmailService.sinEspacios(null));
    }

    /** 465 habla SSL directo; 587 usa STARTTLS para cualquier relay de Internet. */
    @Test
    public void eligeSslSegunElPuerto() {
        assertTrue(EmailService.usarSsl("465"));
        assertFalse(EmailService.usarSsl("587"));
        assertFalse(EmailService.usarSsl("1025"));
    }

    @Test
    public void permiteForzarSslPorConfiguracion() {
        System.setProperty("artdent.mail.smtp.ssl", "true");
        try {
            assertTrue(EmailService.usarSsl("587"));
        } finally {
            System.clearProperty("artdent.mail.smtp.ssl");
        }
    }

    @Test
    public void usaElRemitenteCuandoNoHayUsuarioSmtp() {
        assertEquals("cuenta@dominio.com", EmailService.primerNoVacio(null, "cuenta@dominio.com"));
        assertEquals("cuenta@dominio.com", EmailService.primerNoVacio("", "cuenta@dominio.com"));
        assertEquals("login@relay.com", EmailService.primerNoVacio("login@relay.com", "cuenta@dominio.com"));
    }
}
