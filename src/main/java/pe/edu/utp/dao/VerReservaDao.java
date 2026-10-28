/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Interface.java to edit this template
 */
package pe.edu.utp.dao;

import java.util.List;
import pe.edu.utp.entity.VerReserva;


public interface VerReservaDao {
    List<VerReserva> listarReservas(int id);
}
