package pe.edu.utp.utils;
import java.nio.file.*;
import java.nio.charset.StandardCharsets;
import java.util.concurrent.TimeUnit;
import org.junit.Test;
import static org.junit.Assert.*;

public class ConfigExternaTest {
    public static class Probe {
        public static void main(String[] args){if(!args[0].equals(ConfigLoader.getProperty("auditoria")))System.exit(2);}
    }
    @Test public void configuracionExternaRespetaEntornoYPropiedadJava() throws Exception {
        Path archivo=Files.createTempFile("artdent-config-prueba-",".properties");
        try {
            Files.write(archivo,"auditoria=archivo-á".getBytes(StandardCharsets.UTF_8));
            comprobar(archivo,"archivo-á",false,false);comprobar(archivo,"entorno",true,false);comprobar(archivo,"sistema",true,true);
        }finally{Files.deleteIfExists(archivo);}
    }
    private void comprobar(Path archivo,String esperado,boolean entorno,boolean sistema) throws Exception {
        java.util.List<String> args=new java.util.ArrayList<>();
        args.add(Paths.get(System.getProperty("java.home"),"bin",System.getProperty("os.name").toLowerCase().contains("win")?"java.exe":"java").toString());
        args.add("-Dartdent.config="+archivo);if(sistema)args.add("-Dartdent.auditoria=sistema");
        args.add("-cp");args.add(System.getProperty("java.class.path"));args.add(Probe.class.getName());args.add(esperado);
        ProcessBuilder pb=new ProcessBuilder(args);pb.environment().remove("ARTDENT_AUDITORIA");if(entorno)pb.environment().put("ARTDENT_AUDITORIA","entorno");
        Process p=pb.start();try{assertTrue("La lectura de configuración no debe bloquearse",p.waitFor(15,TimeUnit.SECONDS));assertEquals(0,p.exitValue());}finally{p.destroyForcibly();}
    }
}
