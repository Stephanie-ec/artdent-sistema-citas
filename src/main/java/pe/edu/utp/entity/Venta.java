package pe.edu.utp.entity;

/**
 *
 * @author Andrea
 */
public class Venta {

    private int idVenta;
    private double Importe;
    private String FechaHoraPago;
    private int Cita_idCita;

    public Venta(int idVenta, double Importe, String FechaHoraPago, int Cita_idCita) {
        this.idVenta = idVenta;
        this.Importe = Importe;
        this.FechaHoraPago = FechaHoraPago;
        this.Cita_idCita = Cita_idCita;
    }

    public Venta() {
    }

    public int getIdVenta() {
        return idVenta;
    }

    public void setIdVenta(int idVenta) {
        this.idVenta = idVenta;
    }

    public double getImporte() {
        return Importe;
    }

    public void setImporte(double Importe) {
        this.Importe = Importe;
    }

    public String getFechaHoraPago() {
        return FechaHoraPago;
    }

    public void setFechaHoraPago(String FechaHoraPago) {
        this.FechaHoraPago = FechaHoraPago;
    }

    public int getCita_idCita() {
        return Cita_idCita;
    }

    public void setCita_idCita(int Cita_idCita) {
        this.Cita_idCita = Cita_idCita;
    }
    
    
}
