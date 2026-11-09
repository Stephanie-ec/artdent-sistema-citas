package pe.edu.utp.dao;

import java.util.Map;
import pe.edu.utp.entity.Comprobante;
import pe.edu.utp.entity.Pago;

public interface PagoDao {
    boolean registrarPagoYComprobante(Pago pago, Comprobante comprobante);
    boolean tienePago(int idCita);
    Integer obtenerEstadoCita(int idCita);
    java.util.Set<Integer> citasPagadas();
    Pago obtenerPagoPorCita(int idCita);
    Comprobante obtenerComprobantePorCita(int idCita);
    Comprobante obtenerComprobantePorPago(int idPago);
    Comprobante obtenerComprobantePorId(int idComprobante);
    Map<Integer, Comprobante> obtenerMapaComprobantesPorCita();

    /** Costo vigente del servicio de la cita; null si la cita no existe. */
    Double obtenerCostoServicioPorCita(int idCita);

    /** Datos de una cita solo si el DNI coincide con el del paciente; null si no coincide. */
    Map<String, Object> consultarReserva(int idCita, String dni);
}
