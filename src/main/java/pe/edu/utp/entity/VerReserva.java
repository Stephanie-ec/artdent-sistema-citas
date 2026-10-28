package pe.edu.utp.entity;


public class VerReserva {
    
    private int idReserva;
    private String DiaReserva;
    private String HoraReserva;
    private String Descripcion;
    private double Importe;
    private String NombreUsuario;
    private String ApellidoUsuario;
    private String NombrePaciente;
    private String ApellidoPaciente;
    private String Estado;
    private String TipoServicio;
    private String dia_semana;
    private int orden_row;
    private String color;
    private boolean tienePago;
    private String codigoBoleta;
    private int idPago;
    
    public VerReserva() {
    }

    public VerReserva(int idReserva, String DiaReserva, String HoraReserva, String Descripcion, double Importe, String NombreUsuario, String ApellidoUsuario, String NombrePaciente, String ApellidoPaciente, String Estado, String TipoServicio, String dia_semana, int orden_row, String color) {
        this.idReserva = idReserva;
        this.DiaReserva = DiaReserva;
        this.HoraReserva = HoraReserva;
        this.Descripcion = Descripcion;
        this.Importe = Importe;
        this.NombreUsuario = NombreUsuario;
        this.ApellidoUsuario = ApellidoUsuario;
        this.NombrePaciente = NombrePaciente;
        this.ApellidoPaciente = ApellidoPaciente;
        this.Estado = Estado;
        this.TipoServicio = TipoServicio;
        this.dia_semana = dia_semana;
        this.orden_row = orden_row;
        this.color = color;
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

    public String getTipoServicio() {
        return TipoServicio;
    }

    public void setTipoServicio(String TipoServicio) {
        this.TipoServicio = TipoServicio;
    }

    public String getDia_semana() {
        return dia_semana;
    }

    public void setDia_semana(String dia_semana) {
        this.dia_semana = dia_semana;
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
