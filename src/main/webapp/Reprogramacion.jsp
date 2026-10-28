<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Reprogramación de Cita | Centro Odontológico ArtDent</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet">
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
        <!-- Contenido de la Página -->
        <div class="d-flex flex-grow-1">
            <!-- Sidebar -->
            <%@include file="Sidebar.jsp" %>

            <!-- Contenido Principal -->
            <main class="container-fluid p-4 d-flex flex-column flex-grow-1">
                <div class="d-flex flex-wrap justify-content-between align-items-center mb-4 pb-2 border-bottom">
                    <div>
                        <h3 class="fw-bold mb-1" style="color: var(--artdent-primary);">
                            <i class="bi bi-calendar2-range-fill me-2" style="color: var(--artdent-accent);"></i>Reprogramación de Cita / Reserva
                        </h3>
                        <p class="text-muted small mb-0">Seleccione la nueva fecha y hora para el paciente; el sistema enviará una notificación automática por correo.</p>
                    </div>

                    <c:choose>
                        <c:when test="${tipoLista == 'DetRe'}">
                            <form action="ReservaController" method="get">
                                <input type="hidden" name="accion" value="listar" />
                                <button class="btn btn-outline-secondary d-inline-flex align-items-center gap-1 shadow-sm px-3">
                                    <i class="bi bi-x-circle"></i> Cancelar
                                </button>
                            </form>
                        </c:when>
                        <c:otherwise>
                            <form action="ReservaController" method="get">
                                <input type="hidden" name="accion" value="listarCitas" />
                                <button class="btn btn-outline-secondary d-inline-flex align-items-center gap-1 shadow-sm px-3">
                                    <i class="bi bi-x-circle"></i> Cancelar
                                </button>
                            </form>
                        </c:otherwise>
                    </c:choose>
                </div>

                <div class="row justify-content-center">
                    <div class="col-12 col-xl-10">
                        <c:choose>
                            <c:when test="${tipoLista == 'DetRe'}">
                                <!-- Tarjeta de Datos de la Reserva -->
                                <div class="card border-0 shadow-sm rounded-4 overflow-hidden mb-4">
                                    <div class="card-header bg-white py-3 border-bottom d-flex align-items-center justify-content-between">
                                        <span class="fw-bold text-dark">
                                            <i class="bi bi-info-circle me-2" style="color: var(--artdent-primary);"></i>Datos Actuales de la Reserva #RES-${VerReserva[0].idReserva}
                                        </span>
                                        <span class="badge rounded-pill text-dark" style="background-color: var(--artdent-mint);">
                                            Reserva Web
                                        </span>
                                    </div>
                                    <div class="card-body p-0">
                                        <div class="table-responsive">
                                            <table class="table table-bordered mb-0 align-middle">
                                                <tbody>
                                                    <tr>
                                                        <th class="ps-4 text-muted py-2" style="width: 35%; background-color: #f8fafc;">Paciente</th>
                                                        <td class="fw-bold text-dark">${VerReserva[0].nombrePaciente} ${VerReserva[0].apellidoPaciente}</td>
                                                    </tr>
                                                    <tr>
                                                        <th class="ps-4 text-muted py-2" style="background-color: #f8fafc;">Fecha y Hora Actual</th>
                                                        <td><i class="bi bi-calendar-event me-2 text-muted"></i>${VerReserva[0].diaReserva} a las ${VerReserva[0].horaReserva}</td>
                                                    </tr>
                                                    <tr>
                                                        <th class="ps-4 text-muted py-2" style="background-color: #f8fafc;">Servicio Clínico</th>
                                                        <td><span class="badge rounded-pill text-dark" style="background-color: var(--artdent-mint);">${VerReserva[0].tipoServicio}</span></td>
                                                    </tr>
                                                    <tr>
                                                        <th class="ps-4 text-muted py-2" style="background-color: #f8fafc;">Médico Asignado</th>
                                                        <td>Dr(a). ${VerReserva[0].nombreUsuario} ${VerReserva[0].apellidoUsuario}</td>
                                                    </tr>
                                                    <tr>
                                                        <th class="ps-4 text-muted py-2" style="background-color: #f8fafc;">Motivo Original</th>
                                                        <td>${VerReserva[0].descripcion}</td>
                                                    </tr>
                                                </tbody>
                                            </table>
                                        </div>
                                    </div>
                                </div>

                                <!-- Formulario de Nueva Fecha y Hora -->
                                <div class="card border-0 shadow-sm rounded-4 p-4" style="border-top: 4px solid var(--artdent-primary) !important;">
                                    <h5 class="fw-bold mb-3" style="color: var(--artdent-primary);">
                                        <i class="bi bi-clock-history me-2"></i>Asignar Nueva Fecha y Hora
                                    </h5>
                                    <form method="post" action="ReprogramacionController" class="row g-3 align-items-end">
                                        <input type="hidden" name="idReserva" value="${VerReserva[0].idReserva}"> 
                                        <div class="col-md-5">
                                            <label for="new-date" class="form-label fw-semibold">Nueva Fecha <span class="text-danger">*</span></label>
                                            <input type="date" class="form-control" id="new-date" name="new-date" required>
                                        </div>

                                        <div class="col-md-4">
                                            <label for="new-time" class="form-label fw-semibold">Nueva Hora <span class="text-danger">*</span></label>
                                            <input type="time" class="form-control" id="new-time" name="new-time" required>
                                        </div>

                                        <div class="col-md-3">
                                            <button type="submit" class="btn btn-success w-100 py-2 shadow-sm fw-semibold" name="accion" value="UpdateReserva">
                                                <i class="bi bi-check-circle me-1"></i> Confirmar
                                            </button>
                                        </div>
                                    </form>
                                </div>
                            </c:when>

                            <c:when test="${tipoLista == 'DetCi'}">
                                <!-- Tarjeta de Datos de la Cita Médica -->
                                <div class="card border-0 shadow-sm rounded-4 overflow-hidden mb-4">
                                    <div class="card-header bg-white py-3 border-bottom d-flex align-items-center justify-content-between">
                                        <span class="fw-bold text-dark">
                                            <i class="bi bi-info-circle me-2" style="color: var(--artdent-primary);"></i>Datos Actuales de la Cita #CIT-${VerCita[0].idCita}
                                        </span>
                                        <span class="badge rounded-pill text-dark" style="background-color: var(--artdent-mint);">
                                            Cita Médica
                                        </span>
                                    </div>
                                    <div class="card-body p-0">
                                        <div class="table-responsive">
                                            <table class="table table-bordered mb-0 align-middle">
                                                <tbody>
                                                    <tr>
                                                        <th class="ps-4 text-muted py-2" style="width: 35%; background-color: #f8fafc;">Paciente</th>
                                                        <td class="fw-bold text-dark">${VerCita[0].nombrePaciente} ${VerCita[0].apellidoPaciente}</td>
                                                    </tr>
                                                    <tr>
                                                        <th class="ps-4 text-muted py-2" style="background-color: #f8fafc;">Fecha y Hora Actual</th>
                                                        <td><i class="bi bi-calendar-event me-2 text-muted"></i>${VerCita[0].diaReserva} a las ${VerCita[0].horaReserva}</td>
                                                    </tr>
                                                    <tr>
                                                        <th class="ps-4 text-muted py-2" style="background-color: #f8fafc;">Servicio Clínico</th>
                                                        <td><span class="badge rounded-pill text-dark" style="background-color: var(--artdent-mint);">${VerCita[0].tipoServicio}</span></td>
                                                    </tr>
                                                    <tr>
                                                        <th class="ps-4 text-muted py-2" style="background-color: #f8fafc;">Estado Actual</th>
                                                        <td><span class="badge bg-secondary">${VerCita[0].estado}</span></td>
                                                    </tr>
                                                </tbody>
                                            </table>
                                        </div>
                                    </div>
                                </div>

                                <!-- Formulario de Nueva Fecha y Hora -->
                                <div class="card border-0 shadow-sm rounded-4 p-4" style="border-top: 4px solid var(--artdent-primary) !important;">
                                    <h5 class="fw-bold mb-3" style="color: var(--artdent-primary);">
                                        <i class="bi bi-clock-history me-2"></i>Asignar Nueva Fecha y Hora
                                    </h5>
                                    <form method="post" action="ReprogramacionController" class="row g-3 align-items-end">
                                        <input type="hidden" name="idCita" value="${VerCita[0].idCita}"> 
                                        <div class="col-md-5">
                                            <label for="new-date" class="form-label fw-semibold">Nueva Fecha <span class="text-danger">*</span></label>
                                            <input type="date" class="form-control" id="new-date" name="new-date" required>
                                        </div>

                                        <div class="col-md-4">
                                            <label for="new-time" class="form-label fw-semibold">Nueva Hora <span class="text-danger">*</span></label>
                                            <input type="time" class="form-control" id="new-time" name="new-time" required>
                                        </div>

                                        <div class="col-md-3">
                                            <button type="submit" class="btn btn-success w-100 py-2 shadow-sm fw-semibold" name="accion" value="UpdateCita">
                                                <i class="bi bi-check-circle me-1"></i> Confirmar
                                            </button>
                                        </div>
                                    </form>
                                </div>
                            </c:when>
                        </c:choose>
                    </div>
                </div>
            </main>
        </div>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>
