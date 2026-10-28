package pe.edu.utp.daoImpl;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import pe.edu.utp.config.Conexion;
import pe.edu.utp.dao.PacienteDao;
import pe.edu.utp.entity.Paciente;

public class PacienteDaoImpl implements PacienteDao {

    @Override
    public Paciente obtenerPacientePorDNI(String dni) {
        Paciente paciente = null;
        String SQL = "SELECT * FROM paciente WHERE DNI = ?";
        try (Connection cx = Conexion.getConection();
             PreparedStatement ps = cx.prepareStatement(SQL)) {
            ps.setString(1, dni);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    paciente = new Paciente();
                    paciente.setIdPaciente(rs.getInt("idPaciente"));
                    paciente.setNombre(rs.getString("Nombre"));
                    paciente.setApellido(rs.getString("Apellido"));
                    paciente.setDni(rs.getInt("DNI"));
                    paciente.setTelefono(rs.getInt("Telefono"));
                    paciente.setCorreo(rs.getString("Correo"));
                }
            }
        } catch (SQLException e) {
            System.out.println("Error al obtener el paciente por DNI: " + e.getMessage());
        }
        return paciente;
    }

    @Override
    public Paciente obtenerPacientePorId(int id) {
        Paciente paciente = null;
        String SQL = "SELECT * FROM paciente WHERE idPaciente = ?";
        try (Connection cx = Conexion.getConection();
             PreparedStatement ps = cx.prepareStatement(SQL)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    paciente = new Paciente();
                    paciente.setIdPaciente(rs.getInt("idPaciente"));
                    paciente.setNombre(rs.getString("Nombre"));
                    paciente.setApellido(rs.getString("Apellido"));
                    paciente.setDni(rs.getInt("DNI"));
                    paciente.setTelefono(rs.getInt("Telefono"));
                    paciente.setCorreo(rs.getString("Correo"));
                }
            }
        } catch (SQLException e) {
            System.out.println("Error al obtener el paciente por ID: " + e.getMessage());
        }
        return paciente;
    }

    @Override
    public List<Paciente> listarPacientes() {
        List<Paciente> lista = new ArrayList<>();
        String SQL = "SELECT * FROM paciente ORDER BY idPaciente DESC";
        try (Connection cx = Conexion.getConection();
             PreparedStatement ps = cx.prepareStatement(SQL);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Paciente p = new Paciente();
                p.setIdPaciente(rs.getInt("idPaciente"));
                p.setNombre(rs.getString("Nombre"));
                p.setApellido(rs.getString("Apellido"));
                p.setDni(rs.getInt("DNI"));
                p.setTelefono(rs.getInt("Telefono"));
                p.setCorreo(rs.getString("Correo"));
                lista.add(p);
            }
        } catch (SQLException e) {
            System.out.println("Error al listar pacientes: " + e.getMessage());
        }
        return lista;
    }

    @Override
    public List<Paciente> buscarPacientes(String criterio) {
        List<Paciente> lista = new ArrayList<>();
        String SQL = "SELECT * FROM paciente WHERE DNI LIKE ? OR Nombre LIKE ? OR Apellido LIKE ? ORDER BY idPaciente DESC";
        try (Connection cx = Conexion.getConection();
             PreparedStatement ps = cx.prepareStatement(SQL)) {
            String patron = "%" + criterio + "%";
            ps.setString(1, patron);
            ps.setString(2, patron);
            ps.setString(3, patron);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Paciente p = new Paciente();
                    p.setIdPaciente(rs.getInt("idPaciente"));
                    p.setNombre(rs.getString("Nombre"));
                    p.setApellido(rs.getString("Apellido"));
                    p.setDni(rs.getInt("DNI"));
                    p.setTelefono(rs.getInt("Telefono"));
                    p.setCorreo(rs.getString("Correo"));
                    lista.add(p);
                }
            }
        } catch (SQLException e) {
            System.out.println("Error al buscar pacientes: " + e.getMessage());
        }
        return lista;
    }

    @Override
    public boolean registrarPaciente(Paciente p) {
        String SQL = "INSERT INTO paciente (Nombre, Apellido, DNI, Telefono, Correo) VALUES (?, ?, ?, ?, ?)";
        try (Connection cx = Conexion.getConection();
             PreparedStatement ps = cx.prepareStatement(SQL)) {
            ps.setString(1, p.getNombre());
            ps.setString(2, p.getApellido());
            ps.setInt(3, p.getDni());
            ps.setInt(4, p.getTelefono());
            ps.setString(5, p.getCorreo());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.out.println("Error al registrar paciente: " + e.getMessage());
            return false;
        }
    }

    @Override
    public boolean actualizarPaciente(Paciente p) {
        String SQL = "UPDATE paciente SET Nombre = ?, Apellido = ?, Telefono = ?, Correo = ? WHERE idPaciente = ?";
        try (Connection cx = Conexion.getConection();
             PreparedStatement ps = cx.prepareStatement(SQL)) {
            ps.setString(1, p.getNombre());
            ps.setString(2, p.getApellido());
            ps.setInt(3, p.getTelefono());
            ps.setString(4, p.getCorreo());
            ps.setInt(5, p.getIdPaciente());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.out.println("Error al actualizar paciente: " + e.getMessage());
            return false;
        }
    }
}
