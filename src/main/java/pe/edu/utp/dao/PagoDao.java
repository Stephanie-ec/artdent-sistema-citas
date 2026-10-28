package pe.edu.utp.dao;

import java.util.Map;
import pe.edu.utp.entity.Comprobante;
import pe.edu.utp.entity.Pago;

public interface PagoDao {
    boolean registrarPagoYComprobante(Pago pago, Comprobante comprobante);
    boolean tienePago(int idCita);
    Pago obtenerPagoPorCita(int idCita);
    Comprobante obtenerComprobantePorCita(int idCita);
    Comprobante obtenerComprobantePorPago(int idPago);
    Comprobante obtenerComprobantePorId(int idComprobante);
    Map<Integer, Comprobante> obtenerMapaComprobantesPorCita();
}
