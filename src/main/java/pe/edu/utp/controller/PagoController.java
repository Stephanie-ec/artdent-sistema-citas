package pe.edu.utp.controller;

import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.UUID;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import pe.edu.utp.dao.PagoDao;
import pe.edu.utp.daoImpl.PagoDaoImpl;
import pe.edu.utp.entity.Comprobante;
import pe.edu.utp.entity.Pago;

@WebServlet("/PagoController")
public class PagoController extends HttpServlet {

    private final PagoDao pagoDao = new PagoDaoImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        if (action == null) {
            action = "verBoleta";
        }

        if ("verBoleta".equalsIgnoreCase(action)) {
            verBoleta(request, response);
        } else {
            response.sendRedirect("index.jsp");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        if (action == null) {
            action = "";
        }

        switch (action) {
            case "registrarPagoEfectivo":
                registrarPagoEfectivo(request, response);
                break;
            case "pagarEnLinea":
                pagarEnLinea(request, response);
                break;
            default:
                response.sendRedirect("index.jsp");
                break;
        }
    }

    private void registrarPagoEfectivo(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            int idCita = Integer.parseInt(request.getParameter("idCita"));
            double monto = Double.parseDouble(request.getParameter("monto"));
            String nombreCliente = request.getParameter("nombreCliente");
            String dniCliente = request.getParameter("dniCliente");

            if (nombreCliente != null) nombreCliente = nombreCliente.trim();
            if (dniCliente != null) dniCliente = dniCliente.trim();

            String timeStamp = new SimpleDateFormat("yyyyMMddHHmmss").format(new Date());
            String codTransaccion = "EFEC-" + timeStamp;

            Pago pago = new Pago();
            pago.setCita_idCita(idCita);
            pago.setMonto(monto);
            pago.setMetodoPago_idMetodo(2); // 2 = Efectivo (MetodoPago)
            pago.setCodigoTransaccion(codTransaccion);

            Comprobante comp = new Comprobante();
            comp.setSerie("B001");
            comp.setNombreCliente(nombreCliente);
            comp.setDniCliente(dniCliente);

            boolean exito = pagoDao.registrarPagoYComprobante(pago, comp);

            if (exito) {
                response.sendRedirect("ReservaController?accion=listar&msg=pagoEfectivoOk&boleta=" 
                        + comp.getCodigoBoletaCompleto());
            } else {
                request.setAttribute("error", "No se pudo registrar el pago en efectivo o la cita ya cuenta con un pago asociado.");
                request.getRequestDispatcher("error.jsp").forward(request, response);
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error al procesar pago en efectivo: " + e.getMessage());
            request.getRequestDispatcher("error.jsp").forward(request, response);
        }
    }

    private void pagarEnLinea(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            int idCita = Integer.parseInt(request.getParameter("idCita"));
            double monto = Double.parseDouble(request.getParameter("monto"));
            String nombreCliente = request.getParameter("nombreCliente");
            String dniCliente = request.getParameter("dniCliente");
            String codigoReserva = request.getParameter("codigoReserva");

            if (nombreCliente != null) nombreCliente = nombreCliente.trim();
            if (dniCliente != null) dniCliente = dniCliente.trim();

            String timeStamp = new SimpleDateFormat("yyyyMMdd-").format(new Date());
            String codTransaccion = "TXN-" + timeStamp + UUID.randomUUID().toString().substring(0, 8).toUpperCase();

            Pago pago = new Pago();
            pago.setCita_idCita(idCita);
            pago.setMonto(monto);
            pago.setMetodoPago_idMetodo(1); // 1 = En línea (MetodoPago)
            pago.setCodigoTransaccion(codTransaccion);

            Comprobante comp = new Comprobante();
            comp.setSerie("B001");
            comp.setNombreCliente(nombreCliente);
            comp.setDniCliente(dniCliente);

            boolean exito = pagoDao.registrarPagoYComprobante(pago, comp);

            if (exito) {
                // Redirigir a vista de boleta electrónica generada
                response.sendRedirect("PagoController?action=verBoleta&idPago=" + pago.getIdPago() 
                        + "&codigoReserva=" + (codigoReserva != null ? codigoReserva : ""));
            } else {
                request.setAttribute("error", "La reserva ya cuenta con un pago registrado previamente o ocurrió un problema con la pasarela.");
                request.getRequestDispatcher("error.jsp").forward(request, response);
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error al procesar pago en línea: " + e.getMessage());
            request.getRequestDispatcher("error.jsp").forward(request, response);
        }
    }

    private void verBoleta(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            String idPagoStr = request.getParameter("idPago");
            String idCitaStr = request.getParameter("idCita");
            String idCompStr = request.getParameter("idComprobante");

            Comprobante comp = null;
            if (idPagoStr != null && !idPagoStr.isEmpty()) {
                comp = pagoDao.obtenerComprobantePorPago(Integer.parseInt(idPagoStr));
            } else if (idCitaStr != null && !idCitaStr.isEmpty()) {
                comp = pagoDao.obtenerComprobantePorCita(Integer.parseInt(idCitaStr));
            } else if (idCompStr != null && !idCompStr.isEmpty()) {
                comp = pagoDao.obtenerComprobantePorId(Integer.parseInt(idCompStr));
            }

            if (comp != null) {
                request.setAttribute("comprobante", comp);
                request.setAttribute("codigoReserva", request.getParameter("codigoReserva"));
                request.getRequestDispatcher("boleta.jsp").forward(request, response);
            } else {
                request.setAttribute("error", "No se encontró el comprobante solicitado.");
                request.getRequestDispatcher("error.jsp").forward(request, response);
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error al cargar el comprobante: " + e.getMessage());
            request.getRequestDispatcher("error.jsp").forward(request, response);
        }
    }
}
