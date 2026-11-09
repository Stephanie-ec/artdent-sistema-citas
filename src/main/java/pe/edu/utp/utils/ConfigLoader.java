package pe.edu.utp.utils;

import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;

public class ConfigLoader {
    private static final Properties properties = new Properties();

    static {
        String archivo=System.getProperty("artdent.config");
        if(archivo==null || archivo.trim().isEmpty())archivo=System.getenv("ARTDENT_CONFIG");
        try (InputStream input = archivo==null || archivo.trim().isEmpty()?null:
                java.nio.file.Files.newInputStream(java.nio.file.Paths.get(archivo))) {
            if (input != null) properties.load(new java.io.InputStreamReader(input,java.nio.charset.StandardCharsets.UTF_8));
        } catch (IOException ex) {
            throw new ExceptionInInitializerError("No se pudo leer la configuración externa de ArtDent");
        }
        // Sin ruta externa: se usa src/main/resources/config.properties (ambiente local)
        if (properties.isEmpty()) {
            try (InputStream local = ConfigLoader.class.getClassLoader().getResourceAsStream("config.properties")) {
                if (local != null) {
                    properties.load(new java.io.InputStreamReader(local, java.nio.charset.StandardCharsets.UTF_8));
                } else {
                    System.err.println("No se encontró config.properties ni la variable ARTDENT_CONFIG");
                }
            } catch (IOException ex) {
                System.err.println("Error al cargar config.properties: " + ex.getMessage());
            }
        }
    }

    public static String getProperty(String key) {
        String override = System.getProperty("artdent." + key);
        if (override != null) return override;
        override = System.getenv("ARTDENT_" + key.toUpperCase(java.util.Locale.ROOT).replace('.', '_'));
        if (override != null) return override;
        return properties.getProperty(key);
    }
}
