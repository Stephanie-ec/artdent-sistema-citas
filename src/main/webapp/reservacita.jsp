<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reserva de Cita - Art Dent</title>
    <!-- Bootstrap 5.3 & Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body class="d-flex flex-column min-vh-100 bg-brand-light">

    <%@include file="header.jsp" %>

    <div class="container flex-grow-1 my-5">
        <div class="row justify-content-center">
            <div class="col-12 col-lg-8">
                <div class="card shadow-sm border-0" style="border-radius: 16px; overflow: hidden;">
                    <div class="p-4 text-center text-white" style="background: linear-gradient(135deg, var(--artdent-primary), var(--artdent-primary-hover)); border-bottom: 3px solid var(--artdent-accent);">
                        <h2 class="fw-bold mb-1 text-white">Reservar Cita Odontológica</h2>
                        <p class="mb-0 text-white-50 small">Centro Odontológico Art Dent &bull; Sedes Chosica y Chaclacayo</p>
                    </div>

                    <div class="p-4 p-md-5 bg-white">
                        <form action="ReservaController" method="POST">
                            <input type="hidden" name="idUsuario" id="idUsuario" value="<%= (request.getSession(false) != null && request.getSession(false).getAttribute("idUsuario") != null) ? request.getSession(false).getAttribute("idUsuario") : "" %>">
                            
                            <div class="row g-3 mb-3">
                                <div class="col-md-6">
                                    <label for="nombre" class="form-label fw-semibold">Nombre <span class="text-danger">*</span></label>
                                    <input type="text" class="form-control" id="nombre" name="nombre"
                                           placeholder="Ingrese su nombre" value="${nombre}" required>
                                </div>
                                <div class="col-md-6">
                                    <label for="apellido" class="form-label fw-semibold">Apellido <span class="text-danger">*</span></label>
                                    <input type="text" class="form-control" id="apellido" name="apellido"
                                           placeholder="Ingrese su apellido" value="${apellido}" required>
                                </div>
                            </div>

                            <div class="row g-3 mb-3">
                                <div class="col-md-6">
                                    <label for="dni" class="form-label fw-semibold">DNI <span class="text-danger">*</span></label>
                                    <div class="input-group">
                                        <input type="text" class="form-control" id="dni" name="dni" 
                                               placeholder="8 dígitos" maxlength="8" 
                                               value="${param.dni}" required 
                                               onkeyup="if (event.keyCode === 13) buscarPaciente();"
                                               onblur="buscarPaciente();">
                                        <button class="btn btn-outline-primary" type="button" onclick="buscarPaciente();">
                                            <i class="bi bi-search"></i>
                                        </button>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <label for="telefono" class="form-label fw-semibold">Celular <span class="text-danger">*</span></label>
                                    <input type="tel" class="form-control" id="telefono" name="telefono"
                                           placeholder="9 dígitos" minlength="9" maxlength="9" 
                                           pattern="[0-9]{9}" value="${telefono}" required>
                                </div>
                            </div>

                            <div class="mb-3">
                                <label for="correo" class="form-label fw-semibold">Correo Electrónico <span class="text-danger">*</span></label>
                                <input type="email" class="form-control" id="correo" name="correo" 
                                       placeholder="correo@ejemplo.com" value="${correo}" required>
                            </div>

                            <div class="row g-3 mb-3">
                                <div class="col-md-6">
                                    <label for="fecha" class="form-label fw-semibold">Fecha de la Reserva <span class="text-danger">*</span></label>
                                    <input type="date" class="form-control" id="fecha" name="fecha" required onchange="verificarCampos();">
                                </div>
                                <div class="col-md-6">
                                    <label for="hora" class="form-label fw-semibold">Hora de Cita <span class="text-danger">*</span></label>
                                    <input type="time" class="form-control" id="hora" name="hora" onchange="ajustarHora();verificarCampos();" min="08:00" max="20:00" required>
                                </div>
                            </div>

                            <div class="mb-3">
                                <label for="motivo" class="form-label fw-semibold">Motivo (Servicio) <span class="text-danger">*</span></label>
                                <select class="form-select" id="motivo" name="motivo" onchange="cargarDoctores();actualizarPrecio();verificarCampos();" required>
                                    <option value="" selected disabled>Seleccionar Tratamiento...</option>
                                    <c:forEach var="servicio" items="${servicios}">
                                        <option value="${servicio.idServicio}" data-costo="${servicio.costo}" data-id="${servicio.idServicio}">
                                            ${servicio.tipoServicio}
                                        </option>
                                    </c:forEach>
                                </select>
                            </div>

                            <input type="hidden" name="precio_consulta" id="precio_consulta">
                            <input type="hidden" name="idServicio" id="idServicio">

                            <div class="mb-3" id="medico-container" style="display:none;">
                                <div class="p-3 bg-brand-light rounded-3 border border-brand-primary">
                                    <label for="medico" class="form-label fw-bold text-brand-primary mb-1">
                                        <i class="bi bi-person-check-fill me-1"></i> Especialista Odontólogo Asignado
                                    </label>
                                    <select class="form-select border-brand-primary" id="medico" name="medico">
                                        <option value="" selected disabled>Seleccionar Odontólogo...</option>
                                    </select>
                                </div>
                            </div>

                            <div class="p-3 bg-brand-light rounded-3 border mb-3">
                                <div class="d-flex justify-content-between align-items-center">
                                    <span class="text-muted fw-bold small text-uppercase">Costo Referencial:</span>
                                    <div class="d-flex align-items-center">
                                        <span class="fs-4 fw-bold text-brand-dark me-1">S/</span>
                                        <input type="text" class="form-control-plaintext fs-4 fw-bold text-brand-primary p-0 text-end" 
                                               id="pago" name="pago" readonly value="0.00" style="width: 100px;">
                                    </div>
                                </div>
                            </div>

                            <div class="mb-3">
                                <label for="descripcion" class="form-label fw-semibold">Notas o Síntomas Adicionales</label>
                                <textarea class="form-control" id="descripcion" name="descripcion" rows="3" placeholder="Detalles o molestias previas..."></textarea>
                            </div>

                            <div class="form-check mb-4">
                                <input class="form-check-input" type="checkbox" id="aceptar-condiciones" name="aceptar-condiciones" required checked>
                                <label class="form-check-label small text-muted" for="aceptar-condiciones">
                                    Acepto los términos de servicio y la política de privacidad de Art Dent
                                </label>
                            </div>

                            <button type="submit" class="btn btn-primary btn-lg w-100 fw-bold rounded-pill shadow-sm">
                                <i class="bi bi-calendar-check me-2"></i> Confirmar y Reservar Cita
                            </button>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <%@include file="footer.jsp" %>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

    <script>
        function verificarCampos() {
            var motivo = document.getElementById('motivo').value;
            var fecha = document.getElementById('fecha').value;
            var hora = document.getElementById('hora').value;

            var medicoSelect = document.getElementById('medico');
            medicoSelect.innerHTML = '<option value="" selected disabled>Seleccionar Odontólogo...</option>';

            if (motivo && fecha && hora) {
                cargarDoctores();
                document.getElementById('medico-container').style.display = 'block';
            } else {
                document.getElementById('medico-container').style.display = 'none';
            }
        }

        document.getElementById('hora').addEventListener('change', function () {
            var medicoSelect = document.getElementById('medico');
            medicoSelect.value = "";
            verificarCampos();
        });

        document.getElementById('fecha').addEventListener('change', verificarCampos);
        document.getElementById('motivo').addEventListener('change', verificarCampos);

        function cargarDoctores() {
            var idServicio = document.getElementById('motivo').value;
            var fecha = document.getElementById('fecha').value;
            var hora = document.getElementById('hora').value;
            if (!hora || !fecha || !idServicio) return;

            var xhr = new XMLHttpRequest();
            xhr.open('GET', 'ServicioController?action=cargarDoctores&motivo=' + idServicio + '&hora=' + hora + '&fecha=' + fecha, true);
            xhr.onreadystatechange = function () {
                if (xhr.readyState === 4 && xhr.status === 200) {
                    var doctoresSelect = document.getElementById('medico');
                    doctoresSelect.innerHTML = '<option value="" selected disabled>Seleccionar Odontólogo...</option>';
                    doctoresSelect.innerHTML += xhr.responseText;
                }
            };
            xhr.send();
        }

        function buscarPaciente() {
            const dni = document.getElementById('dni').value.trim();
            if (dni.length === 8) {
                const xhr = new XMLHttpRequest();
                xhr.open('GET', 'PacienteController?action=complet&dni=' + dni, true);
                xhr.onreadystatechange = function () {
                    if (xhr.readyState == 4 && xhr.status == 200) {
                        try {
                            const parser = new DOMParser();
                            const doc = parser.parseFromString(xhr.responseText, 'text/html');
                            const nombre = doc.getElementById('nombre') ? doc.getElementById('nombre').value : '';
                            const apellido = doc.getElementById('apellido') ? doc.getElementById('apellido').value : '';
                            const correo = doc.getElementById('correo') ? doc.getElementById('correo').value : '';
                            const telefono = doc.getElementById('telefono') ? doc.getElementById('telefono').value : '';

                            if (nombre) document.getElementById('nombre').value = nombre;
                            if (apellido) document.getElementById('apellido').value = apellido;
                            if (correo) document.getElementById('correo').value = correo;
                            if (telefono) document.getElementById('telefono').value = telefono;
                        } catch(e) {
                            console.error(e);
                        }
                    }
                };
                xhr.send();
            }
        }

        function ajustarHora() {
            var horaInput = document.getElementById('hora');
            var valorHora = horaInput.value;
            if (!valorHora) return;

            var partesHora = valorHora.split(':');
            var horas = parseInt(partesHora[0]);
            var minutos = parseInt(partesHora[1]);

            minutos = Math.round(minutos / 15) * 15;
            if (minutos === 60) {
                minutos = 0;
                horas++;
            }
            if (minutos < 10) minutos = '0' + minutos;
            if (horas < 10) horas = '0' + horas;

            if (horas >= 8 && horas <= 20) {
                horaInput.value = horas + ':' + minutos;
            } else {
                alert("La hora seleccionada debe estar entre las 08:00 y las 20:00.");
                horaInput.value = "";
            }
        }

        function actualizarPrecio() {
            const select = document.getElementById('motivo');
            if (!select || select.selectedIndex < 0) return;
            const selectedOption = select.options[select.selectedIndex];
            if (!selectedOption) return;

            const costo = selectedOption.getAttribute('data-costo') || "0.00";
            const idServicio = selectedOption.getAttribute('data-id') || selectedOption.value;

            document.getElementById('precio_consulta').value = costo;
            document.getElementById('idServicio').value = idServicio;
            document.getElementById('pago').value = parseFloat(costo).toFixed(2);
        }

        document.addEventListener('DOMContentLoaded', function () {
            const fechaInput = document.getElementById('fecha');
            if (fechaInput) {
                const hoy = new Date().toISOString().split('T')[0];
                fechaInput.min = hoy;
            }
        });
    </script>
</body>
</html>
