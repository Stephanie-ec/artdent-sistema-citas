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
            <p class="text-muted mb-0">Ingresa el código de tu reserva y tu DNI para ver su estado o volver a descargar tu boleta.</p>
        </div>

        <c:if test="${param.error == 'datos'}">
            <div class="alert alert-warning">Ingresa el código (por ejemplo ART-RES-00018) y un DNI de 8 dígitos.</div>
        </c:if>
        <c:if test="${param.error == 'noexiste'}">
            <div class="alert alert-danger">No encontramos una reserva con ese código y ese DNI. Revisa los datos.</div>
        </c:if>
        <c:if test="${param.error == 'permiso'}">
            <div class="alert alert-info">Para proteger tus datos, la boleta solo se muestra después de verificar tu código y tu DNI.</div>
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
                                <c:when test="${reserva.boletaDisponible}"><a class="btn btn-outline-primary d-block" href="PagoController?action=verBoleta&amp;idCita=${reserva.idCita}">Ver / Descargar Boleta</a></c:when>
                                <c:otherwise><p class="text-muted">El pago está registrado, pero no hay una boleta disponible. Comuníquese con la clínica; no vuelva a pagar.</p></c:otherwise>
                            </c:choose>
                            <c:if test="${reserva.estadoId == 5 || reserva.estadoId == 6}">
                                <div class="alert alert-warning mt-3" role="status">Su pago y boleta se conservan. <a href="PagoManualController?cita=${reserva.idCita}">Consultar estado de la devolución</a>.</div>
                            </c:if>
                        </c:when>
                        <c:when test="${reserva.estadoId != 5 && reserva.estadoId != 6}">
                            <p class="text-muted">Pago pendiente. Puede pagar con Yape/Plin o en ventanilla.</p>
                            <a class="btn btn-success" href="PagoManualController?cita=${reserva.idCita}">Enviar / consultar comprobante Yape / Plin</a>
                        </c:when>
                        <c:otherwise><div class="alert alert-secondary mb-0">Esta cita está anulada y no admite pagos.</div></c:otherwise>
                    </c:choose>

                </div>
            </div>
        </c:if>

    </main>

    <%@include file="footer.jsp"%>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <script src="${pageContext.request.contextPath}/js/validacion-campos.js"></script>
</body>
</html>
