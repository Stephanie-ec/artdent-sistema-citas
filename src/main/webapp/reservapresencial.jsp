<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Registrar Cita Presencial | Centro Odontológico ArtDent</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <link rel="stylesheet" href="css/style.css">
    </head>
    <body class="d-flex flex-column min-vh-100 bg-light">
        <%
            HttpSession ses = request.getSession();
            String rolActual = (String) ses.getAttribute("TipoRol");
            if (rolActual == null || (!rolActual.equalsIgnoreCase("Secretaria") && !rolActual.equalsIgnoreCase("Administrador"))) {
                response.sendRedirect("iniciosesionerror.jsp");
                return;
            }
        %>

        <%@include file="NavPanel.jsp" %>

        <div class="d-flex flex-grow-1">
            <%@include file="Sidebar.jsp" %>

            <main class="container-fluid p-4 d-flex flex-column flex-grow-1">
                <div class="d-flex flex-wrap justify-content-between align-items-center mb-4 pb-2 border-bottom">
                    <div>
                        <h3 class="fw-bold mb-1" style="color: var(--artdent-primary);">
                            <i class="fa-solid fa-notes-medical me-2" style="color: var(--artdent-accent);"></i>Registrar Cita Presencial
                        </h3>
                        <p class="text-muted small mb-0">
                            Atención para recepción y ventanilla: registre pacientes que acuden físicamente o por vía telefónica.
                        </p>
                    </div>
                    <a href="ReservaController?accion=listarCitas" class="btn btn-outline-primary d-inline-flex align-items-center gap-1 shadow-sm px-3 mt-2 mt-md-0">
                        <i class="bi bi-arrow-left"></i> Volver a Citas
                    </a>
                </div>

                <div class="row justify-content-center">
                    <div class="col-lg-10 col-xl-9">
                        <div class="card shadow-sm border-0 rounded-4 overflow-hidden">
                            <div class="card-header bg-white py-3 border-bottom d-flex align-items-center justify-content-between">
                                <span class="fw-bold text-dark">
                                    <i class="bi bi-person-lines-fill me-2" style="color: var(--artdent-primary);"></i>Formulario de Atención Presencial
                                </span>
                                <span class="badge rounded-pill text-dark" style="background-color: var(--artdent-mint);">
                                    <i class="bi bi-shield-check me-1" style="color: var(--artdent-primary);"></i>Recepción ArtDent
                                </span>
                            </div>
                            <div class="card-body p-4">
                                <form action="CitaController" method="POST" id="formPresencial">
                                    <input type="hidden" name="accion" value="registrarPresencial">
                                    <input type="hidden" name="origen" value="Presencial">

                                    <!-- Sección 1: Datos del Paciente -->
                                    <div class="d-flex align-items-center mb-3 pb-2 border-bottom">
                                        <div class="rounded-circle d-flex align-items-center justify-content-center me-2 text-white fw-bold" style="width: 26px; height: 26px; background-color: var(--artdent-primary); font-size: 0.8rem;">1</div>
                                        <h6 class="fw-bold mb-0" style="color: var(--artdent-primary);">Datos del Paciente</h6>
                                    </div>

                                    <div class="row g-3 mb-4">
                                        <div class="col-md-4">
                                            <label for="dni" class="form-label fw-semibold">DNI del Paciente <span class="text-danger">*</span></label>
                                            <div class="input-group">
                                                <input type="text" class="form-control" id="dni" name="dni" 
                                                       placeholder="8 dígitos" maxlength="8" pattern="\d{8}" required>
                                                <button class="btn btn-primary" type="button" onclick="buscarPacienteRapido()" title="Consultar si ya existe">
                                                    <i class="bi bi-search"></i>
                                                </button>
                                            </div>
                                            <small id="dniFeedback" class="text-muted"></small>
                                        </div>

                                        <div class="col-md-4">
                                            <label for="nombre" class="form-label fw-semibold">Nombres <span class="text-danger">*</span></label>
                                            <input type="text" class="form-control" id="nombre" name="nombre" 
                                                   placeholder="Nombres completos" required>
                                        </div>

                                        <div class="col-md-4">
                                            <label for="apellido" class="form-label fw-semibold">Apellidos <span class="text-danger">*</span></label>
                                            <input type="text" class="form-control" id="apellido" name="apellido" 
                                                   placeholder="Apellidos completos" required>
                                        </div>

                                        <div class="col-md-6">
                                            <label for="telefono" class="form-label fw-semibold">Teléfono / Celular <span class="text-danger">*</span></label>
                                            <input type="tel" class="form-control" id="telefono" name="telefono" 
                                                   placeholder="9 dígitos" maxlength="9" pattern="\d{9}" required>
                                        </div>

                                        <div class="col-md-6">
                                            <label for="correo" class="form-label fw-semibold">Correo Electrónico (Notificación Automática)</label>
                                            <input type="email" class="form-control" id="correo" name="correo" 
                                                   placeholder="correo@ejemplo.com">
                                            <small class="text-muted">Se enviará el aviso de registro al correo del paciente.</small>
                                        </div>
                                    </div>

                                    <!-- Sección 2: Programación del Turno -->
                                    <div class="d-flex align-items-center mb-3 pb-2 border-bottom">
                                        <div class="rounded-circle d-flex align-items-center justify-content-center me-2 text-white fw-bold" style="width: 26px; height: 26px; background-color: var(--artdent-primary); font-size: 0.8rem;">2</div>
                                        <h6 class="fw-bold mb-0" style="color: var(--artdent-primary);">Programación del Turno Odontológico</h6>
                                    </div>

                                    <div class="row g-3 mb-4">
                                        <div class="col-md-6">
                                            <label for="idServicio" class="form-label fw-semibold">Servicio Dental <span class="text-danger">*</span></label>
                                            <select class="form-select" id="idServicio" name="idServicio" required onchange="actualizarPrecio()">
                                                <option value="" disabled selected>Seleccione un servicio...</option>
                                                <c:forEach var="serv" items="${servicios}">
                                                    <option value="${serv.idServicio}" data-precio="${serv.costo}">
                                                        ${serv.tipoServicio} - S/ ${serv.costo}
                                                    </option>
                                                </c:forEach>
                                            </select>
                                        </div>

                                        <div class="col-md-6">
                                            <label for="medico" class="form-label fw-semibold">Odontólogo Tratante <span class="text-danger">*</span></label>
                                            <select class="form-select" id="medico" name="medico" required>
                                                <option value="" disabled selected>Seleccione el odontólogo...</option>
                                                <c:forEach var="doc" items="${odontologos}">
                                                    <option value="${doc.idUsuario}">
                                                        Dr(a). ${doc.nombre} ${doc.apellido}
                                                    </option>
                                                </c:forEach>
                                            </select>
                                        </div>

                                        <div class="col-md-4">
                                            <label for="fecha" class="form-label fw-semibold">Fecha de Atención <span class="text-danger">*</span></label>
                                            <input type="date" class="form-control" id="fecha" name="fecha" required>
                                        </div>

                                        <div class="col-md-4">
                                            <label for="hora" class="form-label fw-semibold">Hora de Cita <span class="text-danger">*</span></label>
                                            <input type="time" class="form-control" id="hora" name="hora" required>
                                        </div>

                                        <div class="col-md-4">
                                            <label for="precio_consulta" class="form-label fw-semibold">Importe Base (S/)</label>
                                            <input type="number" step="0.01" class="form-control bg-light" id="precio_consulta" name="precio_consulta" value="0.00" readonly>
                                        </div>

                                        <div class="col-12">
                                            <label for="descripcion" class="form-label fw-semibold">Observaciones / Motivo de Consulta</label>
                                            <textarea class="form-control" id="descripcion" name="descripcion" rows="2" 
                                                      placeholder="Indique detalles de recepción presencial o motivo de la visita..."></textarea>
                                        </div>
                                    </div>

                                    <!-- Estado y Origen fijos informativos -->
                                    <div class="alert border-0 shadow-sm rounded-3 py-3 d-flex align-items-center mb-4" style="background-color: #edf7fa;">
                                        <i class="bi bi-info-circle-fill fs-4 me-3" style="color: var(--artdent-primary);"></i>
                                        <div class="small text-dark">
                                            <strong>Estado inicial de atención:</strong> Cita confirmada de inmediato (<span class="badge bg-success">Confirmado</span>) con origen <code>Presencial</code> y asignada a la secretaría en turno.
                                        </div>
                                    </div>

                                    <div class="d-flex justify-content-end gap-2">
                                        <a href="ReservaController?accion=listarCitas" class="btn btn-outline-secondary px-4">
                                            Cancelar
                                        </a>
                                        <button type="submit" class="btn btn-success px-4 fw-semibold shadow-sm">
                                            <i class="bi bi-check-circle me-1"></i>Confirmar y Agendar Cita Presencial
                                        </button>
                                    </div>
                                </form>
                            </div>
                        </div>
                    </div>
                </div>

            </main>
        </div>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
        <script>
            function actualizarPrecio() {
                var select = document.getElementById("idServicio");
                var opt = select.options[select.selectedIndex];
                var precio = opt.getAttribute("data-precio") || "0.00";
                document.getElementById("precio_consulta").value = parseFloat(precio).toFixed(2);
            }

            function buscarPacienteRapido() {
                var dni = document.getElementById("dni").value.trim();
                var feedback = document.getElementById("dniFeedback");
                if (dni.length !== 8) {
                    feedback.className = "text-danger";
                    feedback.innerText = "Ingrese un DNI válido de 8 dígitos.";
                    return;
                }
                feedback.className = "text-muted";
                feedback.innerText = "Buscando paciente...";

                fetch("PacienteController?dni=" + encodeURIComponent(dni))
                    .then(response => response.json())
                    .then(data => {
                        if (data && data.existe) {
                            document.getElementById("nombre").value = data.nombre || "";
                            document.getElementById("apellido").value = data.apellido || "";
                            document.getElementById("telefono").value = data.telefono || "";
                            document.getElementById("correo").value = data.correo || "";
                            feedback.className = "text-success fw-semibold";
                            feedback.innerText = "✓ Paciente registrado encontrado.";
                        } else {
                            feedback.className = "text-primary fw-semibold";
                            feedback.innerText = "Paciente nuevo. Ingrese los datos para su registro.";
                        }
                    })
                    .catch(err => {
                        feedback.className = "text-muted";
                        feedback.innerText = "No se pudo consultar automáticamente. Complete los datos manualmente.";
                    });
            }
        </script>
    </body>
</html>
