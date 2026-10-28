/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package pe.edu.utp.daoImpl;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;
import pe.edu.utp.config.Conexion;
import pe.edu.utp.dao.UsuarioDao;
import pe.edu.utp.dto.InicioSesionDTO;
import pe.edu.utp.dto.LoginResultDTO;
import pe.edu.utp.entity.Usuario;
import pe.edu.utp.utils.SecurityUtils;

/**
 *
 * @author Christhian
 */
public class UsuarioDaoImpl implements UsuarioDao {

    @Override
    public List<InicioSesionDTO> login(String dni, String password) {
        List<InicioSesionDTO> lista = new ArrayList<>();
        LoginResultDTO res = autenticar(dni, password);
        if (res != null && res.isExito() && res.getUsuario() != null) {
            lista.add(res.getUsuario());
        }
        return lista;
    }

    @Override
    public LoginResultDTO autenticar(String dni, String password) {
        LoginResultDTO resultado = new LoginResultDTO();
        resultado.setExito(false);

        if (dni == null || dni.trim().isEmpty() || password == null) {
            resultado.setMensaje("Debe ingresar su número de documento y contraseña.");
            return resultado;
        }

        String sql = "SELECT u.idUsuario, u.Nombre, u.Apellido, u.DNI, u.Clave, "
                   + "       u.IntentosFallidos, u.BloqueadoHasta, r.TipoRol, "
                   + "       TIMESTAMPDIFF(MINUTE, NOW(), u.BloqueadoHasta) AS minutosRestantes "
                   + "FROM Usuario u "
                   + "INNER JOIN Rol r ON u.Rol_idRol = r.idRol "
                   + "WHERE u.DNI = ?";

        try (Connection conn = Conexion.getConection()) {
            if (conn == null) {
                resultado.setMensaje("Error al conectar con la base de datos.");
                return resultado;
            }

            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setString(1, dni.trim());
                try (ResultSet res = stmt.executeQuery()) {
                    if (!res.next()) {
                        resultado.setMensaje("Usuario o contraseña incorrectos.");
                        resultado.setIntentosRestantes(5);
                        return resultado;
                    }

                    int idUsuario = res.getInt("idUsuario");
                    String storedHash = res.getString("Clave");
                    int intentos = res.getInt("IntentosFallidos");
                    java.sql.Timestamp bloqueadoHasta = res.getTimestamp("BloqueadoHasta");
                    int minutosRestantes = res.getInt("minutosRestantes");

                    // 1. Validar si la cuenta se encuentra bloqueada (RNF08)
                    if (bloqueadoHasta != null) {
                        java.sql.Timestamp ahora = new java.sql.Timestamp(System.currentTimeMillis());
                        if (bloqueadoHasta.after(ahora) || minutosRestantes > 0) {
                            resultado.setBloqueado(true);
                            int min = minutosRestantes > 0 ? minutosRestantes : 1;
                            resultado.setMinutosRestantes(min);
                            resultado.setMensaje("Su cuenta se encuentra bloqueada temporalmente por 15 minutos debido a 5 intentos fallidos. Intente nuevamente en " + min + " minuto(s).");
                            return resultado;
                        } else {
                            // Desbloqueo automático al haber transcurrido los 15 minutos
                            resetearBloqueo(conn, idUsuario);
                            intentos = 0;
                        }
                    }

                    // 2. Verificar contraseña con BCrypt y retrocompatibilidad (RNF03)
                    boolean passwordValido = SecurityUtils.verifyPassword(password.trim(), storedHash);

                    if (passwordValido) {
                        // Restablecer intentos fallidos y bloqueo
                        resetearBloqueo(conn, idUsuario);

                        // Si el hash requería actualización a BCrypt, migrarlo transparentemente
                        if (SecurityUtils.needsRehash(storedHash)) {
                            String nuevoHashBCrypt = SecurityUtils.hashPassword(password.trim());
                            actualizarClaveHash(conn, idUsuario, nuevoHashBCrypt);
                            System.out.println("[RNF03] Contraseña del usuario DNI " + dni + " migrada a BCrypt.");
                        }

                        InicioSesionDTO usuarioDTO = new InicioSesionDTO(
                            idUsuario,
                            res.getString("Nombre"),
                            res.getString("Apellido"),
                            res.getInt("DNI"),
                            res.getString("TipoRol")
                        );

                        resultado.setExito(true);
                        resultado.setUsuario(usuarioDTO);
                        resultado.setIntentosRestantes(5);
                        resultado.setMensaje("Inicio de sesión exitoso.");
                        return resultado;
                    } else {
                        // Contraseña incorrecta: Incrementar intentos fallidos
                        int nuevosIntentos = intentos + 1;
                        if (nuevosIntentos >= 5) {
                            bloquearUsuario(conn, idUsuario);
                            resultado.setBloqueado(true);
                            resultado.setMinutosRestantes(15);
                            resultado.setIntentosRestantes(0);
                            resultado.setMensaje("Ha superado los 5 intentos fallidos. Su cuenta ha sido bloqueada temporalmente por 15 minutos.");
                        } else {
                            registrarIntentoFallido(conn, idUsuario, nuevosIntentos);
                            int restantes = 5 - nuevosIntentos;
                            resultado.setIntentosRestantes(restantes);
                            resultado.setMensaje("Usuario o contraseña incorrectos. Le quedan " + restantes + " intento(s) antes del bloqueo de cuenta.");
                        }
                        return resultado;
                    }
                }
            }
        } catch (SQLException e) {
            System.out.println("Error en autenticación segura: " + e.getMessage());
            resultado.setMensaje("Error interno del servidor durante la autenticación.");
        }

