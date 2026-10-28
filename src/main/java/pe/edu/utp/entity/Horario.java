package pe.edu.utp.entity;

public class Horario {

    private int idHorario;
    private String HoraInicio;
    private String HoraFinal;
    private String DiaSemana;

    public Horario() {
    }

    public Horario(int idHorario, String HoraInicio, String HoraFinal, String DiaSemana) {
        this.idHorario = idHorario;
        this.HoraInicio = HoraInicio;
        this.HoraFinal = HoraFinal;
        this.DiaSemana = DiaSemana;
    }

    public int getIdHorario() {
        return idHorario;
    }

    public void setIdHorario(int idHorario) {
        this.idHorario = idHorario;
    }

    public String getHoraInicio() {
        return HoraInicio;
    }

    public void setHoraInicio(String HoraInicio) {
        this.HoraInicio = HoraInicio;
    }

    public String getHoraFinal() {
        return HoraFinal;
    }

    public void setHoraFinal(String HoraFinal) {
        this.HoraFinal = HoraFinal;
    }

    public String getDiaSemana() {
        return DiaSemana;
    }

    public void setDiaSemana(String DiaSemana) {
        this.DiaSemana = DiaSemana;
    }

}
