package pe.edu.utp.daoImpl;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import pe.edu.utp.config.Conexion;
import pe.edu.utp.dao.CitaDao;
import pe.edu.utp.entity.Cita;
import pe.edu.utp.entity.Comprobante;
import pe.edu.utp.entity.Paciente;
import pe.edu.utp.entity.Venta;
import pe.edu.utp.entity.VerCita;

/**
 *
 * @author Andrea
 */
public class CitaDaoImpl implements CitaDao {

    private PreparedStatement ps;
    private PreparedStatement ps1;

    private ResultSet rs;

    private Connection cx;

    @Override
    public int createCitasilapersonaesnueva(Paciente p, Cita c, Venta v) {
        try {
            // Obtener conexión
            cx = Conexion.getConection();
            if (cx == null) {
                System.out.println("No se pudo establecer conexión con la base de datos.");
                return 0;  // Retorna 0 si no hay conexión
            }
            // Llamar a sp_registrarusuario
            ps = cx.prepareStatement("{CALL sp_registrarusuario(?, ?, ?, ?, ?)}");
            ps.setString(1, p.getNombre());
            ps.setString(2, p.getApellido());
            ps.setString(3, String.format("%08d", p.getDni()));
            ps.setInt(4, p.getTelefono());
            ps.setString(5, p.getCorreo());
            ps.executeUpdate();
            ps.close();

            // Llamar a sp_registrarprimeracita
            ps = cx.prepareStatement("{CALL sp_registrarprimeracita(?, ?, ?, ?, ?)}");
            ps.setString(1, c.getDiaReserva());
            ps.setString(2, c.getHoraReserva());
            ps.setInt(3, c.getId_Servicio());
            ps.setInt(4, c.getId_Estado());
            ps.setInt(5, c.getOdontologo_idUsuario());
            ps.executeUpdate();
            ps.close();

            // Llamar a sp_ventas
            ps = cx.prepareStatement("{CALL sp_ventas(?)}");
            ps.setDouble(1, v.getImporte());
            ps.executeUpdate();
            ps.close();

            return 1; // Éxito
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try {
                if (ps != null) {
                    ps.close();
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        return 0; // Error
    }

    @Override
    public int createCitasilapersonayaexiste(Paciente p, Cita c, Venta v) {
        try {
            // Obtener conexión
            cx = Conexion.getConection();
            if (cx == null) {
                System.out.println("No se pudo establecer conexión con la base de datos.");
                return 0;  // Retorna 0 si no hay conexión
            }
            System.out.println("dni q ="+p.getDni());
            // Llamar a sp_registrarcita
            ps = cx.prepareStatement("{CALL sp_registrarcita(?, ?, ?, ?, ?, ?)}");
            ps.setString(1, c.getDiaReserva());
            ps.setString(2, c.getHoraReserva());
            ps.setInt(3, c.getId_Servicio());
            ps.setString(4, "" + p.getIdPaciente());
            ps.setInt(5, c.getId_Estado());
            ps.setInt(6, c.getOdontologo_idUsuario());
            ps.executeUpdate();
            ps.close();

            // Llamar a sp_ventas
            ps = cx.prepareStatement("{CALL sp_ventas(?)}");
            ps.setDouble(1, v.getImporte());
            ps.executeUpdate();
            ps.close();

            return 1; // Éxito
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try {
                if (ps != null) {
                    ps.close();
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        return 0; // Error
    }

    @Override
    public int verificarExistencia(int dni) {
        try (Connection conn=Conexion.getConection(); PreparedStatement st=conn.prepareStatement("SELECT idPaciente FROM Paciente WHERE DNI=?")) {
            st.setString(1,String.format("%08d",dni));
            try(ResultSet rs=st.executeQuery()) { return rs.next()?rs.getInt(1):0; }
        } catch(SQLException e) { throw new IllegalStateException("No se pudo consultar el paciente",e); }
    }

    @Override
    public int updateCita(int idCita, String nuevaFecha, String nuevaHora) {
        // Obtener conexión
        cx = Conexion.getConection();
        if (cx == null) {
            System.out.println("No se pudo establecer conexión con la base de datos.");
            return 0;
        }

        // Nombre del procedimiento almacenado para actualizar la cita
        String SQL = "{CALL ps_ReprogramarCita(?, ?, ?)}";

        try {
            // Preparar el statement con el procedimiento almacenado
            ps = cx.prepareStatement(SQL);
            ps.setInt(1, idCita);
            ps.setString(2, nuevaFecha);
            ps.setString(3, nuevaHora);

            // Ejecutar la actualización
            int result = ps.executeUpdate();

            return result; // Retorna el número de filas afectadas
        } catch (SQLException e) {
            System.out.println("Error al actualizar la cita: " + e.getMessage());
            return 0;  // Retorna 0 si ocurrió un error
        } finally {
            // Cerrar recursos (PreparedStatement, Connection)
            try {
                if (ps != null) {
                    ps.close();
                }
                if (cx != null) {
                    cx.close();
                }
            } catch (SQLException e) {
                System.out.println("Error al cerrar recursos: " + e.getMessage());
            }
        }
    }

    @Override
    public Cita readCita(int id) {
        throw new UnsupportedOperationException("Not supported yet."); // Generated from nbfs://nbhost/SystemFileSystem/Templates/Classes/Code/GeneratedMethodBody
    }

    @Override
    public List<VerCita> listarCitas(int idUsuario) {
        List<VerCita> lista = new ArrayList<>();
        String SQL = "{call sp_ListarCitasPorUsuario(?)}";  // Procedimiento almacenado

        try {
            // Obtener la conexión
            cx = Conexion.getConection();
            // Preparar el statement con el procedimiento almacenado
            ps = cx.prepareStatement(SQL);
            ps.setInt(1, idUsuario);  // Pasar el ID del usuario

            // Ejecutar la consulta
            rs = ps.executeQuery();

            // Recorrer los resultados
            while (rs.next()) {
                VerCita re = new VerCita();
                re.setIdCita(rs.getInt("idCita"));
                re.setDiaReserva(rs.getString("DiaReserva"));
                re.setHoraReserva(rs.getString("HoraReserva"));
                re.setNombrePaciente(rs.getString("NombrePaciente"));
                re.setApellidoPaciente(rs.getString("ApellidoPaciente"));
                re.setEstado(rs.getString("Estado"));
                re.setTipoServicio(rs.getString("TipoServicio"));

                lista.add(re);
            }
        } catch (SQLException e) {
            System.out.println("Error al obtener reservas: " + e.getMessage());
        } finally {
            // Cerrar recursos (ResultSet, PreparedStatement, Connection)
            try {
                if (rs != null) {
                    rs.close();
                }
                if (ps != null) {
                    ps.close();
                }
                if (cx != null) {
                    cx.close();
                }
            } catch (SQLException e) {
                System.out.println("Error al cerrar recursos: " + e.getMessage());
            }
        }

        System.out.println("Total de reservas recuperadas: " + lista.size());
        try {
            Map<Integer, Comprobante> mapComp = new PagoDaoImpl().obtenerMapaComprobantesPorCita();
            java.util.Set<Integer> pagadas = new PagoDaoImpl().citasPagadas();
            for (VerCita re : lista) {
                re.setTienePago(pagadas.contains(re.getIdCita()));
                if (mapComp.containsKey(re.getIdCita())) {
                    Comprobante c = mapComp.get(re.getIdCita());
                    re.setTienePago(true);
                    re.setCodigoBoleta(c.getCodigoBoletaCompleto());
                    re.setIdPago(c.getPago_idPago());
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return lista;

    }

    @Override
    public List<VerCita> listarHistorialCitas(int idUsuario) {
        List<VerCita> lista = new ArrayList<>();
        String SQL = "{call sp_ListarHisotialCitas(?)}";  // Procedimiento almacenado

        try {
            // Obtener la conexión
            cx = Conexion.getConection();
            // Preparar el statement con el procedimiento almacenado
            ps = cx.prepareStatement(SQL);
            ps.setInt(1, idUsuario);  // Pasar el ID del usuario

            // Ejecutar la consulta
            rs = ps.executeQuery();

            // Recorrer los resultados
            while (rs.next()) {
                VerCita re = new VerCita();
                re.setIdCita(rs.getInt("idCita"));
                re.setDiaReserva(rs.getString("DiaReserva"));
                re.setHoraReserva(rs.getString("HoraReserva"));
                re.setNombrePaciente(rs.getString("NombrePaciente"));
                re.setApellidoPaciente(rs.getString("ApellidoPaciente"));
                re.setEstado(rs.getString("Estado"));
                re.setTipoServicio(rs.getString("TipoServicio"));
                lista.add(re);
            }
        } catch (SQLException e) {
            System.out.println("Error al obtener reservas: " + e.getMessage());
        } finally {
            // Cerrar recursos (ResultSet, PreparedStatement, Connection)
            try {
                if (rs != null) {
                    rs.close();
                }
                if (ps != null) {
                    ps.close();
                }
                if (cx != null) {
                    cx.close();
                }
            } catch (SQLException e) {
                System.out.println("Error al cerrar recursos: " + e.getMessage());
            }
        }

        System.out.println("Total de reservas recuperadas: " + lista.size());
        return lista;

    }

    @Override
    public List<VerCita> listarTodasCitas(int idUsuario) {
        List<VerCita> lista = new ArrayList<>();
        String SQL = "{call sp_ListarTodasCitas(?)}";  // Procedimiento almacenado

        try {
            // Obtener la conexión
            cx = Conexion.getConection();
            // Preparar el statement con el procedimiento almacenado
            ps = cx.prepareStatement(SQL);
            ps.setInt(1, idUsuario);  // Pasar el ID del usuario

            // Ejecutar la consulta
            rs = ps.executeQuery();

            // Recorrer los resultados
            while (rs.next()) {
                VerCita re = new VerCita();
                re.setIdCita(rs.getInt("idCita"));
                re.setDiaReserva(rs.getString("DiaReserva"));
                re.setHoraReserva(rs.getString("HoraReserva"));
                re.setNombrePaciente(rs.getString("NombrePaciente"));
                re.setApellidoPaciente(rs.getString("ApellidoPaciente"));
                re.setEstado(rs.getString("Estado"));
                re.setTipoServicio(rs.getString("TipoServicio"));
                re.setNombreUsuario(rs.getString("NombreOdontologo"));
                re.setApellidoUsuario(rs.getString("ApellidoOdontologo"));
                lista.add(re);
            }
        } catch (SQLException e) {
            System.out.println("Error al obtener reservas: " + e.getMessage());
        } finally {
            // Cerrar recursos (ResultSet, PreparedStatement, Connection)
            try {
                if (rs != null) {
                    rs.close();
                }
                if (ps != null) {
                    ps.close();
                }
                if (cx != null) {
                    cx.close();
                }
            } catch (SQLException e) {
                System.out.println("Error al cerrar recursos: " + e.getMessage());
            }
        }

        System.out.println("Total de reservas recuperadas: " + lista.size());
        return lista;

    }

    @Override
    public List<VerCita> listarTodasCitasAd() {
        List<VerCita> lista = new ArrayList<>();
        String SQL = "{call sp_ListarTodasCitasAd}";  // Procedimiento almacenado

        try {
            // Obtener la conexión
            cx = Conexion.getConection();
            // Preparar el statement con el procedimiento almacenado
            ps = cx.prepareStatement(SQL);

            // Ejecutar la consulta
            rs = ps.executeQuery();

            // Recorrer los resultados
            while (rs.next()) {
                VerCita re = new VerCita();
                re.setIdCita(rs.getInt("idCita"));
                re.setDiaReserva(rs.getString("DiaReserva"));
                re.setHoraReserva(rs.getString("HoraReserva"));
                re.setNombrePaciente(rs.getString("NombrePaciente"));
                re.setApellidoPaciente(rs.getString("ApellidoPaciente"));
                re.setEstado(rs.getString("Estado"));
                re.setTipoServicio(rs.getString("TipoServicio"));
                re.setNombreUsuario(rs.getString("NombreOdontologo"));
                re.setApellidoUsuario(rs.getString("ApellidoOdontologo"));
                lista.add(re);
            }
        } catch (SQLException e) {
            System.out.println("Error al obtener reservas: " + e.getMessage());
        } finally {
            // Cerrar recursos (ResultSet, PreparedStatement, Connection)
            try {
                if (rs != null) {
                    rs.close();
                }
                if (ps != null) {
                    ps.close();
                }
                if (cx != null) {
                    cx.close();
                }
            } catch (SQLException e) {
                System.out.println("Error al cerrar recursos: " + e.getMessage());
            }
        }

        System.out.println("Total de reservas recuperadas: " + lista.size());
        return lista;

    }
    
    @Override
    public List<VerCita> DetalleCita(int idCita) {
        List<VerCita> lista = new ArrayList<>();
        String SQL = "{call sp_DetalleCita(?)}";  // Procedimiento almacenado

        try {
            // Obtener la conexión
            cx = Conexion.getConection();
            // Preparar el statement con el procedimiento almacenado
            ps = cx.prepareStatement(SQL);
            ps.setInt(1, idCita);  // Pasar el ID del usuario

            // Ejecutar la consulta
            rs = ps.executeQuery();

            // Recorrer los resultados
            while (rs.next()) {
                VerCita re = new VerCita();
                re.setIdCita(rs.getInt("idCita"));
                re.setDiaReserva(rs.getString("DiaReserva"));
                re.setHoraReserva(rs.getString("HoraReserva"));
                re.setNombrePaciente(rs.getString("NombrePaciente"));
                re.setApellidoPaciente(rs.getString("ApellidoPaciente"));
                re.setEstado(rs.getString("Estado"));
                re.setTipoServicio(rs.getString("TipoServicio"));
                re.setNombreUsuario(rs.getString("NombreOdontologo"));
                re.setApellidoUsuario(rs.getString("ApellidoOdontologo"));
                lista.add(re);
            }
        } catch (SQLException e) {
            System.out.println("Error al obtener reservas: " + e.getMessage());
        } finally {
            // Cerrar recursos (ResultSet, PreparedStatement, Connection)
            try {
                if (rs != null) {
                    rs.close();
                }
                if (ps != null) {
                    ps.close();
                }
                if (cx != null) {
                    cx.close();
                }
            } catch (SQLException e) {
                System.out.println("Error al cerrar recursos: " + e.getMessage());
            }
        }

        System.out.println("Total de reservas recuperadas: " + lista.size());
        return lista;

    }

    @Override
    public int DeleteCita(int idCita) {
        // Obtener conexión
        cx = Conexion.getConection();
        if (cx == null) {
            System.out.println("No se pudo establecer conexión con la base de datos.");
            return 0;
        }
        String SQL = "UPDATE Cita SET Estado_idEstado = 6 WHERE idCita = ?";
        try {
            ps = cx.prepareStatement(SQL);
            ps.setInt(1, idCita);
            int result = ps.executeUpdate();

            return result;
        } catch (SQLException e) {
            System.out.println("Error al actualizar el estado de la reserva: " + e.getMessage());
            return 0;
        } finally {
            try {
                if (ps != null) {
                    ps.close();
                }
                if (cx != null) {
                    cx.close();
                }
            } catch (SQLException e) {
                System.out.println("Error al cerrar recursos: " + e.getMessage());
            }
        }
    }

    @Override
    public List<VerCita> listarCitasPorDia(String dia_semana) {
        List<VerCita> lista = new ArrayList<>();
        String SQL = "{call ListarCitasSemanaActual(?)}";

        try (Connection conn = Conexion.getConection();
             PreparedStatement st = conn.prepareStatement(SQL)) {
            st.setString(1, dia_semana);
            try (ResultSet res = st.executeQuery()) {
                while (res.next()) {
                    VerCita re = new VerCita();
                    re.setIdCita(res.getInt("idCita"));
                    re.setDiaReserva(res.getString("DiaReserva"));
                    re.setHoraReserva(res.getString("HoraReserva"));
                    re.setNombrePaciente(res.getString("NombrePaciente"));
                    re.setApellidoPaciente(res.getString("ApellidoPaciente"));
                    re.setEstado(res.getString("EstadoReserva"));
                    re.setTipoServicio(res.getString("TipoServicio"));
                    re.setNombreUsuario(res.getString("NombreOdontologo"));
                    re.setApellidoUsuario(res.getString("ApellidoOdontologo"));
                    re.setOrden_row(res.getInt("orden_row"));
                    re.setColor(res.getString("color"));
                    try {
                        re.setCosto(res.getDouble("Costo"));
                    } catch (Exception ignored) {}
                    lista.add(re);
                }
            }
        } catch (SQLException e) {
            System.out.println("Error al obtener citas por dia: " + e.getMessage());
        }

        System.out.println("Total de citas recuperadas: " + lista.size());
        return lista;
    }

    @Override
    public List<VerCita> listarCitasPorDiaSemana(String dia_semana, int semanaActual) {
        List<VerCita> lista = new ArrayList<>();
        String SQL = "{call ListarCitasPorDiaSemana(?, ?)}";

        try (Connection conn = Conexion.getConection();
             PreparedStatement st = conn.prepareStatement(SQL)) {
            st.setString(1, dia_semana);
            st.setInt(2, semanaActual);
            try (ResultSet res = st.executeQuery()) {
                while (res.next()) {
                    VerCita re = new VerCita();
                    re.setIdCita(res.getInt("idCita"));
                    re.setDiaReserva(res.getString("DiaReserva"));
                    re.setHoraReserva(res.getString("HoraReserva"));
                    re.setNombrePaciente(res.getString("NombrePaciente"));
                    re.setApellidoPaciente(res.getString("ApellidoPaciente"));
                    re.setEstado(res.getString("EstadoReserva"));
                    re.setTipoServicio(res.getString("TipoServicio"));
                    re.setNombreUsuario(res.getString("NombreOdontologo"));
                    re.setApellidoUsuario(res.getString("ApellidoOdontologo"));
                    try {
                        re.setCosto(res.getDouble("Costo"));
                    } catch (Exception ignored) {}
                    re.setOrden_row(res.getInt("orden_row"));
                    re.setColor(res.getString("color"));
                    lista.add(re);
                }
            }
        } catch (SQLException e) {
            System.out.println("Error al obtener citas por dia semana: " + e.getMessage());
        }

        System.out.println("Total de citas recuperadas: " + lista.size());
        return lista;
    }

    @Override
    public int updateEstadoCita(int idCita, String estadoActual) {
        // Obtener conexión
        cx = Conexion.getConection();
        if (cx == null) {
            System.out.println("No se pudo establecer conexión con la base de datos.");
            return 0;
        }
        String SQL = "UPDATE Cita SET Estado_idEstado = ? WHERE idCita = ?";
        int nuevoEstado;
        if ("Reprogramado".equalsIgnoreCase(estadoActual)) {
            nuevoEstado = 3;
        } else if ("Confirmado".equalsIgnoreCase(estadoActual)) {
            nuevoEstado = 2;
        } else if ("En espera".equalsIgnoreCase(estadoActual)) {
            nuevoEstado = 3;
        } else {
            System.out.println("El estado actual no es válido para la actualización.");
            return 0;
        }
        try {
            ps = cx.prepareStatement(SQL);
            ps.setInt(1, nuevoEstado);
            ps.setInt(2, idCita);
            int result = ps.executeUpdate();

            return result;
        } catch (SQLException e) {
            System.out.println("Error al actualizar el estado de la reserva: " + e.getMessage());
            return 0;
        } finally {
            try {
                if (ps != null) {
                    ps.close();
                }
                if (cx != null) {
                    cx.close();
                }
            } catch (SQLException e) {
                System.out.println("Error al cerrar recursos: " + e.getMessage());
            }
        }
    }

    @Override
    public int updateEstadoCitaCancelado(int idCita) {
        // Obtener conexión
        cx = Conexion.getConection();
        if (cx == null) {
            System.out.println("No se pudo establecer conexión con la base de datos.");
            return 0;
        }
        String SQL = "UPDATE Cita SET Estado_idEstado = 5 WHERE idCita = ?";
        try {
            ps = cx.prepareStatement(SQL);
            ps.setInt(1, idCita);
            int result = ps.executeUpdate();

            return result;
        } catch (SQLException e) {
            System.out.println("Error al actualizar el estado de la reserva: " + e.getMessage());
            return 0;
        } finally {
            try {
                if (ps != null) {
                    ps.close();
                }
                if (cx != null) {
                    cx.close();
                }
            } catch (SQLException e) {
                System.out.println("Error al cerrar recursos: " + e.getMessage());
            }
        }
    }
    @Override
    public List<Cita> listarCitasRecientes() {
        List<Cita> citas = new ArrayList<>();
        String SQL = "{CALL sp_listarCitasRecientes()}";

        try {
            cx = Conexion.getConection();
            ps = cx.prepareStatement(SQL);
            rs = ps.executeQuery();

            while (rs.next()) {
                Cita cita = new Cita();
                cita.setIdCita(rs.getInt("idCita"));
                cita.setDiaReserva(""+rs.getDate("DiaReserva").toLocalDate());
                cita.setHoraReserva(""+rs.getTime("HoraReserva").toLocalTime());
                cita.setNombrePaciente(rs.getString("NombrePaciente"));
                cita.setNombreServicio(rs.getString("NombreServicio"));
                cita.setEstadoNombre(rs.getString("EstadoNombre"));
                citas.add(cita);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return citas;
    }
    
    @Override
    public int contarPacientes() {
        return contar("SELECT COUNT(*) FROM Paciente");
    }

    @Override
    public int contarEnEspera() {
        return contar("SELECT COUNT(*) FROM Cita c INNER JOIN Estado e ON c.Estado_idEstado = e.idEstado WHERE e.TipoEstado = 'En espera'");
    }

    @Override
    public java.util.Set<Integer> idsCitasDeOdontologo(int idOdontologo) {
        java.util.Set<Integer> ids = new java.util.HashSet<>();
        String sql = "SELECT idCita FROM Cita WHERE Odontologo_idUsuario = ?";
        try (Connection conn = Conexion.getConection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, idOdontologo);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ids.add(rs.getInt(1));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return ids;
    }

    private int contar(String sql) {
        try (Connection conn = Conexion.getConection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            return rs.next() ? rs.getInt(1) : 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return 0;
        }
    }

    @Override
    public int obtenerTotalCitasReservas() {
        int total = 0;
        String sql = "SELECT COUNT(*) AS TotalContado FROM Cita"; // reserva es una vista de Cita: no sumar dos veces
        try (Connection conn = Conexion.getConection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                total = rs.getInt("TotalContado");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return total;
    }
    
    @Override
    public String getEmailPacienteByCitaId(int idCita) {
        String correo = "";
        String SQL = "SELECT p.Correo FROM Cita c INNER JOIN Paciente p ON c.Paciente_idPaciente = p.idPaciente WHERE c.idCita = ?";
        try (Connection conn = Conexion.getConection(); PreparedStatement ps = conn.prepareStatement(SQL)) {
            ps.setInt(1, idCita);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    correo = rs.getString("Correo");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return correo;
    }

    @Override
    public String[] obtenerNombrePaciente(int dni) {
        String sql = "SELECT Nombre, Apellido FROM Paciente WHERE DNI = ?";
        try (Connection conn = Conexion.getConection(); PreparedStatement st = conn.prepareStatement(sql)) {
            st.setString(1, String.format("%08d", dni));
            try (ResultSet r = st.executeQuery()) {
                if (r.next()) {
                    return new String[]{r.getString("Nombre"), r.getString("Apellido")};
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    @Override
    public void actualizarContactoPaciente(int idPaciente, int telefono, String correo) {
        String sql = "UPDATE Paciente SET Telefono = ?, Correo = ? WHERE idPaciente = ?";
        try (Connection conn = Conexion.getConection(); PreparedStatement st = conn.prepareStatement(sql)) {
            st.setString(1, String.valueOf(telefono));
            st.setString(2, correo);
            st.setInt(3, idPaciente);
            st.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @Override
    public int createReservaWeb(Paciente p, Cita c, double importe, String descripcion) {
        return registrarCita(p,c,importe,descripcion,0,false);
    }

    @Override
    public int createCitaPresencial(Paciente p, Cita c, double importe, String descripcion, int idSecretaria) {
        return registrarCita(p,c,importe,descripcion,idSecretaria,true);
    }

    private int registrarCita(Paciente p, Cita cita, double importe, String descripcion, int actor, boolean presencial) {
        try (Connection conn = Conexion.getConection()) {
            int pacienteId;
            // La clave unica de DNI resuelve dos altas simultaneas sin buscar MAX(id).
            try (PreparedStatement st = conn.prepareStatement(
                    "INSERT INTO Paciente(Nombre,Apellido,DNI,Telefono,Correo) VALUES(?,?,?,?,?) "
                    + "ON DUPLICATE KEY UPDATE idPaciente=LAST_INSERT_ID(idPaciente)")) {
                st.setString(1,p.getNombre()); st.setString(2,p.getApellido());
                st.setString(3,String.format("%08d",p.getDni())); st.setInt(4,p.getTelefono()); st.setString(5,p.getCorreo());
                st.executeUpdate();
            }
            try (PreparedStatement st=conn.prepareStatement("SELECT idPaciente,Nombre,Apellido FROM Paciente WHERE DNI=?")) {
                st.setString(1,String.format("%08d",p.getDni()));
                try (ResultSet rs=st.executeQuery()) {
                    if (!rs.next()) return 0;
                    pacienteId=rs.getInt(1);
                    if (!normalizarNombre(rs.getString(2)).equals(normalizarNombre(p.getNombre()))
                            || !normalizarNombre(rs.getString(3)).equals(normalizarNombre(p.getApellido()))) {
                        throw new pe.edu.utp.utils.ReservaNoDisponibleException("El DNI ya esta registrado con otros nombres.",null);
                    }
                }
            }
            try (java.sql.CallableStatement st=conn.prepareCall("{call sp_artdent_crearCita(?,?,?,?,?,?,?,?,?,?)}")) {
                st.setString(1,cita.getDiaReserva()); st.setString(2,cita.getHoraReserva());
                st.setString(3,descripcion==null || descripcion.trim().isEmpty() ? (presencial?"Cita Presencial":"Reserva Web") : descripcion);
                st.setDouble(4,importe); st.setString(5,presencial?"Presencial":"Web");
                if(actor>0)st.setInt(6,actor); else st.setNull(6,java.sql.Types.INTEGER);
                st.setInt(7,pacienteId); st.setInt(8,cita.getId_Servicio()); st.setInt(9,presencial?3:1);
                st.setInt(10,cita.getOdontologo_idUsuario()); st.execute();
            }
            // LAST_INSERT_ID pertenece a esta conexion; no depende del paciente ni de otras reservas.
            try (PreparedStatement st=conn.prepareStatement("SELECT LAST_INSERT_ID()"); ResultSet rs=st.executeQuery()) {
                return rs.next()?rs.getInt(1):0;
            }
        } catch (SQLException e) {
            if ("45000".equals(e.getSQLState())) throw new pe.edu.utp.utils.ReservaNoDisponibleException(e.getMessage(),e);
            java.util.logging.Logger.getLogger(CitaDaoImpl.class.getName()).log(java.util.logging.Level.SEVERE,"No se pudo registrar la cita",e);
            return 0;
        }
    }

    private static String normalizarNombre(String valor) {
        return java.text.Normalizer.normalize(valor.trim().toLowerCase(java.util.Locale.ROOT),java.text.Normalizer.Form.NFD)
                .replaceAll("\\p{M}","").replaceAll("\\s+"," ");
    }

    @Override
    public int registrarNotificacion(String asunto, int idEstado, int idCita, boolean enviado) {
        String sql = "INSERT INTO Notificacion (Asunto, FechaEnvio, Enviado, Estado_idEstado, Cita_idCita) VALUES (?, NOW(), ?, ?, ?)";
        if (asunto != null && asunto.length() > 100) {
            asunto = asunto.substring(0, 100);
        }
        try (Connection conn = Conexion.getConection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, asunto);
            ps.setInt(2, enviado ? 1 : 0);
            ps.setInt(3, idEstado);
            ps.setInt(4, idCita);
            return ps.executeUpdate();
        } catch (SQLException e) {
            System.err.println("Error al registrar notificación (RF09): " + e.getMessage());
            return 0;
        }
    }
}
