package pe.edu.utp.daoImpl;
import java.math.BigDecimal;
import java.sql.*;
import java.time.YearMonth;
import java.util.*;
import pe.edu.utp.config.Conexion;

/** F-09: pagos registrados, agrupados por FechaPago; incluye pagos de citas anuladas. */
public class IngresosDao {
    public Map<YearMonth,BigDecimal> porMes(Integer doctor) throws SQLException {
        Map<YearMonth,BigDecimal> result=new TreeMap<>();
        String sql="SELECT DATE_FORMAT(p.FechaPago,'%Y-%m') AS Mes,SUM(p.Monto) AS Total "
                +"FROM Pago p JOIN Cita c ON c.idCita=p.Cita_idCita "
                + (doctor==null?"":"WHERE c.Odontologo_idUsuario=? ")+"GROUP BY Mes ORDER BY Mes";
        try(Connection c=Conexion.getConection();PreparedStatement s=c.prepareStatement(sql)) {
            if(doctor!=null)s.setInt(1,doctor);
            try(ResultSet r=s.executeQuery()){while(r.next())result.put(YearMonth.parse(r.getString(1)),r.getBigDecimal(2));}
        }
        return result;
    }
    public BigDecimal total() throws SQLException {
        return porMes(null).values().stream().reduce(BigDecimal.ZERO,BigDecimal::add);
    }
    public Integer filtroDoctor(int usuario) throws SQLException {
        try(Connection c=Conexion.getConection();PreparedStatement s=c.prepareStatement("SELECT Rol_idRol FROM Usuario WHERE idUsuario=? AND Activo=1")) {
            s.setInt(1,usuario);try(ResultSet r=s.executeQuery()) {
                if(!r.next())throw new SQLException("Usuario no disponible","45000");
                return r.getInt(1)==3?usuario:null;
            }
        }
    }
}
