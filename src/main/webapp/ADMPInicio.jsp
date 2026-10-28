<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Panel de Administración | Centro Odontológico ArtDent</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    <link rel="stylesheet" href="css/style.css">
    <style>
        .card-stat {
            transition: transform 0.2s ease, box-shadow 0.2s ease;
        }
        .card-stat:hover {
            transform: translateY(-3px);
            box-shadow: 0 0.5rem 1rem rgba(0, 0, 0, 0.08) !important;
        }
    </style>
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
            <!-- Sidebar Administrador -->
            <%@include file="ADMPSlidebar.jsp"%>

            <!-- Main Content -->
            <main class="col-md-9 ms-sm-auto col-lg-10 p-4">
                <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pb-3 mb-4 border-bottom">
                    <div>
                        <h2 class="h3 fw-bold mb-1" style="color: var(--artdent-primary);">
                            <i class="bi bi-speedometer2 me-2" style="color: var(--artdent-accent);"></i>Panel de Administración ArtDent
                        </h2>
                        <p class="text-muted small mb-0">Resumen operativo general de la clínica, indicadores comerciales y citas en curso.</p>
                    </div>
                    <div class="btn-toolbar mb-2 mb-md-0 gap-2">
                        <span class="badge rounded-pill text-dark d-inline-flex align-items-center px-3 py-2" style="background-color: var(--artdent-mint);">
                            <i class="bi bi-person-badge-fill me-2" style="color: var(--artdent-primary);"></i>Sesión activa: <%= usuario %>
                        </span>
                    </div>
                </div>

                <!-- Dashboard Cards -->
                <div class="row g-3 mb-4">
                    <div class="col-xl-3 col-md-6">
                        <div class="card card-stat border-0 shadow-sm rounded-4 h-100 p-3" style="border-left: 5px solid var(--artdent-primary) !important;">
                            <div class="card-body p-2">
                                <div class="d-flex align-items-center justify-content-between">
                                    <div>
                                        <div class="text-muted small fw-bold text-uppercase mb-1">Citas y Reservas</div>
                                        <h3 class="fw-bold mb-0 text-dark">
                                            <%= request.getAttribute("totalCitasReservas") != null ? request.getAttribute("totalCitasReservas") : "0" %>
                                        </h3>
                                    </div>
                                    <div class="rounded-circle d-flex align-items-center justify-content-center p-3" style="background-color: rgba(48, 164, 198, 0.12); width: 50px; height: 50px;">
                                        <i class="bi bi-calendar-check fs-4" style="color: var(--artdent-primary);"></i>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="col-xl-3 col-md-6">
                        <div class="card card-stat border-0 shadow-sm rounded-4 h-100 p-3" style="border-left: 5px solid var(--artdent-accent) !important;">
                            <div class="card-body p-2">
                                <div class="d-flex align-items-center justify-content-between">
                                    <div>
                                        <div class="text-muted small fw-bold text-uppercase mb-1">Ingresos Totales</div>
                                        <h3 class="fw-bold mb-0" style="color: #278829;">
                                            S/ <%= request.getAttribute("totalIngresos") != null ? request.getAttribute("totalIngresos") : "0.00" %>
                                        </h3>
                                    </div>
                                    <div class="rounded-circle d-flex align-items-center justify-content-center p-3" style="background-color: rgba(159, 204, 58, 0.15); width: 50px; height: 50px;">
                                        <i class="bi bi-cash-coin fs-4" style="color: var(--artdent-accent);"></i>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="col-xl-3 col-md-6">
                        <div class="card card-stat border-0 shadow-sm rounded-4 h-100 p-3" style="border-left: 5px solid var(--artdent-mint) !important;">
                            <div class="card-body p-2">
                                <div class="d-flex align-items-center justify-content-between">
                                    <div>
                                        <div class="text-muted small fw-bold text-uppercase mb-1">Pacientes Totales</div>
                                        <h3 class="fw-bold mb-0 text-dark">1,200</h3>
                                    </div>
                                    <div class="rounded-circle d-flex align-items-center justify-content-center p-3" style="background-color: rgba(180, 221, 194, 0.3); width: 50px; height: 50px;">
                                        <i class="bi bi-people-fill fs-4" style="color: var(--artdent-primary);"></i>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="col-xl-3 col-md-6">
                        <div class="card card-stat border-0 shadow-sm rounded-4 h-100 p-3" style="border-left: 5px solid #212529 !important;">
                            <div class="card-body p-2">
                                <div class="d-flex align-items-center justify-content-between">
                                    <div>
                                        <div class="text-muted small fw-bold text-uppercase mb-1">En Espera / Pendientes</div>
                                        <h3 class="fw-bold mb-0 text-dark">18</h3>
                                    </div>
                                    <div class="rounded-circle d-flex align-items-center justify-content-center p-3" style="background-color: rgba(33, 37, 41, 0.1); width: 50px; height: 50px;">
                                        <i class="bi bi-hourglass-split fs-4" style="color: var(--artdent-dark);"></i>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Recent Appointments -->
                <div class="card border-0 shadow-sm rounded-4 overflow-hidden mb-4">
                    <div class="card-header bg-white py-3 border-bottom d-flex justify-content-between align-items-center">
                        <h6 class="m-0 fw-bold text-dark d-flex align-items-center">
                            <i class="bi bi-journal-medical me-2" style="color: var(--artdent-primary);"></i>Citas Médicas Recientes
                        </h6>
                        <a href="ReservaController?accion=listarCitas" class="btn btn-sm btn-outline-primary rounded-pill px-3">Ver todas</a>
                    </div>
                    <div class="card-body p-0">
                        <div class="table-responsive">
                            <table class="table table-hover align-middle mb-0" id="citasTable">
                                <thead style="background-color: #edf7fa; color: var(--artdent-dark);">
                                    <tr>
                                        <th class="ps-4 py-3">Paciente</th>
                                        <th class="py-3">Fecha</th>
                                        <th class="py-3">Hora</th>
                                        <th class="py-3">Tratamiento / Servicio</th>
                                        <th class="py-3 text-center">Estado</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="cita" items="${citasRecientes}">
                                        <tr>
                                            <td class="ps-4 fw-semibold text-dark">
                                                <i class="bi bi-person-fill me-2" style="color: var(--artdent-primary);"></i>${cita.nombrePaciente}
                                            </td>
                                            <td><i class="bi bi-calendar-event me-1 text-muted"></i>${cita.diaReserva}</td>
                                            <td><i class="bi bi-clock me-1 text-muted"></i>${cita.horaReserva}</td>
                                            <td>
                                                <span class="badge rounded-pill text-dark" style="background-color: var(--artdent-mint);">
                                                    ${cita.nombreServicio}
                                                </span>
                                            </td>
                                            <td class="text-center">
                                                <span class="badge rounded-pill px-3 py-2 ${cita.estadoNombre == 'Confirmado' || cita.estadoNombre == 'Completado' ? 'bg-success text-white' : (cita.estadoNombre == 'Cancelado' || cita.estadoNombre == 'Rechazado' ? 'bg-danger text-white' : 'bg-warning text-dark')}">
                                                    ${cita.estadoNombre}
                                                </span>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                    <c:if test="${empty citasRecientes}">
                                        <tr>
                                            <td colspan="5" class="text-center py-4 text-muted">No se registran citas recientes en este periodo.</td>
                                        </tr>
                                    </c:if>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>

                <!-- Recent Web Reservations -->
                <div class="card border-0 shadow-sm rounded-4 overflow-hidden mb-4">
                    <div class="card-header bg-white py-3 border-bottom d-flex justify-content-between align-items-center">
                        <h6 class="m-0 fw-bold text-dark d-flex align-items-center">
                            <i class="bi bi-calendar-check me-2" style="color: var(--artdent-accent);"></i>Reservas Web Recientes
                        </h6>
                        <a href="ReservaController?accion=listar" class="btn btn-sm btn-outline-primary rounded-pill px-3">Ver todas</a>
                    </div>
                    <div class="card-body p-0">
                        <div class="table-responsive">
                            <table class="table table-hover align-middle mb-0" id="reservasTable">
                                <thead style="background-color: #edf7fa; color: var(--artdent-dark);">
                                    <tr>
                                        <th class="ps-4 py-3">Paciente</th>
                                        <th class="py-3">Fecha</th>
                                        <th class="py-3">Hora</th>
                                        <th class="py-3">Tratamiento / Servicio</th>
                                        <th class="py-3 text-center">Estado</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="reserva" items="${reservasRecientes}">
                                        <tr>
                                            <td class="ps-4 fw-semibold text-dark">
                                                <i class="bi bi-person-fill me-2" style="color: var(--artdent-primary);"></i>${reserva.nombrePaciente}
                                            </td>
                                            <td><i class="bi bi-calendar-event me-1 text-muted"></i>${reserva.diaReserva}</td>
                                            <td><i class="bi bi-clock me-1 text-muted"></i>${reserva.horaReserva}</td>
                                            <td>
                                                <span class="badge rounded-pill text-dark" style="background-color: var(--artdent-mint);">
                                                    ${reserva.nombreServicio}
                                                </span>
                                            </td>
                                            <td class="text-center">
                                                <span class="badge rounded-pill px-3 py-2 ${reserva.estadoNombre == 'Confirmado' || reserva.estadoNombre == 'Completado' ? 'bg-success text-white' : (reserva.estadoNombre == 'Cancelado' || reserva.estadoNombre == 'Rechazado' ? 'bg-danger text-white' : 'bg-warning text-dark')}">
                                                    ${reserva.estadoNombre}
                                                </span>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                    <c:if test="${empty reservasRecientes}">
                                        <tr>
                                            <td colspan="5" class="text-center py-4 text-muted">No se registran reservas recientes en este periodo.</td>
                                        </tr>
                                    </c:if>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>

            </main>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>