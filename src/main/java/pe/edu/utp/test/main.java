/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Main.java to edit this template
 */
package pe.edu.utp.test;

import java.util.List;
import pe.edu.utp.dao.ServicioDao;
import pe.edu.utp.daoImpl.ServicioDaoImpl;
import pe.edu.utp.entity.Servicio;

/**
 *
 * @author Christhian
 */
public class main {

    public static ServicioDao servicioDao = new ServicioDaoImpl();

    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) {
        /*List<Servicio> listaServicios = servicioDao.readAll();
        System.out.println("pruebaaa");
        for (Servicio servicio : listaServicios) {
            System.out.println("ID: " + servicio.getIdServicio() + ", Tipo: " + servicio.getTipoServicio() + ", Costo: " + servicio.getCosto());
        }*/
    }
}
