package pe.edu.utp.daoImpl;

import java.sql.*;
import java.math.BigDecimal;
import java.util.*;
import pe.edu.utp.config.Conexion;
import pe.edu.utp.entity.*;

public class PagoManualDao {
    public static final class Revision {
        public final int cita;public final boolean modificada;
        Revision(int cita,boolean modificada){this.cita=cita;this.modificada=modificada;}
    }
    private static SQLException conflicto(String mensaje){return new SQLException(mensaje,"45000");}
    private void personal(Connection c,int actor) throws SQLException {
        try(PreparedStatement s=c.prepareStatement("SELECT 1 FROM Usuario WHERE idUsuario=? AND Activo=1 AND Rol_idRol IN(1,2)")) {
            s.setInt(1,actor);try(ResultSet r=s.executeQuery()){if(!r.next())throw conflicto("Su rol no permite revisar pagos.");}
        }
    }
    private BigDecimal bloquear(Connection c,int id) throws SQLException {
        try(PreparedStatement s=c.prepareStatement("SELECT c.Estado_idEstado,COALESCE(NULLIF(c.Importe,0),se.Costo) FROM Cita c JOIN Servicio se ON se.idServicio=c.Servicio_idServicio WHERE c.idCita=? FOR UPDATE")) {
            s.setInt(1,id);try(ResultSet r=s.executeQuery()) {
                if(!r.next()||!Arrays.asList(1,3,4).contains(r.getInt(1)))throw conflicto("La cita no admite pagos.");
                BigDecimal monto=r.getBigDecimal(2);if(monto==null||monto.signum()<=0)throw conflicto("Importe no válido.");return monto;
            }
        }
    }
    public void solicitar(int cita,String canal,String codigo,String archivo,String nombre,String dni) throws SQLException {
        if(!Arrays.asList("YAPE","PLIN").contains(canal)||codigo==null||!codigo.matches("[A-Z0-9-]{4,40}")
                ||archivo==null||!archivo.matches("[a-f0-9-]{36}\\.png")||nombre==null||!nombre.matches("[\\p{L}' -]{3,100}")||dni==null||!dni.matches("[0-9]{8}"))throw conflicto("Revise el canal, código y datos del titular.");
        try(Connection c=Conexion.getConection()) {
            c.setAutoCommit(false);
            try {
                BigDecimal monto=bloquear(c,cita);
                try(PreparedStatement s=c.prepareStatement("SELECT idPago FROM Pago WHERE Cita_idCita=?")) {s.setInt(1,cita);try(ResultSet r=s.executeQuery()){if(r.next())throw conflicto("La cita ya está pagada.");}}
                try(PreparedStatement s=c.prepareStatement("SELECT idSolicitud FROM SolicitudPago WHERE Cita_idCita=? AND Estado='PENDIENTE'")) {s.setInt(1,cita);try(ResultSet r=s.executeQuery()){if(r.next())throw conflicto("Ya existe un comprobante pendiente de revisión.");}}
                try(PreparedStatement s=c.prepareStatement("INSERT INTO SolicitudPago(Cita_idCita,Canal,CodigoOperacion,Archivo,Monto,NombreCliente,DNICliente) VALUES(?,?,?,?,?,?,?)")) {
                    s.setInt(1,cita);s.setString(2,canal);s.setString(3,codigo);s.setString(4,archivo);s.setBigDecimal(5,monto);s.setString(6,nombre.trim());s.setString(7,dni);s.executeUpdate();
                }
                c.commit();
            } catch(SQLException|RuntimeException e){c.rollback();throw e;} finally {c.setAutoCommit(true);}
        }
    }
    public int revisar(int solicitud,int actor,boolean aprobar,String motivo) throws SQLException {
        return revisarResultado(solicitud,actor,aprobar,motivo).cita;
    }
    public Revision revisarResultado(int solicitud,int actor,boolean aprobar,String motivo) throws SQLException {
        if(!aprobar&&(motivo==null||motivo.trim().isEmpty()||motivo.length()>300))throw conflicto("Indique un motivo de hasta 300 caracteres.");
        try(Connection c=Conexion.getConection()) {
            c.setAutoCommit(false);
            try {
                personal(c,actor);
                int cita;
                try(PreparedStatement s=c.prepareStatement("SELECT Cita_idCita FROM SolicitudPago WHERE idSolicitud=?")){s.setInt(1,solicitud);try(ResultSet r=s.executeQuery()){if(!r.next())throw conflicto("No existe la solicitud.");cita=r.getInt(1);}}
                // Orden uniforme con efectivo y cancelación: primero Cita, luego solicitud.
                try(PreparedStatement s=c.prepareStatement("SELECT idCita FROM Cita WHERE idCita=? FOR UPDATE")){s.setInt(1,cita);s.executeQuery().close();}
                Pago pago=new Pago();Comprobante boleta=new Comprobante();
                try(PreparedStatement s=c.prepareStatement("SELECT * FROM SolicitudPago WHERE idSolicitud=? FOR UPDATE")) {
                    s.setInt(1,solicitud);try(ResultSet r=s.executeQuery()) {
                        r.next();
                        if(!"PENDIENTE".equals(r.getString("Estado"))){
                            if((aprobar&&"APROBADA".equals(r.getString("Estado")))||(!aprobar&&"RECHAZADA".equals(r.getString("Estado")))){c.commit();return new Revision(cita,false);}
                            throw conflicto("La solicitud ya fue revisada con otro resultado. Actualice la página.");
                        }
                        if(aprobar) {
                            BigDecimal actual=bloquear(c,cita);
                            if(actual.compareTo(r.getBigDecimal("Monto"))!=0)throw conflicto("El importe cambió; rechace la solicitud y solicite un nuevo comprobante.");
                            pago.setCita_idCita(cita);pago.setMetodoPago_idMetodo(1);pago.setCodigoTransaccion(r.getString("Canal")+":"+r.getString("CodigoOperacion"));
                            boleta.setSerie("B001");boleta.setNombreCliente(r.getString("NombreCliente"));boleta.setDniCliente(r.getString("DNICliente"));
                        }
                    }
                }
                if(aprobar&&!new PagoDaoImpl().registrarEnConexion(c,pago,boleta))throw conflicto("La cita ya tiene pago o no admite el cobro.");
                try(PreparedStatement s=c.prepareStatement("UPDATE SolicitudPago SET Estado=?,Motivo=?,Revisada=NOW(),Revisor_idUsuario=?,Pago_idPago=? WHERE idSolicitud=?")) {
                    s.setString(1,aprobar?"APROBADA":"RECHAZADA");s.setString(2,aprobar?null:motivo.trim());s.setInt(3,actor);
                    if(aprobar)s.setInt(4,pago.getIdPago());else s.setNull(4,Types.INTEGER);s.setInt(5,solicitud);s.executeUpdate();
                }
                if(aprobar)try(PreparedStatement s=c.prepareStatement("UPDATE Cita SET Estado_idEstado=3 WHERE idCita=? AND Estado_idEstado=1")){s.setInt(1,cita);s.executeUpdate();}
                c.commit();return new Revision(cita,true);
            } catch(SQLException|RuntimeException e){c.rollback();throw e;} finally {c.setAutoCommit(true);}
        }
    }
    public int devolver(int pago,int actor,String referencia) throws SQLException {
        if(referencia==null||referencia.trim().isEmpty()||referencia.length()>100)throw conflicto("Indique la referencia de la devolución (hasta 100 caracteres).");
        try(Connection c=Conexion.getConection()) {
            c.setAutoCommit(false);
            try {
                personal(c,actor);int cita;
                try(PreparedStatement s=c.prepareStatement("SELECT p.Cita_idCita FROM Devolucion d JOIN Pago p ON p.idPago=d.Pago_idPago WHERE d.Pago_idPago=? FOR UPDATE")) {
                    s.setInt(1,pago);try(ResultSet r=s.executeQuery()){if(!r.next())throw conflicto("No existe una devolución para ese pago.");cita=r.getInt(1);}
                }
                try(PreparedStatement s=c.prepareStatement("UPDATE Devolucion SET Estado='REALIZADA',Referencia=?,Realizada=NOW(),Actor_idUsuario=? WHERE Pago_idPago=? AND Estado='PENDIENTE'")) {
                    s.setString(1,referencia.trim());s.setInt(2,actor);s.setInt(3,pago);s.executeUpdate();
                }
                c.commit();return cita;
            }catch(SQLException|RuntimeException e){c.rollback();throw e;}finally{c.setAutoCommit(true);}
        }
    }
    public List<Map<String,Object>> solicitudes(Integer cita) throws SQLException {
        return listar("SELECT idSolicitud AS id,Cita_idCita AS cita,Canal AS canal,CodigoOperacion AS codigo,Monto AS monto,Estado AS estado,Motivo AS motivo,Archivo AS archivo,Creada AS creada FROM SolicitudPago"
                +(cita==null?"":" WHERE Cita_idCita=?")+" ORDER BY idSolicitud DESC LIMIT 100",cita);
    }
    public List<Map<String,Object>> devoluciones(Integer cita) throws SQLException {
        return listar("SELECT d.Pago_idPago AS pago,p.Cita_idCita AS cita,p.Monto AS monto,d.Estado AS estado,d.Referencia AS referencia,d.Realizada AS realizada FROM Devolucion d JOIN Pago p ON p.idPago=d.Pago_idPago"
                +(cita==null?"":" WHERE p.Cita_idCita=?")+" ORDER BY p.idPago DESC LIMIT 100",cita);
    }
    private List<Map<String,Object>> listar(String sql,Integer cita) throws SQLException {
        List<Map<String,Object>> lista=new ArrayList<>();
        try(Connection c=Conexion.getConection();PreparedStatement s=c.prepareStatement(sql)) {
            if(cita!=null)s.setInt(1,cita);
            try(ResultSet r=s.executeQuery()){while(r.next()){Map<String,Object> fila=new LinkedHashMap<>();for(int i=1;i<=r.getMetaData().getColumnCount();i++)fila.put(r.getMetaData().getColumnLabel(i),r.getObject(i));lista.add(fila);}}
        }return lista;
    }
    public Map<String,Object> adjunto(int id) throws SQLException {
        try(Connection c=Conexion.getConection();PreparedStatement s=c.prepareStatement("SELECT Cita_idCita,Archivo FROM SolicitudPago WHERE idSolicitud=?")) {
            s.setInt(1,id);try(ResultSet r=s.executeQuery()){if(!r.next())return null;Map<String,Object> datos=new HashMap<>();datos.put("cita",r.getInt(1));datos.put("archivo",r.getString(2));return datos;}
        }
    }
}
