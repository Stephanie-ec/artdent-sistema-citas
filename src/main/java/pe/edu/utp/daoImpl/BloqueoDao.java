package pe.edu.utp.daoImpl;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import pe.edu.utp.config.Conexion;

/** R-11: bloqueos de agenda por feriado o vacaciones (toda la clínica o un odontólogo). */
public class BloqueoDao {

    public List<Map<String, Object>> listar() {
        List<Map<String, Object>> lista = new ArrayList<>();
        String sql = "SELECT b.idBloqueo, b.Desde, b.Hasta, b.Motivo, b.Usuario_idUsuario, "
                + "CONCAT(u.Nombre,' ',u.Apellido) AS Odontologo "
                + "FROM BloqueoAgenda b LEFT JOIN Usuario u ON u.idUsuario=b.Usuario_idUsuario "
                + "ORDER BY b.Desde DESC, b.idBloqueo DESC";
        try (Connection c = Conexion.getConection();
             PreparedStatement s = c.prepareStatement(sql);
             ResultSet r = s.executeQuery()) {
            while (r.next()) {
                Map<String, Object> fila = new LinkedHashMap<>();
                fila.put("idBloqueo", r.getInt("idBloqueo"));
                fila.put("desde", r.getString("Desde"));
                fila.put("hasta", r.getString("Hasta"));
                fila.put("motivo", r.getString("Motivo"));
                fila.put("usuarioId", r.getObject("Usuario_idUsuario"));
                fila.put("odontologo", r.getString("Odontologo"));
                lista.add(fila);
            }
        } catch (SQLException e) {
            throw new IllegalStateException("No se pudieron listar los bloqueos de agenda", e);
        }
        return lista;
    }

    public boolean crear(String desde, String hasta, Integer usuarioId, String motivo, int actor) {
        String sql = "INSERT INTO BloqueoAgenda(Desde,Hasta,Usuario_idUsuario,Motivo,Actor_idUsuario) VALUES(?,?,?,?,?)";
        try (Connection c = Conexion.getConection();
             PreparedStatement s = c.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            s.setString(1, desde);
            s.setString(2, hasta);
            if (usuarioId == null) {
                s.setNull(3, java.sql.Types.INTEGER);
            } else {
                s.setInt(3, usuarioId);
            }
            s.setString(4, motivo);
            s.setInt(5, actor);
            return s.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new IllegalStateException("No se pudo registrar el bloqueo de agenda", e);
        }
    }

    public boolean eliminar(int id) {
        try (Connection c = Conexion.getConection();
             PreparedStatement s = c.prepareStatement("DELETE FROM BloqueoAgenda WHERE idBloqueo=?")) {
            s.setInt(1, id);
            return s.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new IllegalStateException("No se pudo eliminar el bloqueo de agenda", e);
        }
    }
}
