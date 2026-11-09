package pe.edu.utp.utils;
public class ReservaNoDisponibleException extends RuntimeException {
    public ReservaNoDisponibleException(String mensaje, Throwable causa) { super(mensaje, causa); }
}
