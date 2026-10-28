/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Interface.java to edit this template
 */
package pe.edu.utp.dao;

import java.util.List;
import pe.edu.utp.entity.Paciente;
import pe.edu.utp.entity.Reserva;
import pe.edu.utp.entity.VerReserva;

/**
 *
 * @author Christhian
 */
public interface ReservaDao {

    int createReserva(Paciente p, Reserva r);
    
    int createReservaPacex(Paciente p, Reserva r);

    int updateReserva(int idCita, String nuevaFecha, String nuevaHora);

    int deleteReserva(int id);

    Reserva readReserva(int id);

    List<VerReserva> listarReservas(int id);
    
    List<VerReserva> listarTodasReservas(int id);
    
    List<VerReserva> listarHistorialReservas(int id);
    
    List<VerReserva> DetalleReserva(int id);
    
    List<VerReserva> listarReservasPorDia(String dia_semana);
    
    List<VerReserva> listarReservasPorDiaSemana(String dia_semana, int semanaActual);
    
    public int updateEstadoCancelado(int idReserva);
    
    public int updateEstadoReserv(int idReserva, String estadoActual);

    public int rechazarReserva(int idReserva);
    
    List<Reserva> listarReservasRecientes();
    
    public int verificarExistencia(int dni);
    
     List<VerReserva> listarTodasReservasAd();
    public double obtenerTotalIngresos();

    public String getEmailPacienteByReservaId(int idReserva);
}
