import java.nio.file.*;
import java.io.*;
import java.util.*;
import java.util.zip.*;

/** Ejecutar desde la raíz: java scripts/EmpaquetarEntrega.java target/entrega.zip */
class EmpaquetarEntrega {
    public static void main(String[] args) throws Exception {
        if(args.length!=1)throw new IllegalArgumentException("Indique un ZIP nuevo dentro de target");
        Path root=Path.of("").toAbsolutePath().normalize(),target=root.resolve("target"),salida=root.resolve(args[0]).normalize();
        if(!salida.startsWith(target)||!salida.toString().endsWith(".zip"))throw new IllegalArgumentException("La salida debe ser target/nombre.zip");
        Path war=target.resolve("ArtDent-1.0-SNAPSHOT.war");
        try(ZipFile zip=new ZipFile(war.toFile())) {
            Enumeration<? extends ZipEntry> entradas=zip.entries();
            while(entradas.hasMoreElements())if(sensible(entradas.nextElement().getName()))throw new IllegalStateException("El WAR contiene configuración privada; ejecute clean package con el POM actualizado");
        }
        List<Path> archivos=new ArrayList<>();
        for(String dir:List.of("src/main/java","src/main/webapp","src/main/resources","src/main/document","src/test","scripts","RF","RNF")) {
            Path base=root.resolve(dir);if(!Files.isDirectory(base))continue;
            try(var paths=Files.walk(base)){paths.filter(p->Files.isRegularFile(p,LinkOption.NOFOLLOW_LINKS)).filter(p->!privado(root.relativize(p).toString())).filter(p->permitido(p)).forEach(archivos::add);}
        }
        for(String nombre:List.of("pom.xml","README.md",".gitignore"))if(Files.isRegularFile(root.resolve(nombre)))archivos.add(root.resolve(nombre));
        archivos.add(war);Files.createDirectories(target);
        try(ZipOutputStream zip=new ZipOutputStream(Files.newOutputStream(salida,StandardOpenOption.CREATE_NEW))) {
            for(Path p:archivos) {
                String nombre=root.relativize(p).toString().replace('\\','/');
                zip.putNextEntry(new ZipEntry(nombre));Files.copy(p,zip);zip.closeEntry();
            }
        }
        System.out.println("Entrega creada: "+salida+" ("+archivos.size()+" archivos; sin configuración privada)");
    }
    private static boolean permitido(Path p){String s=p.getFileName().toString().toLowerCase(Locale.ROOT);return s.matches(".*\\.(java|jsp|xml|sql|md|json|txt|js|cjs|css|png|jpg|jpeg|svg|gif|ico|woff2?|ttf|ps1|example)");}
    private static boolean privado(String nombre) {
        String s=nombre.toLowerCase(Locale.ROOT);return sensible(nombre)||(s.endsWith(".properties")&&!s.endsWith(".example"));
    }
    private static boolean sensible(String nombre) {
        String s=nombre.replace('\\','/').toLowerCase(Locale.ROOT);String n=s.substring(s.lastIndexOf('/')+1);
        return n.equals("config.properties")||n.startsWith(".env")||n.matches(".*\\.(pem|key|p12|pfx|jks)")||
                s.contains("/adjuntos/");
    }
}
