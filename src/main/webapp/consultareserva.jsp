<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Consultar mi reserva - Art Dent</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Open+Sans:wght@400;600;700&family=Roboto:wght@500;700;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css?v=20261103">
</head>
<body class="bg-brand-light">
    <%@include file="header.jsp"%>

    <main class="container py-5" style="max-width: 720px;">
        <div class="text-center mb-4">
            <h1 class="h3 fw-bold text-brand-dark">Consultar mi reserva</h1>
            <p class="text-muted mb-0">Ingresa el código de tu reserva y tu DNI para ver su estado o volver a descargar tu comprobante de pago.</p>
        </div>

        <c:if test="${param.error == 'datos'}">
            <div class="alert alert-warning">Ingresa el código (por ejemplo ART-RES-00018) y un DNI de 8 dígitos.</div>
        </c:if>
        <c:if test="${param.error == 'noexiste'}">
            <div class="alert alert-danger">No encontramos una reserva con ese código y ese DNI. Revisa los datos.</div>
        </c:if>
        <c:if test="${param.error == 'permiso'}">
            <div class="alert alert-info">Para proteger tus datos, el comprobante solo se muestra después de verificar tu código y tu DNI.</div>
        </c:if>
        <c:if test="${param.ok == 'cancelada'}">
            <div class="alert alert-success">Su reserva fue cancelada. Si tenía un pago, la devolución queda pendiente con la clínica.</div>
        </c:if>
        <c:if test="${param.ok == 'reprogramada'}">
            <div class="alert alert-success">Su cita fue reprogramada. Revise la nueva fecha y hora.</div>
        </c:if>
        <c:if test="${param.error == 'regla'}">
            <div class="alert alert-warning"><c:out value="${param.detalle}"/></div>
        </c:if>
        <c:if test="${param.error == 'formato'}">
            <div class="alert alert-warning">Indique una fecha (AAAA-MM-DD) y una hora válidas.</div>
        </c:if>
        <c:if test="${param.error == 'general'}">
            <div class="alert alert-danger">No pudimos modificar la reserva en este momento. Intente nuevamente o llame a la clínica.</div>
        </c:if>

        <div class="card border-0 shadow-sm" style="border-radius: 16px;">
            <div class="card-body p-4">
                <form action="PagoController" method="get" class="row g-3">
                    <input type="hidden" name="action" value="consultar">
                    <div class="col-12 col-md-6">
                        <label for="codigo" class="form-label fw-semibold">Código de reserva</label>
                        <input type="text" class="form-control text-uppercase" id="codigo" name="codigo" placeholder="ART-RES-00018" maxlength="15" required>
                    </div>
                    <div class="col-12 col-md-6">
                        <label for="dni" class="form-label fw-semibold">DNI del paciente</label>
                        <input type="text" class="form-control" id="dni" name="dni" placeholder="8 dígitos" maxlength="8" inputmode="numeric" pattern="\d{8}" required>
                    </div>
                    <div class="col-12 text-end">
                        <button type="submit" class="btn btn-primary px-4">Consultar</button>
                    </div>
                </form>
            </div>
        </div>

        <c:if test="${not empty reserva}">
            <div class="card border-0 shadow-sm mt-4" style="border-radius: 16px;">
                <div class="card-body p-4">
                    <div class="d-flex justify-content-between align-items-center mb-3">
                        <span class="fw-bold font-monospace fs-5"><c:out value="${codigo}"/></span>
                        <span class="badge ${reserva.estadoId == 5 || reserva.estadoId == 6 ? 'bg-danger' : reserva.estadoId == 2 ? 'bg-success' : reserva.estadoId == 3 ? 'bg-primary' : 'bg-warning text-dark'} px-3 py-2"><c:out value="${reserva.estado}"/></span>
                    </div>
                    <p class="mb-1"><strong>Paciente:</strong> <c:out value="${reserva.paciente}"/></p>
                    <p class="mb-1"><strong>Tratamiento:</strong> <c:out value="${reserva.servicio}"/></p>
                    <p class="mb-1"><strong>Odontólogo:</strong> <c:out value="${reserva.odontologo}"/></p>
                    <p class="mb-1"><strong>Fecha y hora:</strong> <c:out value="${reserva.fecha}"/> · <c:out value="${reserva.hora}"/></p>
                    <p class="mb-3"><strong>Importe:</strong> S/ <c:out value="${reserva.importe}"/></p>
                    <c:choose>
                        <c:when test="${reserva.pagado}">
                            <span class="badge bg-success mb-3">Pagado</span>
                            <c:choose>
                                <c:when test="${reserva.boletaDisponible}"><a class="btn btn-outline-primary d-block" href="PagoController?action=verBoleta&amp;idCita=${reserva.idCita}">Ver / Descargar comprobante</a></c:when>
                                <c:otherwise><p class="text-muted">El pago está registrado, pero no hay un comprobante disponible. Comuníquese con la clínica; no vuelva a pagar.</p></c:otherwise>
                            </c:choose>
                            <c:if test="${reserva.estadoId == 5 || reserva.estadoId == 6}">
                                <div class="alert alert-warning mt-3" role="status">Su pago y comprobante se conservan. <a href="PagoManualController?cita=${reserva.idCita}">Consultar estado de la devolución</a>.</div>
                            </c:if>
                        </c:when>
                        <c:when test="${reserva.estadoId != 5 && reserva.estadoId != 6}">
                            <p class="text-muted">Pago pendiente. Puede pagar con Yape/Plin o en ventanilla.</p>
                            <a class="btn btn-success" href="PagoManualController?cita=${reserva.idCita}">Enviar / consultar comprobante Yape / Plin</a>
                        </c:when>
                        <c:otherwise><div class="alert alert-secondary mb-0">Esta cita está anulada y no admite pagos.</div></c:otherwise>
                    </c:choose>

                    <c:if test="${reserva.estadoId == 1 || reserva.estadoId == 3 || reserva.estadoId == 4}">
                        <hr class="my-4">
                        <h6 class="fw-bold">¿No puedes asistir?</h6>
                        <p class="text-muted small">Puedes cancelar o reprogramar hasta 24 horas antes de tu cita. Con menos tiempo, comunícate con la clínica.</p>
                        <form action="MiReserva" method="post" class="d-inline" onsubmit="return confirm('¿Cancelar esta reserva?');">
                            <input type="hidden" name="formToken" value="${formToken}">
                            <input type="hidden" name="accion" value="cancelar">
                            <input type="hidden" name="idCita" value="${reserva.idCita}">
                            <button type="submit" class="btn btn-outline-danger">Cancelar mi cita</button>
                        </form>
                        <form action="MiReserva" method="post" class="row g-2 mt-3">
                            <input type="hidden" name="formToken" value="${formToken}">
                            <input type="hidden" name="accion" value="reprogramar">
                            <input type="hidden" name="idCita" value="${reserva.idCita}">
                            <div class="col-12 col-md-5">
                                <label class="form-label small mb-1" for="nuevaFecha">Nueva fecha</label>
                                <input type="date" class="form-control" id="nuevaFecha" name="fecha" required>
                            </div>
                            <div class="col-12 col-md-4">
                                <label class="form-label small mb-1" for="nuevaHora">Nueva hora</label>
                                <input type="time" class="form-control" id="nuevaHora" name="hora" min="08:00" max="18:30" required>
                            </div>
                            <div class="col-12 col-md-3 d-flex align-items-end">
                                <button type="submit" class="btn btn-outline-primary w-100">Reprogramar</button>
                            </div>
                        </form>
                    </c:if>

                </div>
            </div>
        </c:if>

    </main>

    <%@include file="footer.jsp"%>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <script src="${pageContext.request.contextPath}/js/validacion-campos.js"></script>
</body>
</html>
