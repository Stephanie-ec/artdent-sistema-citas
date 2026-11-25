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
    /** R-02: detalle reutilizable para que el correo diga qué cita, cuándo y dónde. */
    public String detalle(int id) throws SQLException {
        String SQL = "SELECT c.FechaCita, c.HoraCita, s.TipoServicio, "
                + "CONCAT(u.Nombre,' ',u.Apellido) AS Odontologo "
                + "FROM Cita c JOIN Servicio s ON s.idServicio=c.Servicio_idServicio "
                + "JOIN Usuario u ON u.idUsuario=c.Odontologo_idUsuario WHERE c.idCita=?";
        try (Connection c = Conexion.getConection(); PreparedStatement s = c.prepareStatement(SQL)) {
            s.setInt(1, id);
            try (ResultSet r = s.executeQuery()) {
                if (!r.next()) return "";
                return "Codigo de cita: " + String.format("ART-RES-%05d", id)
                        + "\nFecha: " + r.getString("FechaCita")
                        + "\nHora: " + r.getString("HoraCita")
                        + "\nServicio: " + r.getString("TipoServicio")
                        + "\nOdontologo: " + r.getString("Odontologo")
                        + "\nSede: Jr. Chiclayo 268, Chosica";
            }
        }
    }
    /** R-10: cancelación del paciente; el DNI y las 24 horas se validan dentro del procedimiento. */
    public void cancelarReservaPaciente(int id, String dni) throws SQLException {
        try(Connection c=Conexion.getConection(); CallableStatement s=c.prepareCall("{call sp_artdent_cancelarReservaPaciente(?,?)}")) {
            s.setInt(1,id); s.setString(2,dni); s.execute();
        }
    }
    /** R-10: reprogramación del paciente con la misma validación de agenda. */
    public void reprogramarReservaPaciente(int id, String dni, String fecha, String hora) throws SQLException {
        try(Connection c=Conexion.getConection(); CallableStatement s=c.prepareCall("{call sp_artdent_reprogramarReservaPaciente(?,?,?,?)}")) {
            s.setInt(1,id); s.setString(2,dni); s.setString(3,fecha); s.setString(4,hora); s.execute();
        }
    }
    public void reprogramar(int id, String fecha, String hora, boolean web) throws SQLException {
        try (Connection c = Conexion.getConection();
             CallableStatement s = c.prepareCall(web ? "{call ps_ReprogramarReserva(?,?,?)}" : "{call ps_ReprogramarCita(?,?,?)}")) {
            s.setInt(1,id); s.setString(2,fecha); s.setString(3,hora); s.execute();
        }
    }
}
