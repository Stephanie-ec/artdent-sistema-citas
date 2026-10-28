/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package pe.edu.utp.components;

import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
/**
 *
 * @author alex0
 */
public class TiempoSuma {
    public int calcularSuma(String hora) {
            System.out.println("Hora recibida: " + hora);

        LocalTime horaInicio = LocalTime.of(8, 0);
        LocalTime horaEntrada = LocalTime.parse(hora, DateTimeFormatter.ofPattern("HH:mm:ss"));
    

        if (horaEntrada.isBefore(horaInicio)) {
            return 0; // Si es antes de las 8 AM, devuelve 0
        }

        long minutosDiferencia = java.time.Duration.between(horaInicio, horaEntrada).toMinutes();
        System.out.println("Resultado: " + minutosDiferencia / 15);
        return (int) (minutosDiferencia / 15);
    }
}