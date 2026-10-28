<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Historial de Atenciones | Centro Odontológico ArtDent</title>
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
                            <i class="bi bi-clock-history me-2" style="color: var(--artdent-accent);"></i>Historial de Atenciones
                        </h3>
                        <p class="text-muted small mb-0">Consulte el registro histórico de reservas web y citas atendidas o reprogramadas.</p>
                    </div>

                    <div class="d-flex gap-2 mt-2 mt-md-0">
                        <!-- Formulario para listar reservas -->
                        <form action="HistorialController" method="get">
                            <input type="hidden" name="accion" value="ListarHistorialReservas" />
                            <button type="submit" class="btn ${tipoLista == 'hisRe' ? 'btn-primary' : 'btn-outline-primary'} d-inline-flex align-items-center gap-1 shadow-sm px-3">
                                <i class="bi bi-calendar2-check"></i> Reservas Web
                            </button>
                        </form>

                        <!-- Formulario para listar citas -->
                        <form action="HistorialController" method="get">
                            <input type="hidden" name="accion" value="ListarHistorialCitas" />
                            <button type="submit" class="btn ${tipoLista == 'hisCi' ? 'btn-primary' : 'btn-outline-primary'} d-inline-flex align-items-center gap-1 shadow-sm px-3">
                                <i class="bi bi-journal-medical"></i> Citas Médicas
                            </button>
                        </form>
                    </div>
                </div>

                <!-- Tabla de Historial -->
                <div class="card border-0 shadow-sm rounded-4 overflow-hidden flex-grow-1">
                    <div class="card-header bg-white py-3 border-bottom d-flex align-items-center justify-content-between">
                        <span class="fw-bold text-dark">
                            <c:choose>
                                <c:when test="${tipoLista == 'hisRe'}">Listado de Reservas Web Históricas</c:when>
                                <c:when test="${tipoLista == 'hisCi'}">Listado de Citas Presenciales e Historial Clínico</c:when>
                                <c:otherwise>Registro Histórico General</c:otherwise>
                            </c:choose>
                        </span>
                        <span class="badge rounded-pill text-dark" style="background-color: var(--artdent-mint);">
                            <i class="bi bi-shield-check me-1" style="color: var(--artdent-primary);"></i>Clínica ArtDent
                        </span>
                    </div>

                    <div class="table-responsive flex-grow-1">
                        <table class="table table-hover align-middle mb-0">
                            <thead style="background-color: #edf7fa; color: var(--artdent-dark);">
                                <tr class="text-center">
                                    <th class="py-3">Paciente</th>
                                    <th class="py-3">Fecha y Hora</th>
                                    <th class="py-3">Estado</th>
                                    <th class="py-3 text-center">Acciones</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:choose>
                                    <c:when test="${tipoLista == 'hisRe'}">
                                        <c:forEach var="reserva" items="${VerReserva}">
                                            <tr class="text-center">          
                                                <td class="fw-semibold text-dark text-start ps-4">
                                                    <i class="bi bi-person-fill me-2" style="color: var(--artdent-primary);"></i>${reserva.nombrePaciente} ${reserva.apellidoPaciente}
                                                </td>
                                                <td><i class="bi bi-calendar-event me-1 text-muted"></i>${reserva.diaReserva}</td>
                                                <td>
                                                    <span class="badge rounded-pill px-3 py-2 ${reserva.estado == 'Confirmado' || reserva.estado == 'Completado' ? 'bg-success text-white' : (reserva.estado == 'Cancelado' || reserva.estado == 'Rechazado' ? 'bg-danger text-white' : 'bg-warning text-dark')}">
                                                        ${reserva.estado}
                                                    </span>
                                                </td>
                                                <td class="text-center">
                                                    <form action="HistorialController" method="get" class="d-inline">
                                                        <input type="hidden" name="id" value="${reserva.idReserva}" />
                                                        <input type="hidden" name="accion" value="VerDetalleRe" />
                                                        <button class="btn btn-sm btn-primary rounded-pill px-3 shadow-sm">
                                                            <i class="bi bi-eye me-1"></i> Ver Detalles
                                                        </button>
                                                    </form>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </c:when>
                                    <c:when test="${tipoLista == 'hisCi'}">
                                        <c:forEach var="cita" items="${VerCita}">
                                            <tr class="text-center">          
                                                <td class="fw-semibold text-dark text-start ps-4">
                                                    <i class="bi bi-person-fill me-2" style="color: var(--artdent-primary);"></i>${cita.nombrePaciente} ${cita.apellidoPaciente}
                                                </td>
                                                <td><i class="bi bi-calendar-event me-1 text-muted"></i>${cita.diaReserva}</td>
                                                <td>
                                                    <span class="badge rounded-pill px-3 py-2 ${cita.estado == 'Confirmado' || cita.estado == 'Completado' ? 'bg-success text-white' : (cita.estado == 'Cancelado' || cita.estado == 'Rechazado' ? 'bg-danger text-white' : 'bg-warning text-dark')}">
                                                        ${cita.estado}
                                                    </span>
                                                </td>
                                                <td class="text-center">
                                                    <form action="HistorialController" method="get" class="d-inline">
                                                        <input type="hidden" name="id" value="${cita.idCita}" />
                                                        <input type="hidden" name="accion" value="VerDetalleCi" />
                                                        <button class="btn btn-sm btn-primary rounded-pill px-3 shadow-sm">
                                                            <i class="bi bi-eye me-1"></i> Ver Detalles
                                                        </button>
                                                    </form>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </c:when>
                                    <c:otherwise>
                                        <tr>
                                            <td colspan="4" class="text-center py-5 text-muted">
                                                <i class="bi bi-inbox fs-1 d-block mb-2 text-secondary"></i>
                                                Seleccione <strong>Reservas Web</strong> o <strong>Citas Médicas</strong> para visualizar el historial.
                                            </td>
                                        </tr>
                                    </c:otherwise>
                                </c:choose>
                            </tbody>
                        </table>
                    </div>
                </div>
            </main>
        </div>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>