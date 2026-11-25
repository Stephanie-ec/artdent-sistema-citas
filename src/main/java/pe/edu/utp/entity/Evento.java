package pe.edu.utp.entity;

import java.sql.Timestamp;

/** R-15: evento operativo del sistema (INFO, ADVERTENCIA o ERROR). */
public class Evento {

    private int idEvento;
    private Timestamp fecha;
    private String nivel;
    private String origen;
    private String mensaje;
    private boolean atendido;
    private Integer atendidoPor;
    private Timestamp fechaAtencion;
    private String accionTomada;
    private String atendidoPorNombre;

    public int getIdEvento() { return idEvento; }
    public void setIdEvento(int idEvento) { this.idEvento = idEvento; }
    public Timestamp getFecha() { return fecha; }
    public void setFecha(Timestamp fecha) { this.fecha = fecha; }
    public String getNivel() { return nivel; }
    public void setNivel(String nivel) { this.nivel = nivel; }
    public String getOrigen() { return origen; }
    public void setOrigen(String origen) { this.origen = origen; }
    public String getMensaje() { return mensaje; }
    public void setMensaje(String mensaje) { this.mensaje = mensaje; }
    public boolean isAtendido() { return atendido; }
    public void setAtendido(boolean atendido) { this.atendido = atendido; }
    public Integer getAtendidoPor() { return atendidoPor; }
    public void setAtendidoPor(Integer atendidoPor) { this.atendidoPor = atendidoPor; }
    public Timestamp getFechaAtencion() { return fechaAtencion; }
    public void setFechaAtencion(Timestamp fechaAtencion) { this.fechaAtencion = fechaAtencion; }
    public String getAccionTomada() { return accionTomada; }
    public void setAccionTomada(String accionTomada) { this.accionTomada = accionTomada; }
    public String getAtendidoPorNombre() { return atendidoPorNombre; }
    public void setAtendidoPorNombre(String atendidoPorNombre) { this.atendidoPorNombre = atendidoPorNombre; }
}
