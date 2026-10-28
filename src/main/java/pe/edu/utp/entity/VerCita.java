package pe.edu.utp.entity;

public class VerCita {
    private int idCita;
    private String DiaReserva;
    private String HoraReserva;
    private String TipoServicio;
    private String NombrePaciente;
    private String ApellidoPaciente;
    private String Estado;
    private String NombreUsuario;
    private String ApellidoUsuario;
    private double costo;
    private int orden_row;
    private String color;
    private boolean tienePago;
    private String codigoBoleta;
    private int idPago;
    public VerCita() {
    }

    public VerCita(int idCita, String DiaReserva, String HoraReserva, String TipoServicio, String NombrePaciente, String ApellidoPaciente, String Estado, String NombreUsuario, String ApellidoUsuario, double costo,int orden_row, String color) {
        this.idCita = idCita;
        this.DiaReserva = DiaReserva;
        this.HoraReserva = HoraReserva;
        this.TipoServicio = TipoServicio;
        this.NombrePaciente = NombrePaciente;
        this.ApellidoPaciente = ApellidoPaciente;
        this.Estado = Estado;
        this.costo = costo;
        this.NombreUsuario = NombreUsuario;
        this.ApellidoUsuario = ApellidoUsuario;
        this.orden_row = orden_row;
        this.color = color;
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

    public String getTipoServicio() {
        return TipoServicio;
    }

    public void setTipoServicio(String TipoServicio) {
        this.TipoServicio = TipoServicio;
    }

    public String getNombrePaciente() {
        return NombrePaciente;
    }

    public void setNombrePaciente(String NombrePaciente) {
        this.NombrePaciente = NombrePaciente;
    }

    public String getApellidoPaciente() {
        return ApellidoPaciente;
    }

    public void setApellidoPaciente(String ApellidoPaciente) {
        this.ApellidoPaciente = ApellidoPaciente;
    }

    public String getEstado() {
        return Estado;
    }

    public void setEstado(String Estado) {
        this.Estado = Estado;
    }
    
    public String getNombreUsuario() {
        return NombreUsuario;
    }

    public void setNombreUsuario(String NombreUsuario) {
        this.NombreUsuario = NombreUsuario;
    }

    public String getApellidoUsuario() {
        return ApellidoUsuario;
    }

    public void setApellidoUsuario(String ApellidoUsuario) {
        this.ApellidoUsuario = ApellidoUsuario;
    }

    public int getOrden_row() {
        return orden_row;
    }

    public void setOrden_row(int orden_row) {
        this.orden_row = orden_row;
    }

    public String getColor() {
        return color;
    }

    public void setColor(String color) {
        this.color = color;
    }

    public double getCosto() {
        return costo;
    }

    public void setCosto(double costo) {
        this.costo = costo;
    }

    public boolean isTienePago() {
        return tienePago;
    }

    public void setTienePago(boolean tienePago) {
        this.tienePago = tienePago;
    }

    public String getCodigoBoleta() {
        return codigoBoleta;
    }

    public void setCodigoBoleta(String codigoBoleta) {
        this.codigoBoleta = codigoBoleta;
    }

    public int getIdPago() {
        return idPago;
    }

    public void setIdPago(int idPago) {
        this.idPago = idPago;
    }
}
