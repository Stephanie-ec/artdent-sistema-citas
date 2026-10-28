package pe.edu.utp.entity;

public class Pago {
    private int idPago;
    private double monto;
    private String fechaPago;
    private String codigoTransaccion;
    private int metodoPago_idMetodo;
    private String nombreMetodo;
    private int cita_idCita;

    public Pago() {
    }

    public Pago(int idPago, double monto, String fechaPago, String codigoTransaccion, int metodoPago_idMetodo, int cita_idCita) {
        this.idPago = idPago;
        this.monto = monto;
        this.fechaPago = fechaPago;
        this.codigoTransaccion = codigoTransaccion;
        this.metodoPago_idMetodo = metodoPago_idMetodo;
        this.cita_idCita = cita_idCita;
    }

    public int getIdPago() {
        return idPago;
    }

    public void setIdPago(int idPago) {
        this.idPago = idPago;
    }

    public double getMonto() {
        return monto;
    }

    public void setMonto(double monto) {
        this.monto = monto;
    }

    public String getFechaPago() {
        return fechaPago;
    }

    public void setFechaPago(String fechaPago) {
        this.fechaPago = fechaPago;
    }

    public String getCodigoTransaccion() {
        return codigoTransaccion;
    }

    public void setCodigoTransaccion(String codigoTransaccion) {
        this.codigoTransaccion = codigoTransaccion;
    }

    public int getMetodoPago_idMetodo() {
        return metodoPago_idMetodo;
    }

    public void setMetodoPago_idMetodo(int metodoPago_idMetodo) {
        this.metodoPago_idMetodo = metodoPago_idMetodo;
    }

    public String getNombreMetodo() {
        return nombreMetodo;
    }

    public void setNombreMetodo(String nombreMetodo) {
        this.nombreMetodo = nombreMetodo;
    }

    public int getCita_idCita() {
        return cita_idCita;
    }

    public void setCita_idCita(int cita_idCita) {
        this.cita_idCita = cita_idCita;
    }
}
