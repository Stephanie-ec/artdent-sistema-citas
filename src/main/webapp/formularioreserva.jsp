<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@page import="java.util.List"%>
<%@page import="pe.edu.utp.dao.ServicioDao"%>
<%@page import="pe.edu.utp.daoImpl.ServicioDaoImpl"%>
<%@page import="pe.edu.utp.entity.Servicio"%>
<%@page import="pe.edu.utp.dao.UsuarioDao"%>
<%@page import="pe.edu.utp.daoImpl.UsuarioDaoImpl"%>
<%@page import="pe.edu.utp.entity.Usuario"%>

<%
    HttpSession sesionForm = request.getSession(false);
    Integer idUserForm = (sesionForm != null) ? (Integer) sesionForm.getAttribute("idUsuario") : null;
%>
<div class="card shadow-sm border-0 mb-4" style="border-radius: 16px; overflow: hidden;">
    <div class="p-4 text-center text-white" style="background: linear-gradient(135deg, var(--artdent-primary), var(--artdent-primary-hover)); border-bottom: 3px solid var(--artdent-accent);">
        <h2 class="fw-bold mb-1 text-white">Reservar Cita Odontológica</h2>
        <p class="mb-0 text-white-50 small">Centro Odontológico Art Dent &bull; Sedes Chosica y Chaclacayo</p>
    </div>

    <div class="p-4 p-md-5 bg-white">
        <form action="ReservaController" method="POST">
            <input type="hidden" name="idUsuario" id="idUsuario" value="<%= (idUserForm != null ? idUserForm : "") %>">
            
            <div class="row g-3 mb-3">
                <div class="col-md-6">
                    <label for="nombre" class="form-label fw-semibold">Nombre <span class="text-danger">*</span></label>
                    <input type="text" class="form-control" id="nombre" name="nombre" placeholder="Ingrese su nombre" required>
                </div>
                <div class="col-md-6">
                    <label for="apellido" class="form-label fw-semibold">Apellido <span class="text-danger">*</span></label>
                    <input type="text" class="form-control" id="apellido" name="apellido" placeholder="Ingrese su apellido" required>
                </div>
            </div>

            <div class="row g-3 mb-3">
                <div class="col-md-6">
                    <label for="dni" class="form-label fw-semibold">DNI <span class="text-danger">*</span></label>
                    <input type="text" class="form-control" id="dni" name="dni" placeholder="8 dígitos" minlength="8" maxlength="8" pattern="\d{8}" required>
                </div>
                <div class="col-md-6">
                    <label for="telefono" class="form-label fw-semibold">Celular <span class="text-danger">*</span></label>
                    <input type="tel" class="form-control" id="telefono" name="telefono" placeholder="9 dígitos" minlength="9" maxlength="9" pattern="\d{9}" required>
                </div>
            </div>

            <div class="mb-3">
                <label for="email" class="form-label fw-semibold">Correo Electrónico <span class="text-danger">*</span></label>
                <input type="email" class="form-control" id="email" name="email" placeholder="correo@ejemplo.com" required>
            </div>

            <div class="mb-3">
                <label for="motivo" class="form-label fw-semibold">Motivo (Servicio) <span class="text-danger">*</span></label>
                <select class="form-select" id="motivo" name="motivo" onchange="actualizarPrecio()" required>
                    <option value="" selected disabled>Seleccionar Tratamiento...</option>
                    <%
                        try {
                            ServicioDao servicioDao = new ServicioDaoImpl();
                            List<Servicio> serviciosList = servicioDao.listarServicios();
                            request.setAttribute("serviciosList", serviciosList);

                            UsuarioDao usuarioDao = new UsuarioDaoImpl();
                            List<Usuario> doctoresList = usuarioDao.obtenerMedicosDisponibles();
                            request.setAttribute("doctoresList", doctoresList);
                        } catch(Exception e) {}
                    %>
                    <c:forEach var="serv" items="${serviciosList}">
                        <option value="${serv.tipoServicio}" data-costo="${serv.costo}" data-id="${serv.idServicio}">
                            ${serv.tipoServicio}
                        </option>
                    </c:forEach>
                </select>
            </div>

            <input type="hidden" name="precio_consulta" id="precio_consulta">
            <input type="hidden" name="idServicio" id="idServicio">

            <div class="mb-3">
                <label for="medico" class="form-label fw-semibold">Médico Asignado</label>
                <select class="form-select" id="medico" name="medico">
                    <c:forEach var="doc" items="${doctoresList}">
                        <option value="${doc.idUsuario}">Dr(a). ${doc.apellido}, ${doc.nombre}</option>
                    </c:forEach>
                </select>
            </div>

            <div class="row g-3 mb-3">
                <div class="col-md-6">
                    <label for="fecha" class="form-label fw-semibold">Fecha de la Reserva <span class="text-danger">*</span></label>
                    <input type="date" class="form-control" id="fecha" name="fecha" required>
                </div>
                <div class="col-md-6">
                    <label for="hora" class="form-label fw-semibold">Hora de la Reserva <span class="text-danger">*</span></label>
                    <input type="time" class="form-control" id="hora" name="hora" required>
                </div>
            </div>

            <div class="p-3 bg-brand-light rounded-3 border mb-3">
                <div class="d-flex justify-content-between align-items-center">
                    <span class="text-muted fw-bold small text-uppercase">Total Referencial:</span>
                    <div class="d-flex align-items-center">
                        <span class="fs-4 fw-bold text-brand-dark me-1">S/</span>
                        <input type="number" class="form-control-plaintext fs-4 fw-bold text-brand-primary p-0 text-end" 
                               id="pago" name="pago" readonly value="0.00" style="width: 120px;">
                    </div>
                </div>
            </div>

            <div class="mb-3">
                <label for="descripcion" class="form-label fw-semibold">Descripción o Síntomas</label>
                <textarea class="form-control" id="descripcion" name="descripcion" rows="3" placeholder="Detalles de tu consulta..."></textarea>
            </div>

            <div class="form-check mb-4">
                <input class="form-check-input" type="checkbox" id="aceptar-condiciones" name="aceptar-condiciones" required checked>
                <label class="form-check-label small text-muted" for="aceptar-condiciones">
                    Acepto los términos y condiciones de servicio en línea
                </label>
            </div>

            <button type="submit" class="btn btn-primary btn-lg w-100 fw-bold rounded-pill shadow-sm">
                <i class="bi bi-calendar-check me-2"></i> Confirmar Reserva
            </button>
        </form>
    </div>
</div>

<script>
    function actualizarPrecio() {
        const motivoSelect = document.getElementById("motivo");
        if (!motivoSelect || motivoSelect.selectedIndex < 0) return;
        const selectedOption = motivoSelect.options[motivoSelect.selectedIndex];
        if (!selectedOption) return;

        const costo = selectedOption.getAttribute("data-costo");
        const idServicio = selectedOption.getAttribute("data-id");
        const pagoField = document.getElementById("pago");
        const precioConsultaField = document.getElementById("precio_consulta");
        const idServicioField = document.getElementById("idServicio");

        if (costo) {
            pagoField.value = parseFloat(costo).toFixed(2);
            precioConsultaField.value = costo;
            idServicioField.value = idServicio;
        } else {
            pagoField.value = "0.00";
            precioConsultaField.value = "";
            idServicioField.value = "";
        }
    }
</script>
