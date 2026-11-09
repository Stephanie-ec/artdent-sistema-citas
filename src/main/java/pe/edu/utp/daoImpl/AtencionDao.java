package pe.edu.utp.daoImpl;
import java.sql.*;
import java.util.*;
import pe.edu.utp.config.Conexion;

public class AtencionDao {
    public void registrar(int cita,int actor,String diagnostico,String tratamiento,String observaciones) throws SQLException {
        try(Connection c=Conexion.getConection();CallableStatement s=c.prepareCall("{call sp_artdent_registrarAtencion(?,?,?,?,?)}")) {
            s.setInt(1,cita);s.setInt(2,actor);s.setString(3,diagnostico);s.setString(4,tratamiento);s.setString(5,observaciones==null?"":observaciones);s.execute();
        }
    }
    public Map<String,Object> consultar(int cita,int actor) throws SQLException {
        // La autorización vive en esta consulta para proteger también el acceso directo por id.
        String sql="SELECT c.idCita,c.Estado_idEstado,CONCAT(p.Nombre,' ',p.Apellido) AS paciente,a.Diagnostico,a.Tratamiento,a.Observaciones,a.Registrada,CONCAT(autor.Nombre,' ',autor.Apellido) AS autor "
                +"FROM Cita c JOIN Paciente p ON p.idPaciente=c.Paciente_idPaciente "
                +"JOIN Usuario u ON u.idUsuario=? AND u.Activo=1 AND (u.Rol_idRol=1 OR (u.Rol_idRol=3 AND u.idUsuario=c.Odontologo_idUsuario)) "
                +"LEFT JOIN Atencion a ON a.Cita_idCita=c.idCita LEFT JOIN Usuario autor ON autor.idUsuario=a.Autor_idUsuario WHERE c.idCita=?";
        try(Connection c=Conexion.getConection();PreparedStatement s=c.prepareStatement(sql)) {
            s.setInt(1,actor);s.setInt(2,cita);try(ResultSet r=s.executeQuery()) {
                if(!r.next())return null;Map<String,Object> datos=new LinkedHashMap<>();
                for(int i=1;i<=r.getMetaData().getColumnCount();i++)datos.put(r.getMetaData().getColumnLabel(i),r.getObject(i));return datos;
            }
        }
    }
}
