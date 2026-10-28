package pe.edu.utp.entity;

public class ReporteMensual {

    private String mes;
    private int citasCompletadas;
    private int citasEnEspera;
    private int citasReprogramadas;
    private int citasConfirmadas;
    private int citasCanceladas;
    private int totalCitas;
    private int reservasCompletadas;
    private int reservasEnEspera;
    private int reservasReprogramadas;
    private int reservasConfirmadas;
    private int reservasCanceladas;
    private int totalReservas;
    private double totalIngresos;

    public ReporteMensual(String mes, int totalReservas, int totalCitas, int reservasCompletadas, int reservasCanceladas, int citasCompletadas, int citasCanceladas, int citasEnEspera, int citasReprogramadas, int citasConfirmadas, int reservasEnEspera, int reservasReprogramadas, int reservasConfirmadas) {
        this.mes = mes;
        this.totalReservas = totalReservas;
        this.totalCitas = totalCitas;
        this.reservasCompletadas = reservasCompletadas;
        this.reservasCanceladas = reservasCanceladas;
        this.citasCompletadas = citasCompletadas;
        this.citasCanceladas = citasCanceladas;
        this.citasEnEspera = citasEnEspera;
        this.citasReprogramadas = citasReprogramadas;
        this.citasConfirmadas = citasConfirmadas;
        this.reservasEnEspera = reservasEnEspera;
        this.reservasReprogramadas = reservasReprogramadas;
        this.reservasConfirmadas = reservasConfirmadas;
    }

    public String getMes() {
        return mes;
    }

    public void setMes(String mes) {
        this.mes = mes;
    }

    public int getCitasCompletadas() {
        return citasCompletadas;
    }

    public void setCitasCompletadas(int citasCompletadas) {
        this.citasCompletadas = citasCompletadas;
    }

    public int getCitasEnEspera() {
        return citasEnEspera;
    }

    public void setCitasEnEspera(int citasEnEspera) {
        this.citasEnEspera = citasEnEspera;
    }

    public int getCitasReprogramadas() {
        return citasReprogramadas;
    }

    public void setCitasReprogramadas(int citasReprogramadas) {
        this.citasReprogramadas = citasReprogramadas;
    }

    public int getCitasConfirmadas() {
        return citasConfirmadas;
    }

    public void setCitasConfirmadas(int citasConfirmadas) {
        this.citasConfirmadas = citasConfirmadas;
    }

    public int getCitasCanceladas() {
        return citasCanceladas;
    }

    public void setCitasCanceladas(int citasCanceladas) {
        this.citasCanceladas = citasCanceladas;
    }

    public int getTotalCitas() {
        return totalCitas;
    }

    public void setTotalCitas(int totalCitas) {
        this.totalCitas = totalCitas;
    }

    public int getReservasCompletadas() {
        return reservasCompletadas;
    }

    public void setReservasCompletadas(int reservasCompletadas) {
        this.reservasCompletadas = reservasCompletadas;
    }

    public int getReservasEnEspera() {
        return reservasEnEspera;
    }

    public void setReservasEnEspera(int reservasEnEspera) {
        this.reservasEnEspera = reservasEnEspera;
    }

    public int getReservasReprogramadas() {
        return reservasReprogramadas;
    }

    public void setReservasReprogramadas(int reservasReprogramadas) {
        this.reservasReprogramadas = reservasReprogramadas;
    }

    public int getReservasConfirmadas() {
        return reservasConfirmadas;
    }

    public void setReservasConfirmadas(int reservasConfirmadas) {
        this.reservasConfirmadas = reservasConfirmadas;
    }

    public int getReservasCanceladas() {
        return reservasCanceladas;
    }

    public void setReservasCanceladas(int reservasCanceladas) {
        this.reservasCanceladas = reservasCanceladas;
    }

    public int getTotalReservas() {
        return totalReservas;
    }

    public void setTotalReservas(int totalReservas) {
        this.totalReservas = totalReservas;
    }

    public double getTotalIngresos() {
        return totalIngresos;
    }

    public void setTotalIngresos(double totalIngresos) {
        this.totalIngresos = totalIngresos;
    }

}
