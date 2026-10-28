/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package pe.edu.utp.daoImpl;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import pe.edu.utp.config.Conexion;
import pe.edu.utp.dao.ServicioDao;
import pe.edu.utp.entity.Servicio;

/**
 *
 * @author Christhian
 */
public class ServicioDaoImpl implements ServicioDao {

    private PreparedStatement ps;
    private ResultSet rs;
    private Connection cx;
    Servicio ser = new Servicio();

    @Override
    public List<Servicio> readAll() {
        List<Servicio> lista = new ArrayList<>();
        String SQL = "{call sp_listarservicios()}";
        try {
            cx = Conexion.getConection();
            ps = cx.prepareStatement(SQL);
            rs = ps.executeQuery();
            while (rs.next()) {
                Servicio servicio = new Servicio();
                servicio.setIdServicio(rs.getInt("idServicio"));
                servicio.setTipoServicio(rs.getString("TipoServicio"));
                servicio.setLema(rs.getString("Lema"));
                servicio.setDescripcion(rs.getString("Descripcion"));
                servicio.setRespuesta(rs.getString("Respuesta"));
                servicio.setCosto(rs.getBigDecimal("Costo"));// dsct
                servicio.setLinkimagen(obtenerImagenValida(servicio.getTipoServicio(), rs.getString("img")));
                lista.add(servicio);
            }
        } catch (SQLException e) {
            System.out.println("Error al obtener servicios: " + e);
        }
        System.out.println("Total de servicios recuperados: " + lista.size());
        return lista;
    }

    @Override
    public Servicio ListService(int id) {
        Servicio ser = new Servicio(); // Aquí se crea una nueva instancia de Servicio para cada llamada
        String SQL = "SELECT * FROM servicio WHERE IdServicio = ?";
        try {
            cx = Conexion.getConection();
            ps = cx.prepareStatement(SQL);
            ps.setInt(1, id); // Usar parámetros preparados para evitar SQL Injection
            rs = ps.executeQuery();
            if (rs.next()) {
                ser.setIdServicio(rs.getInt("idServicio"));
                ser.setTipoServicio(rs.getString("TipoServicio"));
                ser.setLema(rs.getString("Lema"));
                ser.setDescripcion(rs.getString("Descripcion"));
                ser.setRespuesta(rs.getString("Respuesta"));
                ser.setLinkimagen(obtenerImagenValida(ser.getTipoServicio(), rs.getString("img")));
            }
        } catch (SQLException e) {
            System.out.println("Error al obtener servicio: " + e);
        }
        return ser; // Retorna el objeto Servicio encontrado
    }

