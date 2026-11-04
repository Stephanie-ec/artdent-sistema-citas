package pe.edu.utp.dao;

import java.util.List;
import pe.edu.utp.entity.Cita;
import pe.edu.utp.entity.Paciente;
import pe.edu.utp.entity.ReporteEstado;
import pe.edu.utp.entity.Venta;
import pe.edu.utp.entity.VerCita;

/**
 *
 * @author Andrea
 */
public interface CitaDao {

    int createCitasilapersonaesnueva(Paciente p, Cita c, Venta v);

    int verificarExistencia(int Dni);

    /** Nombre y apellido registrados para el DNI ({nombre, apellido}) o null si no existe. */
    String[] obtenerNombrePaciente(int dni);

    /** Actualiza teléfono y correo del paciente (datos de contacto más recientes). */
    void actualizarContactoPaciente(int idPaciente, int telefono, String correo);

    int updateCita(int idCita, String nuevaFecha, String nuevaHora);

    Cita readCita(int id);

    List<VerCita> listarCitas(int id);

    List<VerCita> listarTodasCitas(int id);
    
    List<VerCita> listarTodasCitasAd();

    List<VerCita> listarHistorialCitas(int id);

    List<VerCita> DetalleCita(int id);

    List<VerCita> listarCitasPorDia(String dia_semana);
    
    List<VerCita> listarCitasPorDiaSemana(String dia_semana, int semanaActual);

    public int updateEstadoCitaCancelado(int idCita);
    
    public int updateEstadoCita(int idCita, String estadoActual);
    
    public int DeleteCita(int idCita);
    
    public int createCitasilapersonayaexiste(Paciente p, Cita c, Venta v);

    List<Cita> listarCitasRecientes();

    public int obtenerTotalCitasReservas();

    public int contarPacientes();

    /** Ids de las citas y reservas asignadas a un odontólogo (Cita.Odontologo_idUsuario). */
    public java.util.Set<Integer> idsCitasDeOdontologo(int idOdontologo);

    public int contarEnEspera();

    public String getEmailPacienteByCitaId(int idCita);

    public int createReservaWeb(Paciente p, Cita c, double importe, String descripcion);

    public int createCitaPresencial(Paciente p, Cita c, double importe, String descripcion, int idSecretaria);

    public int registrarNotificacion(String asunto, int idEstado, int idCita, boolean enviado);
}
