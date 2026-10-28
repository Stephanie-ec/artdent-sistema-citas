<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html> 
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reserva de Cita Web - Art Dent</title>
    <!-- Bootstrap 5.3 & Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Open+Sans:wght@400;600;700&family=Roboto:wght@500;700;900&display=swap" rel="stylesheet">
    <!-- Hoja de Estilos Oficial de Marca Art Dent -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">

    <style>
        .booking-card {
            border: 1px solid var(--artdent-border);
            border-radius: 16px;
            overflow: hidden;
            box-shadow: var(--artdent-shadow-md);
            background: #ffffff;
        }

        .booking-header {
            background: linear-gradient(135deg, var(--artdent-primary), var(--artdent-primary-hover));
            color: #ffffff;
            padding: 2rem;
            text-align: center;
            border-bottom: 3px solid var(--artdent-accent);
        }

        .step-pill {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            font-size: 0.8rem;
            font-weight: 700;
            padding: 4px 12px;
            border-radius: 20px;
            background: rgba(255, 255, 255, 0.2);
            color: #ffffff;
        }
    </style>
</head>

<body class="bg-brand-light">
    <!-- Navbar Oficial -->
    <%@include file="header.jsp"%>

    <main class="container py-5">
        <div class="row justify-content-center">
            <div class="col-12 col-lg-9">
                <div class="card booking-card">
                    <!-- Cabecera Institucional del Formulario -->
                    <div class="booking-header">
                        <div class="d-flex justify-content-center gap-2 mb-2 flex-wrap">
                            <span class="step-pill"><i class="bi bi-1-circle-fill"></i> Datos</span>
                            <span class="step-pill"><i class="bi bi-2-circle-fill"></i> Tratamiento</span>
                            <span class="step-pill"><i class="bi bi-3-circle-fill"></i> Confirmación</span>
                        </div>
                        <h2 class="h3 fw-bold m-0 text-white">Reserva tu Cita Odontológica</h2>
                        <p class="text-white-50 small m-0 mt-1">Completa tus datos personales y selecciona el horario de tu preferencia</p>
                    </div>

                    <div class="card-body p-4 p-md-5">
                        <form action="CitaController" method="POST">
                            <!-- Sección 1: Identificación y Paciente -->
                            <h5 class="fw-bold text-brand-dark mb-3 pb-2 border-bottom d-flex align-items-center gap-2">
                                <i class="bi bi-person-badge text-brand-primary"></i> 1. Datos del Paciente
                            </h5>

                            <div class="row g-3 mb-4">
                                <div class="col-12 col-md-6">
                                    <label for="dni" class="form-label fw-semibold">DNI del Paciente <span class="text-danger">*</span></label>
                                    <div class="input-group">
                                        <span class="input-group-text"><i class="bi bi-card-text"></i></span>
                                        <input type="text" class="form-control" id="dni" name="dni" 
                                               placeholder="8 dígitos" maxlength="8" 
                                               value="${param.dni}" required 
                                               onkeyup="if (event.keyCode === 13) buscarPaciente();"
                                               onblur="buscarPaciente();">
                                        <button class="btn btn-outline-primary" type="button" onclick="buscarPaciente();" title="Buscar paciente registrado">
                                            <i class="bi bi-search"></i>
                                        </button>
                                    </div>
                                    <small class="text-muted" style="font-size: 0.75rem;">Presiona Enter o la lupa si ya te has atendido antes</small>
                                </div>

                                <div class="col-12 col-md-6">
                                    <label for="correo" class="form-label fw-semibold">Correo Electrónico <span class="text-danger">*</span></label>
                                    <div class="input-group">
                                        <span class="input-group-text"><i class="bi bi-envelope"></i></span>
                                        <input type="email" class="form-control" id="correo" name="correo" 
                                               placeholder="correo@ejemplo.com" value="${correo}" required>
                                    </div>
                                </div>

                                <div class="col-12 col-md-6">
                                    <label for="nombre" class="form-label fw-semibold">Nombres <span class="text-danger">*</span></label>
                                    <input type="text" class="form-control" id="nombre" name="nombre"
                                           placeholder="Ingresa tus nombres" value="${nombre}" required>
                                </div>

                                <div class="col-12 col-md-6">
                                    <label for="apellido" class="form-label fw-semibold">Apellidos <span class="text-danger">*</span></label>
                                    <input type="text" class="form-control" id="apellido" name="apellido"
                                           placeholder="Ingresa tus apellidos" value="${apellido}" required>
                                </div>

                                <div class="col-12 col-md-6">
                                    <label for="telefono" class="form-label fw-semibold">Celular / WhatsApp <span class="text-danger">*</span></label>
                                    <div class="input-group">
                                        <span class="input-group-text"><i class="bi bi-phone"></i></span>
                                        <input type="tel" class="form-control" id="telefono" name="telefono"
                                               placeholder="9 dígitos" minlength="9" maxlength="9" 
                                               pattern="[0-9]{9}" value="${telefono}" required>
                                    </div>
                                </div>
                            </div>

                            <!-- Sección 2: Elección de Tratamiento y Fecha -->
                            <h5 class="fw-bold text-brand-dark mb-3 pb-2 border-bottom d-flex align-items-center gap-2">
                                <i class="bi bi-calendar-event text-brand-primary"></i> 2. Tratamiento y Horario
                            </h5>

                            <div class="row g-3 mb-4">
                                <div class="col-12 col-md-6">
                                    <label for="motivo" class="form-label fw-semibold">Servicio o Tratamiento <span class="text-danger">*</span></label>
                                    <select class="form-select" id="motivo" name="motivo" onchange="cargarDoctores();actualizarPrecio();verificarCampos();" required>
                                        <option value="" selected disabled>Seleccionar Tratamiento...</option>
                                        <c:forEach var="servicio" items="${servicios}">
                                            <option value="${servicio.idServicio}" data-costo="${servicio.costo}" data-id="${servicio.idServicio}">
                                                ${servicio.tipoServicio}
                                            </option>
                                        </c:forEach>
                                    </select>
                                </div>

                                <div class="col-12 col-md-3">
                                    <label for="fecha" class="form-label fw-semibold">Fecha <span class="text-danger">*</span></label>
                                    <input type="date" class="form-control" id="fecha" name="fecha" required onchange="verificarCampos();">
                                </div>

                                <div class="col-12 col-md-3">
                                    <label for="hora" class="form-label fw-semibold">Hora <span class="text-danger">*</span></label>
                                    <input type="time" class="form-control" id="hora" name="hora" onchange="ajustarHora();verificarCampos();" min="08:00" max="20:00" required>
                                </div>

                                <!-- Selector de Especialista Dinámico -->
                                <div class="col-12" id="medico-container" style="display:none;">
                                    <div class="p-3 bg-brand-light border rounded-3 border-brand-primary">
                                        <label for="medico" class="form-label fw-bold text-brand-primary mb-1">
                                            <i class="bi bi-person-check-fill me-1"></i> Especialista Odontólogo Asignado
                                        </label>
                                        <select class="form-select border-brand-primary" id="medico" name="medico">
                                            <option value="" selected disabled>Seleccionar Especialista...</option>
                                        </select>
                                        <small class="text-muted d-block mt-1">Especialistas disponibles para el servicio y horario seleccionado.</small>
                                    </div>
                                </div>
                            </div>

                            <!-- Sección 3: Resumen de Inversión y Pago Desacoplado -->
                            <div class="card bg-brand-light border-0 p-4 mb-4" style="border-radius: 12px;">
                                <div class="row align-items-center">
                                    <div class="col-12 col-md-6 text-center text-md-start mb-3 mb-md-0">
                                        <span class="text-muted text-uppercase small fw-bold d-block">Inversión Referencial</span>
                                        <div class="d-inline-flex align-items-baseline">
                                            <span class="fs-4 fw-bold text-brand-dark me-1">S/</span>
                                            <input type="text" class="form-control-plaintext fs-2 fw-bold text-brand-primary p-0" 
                                                   id="pago" name="pago" readonly value="0.00" style="max-width: 140px; display: inline-block;">
                                        </div>
                                    </div>
                                    <div class="col-12 col-md-6">
                                        <div class="alert alert-artdent-mint py-2 px-3 small mb-0 border-0">
                                            <i class="bi bi-info-circle-fill text-brand-primary me-1"></i>
                                            <strong>Nota informativa:</strong> La cita se genera en estado <b>En espera</b>. Podrás efectuar el pago en ventanilla física al acudir a tu consulta o en línea.
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <input type="hidden" name="precio_consulta" id="precio_consulta">
                            <input type="hidden" name="idServicio" id="idServicio">
                            <input type="hidden" name="nombreServicio" id="nombreServicio">
                            <input type="hidden" name="descripcion" id="descripcion" value="Reserva Web - En espera">

                            <!-- Botón de Envío -->
                            <div class="d-grid gap-2">
                                <button type="submit" id="btnConfirmarReserva" class="btn btn-primary btn-lg py-3 fw-bold rounded-pill shadow">
                                    <i class="bi bi-calendar-check me-2"></i> Confirmar y Generar Código de Reserva
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </main>

    <!-- Scripts de Reserva -->
    <script>
        function verificarCampos() {
            var motivo = document.getElementById('motivo').value;
            var fecha = document.getElementById('fecha').value;
            var hora = document.getElementById('hora').value;

            var medicoSelect = document.getElementById('medico');
            medicoSelect.innerHTML = '<option value="" selected disabled>Seleccionar Especialista...</option>';

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
                    doctoresSelect.innerHTML = '<option value="" selected disabled>Seleccionar Especialista...</option>';
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
                alert("La hora de atención debe ser entre las 08:00 y las 20:00.");
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
            const nombre = selectedOption.text.trim();

            document.getElementById('precio_consulta').value = costo;
            document.getElementById('idServicio').value = idServicio;
            document.getElementById('nombreServicio').value = nombre;
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

    <!-- Footer Oficial -->
    <%@include file="footer.jsp"%>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>