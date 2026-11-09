<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!doctype html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <title>Pagos Yape / Plin — ArtDent</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css?v=20261107">
</head>
<body class="bg-light">
<%@include file="/header.jsp"%>
<main class="container py-4" style="max-width:960px">
    <div class="d-flex justify-content-between align-items-center flex-wrap gap-2 mb-3">
        <h1 class="h3 mb-0 text-brand-dark"><i class="bi bi-phone text-brand-primary me-2"></i>Pagos Yape / Plin</h1>
        <c:choose>
            <c:when test="${personalPagos}"><a class="btn btn-outline-secondary" href="${pageContext.request.contextPath}/ReservaController?accion=listarReservasPorDia"><i class="bi bi-arrow-left me-1"></i>Volver al calendario</a></c:when>
            <c:otherwise><a class="btn btn-outline-secondary" href="${pageContext.request.contextPath}/consultareserva.jsp"><i class="bi bi-arrow-left me-1"></i>Volver a Mi reserva</a></c:otherwise>
        </c:choose>
    </div>
    <c:if test="${param.guardado == '1'}"><p class="alert alert-success" role="status"><i class="bi bi-check-circle me-1"></i>Cambio guardado. Un comprobante pendiente todavía no cuenta como pago.</p></c:if>
    <c:if test="${not personalPagos && not empty citaPago}">
        <section class="card border-0 shadow-sm p-4 my-3">
            <h2 class="h5">Comprobantes de la reserva <c:out value="${citaPago}"/></h2>
            <c:choose>
                <c:when test="${permiteSolicitud}">
                    <p>Importe completo: S/ <strong><c:out value="${importePago}"/></strong>. La clínica verificará el movimiento antes de confirmar el pago.</p>
                    <c:choose>
                        <c:when test="${canalConfigurado}">
                            <p class="p-3 bg-brand-light rounded-3">Titular: <strong><c:out value="${titularPago}"/></strong> · Número: <strong><c:out value="${numeroPago}"/></strong></p>
                            <form action="${pageContext.request.contextPath}/PagoManualController" method="post" enctype="multipart/form-data">
                                <input type="hidden" name="accion" value="solicitar"><input type="hidden" name="cita" value="${citaPago}"><input type="hidden" name="formToken" value="${sessionScope.formToken}">
                                <label class="form-label" for="canal">Canal</label><select class="form-select mb-2" name="canal" id="canal"><option value="YAPE">Yape</option><option value="PLIN">Plin</option></select>
                                <label class="form-label" for="codigo">Código de operación</label><input class="form-control mb-2" name="codigo" id="codigo" required minlength="4" maxlength="40" pattern="[A-Za-z0-9-]{4,40}">
                                <label class="form-label" for="nombre">Nombre del titular de la boleta</label><input class="form-control mb-2" name="nombre" id="nombre" required minlength="3" maxlength="100">
                                <label class="form-label" for="dni">DNI del titular</label><input class="form-control mb-2" name="dni" id="dni" required pattern="[0-9]{8}" maxlength="8" inputmode="numeric">
                                <label class="form-label" for="comprobante">Comprobante JPEG o PNG (máximo 5 MB y 12 megapíxeles)</label><input class="form-control mb-3" type="file" name="comprobante" id="comprobante" accept="image/png,image/jpeg" required>
                                <button class="btn btn-primary"><i class="bi bi-upload me-1"></i>Enviar para verificación</button>
                            </form>
                        </c:when>
                        <c:otherwise><p class="alert alert-info mb-0">Yape/Plin está pendiente de configuración. Puede pagar en ventanilla.</p></c:otherwise>
                    </c:choose>
                </c:when>
                <c:otherwise><p class="alert alert-info mb-0">No envíe otro pago mientras la cita esté pagada, anulada o tenga un comprobante pendiente. Revise el estado de sus solicitudes y devoluciones.</p></c:otherwise>
            </c:choose>
        </section>
    </c:if>
    <h2 class="h5 mt-4">Solicitudes recientes</h2>
    <c:if test="${empty solicitudes}"><p class="text-muted">No hay solicitudes.</p></c:if>
    <c:forEach var="s" items="${solicitudes}">
        <section class="card border-0 shadow-sm p-3 mb-3">
            <h3 class="h6">Reserva <c:out value="${s.cita}"/> · <c:out value="${s.canal}"/> · S/ <c:out value="${s.monto}"/></h3>
            <p class="mb-1">Operación <c:out value="${s.codigo}"/> · <strong><c:out value="${s.estado}"/></strong> · <c:out value="${s.creada}"/></p>
            <c:if test="${not empty s.motivo}"><p class="text-danger small">Motivo: <c:out value="${s.motivo}"/></p></c:if>
            <a href="${pageContext.request.contextPath}/PagoManualController?accion=adjunto&amp;id=${s.id}" target="_blank" rel="noopener">Ver comprobante adjunto</a>
            <c:if test="${personalPagos && s.estado == 'PENDIENTE'}">
                <form action="${pageContext.request.contextPath}/PagoManualController" method="post" class="mt-3">
                    <input type="hidden" name="id" value="${s.id}"><input type="hidden" name="formToken" value="${sessionScope.formToken}"><input type="hidden" name="accion" value="aprobar">
                    <label class="small"><input type="checkbox" name="verificado" value="si" required> Verifiqué canal, código, titular e importe en el movimiento bancario.</label>
                    <button class="btn btn-success btn-sm mt-1">Aprobar pago</button>
                </form>
                <form action="${pageContext.request.contextPath}/PagoManualController" method="post" class="mt-2">
                    <input type="hidden" name="id" value="${s.id}"><input type="hidden" name="formToken" value="${sessionScope.formToken}"><input type="hidden" name="accion" value="rechazar">
                    <label for="motivo${s.id}" class="form-label small">Motivo del rechazo</label>
                    <input class="form-control mb-2" name="motivo" id="motivo${s.id}" maxlength="300" required>
                    <button class="btn btn-outline-danger btn-sm">Rechazar comprobante</button>
                </form>
            </c:if>
        </section>
    </c:forEach>
    <h2 class="h5 mt-4">Devoluciones</h2>
    <c:if test="${empty devoluciones}"><p class="text-muted">No hay devoluciones.</p></c:if>
    <c:forEach var="d" items="${devoluciones}">
        <section class="card border-0 shadow-sm p-3 mb-3">
            <p>Reserva <c:out value="${d.cita}"/> · S/ <c:out value="${d.monto}"/> · <strong><c:out value="${d.estado}"/></strong></p>
            <c:if test="${d.estado == 'REALIZADA'}"><p class="small">Referencia: <c:out value="${d.referencia}"/> · <c:out value="${d.realizada}"/></p></c:if>
            <c:if test="${personalPagos && d.estado == 'PENDIENTE'}">
                <form action="${pageContext.request.contextPath}/PagoManualController" method="post">
                    <input type="hidden" name="accion" value="devolver"><input type="hidden" name="pago" value="${d.pago}"><input type="hidden" name="formToken" value="${sessionScope.formToken}">
                    <label for="ref${d.pago}" class="form-label small">Referencia de la devolución efectuada por el importe completo</label>
                    <input class="form-control mb-2" name="referencia" id="ref${d.pago}" required maxlength="100">
                    <button class="btn btn-primary btn-sm">Registrar devolución realizada</button>
                </form>
            </c:if>
        </section>
    </c:forEach>
    <p class="text-muted small">Se muestran hasta 100 registros recientes.</p>
</main>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
