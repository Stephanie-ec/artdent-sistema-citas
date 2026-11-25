package pe.edu.utp.daoImpl;
import java.sql.*;
import java.util.*;
import java.nio.charset.StandardCharsets;
import java.security.*;
import pe.edu.utp.config.Conexion;

public class CorreoDao {
    public void encolar(int cita,int estado,String asunto,String mensaje) throws SQLException {
        encolarConClave(cita,hash(cita+"|"+estado+"|"+asunto+"|"+mensaje),asunto,mensaje);
    }

    /** R-03: un recordatorio por cita, aunque la tarea se ejecute cada hora. */
    public void encolarRecordatorio(int cita,String asunto,String mensaje) throws SQLException {
        encolarConClave(cita,"recordatorio-"+cita,asunto,mensaje);
    }

    private void encolarConClave(int cita,String clave,String asunto,String mensaje) throws SQLException {
        String sql="SELECT p.Correo FROM Cita c JOIN Paciente p ON p.idPaciente=c.Paciente_idPaciente WHERE c.idCita=? "
                +"UNION SELECT u.CorreoElectronico FROM Cita c JOIN Usuario u ON u.idUsuario=c.Odontologo_idUsuario WHERE c.idCita=? "
                +"UNION SELECT CorreoElectronico FROM Usuario WHERE Activo=1 AND Rol_idRol=2";
        Set<String> destinos=new LinkedHashSet<>();
        try(Connection c=Conexion.getConection()) {
            try(PreparedStatement s=c.prepareStatement(sql)){s.setInt(1,cita);s.setInt(2,cita);try(ResultSet r=s.executeQuery()){while(r.next()){String correo=r.getString(1);if(correo!=null&&!correo.trim().isEmpty())destinos.add(correo.trim().toLowerCase(Locale.ROOT));}}}
            String evento=clave;
            c.setAutoCommit(false);
            try {
                for(String destino:destinos)try(PreparedStatement s=c.prepareStatement("INSERT INTO CorreoPendiente(Cita_idCita,Evento,Destinatario,Asunto,Mensaje) VALUES(?,?,?,?,?) ON DUPLICATE KEY UPDATE Evento=VALUES(Evento)")) {
                    s.setInt(1,cita);s.setString(2,evento);s.setString(3,destino);s.setString(4,asunto);s.setString(5,mensaje);s.executeUpdate();
                }
                c.commit();
            }catch(SQLException e){c.rollback();throw e;}finally{c.setAutoCommit(true);}
        }
    }
    private String hash(String texto) {
        try {byte[] bytes=MessageDigest.getInstance("SHA-256").digest(texto.getBytes(StandardCharsets.UTF_8));StringBuilder s=new StringBuilder();for(byte b:bytes)s.append(String.format("%02x",b&255));return s.toString();}
        catch(NoSuchAlgorithmException e){throw new IllegalStateException(e);}
    }
    public Map<String,Object> tomar() throws SQLException {
        try(Connection c=Conexion.getConection()) {
            c.setAutoCommit(false);
            try {
                Map<String,Object> fila=null;
                try(PreparedStatement s=c.prepareStatement("SELECT * FROM CorreoPendiente WHERE Estado<>'ENVIADO' AND Intentos<3 AND Proximo<=NOW() ORDER BY idCorreo LIMIT 1 FOR UPDATE SKIP LOCKED");ResultSet r=s.executeQuery()) {
                    if(r.next()){fila=new HashMap<>();fila.put("id",r.getLong("idCorreo"));fila.put("cita",r.getInt("Cita_idCita"));fila.put("destino",r.getString("Destinatario"));fila.put("asunto",r.getString("Asunto"));fila.put("mensaje",r.getString("Mensaje"));}
                }
                if(fila!=null)try(PreparedStatement s=c.prepareStatement("UPDATE CorreoPendiente SET Estado='ENVIANDO',Intentos=Intentos+1,Proximo=DATE_ADD(NOW(),INTERVAL 10 MINUTE) WHERE idCorreo=?")){s.setLong(1,(Long)fila.get("id"));s.executeUpdate();}
                c.commit();return fila;
            }catch(SQLException e){c.rollback();throw e;}finally{c.setAutoCommit(true);}
        }
    }
    public void resultado(long id,boolean ok) throws SQLException {
        try(Connection c=Conexion.getConection();PreparedStatement s=c.prepareStatement("UPDATE CorreoPendiente SET Estado=?,UltimoError=?,Proximo=DATE_ADD(NOW(),INTERVAL 10 MINUTE) WHERE idCorreo=?")) {
            s.setString(1,ok?"ENVIADO":"PENDIENTE");s.setString(2,ok?null:"No se confirmó la entrega SMTP");s.setLong(3,id);s.executeUpdate();
        }
    }
    /** R-02: el criterio de aceptación exige Notificacion.Enviado=1 cuando el correo salió. */
    public void marcarNotificacionEnviada(int cita,String asunto) throws SQLException {
        try(Connection c=Conexion.getConection();PreparedStatement s=c.prepareStatement("UPDATE Notificacion SET Enviado=1 WHERE Cita_idCita=? AND Asunto=? AND Enviado=0")){
            s.setInt(1,cita);s.setString(2,asunto);s.executeUpdate();
        }
    }

    public void reintentar(long id) throws SQLException {
        try(Connection c=Conexion.getConection();PreparedStatement s=c.prepareStatement("UPDATE CorreoPendiente SET Estado='PENDIENTE',Intentos=0,Proximo=NOW() WHERE idCorreo=? AND (Estado='PENDIENTE' OR (Estado='ENVIANDO' AND Proximo<=NOW()))")){s.setLong(1,id);s.executeUpdate();}
    }
    /** R-15: intentos consumidos por un correo, para avisar cuando agota los reintentos. */
    public int intentos(long id) throws SQLException {
        try(Connection c=Conexion.getConection();PreparedStatement s=c.prepareStatement("SELECT Intentos FROM CorreoPendiente WHERE idCorreo=?")) {
            s.setLong(1,id);try(ResultSet r=s.executeQuery()){return r.next()?r.getInt(1):0;}
        }
    }

    /** R-14: correos que aún esperan envío. */
    public int contarPendientes() throws SQLException {
        return contar("SELECT COUNT(*) FROM CorreoPendiente WHERE Estado<>'ENVIADO' AND Intentos<3");
    }

    /** R-14: correos que agotaron sus reintentos. */
    public int contarFallidos() throws SQLException {
        return contar("SELECT COUNT(*) FROM CorreoPendiente WHERE Estado<>'ENVIADO' AND Intentos>=3");
    }

    private int contar(String sql) throws SQLException {
        try(Connection c=Conexion.getConection();PreparedStatement s=c.prepareStatement(sql);ResultSet r=s.executeQuery()) {
            return r.next()?r.getInt(1):0;
        }
    }

    public List<Map<String,Object>> listar() throws SQLException {
        List<Map<String,Object>> lista=new ArrayList<>();
        try(Connection c=Conexion.getConection();PreparedStatement s=c.prepareStatement("SELECT idCorreo,Cita_idCita,Destinatario,Asunto,Estado,Intentos,UltimoError FROM CorreoPendiente ORDER BY idCorreo DESC LIMIT 100");ResultSet r=s.executeQuery()) {
            while(r.next()){Map<String,Object> fila=new LinkedHashMap<>();for(int i=1;i<=r.getMetaData().getColumnCount();i++)fila.put(r.getMetaData().getColumnLabel(i),r.getObject(i));lista.add(fila);}
        }return lista;
    }
}
