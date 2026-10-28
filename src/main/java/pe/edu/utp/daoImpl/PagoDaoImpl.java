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

    @Override
    public boolean registrarPagoYComprobante(Pago pago, Comprobante comprobante) {
        Connection conn = null;
        PreparedStatement psPago = null;
        PreparedStatement psComp = null;
        ResultSet rsKeys = null;
        ResultSet rsNum = null;
        Statement stNum = null;

        try {
            conn = Conexion.getConection();
            if (conn == null) {
                return false;
            }
            conn.setAutoCommit(false);

            // 1. Verificar si ya existe pago para esta cita
            String checkSQL = "SELECT idPago FROM Pago WHERE Cita_idCita = ?";
            try (PreparedStatement psCheck = conn.prepareStatement(checkSQL)) {
                psCheck.setInt(1, pago.getCita_idCita());
                try (ResultSet rsCheck = psCheck.executeQuery()) {
                    if (rsCheck.next()) {
                        conn.rollback();
                        return false; // Ya tiene pago registrado
                    }
                }
            }

            // 2. Insertar Pago
            String sqlPago = "INSERT INTO Pago (Monto, CodigoTransaccion, MetodoPago_idMetodo, Cita_idCita) VALUES (?, ?, ?, ?)";
            psPago = conn.prepareStatement(sqlPago, Statement.RETURN_GENERATED_KEYS);
            psPago.setDouble(1, pago.getMonto());
            psPago.setString(2, pago.getCodigoTransaccion());
            psPago.setInt(3, pago.getMetodoPago_idMetodo());
            psPago.setInt(4, pago.getCita_idCita());
            psPago.executeUpdate();

            rsKeys = psPago.getGeneratedKeys();
            int idPagoGenerado = 0;
            if (rsKeys.next()) {
                idPagoGenerado = rsKeys.getInt(1);
            } else {
                conn.rollback();
                return false;
            }

            // 3. Obtener siguiente número correlativo de Boleta para serie B001
            String serie = (comprobante.getSerie() != null && !comprobante.getSerie().trim().isEmpty()) 
                    ? comprobante.getSerie().trim() : "B001";
            
            stNum = conn.createStatement();
            String sqlCorrelativo = "SELECT IFNULL(MAX(CAST(Numero AS UNSIGNED)), 0) + 1 AS Siguiente FROM Comprobante WHERE Serie = '" + serie + "'";
            rsNum = stNum.executeQuery(sqlCorrelativo);
            int sigNumero = 1;
            if (rsNum.next()) {
                sigNumero = rsNum.getInt("Siguiente");
            }
            String numeroFormateado = String.format("%08d", sigNumero);

            // 4. Insertar Comprobante
            String sqlComp = "INSERT INTO Comprobante (Serie, Numero, NombreCliente, DNICliente, Pago_idPago) VALUES (?, ?, ?, ?, ?)";
            psComp = conn.prepareStatement(sqlComp, Statement.RETURN_GENERATED_KEYS);
            psComp.setString(1, serie);
            psComp.setString(2, numeroFormateado);
            psComp.setString(3, comprobante.getNombreCliente());
            psComp.setString(4, comprobante.getDniCliente());
            psComp.setInt(5, idPagoGenerado);
            psComp.executeUpdate();

            conn.commit();

            pago.setIdPago(idPagoGenerado);
            comprobante.setPago_idPago(idPagoGenerado);
            comprobante.setSerie(serie);
            comprobante.setNumero(numeroFormateado);

            return true;
        } catch (SQLException e) {
            System.err.println("Error en registrarPagoYComprobante: " + e.getMessage());
            e.printStackTrace();
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            return false;
        } finally {
            try {
                if (rsKeys != null) rsKeys.close();
                if (rsNum != null) rsNum.close();
                if (stNum != null) stNum.close();
                if (psPago != null) psPago.close();
                if (psComp != null) psComp.close();
                if (conn != null) {
                    conn.setAutoCommit(true);
                    conn.close();
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
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
            e.printStackTrace();
            return false;
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
}
