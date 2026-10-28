/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package pe.edu.utp.entity;


public class ReporteEstado {
    private String estado;
    private int total;

    public ReporteEstado(String estado, int total) {
        this.estado = estado;
        this.total = total;
    }

    public String getEstado() {
        return estado;
    }

    public int getTotal() {
        return total;
    }
}
