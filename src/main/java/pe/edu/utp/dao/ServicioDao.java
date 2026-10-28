/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Interface.java to edit this template
 */
package pe.edu.utp.dao;

import java.util.List;
import pe.edu.utp.entity.Servicio;

/**
 *
 * @author Christhian
 */
public interface ServicioDao {

    Servicio ListService(int id);

    List<Servicio> readAll();

    List<Servicio> listarServicios();

    Servicio obtenerServicioPorId(int id);

    boolean insertarServicio(Servicio servicio);

    boolean actualizarServicio(Servicio servicio);

    boolean eliminarServicio(int id);

    boolean reactivarServicio(int id);

    List<Servicio> listarTodosLosServicios();
}
