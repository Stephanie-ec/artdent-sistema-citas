package pe.edu.utp.entity;

public class Comprobante {
    private int idComprobante;
    private String serie;
    private String numero;
    private String fechaEmision;
    private String nombreCliente;
    private String dniCliente;
    private int pago_idPago;
    
    // Propiedades adicionales de presentación
    private double monto;
    private String tipoServicio;
    private String metodoPago;
    private int idCita;

    public Comprobante() {
    }

    public Comprobante(int idComprobante, String serie, String numero, String fechaEmision, String nombreCliente, String dniCliente, int pago_idPago) {
        this.idComprobante = idComprobante;
        this.serie = serie;
        this.numero = numero;
        this.fechaEmision = fechaEmision;
        this.nombreCliente = nombreCliente;
        this.dniCliente = dniCliente;
        this.pago_idPago = pago_idPago;
    }

    public int getIdComprobante() {
        return idComprobante;
    }

    public void setIdComprobante(int idComprobante) {
        this.idComprobante = idComprobante;
    }

    public String getSerie() {
        return serie;
    }

    public void setSerie(String serie) {
        this.serie = serie;
    }

    public String getNumero() {
        return numero;
    }

    public void setNumero(String numero) {
        this.numero = numero;
    }

    public String getFechaEmision() {
        return fechaEmision;
    }

    public void setFechaEmision(String fechaEmision) {
        this.fechaEmision = fechaEmision;
    }

    public String getNombreCliente() {
        return nombreCliente;
    }

    public void setNombreCliente(String nombreCliente) {
        this.nombreCliente = nombreCliente;
    }

    public String getDniCliente() {
        return dniCliente;
    }

    public void setDniCliente(String dniCliente) {
        this.dniCliente = dniCliente;
    }

    public int getPago_idPago() {
        return pago_idPago;
    }

    public void setPago_idPago(int pago_idPago) {
        this.pago_idPago = pago_idPago;
    }

    public double getMonto() {
        return monto;
    }

    public void setMonto(double monto) {
        this.monto = monto;
    }

    public String getTipoServicio() {
        return tipoServicio;
    }

    public void setTipoServicio(String tipoServicio) {
        this.tipoServicio = tipoServicio;
    }

    public String getMetodoPago() {
        return metodoPago;
    }

    public void setMetodoPago(String metodoPago) {
        this.metodoPago = metodoPago;
    }

    public int getIdCita() {
        return idCita;
    }

    public void setIdCita(int idCita) {
        this.idCita = idCita;
    }

    public String getCodigoBoletaCompleto() {
        return (serie != null ? serie : "B001") + "-" + (numero != null ? numero : "00000000");
    }
}
