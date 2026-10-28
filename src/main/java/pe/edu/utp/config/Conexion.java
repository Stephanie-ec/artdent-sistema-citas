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
        Connection conn = null;
        try {
            conn = dataSource.getConnection();
        } catch (SQLException e) {
            System.out.println("Error obteniendo conexion del pool");
            e.printStackTrace();
        }
        return conn;
    }
}
