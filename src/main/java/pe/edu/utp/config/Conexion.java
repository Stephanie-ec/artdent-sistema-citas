package pe.edu.utp.config;

import java.sql.Connection;
import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;
import java.sql.SQLException;

public class Conexion {
    private static HikariDataSource dataSource;

    static {
        try {
            HikariConfig config = new HikariConfig();
            config.setJdbcUrl(pe.edu.utp.utils.ConfigLoader.getProperty("db.url"));
            config.setUsername(pe.edu.utp.utils.ConfigLoader.getProperty("db.user"));
            config.setPassword(pe.edu.utp.utils.ConfigLoader.getProperty("db.password"));
            config.setDriverClassName("com.mysql.cj.jdbc.Driver");
            config.setConnectionInitSql("SET time_zone = '-05:00'");
            
            // Configuracion de pool para manejar alta concurrencia (RNF4)
            config.setMaximumPoolSize(50); 
            config.setMinimumIdle(5);
            config.setIdleTimeout(30000);
            config.setMaxLifetime(1800000);
            config.setConnectionTimeout(30000);
            
            dataSource = new HikariDataSource(config);
            System.out.println("Pool de conexiones (HikariCP) inicializado correctamente");
        } catch (Exception e) {
            System.out.println("Error inicializando pool de conexiones");
            e.printStackTrace();
        }
    }

    public static Connection getConection() {
        if(dataSource==null)throw new IllegalStateException("La base de datos no esta configurada o disponible.");
        try {
            return dataSource.getConnection();
        } catch (SQLException e) {
            throw new IllegalStateException("No se pudo obtener una conexion a la base de datos.",e);
        }
    }
}
