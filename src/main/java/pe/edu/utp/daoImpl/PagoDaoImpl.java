package pe.edu.utp.daoImpl;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.HashMap;
import java.util.Map;
import pe.edu.utp.config.Conexion;
import pe.edu.utp.dao.PagoDao;
import pe.edu.utp.entity.Comprobante;
import pe.edu.utp.entity.Pago;

public class PagoDaoImpl implements PagoDao {
    @Override public java.util.Set<Integer> citasPagadas() {
        java.util.Set<Integer> ids=new java.util.HashSet<>();
        try(Connection c=Conexion.getConection();PreparedStatement s=c.prepareStatement("SELECT Cita_idCita FROM Pago");ResultSet r=s.executeQuery()) {
            while(r.next())ids.add(r.getInt(1));return ids;
        }catch(SQLException e){throw new IllegalStateException("No se pudo consultar los pagos",e);}
    }

    @Override
    public boolean registrarPagoYComprobante(Pago pago, Comprobante comprobante) {
        try(Connection conn=Conexion.getConection()) {
            conn.setAutoCommit(false);
            try {
                boolean ok=registrarEnConexion(conn,pago,comprobante);
                if(ok)conn.commit();else conn.rollback();
                return ok;
            } catch(SQLException|RuntimeException e) {
                conn.rollback();java.util.logging.Logger.getLogger(getClass().getName()).log(java.util.logging.Level.WARNING,"Pago no registrado; transacción revertida",e);return false;
            }
            finally {conn.setAutoCommit(true);}
        } catch(SQLException e) {throw new IllegalStateException("No se pudo registrar el pago",e);}
    }

    /** El llamador controla commit/rollback; comparte el bloqueo de Cita con revisiones manuales. */
    public boolean registrarEnConexion(Connection conn,Pago pago,Comprobante comprobante) throws SQLException {
        String serie=comprobante.getSerie()==null?"B001":comprobante.getSerie().trim();
        if(!serie.matches("[A-Z][A-Z0-9]{3}"))return false;
        java.math.BigDecimal monto;
        // Mismo mutex de fila que cancelar/rechazar/eliminar: se decide con estado actual.
        try(PreparedStatement st=conn.prepareStatement("SELECT c.Estado_idEstado,COALESCE(NULLIF(c.Importe,0),s.Costo) FROM Cita c JOIN Servicio s ON s.idServicio=c.Servicio_idServicio WHERE c.idCita=? FOR UPDATE")) {
            st.setInt(1,pago.getCita_idCita());
            try(ResultSet rs=st.executeQuery()) {
                if(!rs.next()||rs.getInt(1)==5||rs.getInt(1)==6){return false;}
                monto=rs.getBigDecimal(2);
                if(monto==null||monto.signum()<=0){return false;}
            }
        }
        try(PreparedStatement st=conn.prepareStatement("SELECT idPago FROM Pago WHERE Cita_idCita=? FOR UPDATE")) {
            st.setInt(1,pago.getCita_idCita());try(ResultSet rs=st.executeQuery()){if(rs.next()){return false;}}
        }
        int idPago;
        try(PreparedStatement st=conn.prepareStatement("INSERT INTO Pago(Monto,CodigoTransaccion,MetodoPago_idMetodo,Cita_idCita) VALUES(?,?,?,?)",Statement.RETURN_GENERATED_KEYS)) {
            st.setBigDecimal(1,monto);st.setString(2,pago.getCodigoTransaccion());st.setInt(3,pago.getMetodoPago_idMetodo());st.setInt(4,pago.getCita_idCita());st.executeUpdate();
            try(ResultSet rs=st.getGeneratedKeys()){if(!rs.next())throw new SQLException("No se genero el ID del pago");idPago=rs.getInt(1);}
        }
        try(PreparedStatement st=conn.prepareStatement("INSERT IGNORE INTO CorrelativoComprobante(Serie,Ultimo) VALUES(?,0)")){st.setString(1,serie);st.executeUpdate();}
        int siguiente;
        try(PreparedStatement st=conn.prepareStatement("SELECT Ultimo FROM CorrelativoComprobante WHERE Serie=? FOR UPDATE")) {
            st.setString(1,serie);try(ResultSet rs=st.executeQuery()){rs.next();siguiente=rs.getInt(1)+1;}
        }
        if(siguiente>99999999)throw new SQLException("Serie de comprobantes agotada");
        try(PreparedStatement st=conn.prepareStatement("UPDATE CorrelativoComprobante SET Ultimo=? WHERE Serie=?")){st.setInt(1,siguiente);st.setString(2,serie);st.executeUpdate();}
        String numero=String.format(java.util.Locale.ROOT,"%08d",siguiente);
        try(PreparedStatement st=conn.prepareStatement("INSERT INTO Comprobante(Serie,Numero,NombreCliente,DNICliente,Pago_idPago) VALUES(?,?,?,?,?)")) {
            st.setString(1,serie);st.setString(2,numero);st.setString(3,comprobante.getNombreCliente());st.setString(4,comprobante.getDniCliente());st.setInt(5,idPago);st.executeUpdate();
        }
        pago.setIdPago(idPago);pago.setMonto(monto.doubleValue());
        comprobante.setSerie(serie);comprobante.setNumero(numero);comprobante.setPago_idPago(idPago);
        return true;
    }
    @Override public Integer obtenerEstadoCita(int id) {
        try(Connection c=Conexion.getConection();PreparedStatement s=c.prepareStatement("SELECT Estado_idEstado FROM Cita WHERE idCita=?")) {
            s.setInt(1,id);try(ResultSet r=s.executeQuery()){return r.next()?r.getInt(1):null;}
        } catch(SQLException e){throw new IllegalStateException("No se pudo verificar el estado de la cita",e);}
    }

