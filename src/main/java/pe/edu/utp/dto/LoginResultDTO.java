package pe.edu.utp.dto;

public class LoginResultDTO {
    private boolean exito;
    private InicioSesionDTO usuario;
    private boolean bloqueado;
    private int intentosRestantes;
    private int minutosRestantes;
    private String mensaje;

    public LoginResultDTO() {
    }

    public boolean isExito() {
        return exito;
    }

    public void setExito(boolean exito) {
        this.exito = exito;
    }

    public InicioSesionDTO getUsuario() {
        return usuario;
    }

    public void setUsuario(InicioSesionDTO usuario) {
        this.usuario = usuario;
    }

    public boolean isBloqueado() {
        return bloqueado;
    }

    public void setBloqueado(boolean bloqueado) {
        this.bloqueado = bloqueado;
    }

    public int getIntentosRestantes() {
        return intentosRestantes;
    }

    public void setIntentosRestantes(int intentosRestantes) {
        this.intentosRestantes = intentosRestantes;
    }

    public int getMinutosRestantes() {
        return minutosRestantes;
    }

    public void setMinutosRestantes(int minutosRestantes) {
        this.minutosRestantes = minutosRestantes;
    }

    public String getMensaje() {
        return mensaje;
    }

    public void setMensaje(String mensaje) {
        this.mensaje = mensaje;
    }
}
