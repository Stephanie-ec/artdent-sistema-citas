package pe.edu.utp.daoImpl;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import pe.edu.utp.config.Conexion;
import pe.edu.utp.entity.Evento;

/** R-15: persistencia de eventos y consultas de alerta. */
public class EventoDao {

    public void insertar(String nivel, String origen, String mensaje) throws SQLException {
        String sql = "INSERT INTO Evento(Nivel,Origen,Mensaje) VALUES(?,?,?)";
        try (Connection c = Conexion.getConection(); PreparedStatement s = c.prepareStatement(sql)) {
            s.setString(1, nivel);
            s.setString(2, recortar(origen, 60));
            s.setString(3, recortar(mensaje, 500));
            s.executeUpdate();
        }
    }

    public List<Evento> listar(String nivel, boolean soloPendientes) throws SQLException {
        StringBuilder sql = new StringBuilder(
                "SELECT e.*, CONCAT(u.Nombre,' ',u.Apellido) AS AtendioNombre FROM Evento e "
                + "LEFT JOIN Usuario u ON u.idUsuario=e.AtendidoPor WHERE 1=1");
        List<String> parametros = new ArrayList<>();
        if (nivel != null && !nivel.isEmpty()) {
            sql.append(" AND e.Nivel=?");
            parametros.add(nivel);
        }
        if (soloPendientes) {
            sql.append(" AND e.Atendido=0");
        }
        sql.append(" ORDER BY e.Fecha DESC, e.idEvento DESC LIMIT 200");
        List<Evento> lista = new ArrayList<>();
        try (Connection c = Conexion.getConection(); PreparedStatement s = c.prepareStatement(sql.toString())) {
            for (int i = 0; i < parametros.size(); i++) {
                s.setString(i + 1, parametros.get(i));
            }
            try (ResultSet r = s.executeQuery()) {
                while (r.next()) {
                    Evento e = new Evento();
                    e.setIdEvento(r.getInt("idEvento"));
                    e.setFecha(r.getTimestamp("Fecha"));
                    e.setNivel(r.getString("Nivel"));
                    e.setOrigen(r.getString("Origen"));
                    e.setMensaje(r.getString("Mensaje"));
                    e.setAtendido(r.getBoolean("Atendido"));
                    Object por = r.getObject("AtendidoPor");
                    e.setAtendidoPor(por == null ? null : ((Number) por).intValue());
                    e.setFechaAtencion(r.getTimestamp("FechaAtencion"));
                    e.setAccionTomada(r.getString("AccionTomada"));
                    e.setAtendidoPorNombre(r.getString("AtendioNombre"));
                    lista.add(e);
                }
            }
        }
        return lista;
    }

    public boolean atender(int idEvento, int idUsuario, String accion) throws SQLException {
        String sql = "UPDATE Evento SET Atendido=1, AtendidoPor=?, FechaAtencion=NOW(), AccionTomada=? "
                + "WHERE idEvento=? AND Atendido=0";
        try (Connection c = Conexion.getConection(); PreparedStatement s = c.prepareStatement(sql)) {
            s.setInt(1, idUsuario);
            s.setString(2, recortar(accion, 500));
            s.setInt(3, idEvento);
            return s.executeUpdate() > 0;
        }
    }

    public int contarPendientes() throws SQLException {
        return contar("SELECT COUNT(*) FROM Evento WHERE Atendido=0 AND Nivel='ERROR'");
    }

    public int contarPorNivel(String nivel) throws SQLException {
        String sql = "SELECT COUNT(*) FROM Evento WHERE Nivel=? AND Fecha >= DATE_SUB(NOW(), INTERVAL 24 HOUR)";
        try (Connection c = Conexion.getConection(); PreparedStatement s = c.prepareStatement(sql)) {
            s.setString(1, nivel);
            try (ResultSet r = s.executeQuery()) {
                return r.next() ? r.getInt(1) : 0;
            }
        }
    }

    public int contarBloqueosUltimaHora() throws SQLException {
        return contar("SELECT COUNT(*) FROM Evento WHERE Origen='Seguridad' AND Mensaje LIKE 'Cuenta bloqueada%' "
                + "AND Fecha >= DATE_SUB(NOW(), INTERVAL 1 HOUR)");
    }

    public boolean existeAlertaSimilar(String fragmento, int minutos) throws SQLException {
        String sql = "SELECT COUNT(*) FROM Evento WHERE Nivel='ERROR' AND Mensaje LIKE ? "
                + "AND Fecha >= DATE_SUB(NOW(), INTERVAL ? MINUTE)";
        try (Connection c = Conexion.getConection(); PreparedStatement s = c.prepareStatement(sql)) {
            s.setString(1, "%" + fragmento + "%");
            s.setInt(2, minutos);
            try (ResultSet r = s.executeQuery()) {
                return r.next() && r.getInt(1) > 0;
            }
        }
    }

    /** R-14: cuenta eventos cuyo mensaje coincide, dentro de una ventana de horas. */
    public int contarPorMensaje(String fragmento, int horas) throws SQLException {
        String sql = "SELECT COUNT(*) FROM Evento WHERE Mensaje LIKE ? AND Fecha >= DATE_SUB(NOW(), INTERVAL ? HOUR)";
        try (Connection c = Conexion.getConection(); PreparedStatement s = c.prepareStatement(sql)) {
            s.setString(1, "%" + fragmento + "%");
            s.setInt(2, horas);
            try (ResultSet r = s.executeQuery()) {
                return r.next() ? r.getInt(1) : 0;
            }
        }
    }

    public void limpiarAntiguos(int dias) throws SQLException {
        String sql = "DELETE FROM Evento WHERE Fecha < DATE_SUB(NOW(), INTERVAL ? DAY)";
        try (Connection c = Conexion.getConection(); PreparedStatement s = c.prepareStatement(sql)) {
            s.setInt(1, dias);
            s.executeUpdate();
        }
    }

    public List<String> correosAdministradores() throws SQLException {
        List<String> correos = new ArrayList<>();
        String sql = "SELECT CorreoElectronico FROM Usuario WHERE Rol_idRol=1 AND Activo=1";
        try (Connection c = Conexion.getConection(); PreparedStatement s = c.prepareStatement(sql);
             ResultSet r = s.executeQuery()) {
            while (r.next()) {
                String correo = r.getString(1);
                if (correo != null && !correo.trim().isEmpty()) {
                    correos.add(correo.trim());
                }
            }
        }
        return correos;
    }

    private int contar(String sql) throws SQLException {
        try (Connection c = Conexion.getConection(); PreparedStatement s = c.prepareStatement(sql);
             ResultSet r = s.executeQuery()) {
            return r.next() ? r.getInt(1) : 0;
        }
    }

    private static String recortar(String texto, int maximo) {
        if (texto == null) {
            return "";
        }
        return texto.length() <= maximo ? texto : texto.substring(0, maximo);
    }
}
