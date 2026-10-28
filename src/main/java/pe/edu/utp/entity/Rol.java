/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package pe.edu.utp.entity;

/**
 *
 * @author Christhian
 */
public class Rol {

    private int idRol;
    private String TipoRol;

    public Rol() {
    }

    public Rol(int idRol, String TipoRol) {
        this.idRol = idRol;
        this.TipoRol = TipoRol;
    }

    public int getIdRol() {
        return idRol;
    }

    public void setIdRol(int idRol) {
        this.idRol = idRol;
    }

    public String getTipoRol() {
        return TipoRol;
    }

    public void setTipoRol(String TipoRol) {
        this.TipoRol = TipoRol;
    }

}