    @Override
    public List<Servicio> listarServicios() {
        List<Servicio> servicios = new ArrayList<>();
        String SQL = "SELECT idServicio, TipoServicio, Costo, img FROM servicio WHERE Activo = 1";

        try {
            cx = Conexion.getConection();
            ps = cx.prepareStatement(SQL);
            rs = ps.executeQuery();
            while (rs.next()) {
                Servicio servicio = new Servicio();
                servicio.setIdServicio(rs.getInt("idServicio"));
                servicio.setTipoServicio(rs.getString("TipoServicio"));
                servicio.setCosto(rs.getBigDecimal("Costo"));
                servicio.setLinkimagen(obtenerImagenValida(servicio.getTipoServicio(), rs.getString("img")));
                servicio.setActivo(true);
                servicios.add(servicio);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return servicios;
    }

    @Override
    public List<Servicio> listarTodosLosServicios() {
        List<Servicio> servicios = new ArrayList<>();
        String SQL = "SELECT idServicio, TipoServicio, Lema, Descripcion, Respuesta, Costo, img, Activo FROM servicio ORDER BY idServicio ASC";

        try {
            cx = Conexion.getConection();
            ps = cx.prepareStatement(SQL);
            rs = ps.executeQuery();
            while (rs.next()) {
                Servicio servicio = new Servicio();
                servicio.setIdServicio(rs.getInt("idServicio"));
                servicio.setTipoServicio(rs.getString("TipoServicio"));
                servicio.setLema(rs.getString("Lema"));
                servicio.setDescripcion(rs.getString("Descripcion"));
                servicio.setRespuesta(rs.getString("Respuesta"));
                servicio.setCosto(rs.getBigDecimal("Costo"));
                servicio.setLinkimagen(obtenerImagenValida(servicio.getTipoServicio(), rs.getString("img")));
                servicio.setActivo(rs.getInt("Activo") == 1);
                servicios.add(servicio);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return servicios;
    }

    @Override
    public Servicio obtenerServicioPorId(int id) {
        Servicio servicio = null;
        String SQL = "{call sp_obtenerServicioPorId(?)}";

        try {
            cx = Conexion.getConection();
            ps = cx.prepareStatement(SQL);
            ps.setInt(1, id);
            rs = ps.executeQuery();
            if (rs.next()) {
                servicio = new Servicio();
                servicio.setIdServicio(rs.getInt("idServicio"));
                servicio.setTipoServicio(rs.getString("TipoServicio"));
                servicio.setLema(rs.getString("Lema"));
                servicio.setDescripcion(rs.getString("Descripcion"));
                servicio.setRespuesta(rs.getString("Respuesta"));
                servicio.setCosto(rs.getBigDecimal("Costo"));
                servicio.setLinkimagen(obtenerImagenValida(servicio.getTipoServicio(), rs.getString("img")));
                try {
                    servicio.setActivo(rs.getInt("Activo") == 1);
                } catch (Exception ex) {
                    servicio.setActivo(true);
                }
            }
        } catch (SQLException e) {
            System.out.println("Error al obtener usuario por ID: " + e);
        }
        return servicio;
    }

    @Override
    public boolean insertarServicio(Servicio servicio) {
        String SQL = "{call sp_insertarServicio(?,?,?,?,?,?)}";
        try {
            cx = Conexion.getConection();
            ps = cx.prepareStatement(SQL);
            ps.setString(1, servicio.getTipoServicio());
            ps.setString(2, servicio.getLema());
            ps.setString(3, servicio.getDescripcion());
            ps.setString(4, servicio.getRespuesta());
            ps.setBigDecimal(5, servicio.getCosto());
            ps.setString(6, servicio.getLinkimagen());

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public boolean actualizarServicio(Servicio servicio) {
        String SQL = "{call sp_actualizarServicio(?,?,?,?,?,?,?)}";
        try {
            cx = Conexion.getConection();
            ps = cx.prepareStatement(SQL);
            ps.setInt(1, servicio.getIdServicio());
            ps.setString(2, servicio.getTipoServicio());
            ps.setString(3, servicio.getLema());
            ps.setString(4, servicio.getDescripcion());
            ps.setString(5, servicio.getRespuesta());
            ps.setBigDecimal(6, servicio.getCosto());
            ps.setString(7, servicio.getLinkimagen());

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public boolean eliminarServicio(int id) {
        String SQL = "{call sp_eliminarServicio(?)}";
        boolean resultado = false;
        try {
            cx = Conexion.getConection();
            ps = cx.prepareStatement(SQL);
            ps.setInt(1, id);
            resultado = ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.out.println("Error al eliminar servicio: " + e);
        }
        return resultado;
    }

    @Override
    public boolean reactivarServicio(int id) {
        String SQL = "UPDATE servicio SET Activo = 1 WHERE idServicio = ?";
        boolean resultado = false;
        try {
            cx = Conexion.getConection();
            ps = cx.prepareStatement(SQL);
            ps.setInt(1, id);
            resultado = ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.out.println("Error al reactivar servicio: " + e);
        }
        return resultado;
    }

    private String obtenerImagenValida(String tipo, String imgActual) {
        String t = tipo != null ? tipo.toLowerCase().trim() : "";

        if (t.contains("blanqueamiento")) {
            return "https://img.freepik.com/foto-gratis/primer-plano-mujer-dientes-blancos-perfectos_186202-4573.jpg";
        } else if (t.contains("caries")) {
            return "https://img.freepik.com/foto-gratis/dentista-examinando-dientes-paciente-femenino-espejo-bucal_23-2149176709.jpg";
        } else if (t.contains("endodoncia")) {
            return "https://img.freepik.com/foto-gratis/dentista-tratando-paciente-clinica_23-2149176729.jpg";
        } else if (t.contains("prótesis") || t.contains("protesis")) {
            return "https://img.freepik.com/foto-gratis/dentista-sosteniendo-protesis-dental_23-2149176719.jpg";
        } else if (t.contains("cirug")) {
            return "https://img.freepik.com/foto-gratis/medico-examinando-dientes-paciente-femenino-usando-herramientas-dentales_23-2149176721.jpg";
        } else if (t.contains("ortodoncia")) {
            return "https://img.freepik.com/foto-gratis/paciente-femenina-que-muestra-sus-nuevos-frenillos-dental-clinica_23-2149301072.jpg";
        } else if (t.contains("2.0")) {
            return "https://img.freepik.com/foto-gratis/dentista-realizando-higiene-bucal-paciente_23-2149176715.jpg";
        } else if (t.contains("limpieza")) {
            return "https://img.freepik.com/foto-gratis/primer-plano-dentista-limpiando-dientes-paciente_23-2149176713.jpg";
        }

        if (imgActual != null && !imgActual.trim().isEmpty() && imgActual.startsWith("http")
                && !imgActual.contains("aenor.com") && !imgActual.contains("placeholder")
                && !imgActual.contains("photo-1629909613654")) {
            return imgActual;
        }

        return "https://img.freepik.com/foto-gratis/primer-plano-dentista-limpiando-dientes-paciente_23-2149176713.jpg";
    }
}