    @Override
    public Double obtenerCostoServicioPorCita(int idCita) {
        String sql = "SELECT COALESCE(NULLIF(c.Importe,0),s.Costo) AS Costo FROM Cita c INNER JOIN Servicio s ON c.Servicio_idServicio = s.idServicio WHERE c.idCita = ?";
        try (Connection conn = Conexion.getConection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, idCita);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getDouble("Costo") : null;
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return null;
        }
    }

    @Override
    public boolean tienePago(int idCita) {
        String sql = "SELECT idPago FROM Pago WHERE Cita_idCita = ?";
        try (Connection conn = Conexion.getConection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, idCita);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            throw new IllegalStateException("No se pudo verificar si la cita tiene pago. Intente nuevamente.",e);
        }
    }

    @Override
    public Pago obtenerPagoPorCita(int idCita) {
        String sql = "SELECT p.idPago, p.Monto, p.FechaPago, p.CodigoTransaccion, p.MetodoPago_idMetodo, m.NombreMetodo, p.Cita_idCita "
                   + "FROM Pago p "
                   + "INNER JOIN MetodoPago m ON p.MetodoPago_idMetodo = m.idMetodo "
                   + "WHERE p.Cita_idCita = ?";
        try (Connection conn = Conexion.getConection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, idCita);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Pago pago = new Pago();
                    pago.setIdPago(rs.getInt("idPago"));
                    pago.setMonto(rs.getDouble("Monto"));
                    pago.setFechaPago(rs.getString("FechaPago"));
                    pago.setCodigoTransaccion(rs.getString("CodigoTransaccion"));
                    pago.setMetodoPago_idMetodo(rs.getInt("MetodoPago_idMetodo"));
                    pago.setNombreMetodo(rs.getString("NombreMetodo"));
                    pago.setCita_idCita(rs.getInt("Cita_idCita"));
                    return pago;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    @Override
    public Comprobante obtenerComprobantePorCita(int idCita) {
        String sql = "SELECT c.idComprobante, c.Serie, c.Numero, c.FechaEmision, c.NombreCliente, c.DNICliente, c.Pago_idPago, "
                   + "p.Monto, p.Cita_idCita, m.NombreMetodo, s.TipoServicio "
                   + "FROM Comprobante c "
                   + "INNER JOIN Pago p ON c.Pago_idPago = p.idPago "
                   + "INNER JOIN MetodoPago m ON p.MetodoPago_idMetodo = m.idMetodo "
                   + "INNER JOIN Cita ci ON p.Cita_idCita = ci.idCita "
                   + "INNER JOIN Servicio s ON ci.Servicio_idServicio = s.idServicio "
                   + "WHERE p.Cita_idCita = ?";
        try (Connection conn = Conexion.getConection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, idCita);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapearComprobante(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    @Override
    public Comprobante obtenerComprobantePorPago(int idPago) {
        String sql = "SELECT c.idComprobante, c.Serie, c.Numero, c.FechaEmision, c.NombreCliente, c.DNICliente, c.Pago_idPago, "
                   + "p.Monto, p.Cita_idCita, m.NombreMetodo, s.TipoServicio "
                   + "FROM Comprobante c "
                   + "INNER JOIN Pago p ON c.Pago_idPago = p.idPago "
                   + "INNER JOIN MetodoPago m ON p.MetodoPago_idMetodo = m.idMetodo "
                   + "INNER JOIN Cita ci ON p.Cita_idCita = ci.idCita "
                   + "INNER JOIN Servicio s ON ci.Servicio_idServicio = s.idServicio "
                   + "WHERE c.Pago_idPago = ?";
        try (Connection conn = Conexion.getConection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, idPago);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapearComprobante(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    @Override
    public Comprobante obtenerComprobantePorId(int idComprobante) {
        String sql = "SELECT c.idComprobante, c.Serie, c.Numero, c.FechaEmision, c.NombreCliente, c.DNICliente, c.Pago_idPago, "
                   + "p.Monto, p.Cita_idCita, m.NombreMetodo, s.TipoServicio "
                   + "FROM Comprobante c "
                   + "INNER JOIN Pago p ON c.Pago_idPago = p.idPago "
                   + "INNER JOIN MetodoPago m ON p.MetodoPago_idMetodo = m.idMetodo "
                   + "INNER JOIN Cita ci ON p.Cita_idCita = ci.idCita "
                   + "INNER JOIN Servicio s ON ci.Servicio_idServicio = s.idServicio "
                   + "WHERE c.idComprobante = ?";
        try (Connection conn = Conexion.getConection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, idComprobante);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapearComprobante(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    @Override
    public Map<Integer, Comprobante> obtenerMapaComprobantesPorCita() {
        Map<Integer, Comprobante> map = new HashMap<>();
        String sql = "SELECT c.idComprobante, c.Serie, c.Numero, c.FechaEmision, c.NombreCliente, c.DNICliente, c.Pago_idPago, "
                   + "p.Monto, p.Cita_idCita, m.NombreMetodo, s.TipoServicio "
                   + "FROM Comprobante c "
                   + "INNER JOIN Pago p ON c.Pago_idPago = p.idPago "
                   + "INNER JOIN MetodoPago m ON p.MetodoPago_idMetodo = m.idMetodo "
                   + "INNER JOIN Cita ci ON p.Cita_idCita = ci.idCita "
                   + "INNER JOIN Servicio s ON ci.Servicio_idServicio = s.idServicio";
        try (Connection conn = Conexion.getConection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Comprobante comp = mapearComprobante(rs);
                map.put(comp.getIdCita(), comp);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return map;
    }

    private Comprobante mapearComprobante(ResultSet rs) throws SQLException {
        Comprobante comp = new Comprobante();
        comp.setIdComprobante(rs.getInt("idComprobante"));
        comp.setSerie(rs.getString("Serie"));
        comp.setNumero(rs.getString("Numero"));
        comp.setFechaEmision(rs.getString("FechaEmision"));
        comp.setNombreCliente(rs.getString("NombreCliente"));
        comp.setDniCliente(rs.getString("DNICliente"));
        comp.setPago_idPago(rs.getInt("Pago_idPago"));
        comp.setMonto(rs.getDouble("Monto"));
        comp.setIdCita(rs.getInt("Cita_idCita"));
        comp.setMetodoPago(rs.getString("NombreMetodo"));
        comp.setTipoServicio(rs.getString("TipoServicio"));
        return comp;
    }

    @Override
    public Map<String, Object> consultarReserva(int idCita, String dni) {
        String sql = "SELECT c.idCita, c.FechaCita, c.HoraCita, c.Estado_idEstado, COALESCE(NULLIF(c.Importe,0),s.Costo) AS Importe, CONCAT(od.Nombre,' ',od.Apellido) AS Odontologo, e.TipoEstado, s.TipoServicio, "
                + "CONCAT(p.Nombre, ' ', p.Apellido) AS Paciente, "
                + "(SELECT COUNT(*) FROM Pago pg WHERE pg.Cita_idCita = c.idCita) AS Pagos, "
                + "(SELECT COUNT(*) FROM Comprobante co JOIN Pago pg ON pg.idPago=co.Pago_idPago WHERE pg.Cita_idCita=c.idCita) AS Boletas "
                + "FROM Cita c JOIN Paciente p ON p.idPaciente = c.Paciente_idPaciente JOIN Usuario od ON od.idUsuario=c.Odontologo_idUsuario "
                + "JOIN Estado e ON e.idEstado = c.Estado_idEstado "
                + "JOIN Servicio s ON s.idServicio = c.Servicio_idServicio "
                + "WHERE c.idCita = ? AND p.DNI = ?";
        try (Connection conn = Conexion.getConection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, idCita);
            ps.setString(2, dni);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    return null;
                }
                Map<String, Object> r = new HashMap<>();
                r.put("idCita", rs.getInt("idCita"));
                r.put("estadoId",rs.getInt("Estado_idEstado"));
                r.put("odontologo",rs.getString("Odontologo"));
                r.put("importe",rs.getBigDecimal("Importe"));
                r.put("fecha", String.valueOf(rs.getDate("FechaCita")));
                r.put("hora", String.valueOf(rs.getTime("HoraCita")).substring(0, 5));
                r.put("estado", rs.getString("TipoEstado"));
                r.put("servicio", rs.getString("TipoServicio"));
                r.put("paciente", rs.getString("Paciente"));
                r.put("pagado", rs.getInt("Pagos") > 0);
                r.put("boletaDisponible",rs.getInt("Boletas")>0);
                return r;
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return null;
        }
    }
}
