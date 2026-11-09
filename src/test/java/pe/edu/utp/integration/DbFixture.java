package pe.edu.utp.integration;

import java.sql.*;
import java.time.*;
import java.time.temporal.TemporalAdjusters;
import java.util.concurrent.atomic.AtomicInteger;
import org.junit.After;
import org.junit.Before;

/** Solo base aislada: se niega a ejecutar en una BD cuyo nombre no termine en _test. */
public abstract class DbFixture {
    private static final AtomicInteger DNI = new AtomicInteger(88000000);
    protected Connection db;
    protected int doctor, paciente;
    protected LocalDate fecha = LocalDate.now(ZoneId.of("America/Lima")).plusWeeks(2)
            .with(TemporalAdjusters.nextOrSame(DayOfWeek.MONDAY));

    protected Connection conexion() throws SQLException {
        String url = pe.edu.utp.utils.ConfigLoader.getProperty("db.url");
        if(url==null)url="";
        if (!url.matches("jdbc:mysql://[^/]+/[A-Za-z0-9_]+_test(?:\\?.*)?")) {
            throw new IllegalStateException("Las pruebas requieren -Dartdent.db.url con base terminada en _test");
        }
        String usuario=pe.edu.utp.utils.ConfigLoader.getProperty("db.user"),clave=pe.edu.utp.utils.ConfigLoader.getProperty("db.password");
        return DriverManager.getConnection(url,usuario==null?"root":usuario,clave==null?"":clave);
    }

    protected int insertar(String sql) throws SQLException {
        try (Statement s = db.createStatement()) {
            s.executeUpdate(sql, Statement.RETURN_GENERATED_KEYS);
            try (ResultSet r = s.getGeneratedKeys()) { r.next(); return r.getInt(1); }
        }
    }
    protected int numero(String sql) throws SQLException {
        try (Statement s = db.createStatement(); ResultSet r = s.executeQuery(sql)) { r.next(); return r.getInt(1); }
    }
    protected int cita(int estado, String origen, String hora) throws SQLException {
        return insertar("INSERT INTO Cita(FechaCita,HoraCita,Descripcion,Importe,Origen,Paciente_idPaciente,"
                + "Servicio_idServicio,Estado_idEstado,Odontologo_idUsuario) VALUES('" + fecha + "','" + hora
                + "','Prueba integral',100,'" + origen + "'," + paciente + ",1," + estado + "," + doctor + ")");
    }
    protected void pago(int cita) throws SQLException {
        int pago = insertar("INSERT INTO Pago(Monto,MetodoPago_idMetodo,Cita_idCita) VALUES(100,2," + cita + ")");
        insertar("INSERT INTO Comprobante(Serie,Numero,NombreCliente,DNICliente,Pago_idPago) VALUES('TST1','"
                + String.format("%08d", pago) + "','Paciente Prueba','12345678'," + pago + ")");
    }
    @Before public void preparar() throws Exception {
        db = conexion();
        doctor = insertar("INSERT INTO Usuario(Nombre,Apellido,DNI,Telefono,CorreoElectronico,Direccion,FechaNacimiento,Clave,Rol_idRol) "
                + "VALUES('Doctor','Prueba','" + DNI.incrementAndGet() + "','987654321','doctor@example.test','Prueba','1990-01-01','123456',3)");
        paciente = insertar("INSERT INTO Paciente(Nombre,Apellido,DNI,Telefono,Correo) VALUES('Paciente','Prueba','"
                + DNI.incrementAndGet() + "','987654321','paciente@example.test')");
        try (Statement s = db.createStatement()) {
            s.executeUpdate("INSERT INTO Usuario_Servicio VALUES(" + doctor + ",1,1)");
            s.executeUpdate("INSERT INTO Usuario_Horario(Usuario_idUsuario,Horario_idHorario) SELECT " + doctor + ",idHorario FROM Horario");
        }
    }
    @After public void limpiar() throws Exception {
        if (db == null) return;
        try (Statement s = db.createStatement()) {
            String ids = "SELECT idCita FROM Cita WHERE Odontologo_idUsuario=" + doctor;
            s.executeUpdate("DELETE FROM Atencion WHERE Cita_idCita IN ("+ids+")");
            s.executeUpdate("DELETE FROM SolicitudPago WHERE Cita_idCita IN ("+ids+")");
            s.executeUpdate("DELETE FROM Devolucion WHERE Pago_idPago IN (SELECT idPago FROM Pago WHERE Cita_idCita IN ("+ids+"))");
            s.executeUpdate("DELETE FROM Comprobante WHERE Pago_idPago IN (SELECT idPago FROM Pago WHERE Cita_idCita IN (" + ids + "))");
            s.executeUpdate("DELETE FROM Pago WHERE Cita_idCita IN (" + ids + ")");
            s.executeUpdate("DELETE FROM Notificacion WHERE Cita_idCita IN (" + ids + ")");
            s.executeUpdate("DELETE FROM Cita WHERE Odontologo_idUsuario=" + doctor);
            s.executeUpdate("DELETE FROM Usuario_Horario WHERE Usuario_idUsuario=" + doctor);
            s.executeUpdate("DELETE FROM Usuario_Servicio WHERE idUsuario=" + doctor);
            s.executeUpdate("DELETE FROM Usuario WHERE idUsuario=" + doctor);
            s.executeUpdate("DELETE FROM Paciente WHERE idPaciente=" + paciente);
        } finally { db.close(); }
    }
}
