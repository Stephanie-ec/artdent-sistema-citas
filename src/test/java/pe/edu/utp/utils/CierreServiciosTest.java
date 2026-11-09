package pe.edu.utp.utils;
import java.io.*;
import java.math.BigDecimal;
import java.awt.image.BufferedImage;
import java.util.*;
import javax.imageio.ImageIO;
import org.junit.Test;
import static org.junit.Assert.*;
import pe.edu.utp.entity.Servicio;

public class CierreServiciosTest {
    private List<Servicio> catalogo(){Servicio s=new Servicio();s.setIdServicio(1);s.setTipoServicio("Limpieza Dental");s.setCosto(new BigDecimal("40.00"));return Arrays.asList(s);}
    @Test public void iaInvalidaOFallidaUsaRespaldoLocal() {
        Map<String,Object> local=AsistenteDental.responder("limpieza dental",catalogo());
        for(String invalida:Arrays.asList("no json","{\"mensaje\":\"<script>\",\"servicioId\":1}","{\"mensaje\":\"Hola\",\"servicioId\":999}"))
            assertEquals(local,AsistenteIA.responder("limpieza dental",catalogo(),(p,c)->invalida));
        assertEquals(local,AsistenteIA.responder("limpieza dental",catalogo(),(p,c)->{throw new IOException("caída");}));
    }
    @Test public void iaUsaPrecioYNombreDelCatalogoYExcluyeConsultaAjena() {
        Map<String,Object> respuesta=AsistenteIA.responder("limpieza dental",catalogo(),(p,c)->"{\"mensaje\":\"Consulte al odontólogo\",\"servicioId\":1,\"costo\":0}");
        assertEquals(new BigDecimal("40.00"),((Map<?,?>)respuesta.get("servicio")).get("costo"));
        assertTrue(respuesta.get("mensaje").toString().contains("no es un diagnóstico"));
        assertFalse(AsistenteIA.responder("limpieza de casa",catalogo(),(p,c)->{throw new AssertionError("No enviar al proveedor");}).containsKey("servicio"));
    }
    @Test public void comprobanteRechazaTextoGifYArchivosGrandes() throws Exception {
        assertThrows(IOException.class,()->ComprobanteAdjunto.validar(new ByteArrayInputStream("<script>".getBytes("UTF-8"))));
        ByteArrayOutputStream gif=new ByteArrayOutputStream();ImageIO.write(new BufferedImage(3,3,BufferedImage.TYPE_INT_RGB),"gif",gif);
        assertThrows(IOException.class,()->ComprobanteAdjunto.validar(new ByteArrayInputStream(gif.toByteArray())));
        assertThrows(IOException.class,()->ComprobanteAdjunto.validar(new ByteArrayInputStream(new byte[ComprobanteAdjunto.MAX_BYTES+1])));
    }
    @Test public void comprobanteValidoSeRecodificaComoPNG() throws Exception {
        ByteArrayOutputStream jpg=new ByteArrayOutputStream();ImageIO.write(new BufferedImage(5,7,BufferedImage.TYPE_INT_RGB),"jpeg",jpg);
        byte[] limpia=ComprobanteAdjunto.validar(new ByteArrayInputStream(jpg.toByteArray()));
        assertEquals((byte)137,limpia[0]);assertEquals(5,ImageIO.read(new ByteArrayInputStream(limpia)).getWidth());
    }
    private static String cambiarPropiedad(String clave,String valor) {
        String anterior=System.getProperty(clave);
        System.setProperty(clave,valor);
        return anterior;
    }
    private static void restaurarPropiedad(String clave,String anterior) {
        if(anterior==null)System.clearProperty(clave); else System.setProperty(clave,anterior);
    }
    @Test public void reniecObligatorioNoPermiteRegistroSinProveedor() {
        String modoAnterior=cambiarPropiedad("artdent.reniec.mode","required");
        String tokenAnterior=cambiarPropiedad("artdent.reniec.api.token","");
        try{assertNotNull(ReniecService.validarIdentidad("12345678","Ana","Perez"));}
        finally{restaurarPropiedad("artdent.reniec.mode",modoAnterior);restaurarPropiedad("artdent.reniec.api.token",tokenAnterior);}
    }
    @Test public void reniecNoAceptaNombresParcialesNiFalloDelProveedor() {
        String modoAnterior=cambiarPropiedad("artdent.reniec.mode","required");
        try {
            assertNotNull(ReniecService.validarResultado(new ReniecService.Resultado(ReniecService.Estado.ERROR,null,null),"Ana","Pérez"));
            assertNotNull(ReniecService.validarResultado(new ReniecService.Resultado(ReniecService.Estado.NO_EXISTE,null,null),"Ana","Pérez"));
            ReniecService.Resultado real=new ReniecService.Resultado(ReniecService.Estado.ENCONTRADO,"Ana María","Pérez Gómez");
            assertNull(ReniecService.validarResultado(real," ana maria ","Perez Gomez"));
            assertNotNull(ReniecService.validarResultado(real,"Ana","Pérez Gómez"));
            assertNotNull(ReniecService.validarResultado(real,"Ana María","Pérez Otra"));
        } finally {restaurarPropiedad("artdent.reniec.mode",modoAnterior);}
    }
}
