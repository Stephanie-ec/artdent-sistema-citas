/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package pe.edu.utp.daoImpl;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;
import pe.edu.utp.config.Conexion;
import pe.edu.utp.dao.ReservaDao;
import pe.edu.utp.entity.Comprobante;
import pe.edu.utp.entity.Reserva;
import pe.edu.utp.entity.Paciente;
import pe.edu.utp.entity.Usuario;
import pe.edu.utp.entity.VerReserva;

/**
 *
 * @author Christhian
 */
public class ReservaDaoImpl implements ReservaDao {

    private PreparedStatement ps;
    private PreparedStatement ps1;

    private ResultSet rs;

    private Connection cx;

    @Override
    public int createReserva(Paciente p, Reserva r) {
        int x = 0;
        String SQL_1 = "{call sp_registrarusuario (?,?,?,?,?)}";  // Almacenar paciente
        String SQL_2 = "{call sp_crearreserva (?,?,?,?,?,?,?,?)}";  // Almacenar reserva
        try {
            // Obtener conexión
            cx = Conexion.getConection();
            if (cx == null) {
                System.out.println("No se pudo establecer conexión con la base de datos.");
                return x;  // Retorna 0 si no hay conexión
            }

            // Guardar el Paciente
            ps = cx.prepareStatement(SQL_1);
            ps.setString(1, p.getNombre());
            ps.setString(2, p.getApellido());
            ps.setInt(3, p.getDni());
            ps.setInt(4, p.getTelefono());
            ps.setString(5, p.getCorreo());
            x = ps.executeUpdate();  // Ejecutar y guardar paciente
            System.out.println("Inserción de paciente: " + x);

            // Guardar la Reserva
            if (x > 0) {  // Solo intentar guardar la reserva si se insertó el paciente
                ps1 = cx.prepareStatement(SQL_2);
                ps1.setString(1, r.getDiaReserva());
                ps1.setString(2, r.getHoraReserva());
                ps1.setString(3, r.getDescripcion());
                ps1.setDouble(4, r.getImporte());
                ps1.setInt(5, r.getUsuario_idUsuario());
                ps1.setInt(6, r.getEstado_idEstado()); // Este es el parámetro 6
                ps1.setInt(7, r.getServicio_idServicio());
                ps1.setInt(8, r.getOdontologo_idUsuario());

                x = ps1.executeUpdate();
                System.out.println("Inserción de reserva: " + x);
            }

        } catch (SQLException e) {
            e.printStackTrace();
            System.out.println("Error al insertar " + e);
        } finally {
            // Cerrar recursos
            try {
                if (ps != null) {
                    ps.close();
                }
                if (ps1 != null) {
                    ps1.close();
                }
                if (cx != null) {
                    cx.close();
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }

        return x;
    }

    @Override
    public int updateReserva(int idReserva, String nuevaFecha, String nuevaHora) {
        // Obtener conexión
        cx = Conexion.getConection();
        if (cx == null) {
            System.out.println("No se pudo establecer conexión con la base de datos.");
            return 0;
        }

        // Nombre del procedimiento almacenado para actualizar la cita
        String SQL = "{CALL ps_ReprogramarReserva(?, ?, ?)}";

        try {
            // Preparar el statement con el procedimiento almacenado
            ps = cx.prepareStatement(SQL);
            ps.setInt(1, idReserva);
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
    public int updateEstadoReserv(int idReserva, String estadoActual) {
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

        int resultCita = 0;
        int resultRes = 0;

        try (Connection conn = Conexion.getConection()) {
            if (conn == null) {
                System.out.println("No se pudo establecer conexión con la base de datos.");
                return 0;
            }
            try (PreparedStatement psCita = conn.prepareStatement("UPDATE Cita SET Estado_idEstado = ? WHERE idCita = ?")) {
                psCita.setInt(1, nuevoEstado);
                psCita.setInt(2, idReserva);
                resultCita = psCita.executeUpdate();
            }
            try (PreparedStatement psRes = conn.prepareStatement("UPDATE reserva SET Estado_idEstado = ? WHERE idReserva = ?")) {
                psRes.setInt(1, nuevoEstado);
                psRes.setInt(2, idReserva);
                resultRes = psRes.executeUpdate();
            }
        } catch (SQLException e) {
            System.out.println("Error al actualizar el estado de la reserva: " + e.getMessage());
            return 0;
        }

        return Math.max(resultCita, resultRes);
    }

    @Override
    public int updateEstadoCancelado(int idReserva) {
        cx = Conexion.getConection();
        if (cx == null) {
            System.out.println("No se pudo establecer conexión con la base de datos.");
            return 0;
        }
        String SQL = "UPDATE reserva SET Estado_idEstado = 5 WHERE idReserva = ?";

        try {
            ps = cx.prepareStatement(SQL);
            ps.setInt(1, idReserva);
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
    public int rechazarReserva(int idReserva) {
        cx = Conexion.getConection();
        if (cx == null) {
            System.out.println("No se pudo establecer conexión con la base de datos.");
            return 0;
        }
        String SQL = "UPDATE cita SET Estado_idEstado = 6 WHERE idCita = ?";

        try {
            ps = cx.prepareStatement(SQL);
            ps.setInt(1, idReserva);
            int result = ps.executeUpdate();
            return result;
        } catch (SQLException e) {
            System.out.println("Error al rechazar la reserva: " + e.getMessage());
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
    public int deleteReserva(int idReserva) {
        cx = Conexion.getConection();
        if (cx == null) {
            System.out.println("No se pudo establecer conexión con la base de datos.");
            return 0;
        }
        String SQL = "DELETE FROM reserva WHERE idReserva = ?";

        try {
            ps = cx.prepareStatement(SQL);
            ps.setInt(1, idReserva);
            int result = ps.executeUpdate();

            return result;
        } catch (SQLException e) {
            System.out.println("Error al eliminar la reserva: " + e.getMessage());
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
    public Reserva readReserva(int id) {
        throw new UnsupportedOperationException("Not supported yet."); // Generated from nbfs://nbhost/SystemFileSystem/Templates/Classes/Code/GeneratedMethodBody
    }

    @Override
    public int createReservaPacex(Paciente p, Reserva r) {
        int x = 0;
        String SQL_2 = "{call sp_crearreserva (?,?,?,?,?,?,?,?)}";  // Almacenar reserva
        try {
            // Obtener conexión
            cx = Conexion.getConection();
            if (cx == null) {
                System.out.println("No se pudo establecer conexión con la base de datos.");
                return x;  // Retorna 0 si no hay conexión
            }
            ps1 = cx.prepareStatement(SQL_2);
            ps1.setString(1, r.getDiaReserva());
            ps1.setString(2, r.getHoraReserva());
            ps1.setString(3, r.getDescripcion());
            ps1.setDouble(4, r.getImporte());
            ps1.setInt(5, r.getUsuario_idUsuario());
            ps1.setInt(6, r.getEstado_idEstado()); // Este es el parámetro 6
            ps1.setInt(7, r.getServicio_idServicio());
            ps1.setInt(8, r.getOdontologo_idUsuario());

            x = ps1.executeUpdate();
            System.out.println("Inserción de reserva: " + x);
        } catch (SQLException ex) {
            Logger.getLogger(ReservaDaoImpl.class.getName()).log(Level.SEVERE, null, ex);
        }

        return x;
    }

    @Override
    public int verificarExistencia(int dni) {
        // Obtener conexión
        cx = Conexion.getConection();
        if (cx == null) {
            System.out.println("No se pudo establecer conexión con la base de datos.");
            return 0;  // Retorna 0 si no hay conexión
        }
        String sql = "SELECT idPaciente FROM paciente WHERE DNI = ?";
        int idPaciente;

        try {
            ps = cx.prepareStatement(sql);
            ps.setInt(1, dni);
            rs = ps.executeQuery();

            if (rs.next()) {
                return idPaciente = rs.getInt("idPaciente");  // Devuelve el idPaciente si existe
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try {
                if (rs != null) {
                    rs.close();
                }
                if (ps != null) {
                    ps.close();
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        return 0;  // Devuelve el idPaciente si existe, o 0 si no se encontró
    }

    @Override
    public List<VerReserva> listarReservas(int idUsuario) {
        List<VerReserva> lista = new ArrayList<>();
        String SQL = "{call sp_ListarReservasPorUsuario(?)}";  // Procedimiento almacenado

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
                VerReserva re = new VerReserva();
                re.setIdReserva(rs.getInt("idReserva"));
                re.setDiaReserva(rs.getString("DiaReserva"));
                re.setHoraReserva(rs.getString("HoraReserva"));
                re.setDescripcion(rs.getString("Descripcion"));
                re.setImporte(rs.getDouble("Importe"));
                re.setNombrePaciente(rs.getString("NombrePaciente"));
                re.setApellidoPaciente(rs.getString("ApellidoPaciente"));
                re.setEstado(rs.getString("EstadoReserva"));
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
        try {
            Map<Integer, Comprobante> mapComp = new PagoDaoImpl().obtenerMapaComprobantesPorCita();
            for (VerReserva re : lista) {
                if (mapComp.containsKey(re.getIdReserva())) {
                    Comprobante c = mapComp.get(re.getIdReserva());
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
    public List<VerReserva> listarTodasReservas(int idUsuario) {
        List<VerReserva> lista = new ArrayList<>();
        String SQL = "{call sp_ListarReservasReporte(?)}";  // Procedimiento almacenado

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
                VerReserva re = new VerReserva();
                re.setIdReserva(rs.getInt("idReserva"));
                re.setDiaReserva(rs.getString("DiaReserva"));
                re.setHoraReserva(rs.getString("HoraReserva"));
                re.setDescripcion(rs.getString("Descripcion"));
                re.setImporte(rs.getDouble("Importe"));
                re.setNombrePaciente(rs.getString("NombrePaciente"));
                re.setApellidoPaciente(rs.getString("ApellidoPaciente"));
                re.setEstado(rs.getString("EstadoReserva"));
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
    public List<VerReserva> listarHistorialReservas(int idUsuario) {
        List<VerReserva> lista = new ArrayList<>();
        String SQL = "{call sp_ListarHistorialReservas(?)}";  // Procedimiento almacenado

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
                VerReserva re = new VerReserva();
                re.setIdReserva(rs.getInt("idReserva"));
                re.setDiaReserva(rs.getString("DiaReserva"));
                re.setHoraReserva(rs.getString("HoraReserva"));
                re.setDescripcion(rs.getString("Descripcion"));
                re.setImporte(rs.getDouble("Importe"));
                re.setNombrePaciente(rs.getString("NombrePaciente"));
                re.setApellidoPaciente(rs.getString("ApellidoPaciente"));
                re.setEstado(rs.getString("EstadoReserva"));
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
    public List<VerReserva> DetalleReserva(int idReserva) {
        List<VerReserva> lista = new ArrayList<>();
        String SQL = "{call sp_DetalleReserva(?)}";  // Procedimiento almacenado

        try {
            // Obtener la conexión
            cx = Conexion.getConection();
            // Preparar el statement con el procedimiento almacenado
            ps = cx.prepareStatement(SQL);
            ps.setInt(1, idReserva);  // Pasar el ID del usuario

            // Ejecutar la consulta
            rs = ps.executeQuery();

            // Recorrer los resultados
            while (rs.next()) {
                VerReserva re = new VerReserva();
                re.setIdReserva(rs.getInt("idReserva"));
                re.setDiaReserva(rs.getString("DiaReserva"));
                re.setHoraReserva(rs.getString("HoraReserva"));
                re.setDescripcion(rs.getString("Descripcion"));
                re.setImporte(rs.getDouble("Importe"));
                re.setNombrePaciente(rs.getString("NombrePaciente"));
                re.setApellidoPaciente(rs.getString("ApellidoPaciente"));
                re.setEstado(rs.getString("EstadoReserva"));
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
    public List<VerReserva> listarReservasPorDia(String dia_semana) {
        List<VerReserva> lista = new ArrayList<>();
        String SQL = "{call ListarReservasSemanaActual(?)}";

        try (Connection conn = Conexion.getConection();
             PreparedStatement st = conn.prepareStatement(SQL)) {
            st.setString(1, dia_semana);
            try (ResultSet res = st.executeQuery()) {
                while (res.next()) {
                    VerReserva re = new VerReserva();
                    re.setIdReserva(res.getInt("idReserva"));
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
                        re.setDescripcion(res.getString("Descripcion"));
                    } catch (Exception e) {
                        re.setDescripcion("");
                    }
                    try {
                        re.setImporte(res.getDouble("Importe"));
                    } catch (Exception e) {
                        try {
                            re.setImporte(res.getDouble("Costo"));
                        } catch (Exception ex) {
                            re.setImporte(0.0);
                        }
                    }
                    try {
                        re.setDia_semana(res.getString("dia_semana"));
                    } catch (Exception e) {
                        re.setDia_semana("");
                    }
                    lista.add(re);
                }
            }
        } catch (SQLException e) {
            System.out.println("Error al obtener reservas por dia: " + e.getMessage());
        }

        System.out.println("Total de reservas recuperadas: " + lista.size());
        return lista;
    }

    @Override
    public List<VerReserva> listarReservasPorDiaSemana(String dia_semana, int semanaActual) {
        List<VerReserva> lista = new ArrayList<>();
        String SQL = "{call ListarReservasPorDiaSemana(?, ?)}";

        try (Connection conn = Conexion.getConection();
             PreparedStatement st = conn.prepareStatement(SQL)) {
            st.setString(1, dia_semana);
            st.setInt(2, semanaActual);
            System.out.println("dia: " + dia_semana + " semana:" + semanaActual);
            try (ResultSet res = st.executeQuery()) {
                while (res.next()) {
                    VerReserva re = new VerReserva();
                    re.setIdReserva(res.getInt("idReserva"));
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
                        re.setDescripcion(res.getString("Descripcion"));
                    } catch (Exception e) {
                        re.setDescripcion("");
                    }
                    try {
                        re.setImporte(res.getDouble("Importe"));
                    } catch (Exception e) {
                        try {
                            re.setImporte(res.getDouble("Costo"));
                        } catch (Exception ex) {
                            re.setImporte(0.0);
                        }
                    }
                    try {
                        re.setDia_semana(res.getString("dia_semana"));
                    } catch (Exception e) {
                        re.setDia_semana("");
                    }
                    lista.add(re);
                }
            }
        } catch (SQLException e) {
            System.out.println("Error al obtener reservas por dia semana: " + e.getMessage());
        }

        System.out.println("Total de reservas recuperadas: " + lista.size());
        return lista;
    }

    @Override
    public List<Reserva> listarReservasRecientes() {
        List<Reserva> reservas = new ArrayList<>();
        String SQL = "{CALL sp_listarReservasRecientes()}";

        try {
            cx = Conexion.getConection();
            ps = cx.prepareStatement(SQL);
            rs = ps.executeQuery();

            while (rs.next()) {
                Reserva reserva = new Reserva();
                reserva.setIdReserva(rs.getInt("idReserva"));
                reserva.setDiaReserva("" + rs.getDate("DiaReserva").toLocalDate());
                reserva.setHoraReserva("" + rs.getTime("HoraReserva").toLocalTime());
                reserva.setNombrePaciente(rs.getString("NombrePaciente"));
                reserva.setNombreServicio(rs.getString("NombreServicio"));
                reserva.setEstadoNombre(rs.getString("EstadoNombre"));
                reservas.add(reserva);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return reservas;
    }

    @Override
    public List<VerReserva> listarTodasReservasAd() {
        List<VerReserva> lista = new ArrayList<>();
        String SQL = "{call sp_ListarReservasReporteAd}";  // Procedimiento almacenado

        try {
            // Obtener la conexión
            cx = Conexion.getConection();
            // Preparar el statement con el procedimiento almacenado
            ps = cx.prepareStatement(SQL);

            // Ejecutar la consulta
            rs = ps.executeQuery();

            // Recorrer los resultados
            while (rs.next()) {
                VerReserva re = new VerReserva();
                re.setIdReserva(rs.getInt("idReserva"));
                re.setDiaReserva(rs.getString("DiaReserva"));
                re.setHoraReserva(rs.getString("HoraReserva"));
                re.setDescripcion(rs.getString("Descripcion"));
                re.setImporte(rs.getDouble("Importe"));
                re.setNombrePaciente(rs.getString("NombrePaciente"));
                re.setApellidoPaciente(rs.getString("ApellidoPaciente"));
                re.setEstado(rs.getString("EstadoReserva"));
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
    public double obtenerTotalIngresos() {
        double total = 0.0;
        String sql = "SELECT (SELECT SUM(Costo) FROM servicio WHERE idServicio IN (SELECT Servicio_idServicio FROM cita)) + (SELECT SUM(importe) FROM reserva) AS Total";
        try (Connection conn = Conexion.getConection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                total = rs.getDouble("Total");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return total;
    }

    @Override
    public String getEmailPacienteByReservaId(int idReserva) {
        String correo = "";
        String SQL = "SELECT p.Correo FROM reserva r INNER JOIN paciente p ON r.Paciente_idPaciente = p.idPaciente WHERE r.idReserva = ?";
        try (Connection conn = Conexion.getConection(); PreparedStatement ps = conn.prepareStatement(SQL)) {
            ps.setInt(1, idReserva);
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

}
