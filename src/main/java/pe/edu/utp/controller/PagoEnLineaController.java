package pe.edu.utp.controller;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import pe.edu.utp.daoImpl.PagoDaoImpl;
import pe.edu.utp.entity.Comprobante;
import pe.edu.utp.entity.Pago;
import pe.edu.utp.utils.ConfigLoader;
import pe.edu.utp.utils.EventoService;
import pe.edu.utp.utils.FormToken;
import pe.edu.utp.utils.MercadoPagoService;

/**
 * R-01: pago en línea con Checkout Pro.
 *
 * POST accion=crear  -> crea la preferencia y redirige al checkout de Mercado Pago.
 * GET  accion=retorno -> vuelve del checkout y registra el pago solo si la API
 *                        confirma "approved" y el importe coincide con el costo.
 * GET  accion=notificacion -> webhook: misma verificación, idempotente.
 */
@WebServlet("/PagoEnLinea")
public class PagoEnLineaController extends HttpServlet {

    private static final int METODO_MERCADO_PAGO = 3; // MetodoPago: 3 = Mercado Pago (R-01)
    private final PagoDaoImpl pagoDao = new PagoDaoImpl();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        if (!"crear".equals(req.getParameter("accion"))) {
            res.sendError(400);
            return;
        }
        if (!FormToken.valido(req)) {
            res.sendError(403);
            return;
        }
        if (!MercadoPagoService.habilitado()) {
            error(req, res, 409, "El pago en línea todavía no está habilitado. Puede pagar en ventanilla o con Yape/Plin.");
            return;
        }
        int idCita;
        try {
            idCita = Integer.parseInt(req.getParameter("cita"));
        } catch (RuntimeException e) {
            res.sendError(400);
            return;
        }
        if (!propia(req, idCita)) {
            res.sendError(403);
            return;
        }
        try {
            Integer estado = pagoDao.obtenerEstadoCita(idCita);
            if (estado == null || estado == 5 || estado == 6) {
                error(req, res, 409, "La reserva no admite pagos porque fue cancelada o rechazada.");
                return;
            }
            if (pagoDao.tienePago(idCita)) {
                res.sendRedirect(req.getContextPath() + "/PagoController?action=verBoleta&idCita=" + idCita + "&yaPagado=1");
                return;
            }
            Map<String, Object> datos = pagoDao.datosCobro(idCita);
            if (datos == null) {
                error(req, res, 404, "No se encontró la reserva indicada.");
                return;
            }
            double monto = ((BigDecimal) datos.get("costo")).doubleValue();
            String titulo = "Art Dent - " + datos.get("servicio") + " (ART-RES-" + String.format(java.util.Locale.ROOT, "%05d", idCita) + ")";
            String cuerpo = MercadoPagoService.construirPreferencia(idCita, titulo, monto,
                    String.valueOf(datos.get("paciente")), String.valueOf(datos.get("dni")),
                    datos.get("correo") == null ? null : String.valueOf(datos.get("correo")),
                    urlRetorno(req, "retorno"), urlRetorno(req, "notificacion"));
            Map<String, String> preferencia = MercadoPagoService.crearPreferencia(cuerpo);
            EventoService.info("Pagos", "Preferencia de pago en línea creada para la cita " + idCita);
            res.sendRedirect(preferencia.get("init_point"));
        } catch (IOException e) {
            EventoService.advertencia("Pagos", "Mercado Pago no respondió al crear la preferencia de la cita " + idCita);
            error(req, res, 502, "No pudimos iniciar el pago en línea en este momento. Intente nuevamente o pague en ventanilla.");
        } catch (IllegalStateException e) {
            error(req, res, 503, "El pago en línea no está configurado correctamente. Puede pagar en ventanilla.");
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        String accion = req.getParameter("accion");
        if ("notificacion".equals(accion)) {
            notificacion(req, res);
            return;
        }
        if (!"retorno".equals(accion)) {
            res.sendRedirect(req.getContextPath() + "/index.jsp");
            return;
        }
        retorno(req, res);
    }

