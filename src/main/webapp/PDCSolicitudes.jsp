<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Solicitudes y Reservas - Art Dent</title>
    <!-- Bootstrap 5.3 & Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Open+Sans:wght@400;600;700&family=Roboto:wght@500;700;900&display=swap" rel="stylesheet">
    <!-- Hoja de Estilos Oficial de Marca Art Dent -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>

<body class="d-flex flex-column min-vh-100 bg-brand-light">
    <%
        HttpSession misesion = request.getSession(false);
        String usuario = (misesion != null) ? (String) misesion.getAttribute("Nombre") : null;
        if (usuario == null) {
            response.sendRedirect("iniciosesionerror.jsp");
            return;
        }
    %>

    <%@include file="NavPanel.jsp" %>

    <div class="d-flex flex-grow-1">
        <%@include file="Sidebar.jsp" %>

        <!-- Contenedor Principal de Solicitudes -->
        <main class="container-fluid p-4 d-flex flex-column flex-grow-1">
            <div class="mb-4">
                <h3 class="fw-bold text-brand-dark mb-1">
                    <span class="text-brand-primary">Solicitudes de Citas</span> y Reservas Web
                </h3>
                <p class="text-muted small mb-0">Gestión de flujo de recepción: validación de reservas web, citas presenciales, cobros y emisión de boletas</p>
            </div>

            <!-- Alertas Informativas del Sistema -->
            <c:if test="${param.msg == 'presencialOk'}">
                <div class="alert alert-artdent-mint alert-dismissible fade show d-flex align-items-center mb-3" role="alert">
                    <i class="bi bi-check-circle-fill fs-4 me-2 text-brand-accent"></i>
                    <div>
                        <strong>¡Cita presencial registrada con éxito!</strong> Código generado: <span class="badge bg-brand-primary fs-6 font-monospace">${param.codigo}</span>. Notificación enviada al paciente.
                    </div>
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
            </c:if>

            <c:if test="${param.error == 'sinPago'}">
                <div class="alert alert-danger alert-dismissible fade show d-flex align-items-center mb-3" role="alert">
                    <i class="bi bi-exclamation-triangle-fill fs-4 me-2 text-danger"></i>
                    <div>
                        <strong>No se puede aprobar la reserva:</strong> La aprobación de reservas web requiere un pago registrado previamente (en ventanilla o en línea). Registre el cobro en efectivo antes de confirmar.
                    </div>
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
            </c:if>

            <c:if test="${param.msg == 'pagoEfectivoOk'}">
                <div class="alert alert-artdent-mint alert-dismissible fade show d-flex align-items-center mb-3" role="alert">
                    <i class="bi bi-cash-coin fs-4 me-2 text-brand-accent"></i>
                    <div>
                        <strong>¡Pago en ventanilla registrado con éxito!</strong> Se emitió la boleta electrónica <span class="badge bg-brand-primary fs-6 font-monospace">${param.boleta}</span>. La reserva ahora puede ser confirmada formalmente.
                    </div>
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
            </c:if>

            <c:if test="${param.msg == 'aprobadoOk'}">
                <div class="alert alert-artdent-mint alert-dismissible fade show d-flex align-items-center mb-3" role="alert">
                    <i class="bi bi-check-circle-fill fs-4 me-2 text-brand-accent"></i>
                    <div>
                        <strong>¡Reserva web aprobada!</strong> La cita ha pasado a estado <strong>Confirmado</strong> y se notificó al paciente por correo.
                    </div>
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
            </c:if>

            <c:if test="${param.msg == 'rechazadoOk'}">
                <div class="alert alert-warning alert-dismissible fade show d-flex align-items-center mb-3" role="alert">
                    <i class="bi bi-x-circle-fill fs-4 me-2 text-warning"></i>
                    <div>
                        <strong>Reserva rechazada:</strong> Se actualizó el estado a <strong>Rechazado</strong> y el motivo fue notificado por correo electrónico al paciente.
                    </div>
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
            </c:if>

            <!-- Barra de Acciones y Filtros -->
            <div class="card p-3 mb-4 border-0 shadow-sm" style="border-radius: 12px; background: #ffffff;">
                <div class="d-flex justify-content-between align-items-center flex-wrap gap-2">
                    <a href="CitaController?accion=formPresencial" class="btn btn-success fw-semibold rounded-pill px-4 shadow-sm">
                        <i class="bi bi-calendar-plus me-1"></i> + Registrar Cita Presencial
                    </a>

                    <div class="d-flex gap-2">
                        <form action="ReservaController" method="get">
                            <input type="hidden" name="accion" value="listar" />
                            <button type="submit" class="btn ${tipoLista == 'reserva' ? 'btn-primary text-white shadow-sm' : 'btn-outline-primary'} rounded-pill px-4 fw-semibold">
                                <i class="bi bi-globe me-1"></i> Reservas Web
                            </button>
                        </form>
                        <form action="ReservaController" method="get">
                            <input type="hidden" name="accion" value="listarCitas" />
                            <button type="submit" class="btn ${tipoLista == 'cita' ? 'btn-primary text-white shadow-sm' : 'btn-outline-primary'} rounded-pill px-4 fw-semibold">
                                <i class="bi bi-hospital me-1"></i> Citas Presenciales
                            </button>
                        </form>
                    </div>
                </div>
            </div>

            <!-- Tabla de Registros Clínicos -->
            <div class="card border-0 shadow-sm overflow-hidden flex-grow-1" style="border-radius: 12px;">
                <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0">
                        <thead>
                            <tr>
                                <th class="text-start ps-4">Paciente</th>
                                <th>Fecha y Hora</th>
                                <th>Tratamiento</th>
                                <th>Estado</th>
                                <th>Pago / Boleta</th>
                                <th class="text-center pe-4">Acciones</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:choose>
                                <c:when test="${tipoLista == 'reserva'}">
                                    <c:forEach var="reserva" items="${VerReserva}">
                                        <tr>
                                            <td class="fw-semibold text-start ps-4">
                                                <i class="bi bi-person-fill text-brand-primary me-1"></i>
                                                ${reserva.nombrePaciente} ${reserva.apellidoPaciente}
                                            </td>
                                            <td>
                                                <span class="d-block fw-semibold text-brand-dark">${reserva.diaReserva}</span>
                                                <small class="text-muted"><i class="bi bi-clock me-1"></i>${reserva.horaReserva}</small>
                                            </td>
                                            <td>
                                                <span class="badge bg-brand-light text-brand-dark border px-2 py-1">${reserva.tipoServicio}</span>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${reserva.estado == 'En espera'}">
                                                        <span class="badge bg-mint text-dark px-2 py-1"><i class="bi bi-clock me-1"></i>En espera</span>
                                                    </c:when>
                                                    <c:when test="${reserva.estado == 'Confirmado'}">
                                                        <span class="badge bg-brand-primary text-white px-2 py-1"><i class="bi bi-check-circle me-1"></i>Confirmado</span>
                                                    </c:when>
                                                    <c:when test="${reserva.estado == 'Completado'}">
                                                        <span class="badge bg-brand-accent text-white px-2 py-1"><i class="bi bi-check2-all me-1"></i>Completado</span>
                                                    </c:when>
                                                    <c:when test="${reserva.estado == 'Rechazado'}">
                                                        <span class="badge bg-danger text-white px-2 py-1"><i class="bi bi-x-circle me-1"></i>Rechazado</span>
                                                    </c:when>
                                                    <c:when test="${reserva.estado == 'Cancelado'}">
                                                        <span class="badge bg-secondary text-white px-2 py-1"><i class="bi bi-slash-circle me-1"></i>Cancelado</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge bg-light text-dark px-2 py-1">${reserva.estado}</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>

                                            <!-- Pago / Boleta -->
                                            <td>
                                                <c:choose>
                                                    <c:when test="${reserva.tienePago}">
                                                        <span class="badge bg-mint text-dark px-2 py-1 d-inline-block mb-1">
                                                            <i class="bi bi-check-circle-fill text-brand-accent me-1"></i>Pagado
                                                        </span>
                                                        <div class="small font-monospace fw-bold text-brand-dark">${reserva.codigoBoleta}</div>
                                                        <a href="PagoController?action=verBoleta&idCita=${reserva.idReserva}" target="_blank" class="btn btn-sm btn-outline-primary mt-1 py-0 px-2 rounded-pill" title="Ver Boleta Electrónica">
                                                            <i class="bi bi-receipt"></i> Boleta
                                                        </a>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge bg-warning text-dark px-2 py-1 d-inline-block mb-1">
                                                            <i class="bi bi-hourglass-split me-1"></i>Pendiente
                                                        </span>
                                                        <c:if test="${reserva.estado == 'En espera'}">
                                                            <div>
                                                                <button type="button" class="btn btn-sm btn-outline-success mt-1 py-0 px-2 rounded-pill" data-bs-toggle="modal" data-bs-target="#modalPagoReserva${reserva.idReserva}" title="Cobrar en Efectivo (Ventanilla)">
                                                                    <i class="bi bi-cash-coin me-1"></i>Cobrar
                                                                </button>
                                                            </div>
                                                        </c:if>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>

                                            <!-- Acciones -->
                                            <td class="text-center pe-4">
                                                <div class="d-flex justify-content-center align-items-center flex-wrap gap-1">
                                                    <c:choose>
                                                        <c:when test="${reserva.estado == 'Cancelado' || reserva.estado == 'Rechazado'}">
                                                            <form action="ReprogramacionController" method="post" class="d-inline">
                                                                <input type="hidden" name="idReserva" value="${reserva.idReserva}" />
                                                                <input type="hidden" name="accion" value="deleteReserva" />
                                                                <button class="btn btn-sm btn-outline-danger rounded-pill" type="submit" title="Eliminar registro">
                                                                    <i class="bi bi-trash"></i>
                                                                </button>
                                                            </form>
                                                        </c:when>

                                                        <c:otherwise>
                                                            <c:choose>
                                                                <c:when test="${reserva.estado == 'En espera'}">
                                                                    <c:choose>
                                                                        <c:when test="${reserva.tienePago}">
                                                                            <form action="ReprogramacionController" method="post" class="d-inline">
                                                                                <input type="hidden" name="idReserva" value="${reserva.idReserva}" />
                                                                                <input type="hidden" name="estado" value="${reserva.estado}" />
                                                                                <input type="hidden" name="accion" value="updateEstadoConfirmar" />
                                                                                <button class="btn btn-sm btn-primary rounded-pill px-3" type="submit" title="Aprobar reserva web verificada">
                                                                                    <i class="bi bi-check2"></i> Aprobar
                                                                                </button>
                                                                            </form>
                                                                        </c:when>
                                                                        <c:otherwise>
                                                                            <button class="btn btn-sm btn-secondary rounded-pill px-3" type="button" onclick="alert('No se puede aprobar la reserva: Requiere pago verificado registrado previamente. Por favor, registre el pago en efectivo o espere el pago en línea.')" title="Bloqueado: Requiere Pago">
                                                                                <i class="bi bi-lock-fill"></i> Aprobar
                                                                            </button>
                                                                        </c:otherwise>
                                                                    </c:choose>

                                                                    <button type="button" class="btn btn-sm btn-outline-danger rounded-pill px-2" data-bs-toggle="modal" data-bs-target="#modalRechazoReserva${reserva.idReserva}" title="Rechazar reserva con motivo">
                                                                        <i class="bi bi-x-circle"></i> Rechazar
                                                                    </button>
                                                                </c:when>

                                                                <c:when test="${reserva.estado == 'Reprogramado'}">
                                                                    <form action="ReprogramacionController" method="post" class="d-inline">
                                                                        <input type="hidden" name="idReserva" value="${reserva.idReserva}" />
                                                                        <input type="hidden" name="estado" value="${reserva.estado}" />
                                                                        <input type="hidden" name="accion" value="updateEstadoConfirmar" />
                                                                        <button class="btn btn-sm btn-primary rounded-pill px-3" type="submit">Confirmar</button>
                                                                    </form>
                                                                </c:when>

                                                                <c:when test="${reserva.estado == 'Confirmado'}">
                                                                    <form action="ReprogramacionController" method="post" class="d-inline">
                                                                        <input type="hidden" name="idReserva" value="${reserva.idReserva}" />
                                                                        <input type="hidden" name="estado" value="${reserva.estado}" />
                                                                        <input type="hidden" name="accion" value="updateEstadoCompletado" />
                                                                        <button class="btn btn-sm btn-success rounded-pill px-3" type="submit">Completar</button>
                                                                    </form>
                                                                </c:when>
                                                            </c:choose>

                                                            <!-- Reprogramar -->
                                                            <form action="ReprogramacionController" method="get" class="d-inline">
                                                                <input type="hidden" name="id" value="${reserva.idReserva}" />
                                                                <input type="hidden" name="accion" value="VerReproRe" />
                                                                <button class="btn btn-sm btn-outline-primary rounded-pill" type="submit" title="Reprogramar fecha u hora">
                                                                    <i class="bi bi-calendar2-range"></i>
                                                                </button>
                                                            </form>

                                                            <!-- Cancelar -->
                                                            <form action="ReprogramacionController" method="post" class="d-inline">
                                                                <input type="hidden" name="idReserva" value="${reserva.idReserva}" />
                                                                <input type="hidden" name="accion" value="updateEstadoCancelar" />
                                                                <button class="btn btn-sm btn-outline-secondary rounded-pill" type="submit" title="Cancelar cita">
                                                                    <i class="bi bi-ban"></i>
                                                                </button>
                                                            </form>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </div>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:when>

                                <c:when test="${tipoLista == 'cita'}">
                                    <c:forEach var="cita" items="${VerCita}">
                                        <tr>
                                            <td class="fw-semibold text-start ps-4">
                                                <i class="bi bi-person-fill text-brand-primary me-1"></i>
                                                ${cita.nombrePaciente} ${cita.apellidoPaciente}
                                            </td>
                                            <td>
                                                <span class="d-block fw-semibold text-brand-dark">${cita.diaReserva}</span>
                                                <small class="text-muted"><i class="bi bi-clock me-1"></i>${cita.horaReserva}</small>
                                            </td>
                                            <td>
                                                <span class="badge bg-brand-light text-brand-dark border px-2 py-1">${cita.tipoServicio}</span>
                                            </td>
                                            <td>
                                                <span class="badge ${cita.estado == 'Confirmado' ? 'bg-brand-primary text-white' : (cita.estado == 'Completado' ? 'bg-brand-accent text-white' : 'bg-secondary text-white')} px-2 py-1">
                                                    ${cita.estado}
                                                </span>
                                            </td>

                                            <!-- Pago / Boleta -->
                                            <td>
                                                <c:choose>
                                                    <c:when test="${cita.tienePago}">
                                                        <span class="badge bg-mint text-dark px-2 py-1 d-inline-block mb-1">
                                                            <i class="bi bi-check-circle-fill text-brand-accent me-1"></i>Pagado
                                                        </span>
                                                        <div class="small font-monospace fw-bold text-brand-dark">${cita.codigoBoleta}</div>
                                                        <a href="PagoController?action=verBoleta&idCita=${cita.idCita}" target="_blank" class="btn btn-sm btn-outline-primary mt-1 py-0 px-2 rounded-pill" title="Ver Boleta Electrónica">
                                                            <i class="bi bi-receipt"></i> Boleta
                                                        </a>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge bg-warning text-dark px-2 py-1 d-inline-block mb-1">
                                                            <i class="bi bi-hourglass-split me-1"></i>Pendiente
                                                        </span>
                                                        <div>
                                                            <button type="button" class="btn btn-sm btn-outline-success mt-1 py-0 px-2 rounded-pill" data-bs-toggle="modal" data-bs-target="#modalPagoCita${cita.idCita}" title="Cobrar en Efectivo (Ventanilla)">
                                                                <i class="bi bi-cash-coin me-1"></i>Cobrar
                                                            </button>
                                                        </div>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>

                                            <!-- Acciones Cita -->
                                            <td class="text-center pe-4">
                                                <div class="d-flex justify-content-center align-items-center flex-wrap gap-1">
                                                    <c:choose>
                                                        <c:when test="${cita.estado == 'Cancelado'}">
                                                            <form action="ReprogramacionController" method="post" class="d-inline">
                                                                <input type="hidden" name="idCita" value="${cita.idCita}" />
                                                                <input type="hidden" name="accion" value="deleteCita" />
                                                                <button class="btn btn-sm btn-outline-danger rounded-pill" type="submit">Eliminar</button>
                                                            </form>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <c:choose>
                                                                <c:when test="${cita.estado == 'En espera' || cita.estado == 'Reprogramado'}">
                                                                    <form action="ReprogramacionController" method="post" class="d-inline">
                                                                        <input type="hidden" name="idCita" value="${cita.idCita}" />
                                                                        <input type="hidden" name="estado" value="${cita.estado}" />
                                                                        <input type="hidden" name="accion" value="updateEstadoConfirmarCita" />
                                                                        <button class="btn btn-sm btn-primary rounded-pill px-3" type="submit">Confirmar</button>
                                                                    </form>
                                                                </c:when>
                                                                <c:when test="${cita.estado == 'Confirmado'}">
                                                                    <form action="ReprogramacionController" method="post" class="d-inline">
                                                                        <input type="hidden" name="idCita" value="${cita.idCita}" />
                                                                        <input type="hidden" name="estado" value="${cita.estado}" />
                                                                        <input type="hidden" name="accion" value="updateEstadoCompletadoCita" />
                                                                        <button class="btn btn-sm btn-success rounded-pill px-3" type="submit">Completar</button>
                                                                    </form>
                                                                </c:when>
                                                            </c:choose>
                                                            <form action="ReprogramacionController" method="get" class="d-inline">
                                                                <input type="hidden" name="id" value="${cita.idCita}" />
                                                                <input type="hidden" name="accion" value="VerReproCi" />
                                                                <button class="btn btn-sm btn-outline-primary rounded-pill" type="submit">
                                                                    <i class="bi bi-calendar2-range"></i>
                                                                </button>
                                                            </form>
                                                            <form action="ReprogramacionController" method="post" class="d-inline">
                                                                <input type="hidden" name="idCita" value="${cita.idCita}" />
                                                                <input type="hidden" name="accion" value="updateEstadoCanceladoCita" />
                                                                <button class="btn btn-sm btn-outline-secondary rounded-pill" type="submit">
                                                                    <i class="bi bi-ban"></i>
                                                                </button>
                                                            </form>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </div>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:when>

                                <c:otherwise>
                                    <tr>
                                        <td colspan="6" class="text-center py-4 text-muted">No se registran citas ni reservas en esta bandeja.</td>
                                    </tr>
                                </c:otherwise>
                            </c:choose>
                        </tbody>
                    </table>
                </div>
            </div>
        </main>
    </div>

    <!-- Modals de Cobro y Rechazo (con paleta de marca) -->
    <c:if test="${tipoLista == 'reserva'}">
        <c:forEach var="reserva" items="${VerReserva}">
            <!-- Modal de Pago Efectivo Reserva -->
            <div class="modal fade" id="modalPagoReserva${reserva.idReserva}" tabindex="-1" aria-hidden="true">
                <div class="modal-dialog modal-dialog-centered">
                    <div class="modal-content border-0 shadow-lg" style="border-radius: 16px; overflow: hidden;">
                        <form action="PagoController" method="post">
                            <input type="hidden" name="action" value="registrarPagoEfectivo" />
                            <input type="hidden" name="idCita" value="${reserva.idReserva}" />

                            <div class="modal-header bg-brand-primary text-white border-0 py-3">
                                <h5 class="modal-title fw-bold text-white d-flex align-items-center gap-2">
                                    <i class="bi bi-cash-coin"></i> Registrar Cobro en Ventanilla
                                </h5>
                                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                            </div>
                            <div class="modal-body p-4">
                                <p class="text-muted small mb-3">
                                    Se registrará el cobro físico y se emitirá correlativamente la <strong>Boleta Electrónica (Serie B001)</strong>.
                                </p>
                                <div class="mb-3">
                                    <label class="form-label small fw-bold text-muted">Nombre del Paciente / Pagador</label>
                                    <input type="text" class="form-control" name="nombreCliente" value="${reserva.nombrePaciente} ${reserva.apellidoPaciente}" required />
                                </div>
                                <div class="mb-3">
                                    <label class="form-label small fw-bold text-muted">DNI del Pagador</label>
                                    <input type="text" class="form-control font-monospace" name="dniCliente" placeholder="DNI del pagador" maxlength="8" required />
                                </div>
                                <div class="mb-3">
                                    <label class="form-label small fw-bold text-muted">Monto del Servicio (S/)</label>
                                    <div class="input-group">
                                        <span class="input-group-text">S/</span>
                                        <input type="number" step="0.01" class="form-control font-monospace fw-bold" name="monto" value="${reserva.importe > 0 ? reserva.importe : '100.00'}" required />
                                    </div>
                                </div>
                            </div>
                            <div class="modal-footer bg-light border-0">
                                <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Cancelar</button>
                                <button type="submit" class="btn btn-success fw-bold px-4">
                                    <i class="bi bi-check-circle me-1"></i> Confirmar Cobro
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>

            <!-- Modal Rechazo de Reserva -->
            <div class="modal fade" id="modalRechazoReserva${reserva.idReserva}" tabindex="-1" aria-hidden="true">
                <div class="modal-dialog modal-dialog-centered">
                    <div class="modal-content border-0 shadow-lg" style="border-radius: 16px; overflow: hidden;">
                        <form action="ReprogramacionController" method="post">
                            <input type="hidden" name="accion" value="rechazarReservaWeb" />
                            <input type="hidden" name="idReserva" value="${reserva.idReserva}" />

                            <div class="modal-header bg-danger text-white border-0 py-3">
                                <h5 class="modal-title fw-bold text-white d-flex align-items-center gap-2">
                                    <i class="bi bi-x-circle"></i> Rechazar Reserva Web
                                </h5>
                                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                            </div>
                            <div class="modal-body p-4">
                                <div class="alert alert-warning border-0 small mb-3">
                                    <i class="bi bi-exclamation-circle me-1"></i> La reserva pasará a estado <strong>Rechazado</strong> y el motivo será notificado por correo electrónico al paciente.
                                </div>
                                <div class="mb-3">
                                    <label class="form-label small fw-bold text-muted">Motivo del Rechazo</label>
                                    <select class="form-select" name="motivo" required>
                                        <option value="Datos falsos o incompletos del paciente">Datos falsos o incompletos del paciente</option>
                                        <option value="Cruce de horario con cita presencial">Cruce de horario con cita presencial</option>
                                        <option value="Indisponibilidad imprevista del odontólogo">Indisponibilidad imprevista del odontólogo</option>
                                        <option value="Servicio requiere evaluación previa presencial">Servicio requiere evaluación previa presencial</option>
                                        <option value="Reserva duplicada por el mismo usuario">Reserva duplicada por el mismo usuario</option>
                                        <option value="Falta de pago oportuno en ventanilla">Falta de pago oportuno en ventanilla</option>
                                    </select>
                                </div>
                            </div>
                            <div class="modal-footer bg-light border-0">
                                <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Cancelar</button>
                                <button type="submit" class="btn btn-danger fw-bold px-4">
                                    <i class="bi bi-x-lg me-1"></i> Confirmar Rechazo
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </c:forEach>
    </c:if>

    <!-- Modal Pago Efectivo Cita Presencial -->
    <c:if test="${tipoLista == 'cita'}">
        <c:forEach var="cita" items="${VerCita}">
            <div class="modal fade" id="modalPagoCita${cita.idCita}" tabindex="-1" aria-hidden="true">
                <div class="modal-dialog modal-dialog-centered">
                    <div class="modal-content border-0 shadow-lg" style="border-radius: 16px; overflow: hidden;">
                        <form action="PagoController" method="post">
                            <input type="hidden" name="action" value="registrarPagoEfectivo" />
                            <input type="hidden" name="idCita" value="${cita.idCita}" />

                            <div class="modal-header bg-brand-primary text-white border-0 py-3">
                                <h5 class="modal-title fw-bold text-white d-flex align-items-center gap-2">
                                    <i class="bi bi-cash-coin"></i> Registrar Cobro Presencial
                                </h5>
                                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                            </div>
                            <div class="modal-body p-4">
                                <p class="text-muted small mb-3">
                                    Emisión de <strong>Boleta Electrónica (Serie B001)</strong> para cita en consultorio.
                                </p>
                                <div class="mb-3">
                                    <label class="form-label small fw-bold text-muted">Nombre del Paciente / Pagador</label>
                                    <input type="text" class="form-control" name="nombreCliente" value="${cita.nombrePaciente} ${cita.apellidoPaciente}" required />
                                </div>
                                <div class="mb-3">
                                    <label class="form-label small fw-bold text-muted">DNI del Pagador</label>
                                    <input type="text" class="form-control font-monospace" name="dniCliente" placeholder="DNI del pagador" maxlength="8" required />
                                </div>
                                <div class="mb-3">
                                    <label class="form-label small fw-bold text-muted">Monto del Servicio (S/)</label>
                                    <div class="input-group">
                                        <span class="input-group-text">S/</span>
                                        <input type="number" step="0.01" class="form-control font-monospace fw-bold" name="monto" value="${cita.costo > 0 ? cita.costo : '100.00'}" required />
                                    </div>
                                </div>
                            </div>
                            <div class="modal-footer bg-light border-0">
                                <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Cancelar</button>
                                <button type="submit" class="btn btn-success fw-bold px-4">
                                    <i class="bi bi-check-circle me-1"></i> Emitir Boleta
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </c:forEach>
    </c:if>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
