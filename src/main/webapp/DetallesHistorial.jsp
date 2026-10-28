<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Detalle de Atención | Centro Odontológico ArtDent</title>
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
            <!-- Sidebar Compartido -->
            <%@include file="Sidebar.jsp" %>

            <!-- Contenido Principal -->
            <main class="container-fluid p-4 d-flex flex-column flex-grow-1">
                <div class="d-flex flex-wrap justify-content-between align-items-center mb-4 pb-2 border-bottom">
                    <div>
                        <h3 class="fw-bold mb-1" style="color: var(--artdent-primary);">
                            <i class="bi bi-file-earmark-medical me-2" style="color: var(--artdent-accent);"></i>Detalles de la Atención
                        </h3>
                        <p class="text-muted small mb-0">Información exhaustiva del registro clínico y asignación de turno.</p>
                    </div>

                    <div>
                        <c:choose>
                            <c:when test="${tipoLista == 'DetRe'}">
                                <form action="HistorialController" method="get">
                                    <input type="hidden" name="accion" value="ListarHistorialReservas" />
                                    <button class="btn btn-outline-primary d-inline-flex align-items-center gap-1 shadow-sm px-3">
                                        <i class="bi bi-arrow-left"></i> Volver a Reservas
                                    </button>
                                </form>
                            </c:when>
                            <c:otherwise>
                                <form action="HistorialController" method="get">
                                    <input type="hidden" name="accion" value="ListarHistorialCitas" />
                                    <button class="btn btn-outline-primary d-inline-flex align-items-center gap-1 shadow-sm px-3">
                                        <i class="bi bi-arrow-left"></i> Volver a Citas
                                    </button>
                                </form>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>

                <div class="row justify-content-center">
                    <div class="col-12 col-xl-10">
                        <div class="card border-0 shadow-sm rounded-4 overflow-hidden">
                            <div class="card-header bg-white py-3 border-bottom d-flex align-items-center justify-content-between">
                                <span class="fw-bold text-dark">
                                    <c:choose>
                                        <c:when test="${tipoLista == 'DetRe'}">Ficha de Reserva Web #RES-${VerReserva[0].idReserva}</c:when>
                                        <c:otherwise>Ficha de Cita Clínica #CIT-${VerCita[0].idCita}</c:otherwise>
                                    </c:choose>
                                </span>
                                <span class="badge rounded-pill text-dark" style="background-color: var(--artdent-mint);">
                                    <i class="bi bi-shield-check me-1" style="color: var(--artdent-primary);"></i>Clínica ArtDent
                                </span>
                            </div>
                            <div class="card-body p-0">
                                <c:choose>
                                    <c:when test="${tipoLista == 'DetRe'}">
                                        <div class="table-responsive">
                                            <table class="table table-bordered mb-0 align-middle">
                                                <tbody>
                                                    <tr>
                                                        <th class="ps-4 text-muted py-3" style="width: 35%; background-color: #f8fafc;">ID Reserva</th>
                                                        <td class="fw-bold text-dark">#RES-${VerReserva[0].idReserva}</td>
                                                    </tr>
                                                    <tr>
                                                        <th class="ps-4 text-muted py-3" style="background-color: #f8fafc;">Paciente</th>
                                                        <td class="fw-bold text-dark">
                                                            <i class="bi bi-person-fill me-2" style="color: var(--artdent-primary);"></i>${VerReserva[0].nombrePaciente} ${VerReserva[0].apellidoPaciente}
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <th class="ps-4 text-muted py-3" style="background-color: #f8fafc;">Fecha Agendada</th>
                                                        <td><i class="bi bi-calendar-event me-2 text-muted"></i>${VerReserva[0].diaReserva}</td>
                                                    </tr>
                                                    <tr>
                                                        <th class="ps-4 text-muted py-3" style="background-color: #f8fafc;">Hora de Atención</th>
                                                        <td><i class="bi bi-clock me-2 text-muted"></i>${VerReserva[0].horaReserva}</td>
                                                    </tr>
                                                    <tr>
                                                        <th class="ps-4 text-muted py-3" style="background-color: #f8fafc;">Servicio Clínico</th>
                                                        <td>
                                                            <span class="badge rounded-pill text-dark" style="background-color: var(--artdent-mint); font-size: 0.9rem;">
                                                                ${VerReserva[0].tipoServicio}
                                                            </span>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <th class="ps-4 text-muted py-3" style="background-color: #f8fafc;">Odontólogo Asignado</th>
                                                        <td class="fw-semibold">
                                                            <i class="bi bi-person-badge-fill me-2" style="color: var(--artdent-accent);"></i>Dr(a). ${VerReserva[0].nombreUsuario} ${VerReserva[0].apellidoUsuario}
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <th class="ps-4 text-muted py-3" style="background-color: #f8fafc;">Motivo / Descripción</th>
                                                        <td>${VerReserva[0].descripcion}</td>
                                                    </tr>
                                                    <tr>
                                                        <th class="ps-4 text-muted py-3" style="background-color: #f8fafc;">Estado</th>
                                                        <td>
                                                            <span class="badge rounded-pill px-3 py-2 ${VerReserva[0].estado == 'Confirmado' || VerReserva[0].estado == 'Completado' ? 'bg-success text-white' : (VerReserva[0].estado == 'Cancelado' || VerReserva[0].estado == 'Rechazado' ? 'bg-danger text-white' : 'bg-warning text-dark')}">
                                                                ${VerReserva[0].estado}
                                                            </span>
                                                        </td>
                                                    </tr>
                                                </tbody>
                                            </table>
                                        </div>
                                    </c:when>

                                    <c:when test="${tipoLista == 'DetCi'}">
                                        <div class="table-responsive">
                                            <table class="table table-bordered mb-0 align-middle">
                                                <tbody>
                                                    <tr>
                                                        <th class="ps-4 text-muted py-3" style="width: 35%; background-color: #f8fafc;">ID Cita Médica</th>
                                                        <td class="fw-bold text-dark">#CIT-${VerCita[0].idCita}</td>
                                                    </tr>
                                                    <tr>
                                                        <th class="ps-4 text-muted py-3" style="background-color: #f8fafc;">Paciente</th>
                                                        <td class="fw-bold text-dark">
                                                            <i class="bi bi-person-fill me-2" style="color: var(--artdent-primary);"></i>${VerCita[0].nombrePaciente} ${VerCita[0].apellidoPaciente}
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <th class="ps-4 text-muted py-3" style="background-color: #f8fafc;">Fecha de Cita</th>
                                                        <td><i class="bi bi-calendar-event me-2 text-muted"></i>${VerCita[0].diaReserva}</td>
                                                    </tr>
                                                    <tr>
                                                        <th class="ps-4 text-muted py-3" style="background-color: #f8fafc;">Hora de Cita</th>
                                                        <td><i class="bi bi-clock me-2 text-muted"></i>${VerCita[0].horaReserva}</td>
                                                    </tr>
                                                    <tr>
                                                        <th class="ps-4 text-muted py-3" style="background-color: #f8fafc;">Servicio Clínico</th>
                                                        <td>
                                                            <span class="badge rounded-pill text-dark" style="background-color: var(--artdent-mint); font-size: 0.9rem;">
                                                                ${VerCita[0].tipoServicio}
                                                            </span>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <th class="ps-4 text-muted py-3" style="background-color: #f8fafc;">Estado de la Cita</th>
                                                        <td>
                                                            <span class="badge rounded-pill px-3 py-2 ${VerCita[0].estado == 'Confirmado' || VerCita[0].estado == 'Completado' ? 'bg-success text-white' : (VerCita[0].estado == 'Cancelado' || VerCita[0].estado == 'Rechazado' ? 'bg-danger text-white' : 'bg-warning text-dark')}">
                                                                ${VerCita[0].estado}
                                                            </span>
                                                        </td>
                                                    </tr>
                                                </tbody>
                                            </table>
                                        </div>
                                    </c:when>
                                </c:choose>
                            </div>
                        </div>
                    </div>
                </div>
            </main>
        </div>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>