    /** Webhook: se responde 200 siempre para que Mercado Pago no reintente en bucle. */
    private void notificacion(HttpServletRequest req, HttpServletResponse res) throws IOException {
        res.setStatus(200);
        res.setContentType("text/plain; charset=UTF-8");
        res.getWriter().write("ok");
        if (!MercadoPagoService.habilitado()) {
            return;
        }
        // Mercado Pago envía {"type":"payment","data":{"id":"..."}} o data.id en la URL.
        String id = req.getParameter("data.id");
        if (id == null) {
            id = req.getParameter("id");
        }
        String tipo = req.getParameter("type");
        if (id == null && req.getContentType() != null && req.getContentType().contains("json")) {
            String cuerpo = leerCuerpo(req);
            if (cuerpo != null && cuerpo.contains("\"payment\"")) {
                java.util.regex.Matcher m = java.util.regex.Pattern
                        .compile("\"id\"\\s*:\\s*\"?(\\d{1,20})\"?").matcher(cuerpo);
                if (m.find()) {
                    id = m.group(1);
                }
            }
        }
        if (id == null || (tipo != null && !"payment".equals(tipo)) || !id.matches("\\d{1,20}")) {
            return;
        }
        try {
            MercadoPagoService.Pago pago = MercadoPagoService.consultarPago(id);
            if (pago != null && pago.aprobado()) {
                registrar(id, pago);
            }
        } catch (IOException | RuntimeException e) {
            EventoService.advertencia("Pagos", "No se pudo verificar la notificación de Mercado Pago");
        }
    }

    private void retorno(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        if (!MercadoPagoService.habilitado()) {
            error(req, res, 409, "El pago en línea no está habilitado en este servidor.");
            return;
        }
        String id = req.getParameter("payment_id");
        if (id == null || !id.matches("\\d{1,20}")) {
            id = req.getParameter("collection_id");
        }
        if (id == null || !id.matches("\\d{1,20}")) {
            req.setAttribute("mensaje", "No recibimos el identificador del pago. Si ya pagó, consulte su reserva en unos minutos.");
            req.setAttribute("estadoPago", "PENDIENTE");
            req.getRequestDispatcher("/pagoenlinea.jsp").forward(req, res);
            return;
        }
        MercadoPagoService.Pago pago;
        try {
            pago = MercadoPagoService.consultarPago(id);
        } catch (IOException e) {
            EventoService.advertencia("Pagos", "No se pudo verificar el pago en línea " + id);
            req.setAttribute("mensaje", "No pudimos verificar el pago con Mercado Pago. Consulte su reserva en unos minutos; no vuelva a pagar.");
            req.setAttribute("estadoPago", "PENDIENTE");
            req.getRequestDispatcher("/pagoenlinea.jsp").forward(req, res);
            return;
        }
        if (pago == null) {
            req.setAttribute("mensaje", "Mercado Pago no reconoce ese pago. Consulte su reserva o comuníquese con la clínica.");
            req.setAttribute("estadoPago", "PENDIENTE");
            req.getRequestDispatcher("/pagoenlinea.jsp").forward(req, res);
            return;
        }
        if (!pago.aprobado()) {
            req.setAttribute("estadoPago", pago.pendiente() ? "PENDIENTE" : "RECHAZADO");
            req.setAttribute("mensaje", pago.pendiente()
                    ? "Mercado Pago está procesando el pago (" + pago.detalle + "). Le confirmaremos al aprobarse."
                    : "El pago no fue aprobado (" + pago.detalle + "). No se registró ningún cobro en su reserva.");
            req.getRequestDispatcher("/pagoenlinea.jsp").forward(req, res);
            return;
        }
        try {
            Resultado resultado = registrar(id, pago);
            req.setAttribute("estadoPago", resultado.registrado ? "APROBADO" : "YA PAGADO");
            req.setAttribute("mensaje", resultado.mensaje);
            req.setAttribute("codigoBoleta", resultado.codigoBoleta);
            req.setAttribute("idCita", resultado.idCita > 0 ? resultado.idCita : null);
            if (resultado.registrado && resultado.idCita > 0) {
                permitirCita(req, resultado.idCita);
            }
            req.setAttribute("codigoReserva", resultado.idCita > 0 ? String.format(java.util.Locale.ROOT, "ART-RES-%05d", resultado.idCita) : null);
            req.getRequestDispatcher("/pagoenlinea.jsp").forward(req, res);
        } catch (IllegalStateException e) {
            // El pago se aprobó pero la reserva no es válida: queda el evento para revisión manual.
            EventoService.advertencia("Pagos", "Pago aprobado sin reserva válida: " + pago.referencia);
            req.setAttribute("mensaje", "Recibimos su pago, pero no pudimos asociarlo a la reserva. Comuníquese con la clínica indicando el pago " + id + ".");
            req.setAttribute("estadoPago", "PENDIENTE");
            req.getRequestDispatcher("/pagoenlinea.jsp").forward(req, res);
        }
    }

    private static final class Resultado {

