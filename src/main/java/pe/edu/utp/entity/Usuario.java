/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package pe.edu.utp.entity;

public class Usuario {

    private int idUsuario;
    private String Nombre;
    private String Apellido;
    private int Dni;
    private String Telefono;
    private String CorreoElectronico;
    private String Direccion;
    private String FechaNacimiento;
    private String Clave;
    private int Rol_idRol;
    private String Rol;
    
    public Usuario() {
    }

    public Usuario(int idUsuario, String Nombre, String Apellido, int Dni, String Telefono, String CorreoElectronico, String Direccion, String FechaNacimiento, String Clave, int Rol_idRol) {
        this.idUsuario = idUsuario;
        this.Nombre = Nombre;
        this.Apellido = Apellido;
        this.Dni = Dni;
        this.Telefono = Telefono;
        this.CorreoElectronico = CorreoElectronico;
        this.Direccion = Direccion;
        this.FechaNacimiento = FechaNacimiento;
        this.Clave = Clave;
        this.Rol_idRol = Rol_idRol;
    }

    public Usuario(String Nombre, String Apellido, int Dni, String Telefono, String CorreoElectronico, String Direccion, String FechaNacimiento, String Clave, int Rol_idRol) {
        this.Nombre = Nombre;
        this.Apellido = Apellido;
        this.Dni = Dni;
        this.Telefono = Telefono;
        this.CorreoElectronico = CorreoElectronico;
        this.Direccion = Direccion;
        this.FechaNacimiento = FechaNacimiento;
        this.Clave = Clave;
        this.Rol_idRol = Rol_idRol;
    }

    
    
    public int getIdUsuario() {
        return idUsuario;
    }

    public String getRol() {
        return Rol;
    }

    public void setRol(String Rol) {
        this.Rol = Rol;
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

    public String getTelefono() {
        return Telefono;
    }

    public void setTelefono(String Telefono) {
        this.Telefono = Telefono;
    }

    public String getCorreoElectronico() {
        return CorreoElectronico;
    }

    public void setCorreoElectronico(String CorreoElectronico) {
        this.CorreoElectronico = CorreoElectronico;
    }

    public String getDireccion() {
        return Direccion;
    }

    public void setDireccion(String Direccion) {
        this.Direccion = Direccion;
    }

    public String getFechaNacimiento() {
        return FechaNacimiento;
    }

    public void setFechaNacimiento(String FechaNacimiento) {
        this.FechaNacimiento = FechaNacimiento;
    }

    public String getClave() {
        return Clave;
    }

    public void setClave(String Clave) {
        this.Clave = Clave;
    }

    public int getRol_idRol() {
        return Rol_idRol;
    }

    public void setRol_idRol(int Rol_idRol) {
        this.Rol_idRol = Rol_idRol;
    }

}
