/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package pe.edu.utp.dto;

/**
 *
 * @author Christhian
 */
public class InicioSesionDTO {
    private int idUsuario;
    private String Nombre;
    private String Apellido;
    private int Dni;
    private String TipoRol;

    public InicioSesionDTO() {
    }

    public InicioSesionDTO(int idUsuario, String Nombre, String Apellido, int Dni, String TipoRol) {
        this.idUsuario = idUsuario;
        this.Nombre = Nombre;
        this.Apellido = Apellido;
        this.Dni = Dni;
        this.TipoRol = TipoRol;
    }

    public int getIdUsuario() {
        return idUsuario;
    }

    public void setIdUsuario(int idUsuario) {
        this.idUsuario = idUsuario;
    }

    public String getNombre() {
        return Nombre;
    }

    public void setNombre(String Nombre) {
        this.Nombre = Nombre;
    }

    public String getApellido() {
        return Apellido;
    }

    public void setApellido(String Apellido) {
        this.Apellido = Apellido;
    }

    public int getDni() {
        return Dni;
    }

    public void setDni(int Dni) {
        this.Dni = Dni;
    }

    public String getTipoRol() {
        return TipoRol;
    }

    public void setTipoRol(String TipoRol) {
        this.TipoRol = TipoRol;
    }
    
    
}
