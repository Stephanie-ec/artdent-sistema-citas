package pe.edu.utp.utils;

import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;

public class ConfigLoader {
    private static final Properties properties = new Properties();

    static {
        try (InputStream input = ConfigLoader.class.getClassLoader().getResourceAsStream("config.properties")) {
            if (input == null) {
                System.err.println("No se encontró el archivo de configuración: config.properties");
            } else {
                properties.load(input);
            }
        } catch (IOException ex) {
            System.err.println("Error al cargar la configuración: " + ex.getMessage());
            ex.printStackTrace();
        }
    }

    public static String getProperty(String key) {
        return properties.getProperty(key);
    }
}
