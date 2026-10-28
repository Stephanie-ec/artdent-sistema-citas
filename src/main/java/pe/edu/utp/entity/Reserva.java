package pe.edu.utp.entity;

public class Reserva {

    private int idReserva;
    private String DiaReserva;
    private String HoraReserva;
    private String Descripcion;
    private double Importe;
    //private String FechaHoraPago;
    private int Usuario_idUsuario;
    //private int Paciente_idPaciente;
    private int Estado_idEstado;
    private int Servicio_idServicio;
    private int Odontologo_idUsuario;
    private String nombrePaciente;
    private String nombreServicio;
    private String estadoNombre;
    
    public Reserva() {
    }

    public Reserva(int idReserva, String DiaReserva, String HoraReserva, String Descripcion, double Importe, int Usuario_idUsuario, int Estado_idEstado, int Servicio_idServicio, int Odontologo_idUsuario) {
        this.idReserva = idReserva;
        this.DiaReserva = DiaReserva;
        this.HoraReserva = HoraReserva;
        this.Descripcion = Descripcion;
        this.Importe = Importe;
        this.Usuario_idUsuario = Usuario_idUsuario;
        this.Estado_idEstado = Estado_idEstado;
        this.Servicio_idServicio = Servicio_idServicio;
        this.Odontologo_idUsuario = Odontologo_idUsuario;
    }

    public int getIdReserva() {
        return idReserva;
    }

    public void setIdReserva(int idReserva) {
        this.idReserva = idReserva;
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

    public String getDescripcion() {
        return Descripcion;
    }

    public void setDescripcion(String Descripcion) {
        this.Descripcion = Descripcion;
    }

    public double getImporte() {
        return Importe;
    }

    public void setImporte(double Importe) {
        this.Importe = Importe;
    }

    public int getUsuario_idUsuario() {
        return Usuario_idUsuario;
    }

    public void setUsuario_idUsuario(int Usuario_idUsuario) {
        this.Usuario_idUsuario = Usuario_idUsuario;
    }

    public int getEstado_idEstado() {
        return Estado_idEstado;
    }

    public void setEstado_idEstado(int Estado_idEstado) {
        this.Estado_idEstado = Estado_idEstado;
    }

    public int getServicio_idServicio() {
        return Servicio_idServicio;
    }

    public void setServicio_idServicio(int Servicio_idServicio) {
        this.Servicio_idServicio = Servicio_idServicio;
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
