package pe.edu.utp.entity;

public class Cita {

    private int idCita;
    private String DiaReserva;
    private String HoraReserva;
    private int id_Servicio;
    private int id_Paciente;
    private int id_Estado;
    private int Odontologo_idUsuario;
    private String nombrePaciente;
    private String nombreServicio;
    private String estadoNombre;

    public Cita() {
    }

    public Cita(int idCita, String DiaReserva, String HoraReserva, int id_Servicio, int id_Paciente, int id_Estado, int Odontologo_idUsuario) {
        this.idCita = idCita;
        this.DiaReserva = DiaReserva;
        this.HoraReserva = HoraReserva;
        this.id_Servicio = id_Servicio;
        this.id_Paciente = id_Paciente;
        this.id_Estado = id_Estado;
        this.Odontologo_idUsuario = Odontologo_idUsuario;

    }

    public int getIdCita() {
        return idCita;
    }

    public void setIdCita(int idCita) {
        this.idCita = idCita;
    }

    public String getDiaReserva() {
        return DiaReserva;
    }

    public void setDiaReserva(String DiaReserva) {
        this.DiaReserva = DiaReserva;
    }

    public String getHoraReserva() {
        return HoraReserva;
    }

    public void setHoraReserva(String HoraReserva) {
        this.HoraReserva = HoraReserva;
    }

    public int getId_Servicio() {
        return id_Servicio;
    }

    public void setId_Servicio(int id_Servicio) {
        this.id_Servicio = id_Servicio;
    }

    public int getId_Paciente() {
        return id_Paciente;
    }

    public void setId_Paciente(int id_Paciente) {
        this.id_Paciente = id_Paciente;
    }

    public int getId_Estado() {
        return id_Estado;
    }

    public void setId_Estado(int id_Estado) {
        this.id_Estado = id_Estado;
    }

    public int getOdontologo_idUsuario() {
        return Odontologo_idUsuario;
    }

    public void setOdontologo_idUsuario(int Odontologo_idUsuario) {
        this.Odontologo_idUsuario = Odontologo_idUsuario;
    }

    public String getNombrePaciente() {
        return nombrePaciente;
    }

    public void setNombrePaciente(String nombrePaciente) {
        this.nombrePaciente = nombrePaciente;
    }

    public String getNombreServicio() {
        return nombreServicio;
    }

    public void setNombreServicio(String nombreServicio) {
        this.nombreServicio = nombreServicio;
    }

    public String getEstadoNombre() {
        return estadoNombre;
    }

    public void setEstadoNombre(String estadoNombre) {
        this.estadoNombre = estadoNombre;
    }

}