        boolean registrado;
        String mensaje;
        String codigoBoleta;
        int idCita;
    }

    private Resultado registrar(String idPago, MercadoPagoService.Pago pago) {
        Resultado r = new Resultado();
        int idCita;
        try {
            idCita = Integer.parseInt(pago.referencia);
        } catch (RuntimeException e) {
            throw new IllegalStateException("Referencia de pago no válida");
        }
        r.idCita = idCita;
        Map<String, Object> datos = pagoDao.datosCobro(idCita);
        if (datos == null) {
            throw new IllegalStateException("La cita del pago no existe");
        }
        BigDecimal costo = (BigDecimal) datos.get("costo");
        if (pago.importe == null || pago.importe.compareTo(costo) != 0) {
            EventoService.advertencia("Pagos", "Importe del pago en línea no coincide con la cita " + idCita);
            throw new IllegalStateException("El importe pagado no coincide con el costo de la reserva");
        }
        Pago entidad = new Pago();
        entidad.setCita_idCita(idCita);
        entidad.setMetodoPago_idMetodo(METODO_MERCADO_PAGO);
        entidad.setCodigoTransaccion("MP:" + idPago);
        Comprobante boleta = new Comprobante();
        boleta.setSerie("B001");
        boleta.setNombreCliente(String.valueOf(datos.get("paciente")));
        boleta.setDniCliente(String.valueOf(datos.get("dni")));
        boolean nuevo = pagoDao.registrarPagoYComprobante(entidad, boleta);
        r.registrado = nuevo;
        if (nuevo) {
            pagoDao.confirmarCitaPagada(idCita);
            EventoService.info("Pagos", "Pago en línea aprobado para la cita " + idCita);
            r.codigoBoleta = boleta.getCodigoBoletaCompleto();
            r.mensaje = "Pago aprobado. Su reserva quedó pagada y la boleta fue emitida.";
        } else {
            r.mensaje = "La reserva ya tenía un pago registrado; no se cobró dos veces.";
            Comprobante existente = pagoDao.obtenerComprobantePorCita(idCita);
            r.codigoBoleta = existente == null ? null : existente.getCodigoBoletaCompleto();
        }
        return r;
    }

    /** URL absoluta del retorno; usa mp.base.url si está configurada. */
    static String urlRetorno(HttpServletRequest req, String accion) {
        String base = ConfigLoader.getProperty("mp.base.url");
        if (base == null || base.trim().isEmpty()) {
            String esquema = req.getScheme();
            int puerto = req.getServerPort();
            boolean estandar = ("http".equals(esquema) && puerto == 80) || ("https".equals(esquema) && puerto == 443);
            base = esquema + "://" + req.getServerName() + (estandar ? "" : ":" + puerto) + req.getContextPath();
        }
        return base.replaceAll("/+$", "") + "/PagoEnLinea?accion=" + accion;
    }

    @SuppressWarnings("unchecked")
    private static void permitirCita(HttpServletRequest req, int idCita) {
        HttpSession s = req.getSession();
        Object actual = s.getAttribute("citasPropias");
        java.util.Set<Integer> ids = actual instanceof java.util.Set
                ? (java.util.Set<Integer>) actual : new java.util.HashSet<Integer>();
        ids.add(idCita);
        s.setAttribute("citasPropias", ids);
    }

    private boolean propia(HttpServletRequest req, int idCita) {
        HttpSession s = req.getSession(false);
        if (s == null) {
            return false;
        }
        Object ids = s.getAttribute("citasPropias");
        Object creada = s.getAttribute("reservaIdCita");
        return (ids instanceof java.util.Set && ((java.util.Set<?>) ids).contains(idCita))
                || (creada != null && String.valueOf(idCita).equals(creada.toString()));
    }

    private static String leerCuerpo(HttpServletRequest req) {
        try {
            java.io.BufferedReader lector = req.getReader();
            StringBuilder sb = new StringBuilder();
            char[] buffer = new char[1024];
            int n;
            while ((n = lector.read(buffer)) != -1 && sb.length() < 8192) {
                sb.append(buffer, 0, n);
            }
            return sb.toString();
        } catch (IOException e) {
            return null;
        }
    }

    private void error(HttpServletRequest req, HttpServletResponse res, int estado, String mensaje)
            throws ServletException, IOException {
        res.setStatus(estado);
        req.setAttribute("error", mensaje);
        req.setAttribute("volverUrl", "consultareserva.jsp");
        req.getRequestDispatcher("/error.jsp").forward(req, res);
    }
}
