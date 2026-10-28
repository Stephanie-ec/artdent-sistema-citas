<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Notificaciones del Sistema | Centro Odontológico ArtDent</title>
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
                            <i class="bi bi-bell-fill me-2" style="color: var(--artdent-accent);"></i>Centro de Notificaciones
                        </h3>
                        <p class="text-muted small mb-0">Bitácora de avisos y eventos automáticos sobre citas y reservas de la clínica.</p>
                    </div>

                    <div class="d-flex gap-2 mt-2 mt-md-0">
                        <!-- Formulario para listar reservas -->
                        <form action="NotificacionesController" method="get">
                            <input type="hidden" name="accion" value="listarReservas" />
                            <button type="submit" class="btn ${tipoLista == 'reserva' ? 'btn-primary' : 'btn-outline-primary'} d-inline-flex align-items-center gap-1 shadow-sm px-3">
                                <i class="bi bi-calendar-event"></i> Reservas Web
                            </button>
                        </form>

                        <!-- Formulario para listar citas -->
                        <form action="NotificacionesController" method="get">
                            <input type="hidden" name="accion" value="listarCitas" />
                            <button type="submit" class="btn ${tipoLista == 'cita' ? 'btn-primary' : 'btn-outline-primary'} d-inline-flex align-items-center gap-1 shadow-sm px-3">
                                <i class="bi bi-journal-medical"></i> Citas Médicas
                            </button>
                        </form>
                    </div>
                </div>

                <div class="row justify-content-center flex-grow-1">
                    <div class="col-12 col-xl-10">
                        <c:choose>
                            <c:when test="${tipoLista == 'reserva'}">                        
                                <c:forEach var="reserva" items="${VerReserva}">
                                    <div class="card border-0 shadow-sm rounded-4 mb-3 overflow-hidden" 
                                         style="border-left: 5px solid ${reserva.estado == 'Confirmado' || reserva.estado == 'Completado' ? 'var(--artdent-accent)' : (reserva.estado == 'Cancelado' || reserva.estado == 'Rechazado' ? '#dc3545' : 'var(--artdent-primary)')} !important;">
                                        <div class="card-body p-3 p-md-4 d-flex align-items-center justify-content-between">
                                            <div class="d-flex align-items-center">
                                                <div class="rounded-circle p-3 d-flex align-items-center justify-content-center me-3 shadow-sm"
                                                     style="width: 52px; height: 52px; background-color: ${reserva.estado == 'Confirmado' || reserva.estado == 'Completado' ? 'rgba(159, 204, 58, 0.15)' : (reserva.estado == 'Cancelado' || reserva.estado == 'Rechazado' ? 'rgba(220, 53, 69, 0.12)' : 'rgba(48, 164, 198, 0.15)')};">
                                                    <c:choose>
                                                        <c:when test="${reserva.estado == 'Confirmado'}">
                                                            <i class="bi bi-check2-circle fs-4" style="color: var(--artdent-accent);"></i>
                                                        </c:when>
                                                        <c:when test="${reserva.estado == 'Completado'}">
                                                            <i class="bi bi-clipboard2-check fs-4" style="color: var(--artdent-accent);"></i>
                                                        </c:when>
                                                        <c:when test="${reserva.estado == 'Cancelado' || reserva.estado == 'Rechazado'}">
                                                            <i class="bi bi-x-octagon fs-4 text-danger"></i>
                                                        </c:when>
                                                        <c:when test="${reserva.estado == 'Reprogramado'}">
                                                            <i class="bi bi-arrow-repeat fs-4" style="color: var(--artdent-primary);"></i>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <i class="bi bi-hourglass-split fs-4" style="color: var(--artdent-primary);"></i>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </div>
                                                <div>
                                                    <h6 class="fw-bold mb-1 text-dark">
                                                        Reserva ${reserva.estado}: <span class="fw-semibold text-secondary">${reserva.nombrePaciente} ${reserva.apellidoPaciente}</span>
                                                    </h6>
                                                    <p class="text-muted small mb-0">
                                                        Fecha agendada: <strong>${reserva.diaReserva}</strong> a las <strong>${reserva.horaReserva}</strong>
                                                    </p>
                                                </div>
                                            </div>
                                            <div>
                                                <span class="badge rounded-pill px-3 py-2 ${reserva.estado == 'Confirmado' || reserva.estado == 'Completado' ? 'bg-success text-white' : (reserva.estado == 'Cancelado' || reserva.estado == 'Rechazado' ? 'bg-danger text-white' : 'bg-warning text-dark')}">
                                                    ${reserva.estado}
                                                </span>
                                            </div>
                                        </div>
                                    </div>
                                </c:forEach>
                            </c:when>

                            <c:when test="${tipoLista == 'cita'}">
                                <c:forEach var="cita" items="${VerCita}">
                                    <div class="card border-0 shadow-sm rounded-4 mb-3 overflow-hidden" 
                                         style="border-left: 5px solid ${cita.estado == 'Confirmado' || cita.estado == 'Completado' ? 'var(--artdent-accent)' : (cita.estado == 'Cancelado' || cita.estado == 'Rechazado' ? '#dc3545' : 'var(--artdent-primary)')} !important;">
                                        <div class="card-body p-3 p-md-4 d-flex align-items-center justify-content-between">
                                            <div class="d-flex align-items-center">
                                                <div class="rounded-circle p-3 d-flex align-items-center justify-content-center me-3 shadow-sm"
                                                     style="width: 52px; height: 52px; background-color: ${cita.estado == 'Confirmado' || cita.estado == 'Completado' ? 'rgba(159, 204, 58, 0.15)' : (cita.estado == 'Cancelado' || cita.estado == 'Rechazado' ? 'rgba(220, 53, 69, 0.12)' : 'rgba(48, 164, 198, 0.15)')};">
                                                    <c:choose>
                                                        <c:when test="${cita.estado == 'Confirmado'}">
                                                            <i class="bi bi-check2-circle fs-4" style="color: var(--artdent-accent);"></i>
                                                        </c:when>
                                                        <c:when test="${cita.estado == 'Completado'}">
                                                            <i class="bi bi-clipboard2-check fs-4" style="color: var(--artdent-accent);"></i>
                                                        </c:when>
                                                        <c:when test="${cita.estado == 'Cancelado' || cita.estado == 'Rechazado'}">
                                                            <i class="bi bi-x-octagon fs-4 text-danger"></i>
                                                        </c:when>
                                                        <c:when test="${cita.estado == 'Reprogramado'}">
                                                            <i class="bi bi-arrow-repeat fs-4" style="color: var(--artdent-primary);"></i>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <i class="bi bi-hourglass-split fs-4" style="color: var(--artdent-primary);"></i>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </div>
                                                <div>
                                                    <h6 class="fw-bold mb-1 text-dark">
                                                        Cita Médica ${cita.estado}: <span class="fw-semibold text-secondary">${cita.nombrePaciente} ${cita.apellidoPaciente}</span>
                                                    </h6>
                                                    <p class="text-muted small mb-0">
                                                        Fecha agendada: <strong>${cita.diaReserva}</strong> a las <strong>${cita.horaReserva}</strong>
                                                    </p>
                                                </div>
                                            </div>
                                            <div>
                                                <span class="badge rounded-pill px-3 py-2 ${cita.estado == 'Confirmado' || cita.estado == 'Completado' ? 'bg-success text-white' : (cita.estado == 'Cancelado' || cita.estado == 'Rechazado' ? 'bg-danger text-white' : 'bg-warning text-dark')}">
                                                    ${cita.estado}
                                                </span>
                                            </div>
                                        </div>
                                    </div>
                                </c:forEach>
                            </c:when>

                            <c:otherwise>
                                <div class="card border-0 shadow-sm rounded-4 p-5 text-center my-4">
                                    <div class="mb-3">
                                        <i class="bi bi-bell-slash fs-1 text-secondary"></i>
                                    </div>
                                    <h5 class="fw-bold text-dark">Seleccione un Filtro</h5>
                                    <p class="text-muted mb-0">Haga clic en <strong>Reservas Web</strong> o <strong>Citas Médicas</strong> para revisar la bitácora de notificaciones.</p>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </main>
        </div>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>