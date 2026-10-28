package pe.edu.utp.entity;

import java.math.BigDecimal;

public class Servicio {

    private int idServicio;
    private String tipoServicio;
    private String lema;
    private String descripcion;
    private String respuesta;
    private BigDecimal costo;
    private String linkimagen;
    private boolean activo = true;

    public Servicio() {
    }

    public Servicio(int idServicio, String tipoServicio, String lema, String descripcion, String respuesta, BigDecimal costo, String linkimagen) {
        this.idServicio = idServicio;
        this.tipoServicio = tipoServicio;
        this.lema = lema;
        this.descripcion = descripcion;
        this.respuesta = respuesta;
        this.costo = costo;
        this.linkimagen = linkimagen;
        this.activo = true;
    }

    public Servicio(int idServicio, String tipoServicio, String lema, String descripcion, String respuesta, BigDecimal costo, String linkimagen, boolean activo) {
        this.idServicio = idServicio;
        this.tipoServicio = tipoServicio;
        this.lema = lema;
        this.descripcion = descripcion;
        this.respuesta = respuesta;
        this.costo = costo;
        this.linkimagen = linkimagen;
        this.activo = activo;
    }

    public Servicio(int id, String tipo, BigDecimal costo) {
        this.idServicio = id;
        this.tipoServicio = tipo;
        this.costo = costo;
        this.activo = true;
    }

    public boolean isActivo() {
        return activo;
    }

    public void setActivo(boolean activo) {
        this.activo = activo;
    }

    public String getLinkimagen() {
        return linkimagen;
    }

    public void setLinkimagen(String linkimagen) {
        this.linkimagen = linkimagen;
    }

    public int getIdServicio() {
        return idServicio;
    }

    public void setIdServicio(int idServicio) {
        this.idServicio = idServicio;
    }

    public String getTipoServicio() {
        return tipoServicio;
    }

    public void setTipoServicio(String tipoServicio) {
        this.tipoServicio = tipoServicio;
    }

    public String getLema() {
        return lema;
    }

    public void setLema(String lema) {
        this.lema = lema;
    }

    public String getDescripcion() {
        return descripcion;
    }

    public void setDescripcion(String descripcion) {
        this.descripcion = descripcion;
    }

    public String getRespuesta() {
        return respuesta;
    }

    public void setRespuesta(String respuesta) {
        this.respuesta = respuesta;
    }

    public BigDecimal getCosto() {
        return costo;
    }

    public void setCosto(BigDecimal costo) {
        this.costo = costo;
    }
}
