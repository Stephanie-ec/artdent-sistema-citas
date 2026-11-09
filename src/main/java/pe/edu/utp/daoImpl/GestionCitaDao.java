package pe.edu.utp.daoImpl;

import java.sql.*;
import pe.edu.utp.config.Conexion;

/** Operaciones atomicas: la BD valida el estado actual dentro de la transaccion. */
public class GestionCitaDao {
    public void cambiarEstado(int id, int destino, int actor, boolean web) throws SQLException {
        try(Connection c=Conexion.getConection(); CallableStatement s=c.prepareCall("{call sp_artdent_cambiarEstado(?,?,?,?)}")) {
            s.setInt(1,id); s.setInt(2,destino); s.setInt(3,actor); s.setString(4,web?"Web":"Presencial"); s.execute();
        }
    }
    public void eliminar(int id, int actor, boolean web) throws SQLException {
        try(Connection c=Conexion.getConection(); CallableStatement s=c.prepareCall("{call sp_artdent_eliminarCita(?,?,?)}")) {
            s.setInt(1,id); s.setInt(2,actor); s.setString(3,web?"Web":"Presencial"); s.execute();
        }
    }
    public String correo(int id) throws SQLException {
        try(Connection c=Conexion.getConection(); PreparedStatement s=c.prepareStatement("SELECT p.Correo FROM Cita c JOIN Paciente p ON p.idPaciente=c.Paciente_idPaciente WHERE c.idCita=?")) {
            s.setInt(1,id); try(ResultSet r=s.executeQuery()) { return r.next()?r.getString(1):null; }
        }
    }
    public void reprogramar(int id, String fecha, String hora, boolean web) throws SQLException {
        try (Connection c = Conexion.getConection();
             CallableStatement s = c.prepareCall(web ? "{call ps_ReprogramarReserva(?,?,?)}" : "{call ps_ReprogramarCita(?,?,?)}")) {
            s.setInt(1,id); s.setString(2,fecha); s.setString(3,hora); s.execute();
        }
    }
}
