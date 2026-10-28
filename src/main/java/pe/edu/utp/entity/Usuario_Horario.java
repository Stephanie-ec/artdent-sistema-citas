/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package pe.edu.utp.entity;

/**
 *
 * @author Christhian
 */
public class Usuario_Horario {

    private int idUsuario_Horario;
    private int Usuario_idUsuario;
    private int Horario_idHorario;

    public Usuario_Horario() {
    }

    public Usuario_Horario(int idUsuario_Horario, int Usuario_idUsuario, int Horario_idHorario) {
        this.idUsuario_Horario = idUsuario_Horario;
        this.Usuario_idUsuario = Usuario_idUsuario;
        this.Horario_idHorario = Horario_idHorario;
    }

    public int getIdUsuario_Horario() {
        return idUsuario_Horario;
    }

    public void setIdUsuario_Horario(int idUsuario_Horario) {
        this.idUsuario_Horario = idUsuario_Horario;
    }

    public int getUsuario_idUsuario() {
        return Usuario_idUsuario;
    }

    public void setUsuario_idUsuario(int Usuario_idUsuario) {
        this.Usuario_idUsuario = Usuario_idUsuario;
    }

    public int getHorario_idHorario() {
        return Horario_idHorario;
    }

    public void setHorario_idHorario(int Horario_idHorario) {
        this.Horario_idHorario = Horario_idHorario;
    }

}
