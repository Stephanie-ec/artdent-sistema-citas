package pe.edu.utp.daoImpl;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import pe.edu.utp.config.Conexion;
import pe.edu.utp.dao.RolDao;
import pe.edu.utp.entity.Rol;

public class RolDaoImpl implements RolDao {

    @Override
    public List<Rol> listarRoles() {
        List<Rol> lista = new ArrayList<>();
        String sql = "SELECT * FROM rol";
        try (Connection conn = Conexion.getConection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
             
            while (rs.next()) {
                Rol rol = new Rol();
                rol.setIdRol(rs.getInt("idRol"));
                rol.setTipoRol(rs.getString("TipoRol"));
                lista.add(rol);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return lista;
    }
}