        return resultado;
    }

    private void resetearBloqueo(Connection conn, int idUsuario) throws SQLException {
        String sql = "UPDATE Usuario SET IntentosFallidos = 0, BloqueadoHasta = NULL WHERE idUsuario = ?";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, idUsuario);
            stmt.executeUpdate();
        }
    }

    @Override
    public boolean resetearBloqueo(int idUsuario) {
        try (Connection conn = Conexion.getConection()) {
            resetearBloqueo(conn, idUsuario);
            return true;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    private void registrarIntentoFallido(Connection conn, int idUsuario, int intentos) throws SQLException {
        String sql = "UPDATE Usuario SET IntentosFallidos = ? WHERE idUsuario = ?";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, intentos);
            stmt.setInt(2, idUsuario);
            stmt.executeUpdate();
        }
    }

    private void bloquearUsuario(Connection conn, int idUsuario) throws SQLException {
        String sql = "UPDATE Usuario SET IntentosFallidos = 5, BloqueadoHasta = DATE_ADD(NOW(), INTERVAL 15 MINUTE) WHERE idUsuario = ?";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, idUsuario);
            stmt.executeUpdate();
        }
    }

    private void actualizarClaveHash(Connection conn, int idUsuario, String nuevoHash) {
        String updateSQL = "UPDATE Usuario SET Clave = ? WHERE idUsuario = ?";
        try (PreparedStatement stmt = conn.prepareStatement(updateSQL)) {
            stmt.setString(1, nuevoHash);
            stmt.setInt(2, idUsuario);
            stmt.executeUpdate();
            System.out.println("Contraseña migrada automáticamente a BCrypt para el usuario ID: " + idUsuario);
        } catch (SQLException e) {
            System.out.println("Error al intentar migrar la contraseña: " + e.getMessage());
        }
    }

    @Override
    public List<Usuario> obtenerMedicosDisponibles() {
        List<Usuario> medicos = new ArrayList<>();
        String sql = "SELECT * FROM usuario WHERE Rol_idRol = 3";

        try (Connection conn = Conexion.getConection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet res = stmt.executeQuery()) {
            while (res.next()) {
                Usuario medico = new Usuario();
                medico.setIdUsuario(res.getInt("idUsuario"));
                medico.setApellido(res.getString("Apellido"));
                medico.setNombre(res.getString("Nombre"));
                medicos.add(medico);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return medicos;
    }

    @Override
    public List<Usuario> obtenerMedicosPorServicioYDisponibilidad(int idServicio, LocalDate fechaConv, LocalTime horaObj) {
        List<Usuario> medicos = new ArrayList<>();

        // Rango de tiempo de la nueva cita (inicio y fin)
        LocalTime horaFin = horaObj.plusMinutes(45); // Hora de fin de la nueva cita

        // Convertir la fecha a texto para obtener el día de la semana
        String diaSemanaTexto = convertirDiaSemana(fechaConv);

        String sql = "SELECT DISTINCT u.idUsuario, u.Nombre, u.Apellido "
                + "FROM usuario u "
                + "INNER JOIN Usuario_Servicio us ON u.idUsuario = us.idUsuario "
                + "INNER JOIN Usuario_Horario uh ON u.idUsuario = uh.Usuario_idUsuario "
                + "INNER JOIN Horario h ON uh.Horario_idHorario = h.idHorario "
                + "LEFT JOIN Cita c ON u.idUsuario = c.Odontologo_idUsuario "
                + "    AND c.FechaCita = ? "
                + "    AND c.Estado_idEstado NOT IN (5, 6) "
                + "    AND ((c.HoraCita BETWEEN ? AND ?) OR (? BETWEEN c.HoraCita AND ADDTIME(c.HoraCita, '00:45:00'))) "
                + "WHERE us.idServicio = ? "
                + "AND us.Disponibilidad = 1 "
                + "AND LOWER(h.diaSemana) = ? "
                + "AND c.idCita IS NULL";

        try (Connection cx = Conexion.getConection(); PreparedStatement ps = cx.prepareStatement(sql)) {
            // Asignación de parámetros
            ps.setDate(1, java.sql.Date.valueOf(fechaConv));
            ps.setTime(2, java.sql.Time.valueOf(horaObj));
            ps.setTime(3, java.sql.Time.valueOf(horaFin));
            ps.setTime(4, java.sql.Time.valueOf(horaObj));
            ps.setInt(5, idServicio);
            ps.setString(6, diaSemanaTexto);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Usuario medico = new Usuario();
                    medico.setIdUsuario(rs.getInt("idUsuario"));
                    medico.setNombre(rs.getString("Nombre"));
                    medico.setApellido(rs.getString("Apellido"));
                    medicos.add(medico);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return medicos;
    }

    private String convertirDiaSemana(LocalDate fecha) {
        // Convierte el día al nombre en español, por ejemplo, "lunes", "martes", etc.
        switch (fecha.getDayOfWeek()) {
            case MONDAY:
                return "lunes";
            case TUESDAY:
                return "martes";
            case WEDNESDAY:
                return "miércoles";
            case THURSDAY:
                return "jueves";
            case FRIDAY:
                return "viernes";
            case SATURDAY:
                return "sábado";
            case SUNDAY:
                return "domingo";
            default:
                throw new IllegalArgumentException("Día inválido");
        }
    }

    @Override
    public List<Usuario> listarUsuarios() {
        List<Usuario> lista = new ArrayList<>();
        String SQL = "{call sp_listarUsuarios()}";

        try (Connection conn = Conexion.getConection();
             PreparedStatement stmt = conn.prepareStatement(SQL);
             ResultSet res = stmt.executeQuery()) {

            while (res.next()) {
                Usuario usuario = new Usuario();
                usuario.setIdUsuario(res.getInt("idUsuario"));
                usuario.setNombre(res.getString("Nombre"));
                usuario.setApellido(res.getString("Apellido"));
                usuario.setDni(res.getInt("DNI"));
                usuario.setTelefono(res.getString("Telefono"));
                usuario.setCorreoElectronico(res.getString("CorreoElectronico"));
                usuario.setRol(res.getString("RolN"));
                lista.add(usuario);
            }

        } catch (SQLException e) {
            System.out.println("Error al listar usuarios: " + e);
        }
        return lista;
    }

    @Override
    public boolean registrarUsuario(Usuario usuario) {
        String SQL = "{call sp_insertarUsuario(?,?,?,?,?,?,?,?,?)}";
        boolean resultado = false;

        try (Connection conn = Conexion.getConection();
             PreparedStatement stmt = conn.prepareStatement(SQL)) {
            stmt.setString(1, usuario.getNombre());
            stmt.setString(2, usuario.getApellido());
            stmt.setInt(3, usuario.getDni());
            stmt.setString(4, usuario.getTelefono());
            stmt.setString(5, usuario.getCorreoElectronico());
            stmt.setString(6, usuario.getDireccion());
            stmt.setDate(7, Date.valueOf(usuario.getFechaNacimiento()));
            stmt.setString(8, SecurityUtils.hashPassword(usuario.getClave()));
            stmt.setInt(9, usuario.getRol_idRol());

            resultado = stmt.executeUpdate() > 0;

        } catch (SQLException e) {
            System.out.println("Error al registrar usuario: " + e);
        }

        return resultado;
    }

    @Override
    public Usuario obtenerUsuarioPorId(int id) {
        String SQL = "{call sp_obtenerUsuarioPorId(?)}";
        Usuario usuario = null;

        try (Connection conn = Conexion.getConection();
             PreparedStatement stmt = conn.prepareStatement(SQL)) {
            stmt.setInt(1, id);
            try (ResultSet res = stmt.executeQuery()) {
                if (res.next()) {
                    usuario = new Usuario();
                    usuario.setIdUsuario(res.getInt("idUsuario"));
                    usuario.setNombre(res.getString("Nombre"));
                    usuario.setApellido(res.getString("Apellido"));
                    usuario.setDni(res.getInt("Dni"));
                    usuario.setTelefono(res.getString("Telefono"));
                    usuario.setCorreoElectronico(res.getString("CorreoElectronico"));
                    usuario.setDireccion(res.getString("Direccion"));
                    usuario.setFechaNacimiento(res.getString("FechaNacimiento"));
                    usuario.setClave(res.getString("Clave"));
                    usuario.setRol_idRol(res.getInt("Rol_idRol"));
                    usuario.setRol(res.getString("RolN"));
                }
            }

        } catch (SQLException e) {
            System.out.println("Error al obtener usuario por ID: " + e);
        }

        return usuario;
    }

    @Override
    public boolean actualizarUsuario(Usuario usuario) {
        String SQL = "{call sp_actualizarUsuario(?,?,?,?,?,?,?,?,?,?)}";
        boolean resultado = false;

        String claveFinal = "";
        if (usuario.getClave() == null || usuario.getClave().trim().isEmpty()) {
            Usuario anterior = obtenerUsuarioPorId(usuario.getIdUsuario());
            claveFinal = anterior != null ? anterior.getClave() : "";
        } else {
            claveFinal = SecurityUtils.hashPassword(usuario.getClave());
        }

        try (Connection conn = Conexion.getConection();
             PreparedStatement stmt = conn.prepareStatement(SQL)) {
            stmt.setInt(1, usuario.getIdUsuario());
            stmt.setString(2, usuario.getNombre());
            stmt.setString(3, usuario.getApellido());
            stmt.setInt(4, usuario.getDni());
            stmt.setString(5, usuario.getTelefono());
            stmt.setString(6, usuario.getCorreoElectronico());
            stmt.setString(7, usuario.getDireccion());
            stmt.setDate(8, Date.valueOf(usuario.getFechaNacimiento()));
            stmt.setString(9, claveFinal);
            stmt.setInt(10, usuario.getRol_idRol());

            resultado = stmt.executeUpdate() > 0;

        } catch (SQLException e) {
            System.out.println("Error al actualizar usuario: " + e);
        }

        return resultado;
    }

    @Override
    public boolean eliminarUsuario(int id) {
        String SQL = "{call sp_eliminarUsuario(?)}";
        boolean resultado = false;
        try (Connection conn = Conexion.getConection();
             PreparedStatement stmt = conn.prepareStatement(SQL)) {
            stmt.setInt(1, id);
            resultado = stmt.executeUpdate() > 0;

        } catch (SQLException e) {
            System.out.println("Error al eliminar usuario: " + e);
        }

        return resultado;
    }

    @Override
    public List<pe.edu.utp.entity.Horario> listarHorarios() {
        List<pe.edu.utp.entity.Horario> horarios = new ArrayList<>();
        String sql = "SELECT * FROM Horario ORDER BY idHorario ASC";
        try (Connection conn = Conexion.getConection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet res = stmt.executeQuery()) {
            while (res.next()) {
                pe.edu.utp.entity.Horario h = new pe.edu.utp.entity.Horario();
                h.setIdHorario(res.getInt("idHorario"));
                h.setHoraInicio(res.getString("HoraInicio"));
                h.setHoraFinal(res.getString("HoraFinal"));
                h.setDiaSemana(res.getString("DiaSemana"));
                horarios.add(h);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return horarios;
    }

    @Override
    public List<Integer> obtenerHorariosPorUsuario(int idUsuario) {
        List<Integer> ids = new ArrayList<>();
        String sql = "SELECT Horario_idHorario FROM Usuario_Horario WHERE Usuario_idUsuario = ?";
        try (Connection conn = Conexion.getConection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, idUsuario);
            try (ResultSet res = stmt.executeQuery()) {
                while (res.next()) {
                    ids.add(res.getInt("Horario_idHorario"));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return ids;
    }

    @Override
    public List<Integer> obtenerServiciosPorUsuario(int idUsuario) {
        List<Integer> ids = new ArrayList<>();
        String sql = "SELECT idServicio FROM Usuario_Servicio WHERE idUsuario = ? AND Disponibilidad = 1";
        try (Connection conn = Conexion.getConection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, idUsuario);
            try (ResultSet res = stmt.executeQuery()) {
                while (res.next()) {
                    ids.add(res.getInt("idServicio"));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return ids;
    }

    @Override
    public boolean asignarDisponibilidad(int idUsuario, List<Integer> horariosIds, List<Integer> serviciosIds) {
        String delHorarios = "DELETE FROM Usuario_Horario WHERE Usuario_idUsuario = ?";
        String insHorario = "INSERT INTO Usuario_Horario (Usuario_idUsuario, Horario_idHorario) VALUES (?, ?)";
        String delServicios = "DELETE FROM Usuario_Servicio WHERE idUsuario = ?";
        String insServicio = "INSERT INTO Usuario_Servicio (idUsuario, idServicio, Disponibilidad) VALUES (?, ?, 1)";

        try (Connection conn = Conexion.getConection()) {
            conn.setAutoCommit(false);
            try {
                try (PreparedStatement stmtDelH = conn.prepareStatement(delHorarios)) {
                    stmtDelH.setInt(1, idUsuario);
                    stmtDelH.executeUpdate();
                }
                if (horariosIds != null && !horariosIds.isEmpty()) {
                    try (PreparedStatement stmtInsH = conn.prepareStatement(insHorario)) {
                        for (Integer hId : horariosIds) {
                            stmtInsH.setInt(1, idUsuario);
                            stmtInsH.setInt(2, hId);
                            stmtInsH.addBatch();
                        }
                        stmtInsH.executeBatch();
                    }
                }

                try (PreparedStatement stmtDelS = conn.prepareStatement(delServicios)) {
                    stmtDelS.setInt(1, idUsuario);
                    stmtDelS.executeUpdate();
                }
                if (serviciosIds != null && !serviciosIds.isEmpty()) {
                    try (PreparedStatement stmtInsS = conn.prepareStatement(insServicio)) {
                        for (Integer sId : serviciosIds) {
                            stmtInsS.setInt(1, idUsuario);
                            stmtInsS.setInt(2, sId);
                            stmtInsS.addBatch();
                        }
                        stmtInsS.executeBatch();
                    }
                }

                conn.commit();
                return true;
            } catch (SQLException e) {
                conn.rollback();
                e.printStackTrace();
                return false;
            } finally {
                conn.setAutoCommit(true);
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
}
