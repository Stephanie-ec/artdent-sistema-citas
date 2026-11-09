package pe.edu.utp.daoImpl;
import java.sql.*;
import pe.edu.utp.config.Conexion;

public class SesionPersonalDao {
    public String rolActivo(int id) {
        try(Connection c=Conexion.getConection();PreparedStatement s=c.prepareStatement(
                "SELECT r.TipoRol FROM Usuario u JOIN Rol r ON r.idRol=u.Rol_idRol WHERE u.idUsuario=? AND u.Activo=1")) {
            s.setInt(1,id);try(ResultSet r=s.executeQuery()){return r.next()?r.getString(1):null;}
        }catch(SQLException e){throw new IllegalStateException("No se pudo validar la sesion",e);}
    }
}
