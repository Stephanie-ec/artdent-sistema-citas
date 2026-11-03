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
        } else if ("consultar".equalsIgnoreCase(action)) {
            consultarReserva(request, response);
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
            // D-11: el monto se calcula en el servidor desde Servicio.Costo, no se toma del formulario
            Double costo = pagoDao.obtenerCostoServicioPorCita(idCita);
            if (costo == null) {
                request.setAttribute("error", "No se encontró la cita indicada.");
                request.getRequestDispatcher("error.jsp").forward(request, response);
                return;
            }
            double monto = costo;
            String nombreCliente = request.getParameter("nombreCliente");
            String dniCliente = request.getParameter("dniCliente");

            if (nombreCliente != null) nombreCliente = nombreCliente.trim();
            if (dniCliente != null) dniCliente = dniCliente.trim();

            // Datos del titular obligatorios y con formato válido (la pasarela no acepta campos vacíos)
            if (nombreCliente == null || !nombreCliente.matches("^[A-Za-zÁÉÍÓÚÜÑáéíóúüñ' -]{3,60}$")
                    || dniCliente == null || !dniCliente.matches("\\d{8}")) {
                request.setAttribute("error", "Datos del titular no válidos: ingrese su nombre y un DNI de 8 dígitos.");
                request.getRequestDispatcher("error.jsp").forward(request, response);
                return;
            }

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
            // D-11: el monto se calcula en el servidor desde Servicio.Costo, no se toma del formulario
            Double costo = pagoDao.obtenerCostoServicioPorCita(idCita);
            if (costo == null) {
                request.setAttribute("error", "No se encontró la cita indicada.");
                request.getRequestDispatcher("error.jsp").forward(request, response);
                return;
            }
            // Si la reserva ya se pagó (por ejemplo, volvió atrás en el navegador), se muestra su boleta
            if (pagoDao.tienePago(idCita)) {
                permitirCita(request, idCita);
                response.sendRedirect("PagoController?action=verBoleta&idCita=" + idCita + "&yaPagado=1");
                return;
            }
            double monto = costo;
            String nombreCliente = request.getParameter("nombreCliente");
            String dniCliente = request.getParameter("dniCliente");
            String codigoReserva = request.getParameter("codigoReserva");

            if (nombreCliente != null) nombreCliente = nombreCliente.trim();
            if (dniCliente != null) dniCliente = dniCliente.trim();

            // Datos del titular obligatorios y con formato válido (la pasarela no acepta campos vacíos)
            if (nombreCliente == null || !nombreCliente.matches("^[A-Za-zÁÉÍÓÚÜÑáéíóúüñ' -]{3,60}$")
                    || dniCliente == null || !dniCliente.matches("\\d{8}")) {
                request.setAttribute("error", "Datos del titular no válidos: ingrese su nombre y un DNI de 8 dígitos.");
                request.getRequestDispatcher("error.jsp").forward(request, response);
                return;
            }

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
                permitirCita(request, idCita);
                // Redirigir a vista de boleta electrónica generada
                response.sendRedirect("PagoController?action=verBoleta&idPago=" + pago.getIdPago() 
                        + "&codigoReserva=" + (codigoReserva != null ? codigoReserva : ""));
            } else {
                request.setAttribute("error", "No se pudo registrar el pago. Intente nuevamente o consulte su reserva con su código y DNI.");
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

            // Ley 29733: un visitante solo ve boletas de sus propias reservas (pagadas o consultadas con código y DNI)
            if (comp != null && request.getSession().getAttribute("TipoRol") == null
                    && !citaPermitida(request, comp.getIdCita())) {
                response.sendRedirect("consultareserva.jsp?error=permiso");
                return;
            }
            if (comp != null) {
                request.setAttribute("comprobante", comp);
                request.setAttribute("yaPagado", "1".equals(request.getParameter("yaPagado")));
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

    /** Busca una reserva con su código (ART-RES-00018 o 18) y el DNI del paciente. */
    private void consultarReserva(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String codigo = request.getParameter("codigo") == null ? "" : request.getParameter("codigo").trim().toUpperCase();
        String dni = request.getParameter("dni") == null ? "" : request.getParameter("dni").trim();
        String numero = codigo.replaceAll("[^0-9]", "");
        if (numero.isEmpty() || !dni.matches("\\d{8}")) {
            response.sendRedirect("consultareserva.jsp?error=datos");
            return;
        }
        int idCita;
        try {
            idCita = Integer.parseInt(numero);
        } catch (NumberFormatException e) {
            response.sendRedirect("consultareserva.jsp?error=datos");
            return;
        }
        java.util.Map<String, Object> r = pagoDao.consultarReserva(idCita, dni);
        if (r == null) {
            response.sendRedirect("consultareserva.jsp?error=noexiste");
            return;
        }
        permitirCita(request, idCita);
        if (Boolean.TRUE.equals(r.get("pagado"))) {
            response.sendRedirect("PagoController?action=verBoleta&idCita=" + idCita);
            return;
        }
        request.setAttribute("reserva", r);
        request.setAttribute("codigo", String.format("ART-RES-%05d", idCita));
        request.getRequestDispatcher("consultareserva.jsp").forward(request, response);
    }

    @SuppressWarnings("unchecked")
    private static void permitirCita(HttpServletRequest request, int idCita) {
        javax.servlet.http.HttpSession s = request.getSession();
        java.util.Set<Integer> ids = (java.util.Set<Integer>) s.getAttribute("citasPropias");
        if (ids == null) {
            ids = new java.util.HashSet<>();
            s.setAttribute("citasPropias", ids);
        }
        ids.add(idCita);
    }

    @SuppressWarnings("unchecked")
    private static boolean citaPermitida(HttpServletRequest request, int idCita) {
        Object ids = request.getSession().getAttribute("citasPropias");
        return ids instanceof java.util.Set && ((java.util.Set<Integer>) ids).contains(idCita);
    }

}
