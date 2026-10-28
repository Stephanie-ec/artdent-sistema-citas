<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Disponibilidad Médica | Centro Odontológico ArtDent</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    <link rel="stylesheet" href="css/style.css">
</head>
<body class="d-flex flex-column min-vh-100 bg-light">
    <%
    HttpSession misesion = request.getSession();
    String usuario = (String) request.getSession().getAttribute("Nombre");
    if (usuario == null) {
        response.sendRedirect("iniciosesionerror.jsp");
        return;
    }
    %>

    <%@include file="NavPanel.jsp" %>

    <div class="container-fluid flex-grow-1 d-flex">
        <div class="row flex-grow-1 w-100 g-0">
            <!-- Sidebar Admin -->
            <%@include file="ADMPSlidebar.jsp"%>

            <!-- Main Content -->
            <main class="col-md-9 ms-sm-auto col-lg-10 p-4">
                <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pb-3 mb-4 border-bottom">
                    <div>
                        <h2 class="h3 fw-bold mb-1" style="color: var(--artdent-primary);">
                            <i class="bi bi-clock-history me-2" style="color: var(--artdent-accent);"></i>Gestión de Disponibilidad Médica
                        </h2>
                        <p class="text-muted small mb-0">Asignación de turnos de atención y especialidades clínicas por odontólogo tratante.</p>
                    </div>
                </div>

                <c:if test="${param.guardado == 'ok'}">
                    <div class="alert border-0 shadow-sm rounded-4 mb-4 d-flex align-items-center" role="alert" style="background-color: var(--artdent-mint);">
                        <i class="bi bi-check-circle-fill me-3 fs-4" style="color: var(--artdent-primary);"></i>
                        <div class="text-dark">
                            <strong>¡Disponibilidad médica actualizada exitosamente!</strong> Los horarios y tratamientos autorizados rigen de inmediato en la reserva web y presencial.
                        </div>
                        <button type="button" class="btn-close ms-auto" data-bs-dismiss="alert" aria-label="Close"></button>
                    </div>
                </c:if>

                <!-- Selector de Odontólogo -->
                <div class="card border-0 shadow-sm rounded-4 overflow-hidden mb-4">
                    <div class="card-body p-4">
                        <form method="get" action="UsuarioController" class="row align-items-center g-3">
                            <input type="hidden" name="action" value="disponibilidad">
                            <div class="col-md-4">
                                <label for="selectOdontologo" class="form-label fw-bold text-dark">Seleccionar Odontólogo:</label>
                                <select id="selectOdontologo" name="id" class="form-select form-select-lg shadow-sm" onchange="this.form.submit()">
                                    <c:forEach var="med" items="${odontologos}">
                                        <option value="${med.idUsuario}" ${odontologo != null && odontologo.idUsuario == med.idUsuario ? 'selected' : ''}>
                                            Dr(a). ${med.nombre} ${med.apellido}
                                        </option>
                                    </c:forEach>
                                </select>
                            </div>
                            <div class="col-md-8">
                                <c:if test="${odontologo != null}">
                                    <div class="p-3 bg-white rounded-3 border shadow-sm">
                                        <div class="row align-items-center">
                                            <div class="col-sm-5">
                                                <small class="text-muted d-block">Médico Tratante</small>
                                                <strong class="text-dark fs-6">
                                                    <i class="bi bi-person-badge-fill me-1" style="color: var(--artdent-primary);"></i>Dr(a). ${odontologo.nombre} ${odontologo.apellido}
                                                </strong>
                                            </div>
                                            <div class="col-sm-3">
                                                <small class="text-muted d-block">DNI</small>
                                                <span class="font-monospace fw-semibold">${odontologo.dni}</span>
                                            </div>
                                            <div class="col-sm-4">
                                                <small class="text-muted d-block">Correo</small>
                                                <span class="small text-truncate d-block">${odontologo.correoElectronico}</span>
                                            </div>
                                        </div>
                                    </div>
                                </c:if>
                            </div>
                        </form>
                    </div>
                </div>

                <c:if test="${odontologo != null}">
                    <form action="UsuarioController?action=guardarDisponibilidad" method="post">
                        <input type="hidden" name="idUsuario" value="${odontologo.idUsuario}">

                        <div class="row g-4">
                            <!-- Horarios Semanales -->
                            <div class="col-lg-5">
                                <div class="card border-0 shadow-sm rounded-4 h-100 overflow-hidden">
                                    <div class="card-header py-3 text-white d-flex justify-content-between align-items-center" style="background: linear-gradient(135deg, var(--artdent-primary), #268da9);">
                                        <span class="fw-bold"><i class="bi bi-calendar-week me-2"></i>Días y Horarios de Atención</span>
                                        <span class="badge rounded-pill text-dark" style="background-color: var(--artdent-mint);">Semanal</span>
                                    </div>
                                    <div class="card-body p-4">
                                        <p class="text-muted small mb-3">Indique las jornadas en las que el odontólogo atiende en las sedes de ArtDent:</p>
                                        
                                        <div class="list-group">
                                            <c:forEach var="horario" items="${todosHorarios}">
                                                <c:set var="estaAsignado" value="false" />
                                                <c:forEach var="hId" items="${horariosAsignados}">
                                                    <c:if test="${hId == horario.idHorario}">
                                                        <c:set var="estaAsignado" value="true" />
                                                    </c:if>
                                                </c:forEach>

                                                <label class="list-group-item d-flex justify-content-between align-items-center p-3 border rounded-3 mb-2 shadow-sm">
                                                    <div class="form-check">
                                                        <input class="form-check-input me-2" type="checkbox" name="horarios" value="${horario.idHorario}" id="horario_${horario.idHorario}" ${estaAsignado ? 'checked' : ''}>
                                                        <label class="form-check-label fw-bold text-dark" for="horario_${horario.idHorario}">
                                                            ${horario.diaSemana}
                                                        </label>
                                                    </div>
                                                    <span class="badge rounded-pill text-dark" style="background-color: var(--artdent-mint);">
                                                        <i class="bi bi-clock me-1" style="color: var(--artdent-primary);"></i>${horario.horaInicio} - ${horario.horaFinal}
                                                    </span>
                                                </label>
                                            </c:forEach>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <!-- Servicios que Realiza -->
                            <div class="col-lg-7">
                                <div class="card border-0 shadow-sm rounded-4 h-100 overflow-hidden d-flex flex-column">
                                    <div class="card-header py-3 text-white d-flex justify-content-between align-items-center" style="background: linear-gradient(135deg, var(--artdent-primary), #268da9);">
                                        <span class="fw-bold"><i class="bi bi-heart-pulse-fill me-2"></i>Tratamientos Autorizados</span>
                                        <span class="badge rounded-pill text-dark" style="background-color: var(--artdent-mint);">Especialidades</span>
                                    </div>
                                    <div class="card-body p-4 flex-grow-1">
                                        <p class="text-muted small mb-3">Seleccione los tratamientos clínicos que este odontólogo está facultado para prestar:</p>
                                        
                                        <div class="row g-3">
                                            <c:forEach var="serv" items="${todosServicios}">
                                                <c:set var="servAsignado" value="false" />
                                                <c:forEach var="sId" items="${serviciosAsignados}">
                                                    <c:if test="${sId == serv.idServicio}">
                                                        <c:set var="servAsignado" value="true" />
                                                    </c:if>
                                                </c:forEach>

                                                <div class="col-md-6">
                                                    <div class="p-3 border rounded-3 bg-white h-100 d-flex flex-column justify-content-between shadow-sm">
                                                        <div class="form-check">
                                                            <input class="form-check-input" type="checkbox" name="servicios" value="${serv.idServicio}" id="serv_${serv.idServicio}" ${servAsignado ? 'checked' : ''}>
                                                            <label class="form-check-label fw-bold text-dark" for="serv_${serv.idServicio}">
                                                                ${serv.tipoServicio}
                                                            </label>
                                                        </div>
                                                        <div class="d-flex justify-content-between align-items-center mt-2 pt-2 border-top">
                                                            <span class="small font-monospace" style="color: #278829;">S/ ${serv.costo}</span>
                                                            <c:if test="${!serv.activo}">
                                                                <span class="badge bg-secondary small">Inactivo</span>
                                                            </c:if>
                                                        </div>
                                                    </div>
                                                </div>
                                            </c:forEach>
                                        </div>
                                    </div>
                                    <div class="card-footer bg-white border-top p-3 text-end">
                                        <a href="UsuarioController?action=list" class="btn btn-outline-secondary me-2">Volver a Usuarios</a>
                                        <button type="submit" class="btn btn-primary px-4 fw-semibold shadow-sm">
                                            <i class="bi bi-save me-1"></i> Guardar Disponibilidad
                                        </button>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </form>
                </c:if>
            </main>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
