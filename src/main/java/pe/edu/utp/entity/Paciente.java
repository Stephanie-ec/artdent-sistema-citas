package pe.edu.utp.entity;

public class Paciente {

    private int idPaciente;
    private String Nombre;
    private String Apellido;
    private int Dni;
    private int Telefono;
    private String Correo;

    public Paciente() {
    }

    public Paciente(int idPaciente, String Nombre, String Apellido, int Dni, int Telefono, String Correo) {
        this.idPaciente = idPaciente;
        this.Nombre = Nombre;
        this.Apellido = Apellido;
        this.Dni = Dni;
        this.Telefono = Telefono;
        this.Correo = Correo;
    }

    public int getIdPaciente() {
        return idPaciente;
    }

    public void setIdPaciente(int idPaciente) {
        this.idPaciente = idPaciente;
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

    public int getTelefono() {
        return Telefono;
    }

    public void setTelefono(int Telefono) {
        this.Telefono = Telefono;
    }

    public String getCorreo() {
        return Correo;
    }

    public void setCorreo(String Correo) {
        this.Correo = Correo;
    }

}
