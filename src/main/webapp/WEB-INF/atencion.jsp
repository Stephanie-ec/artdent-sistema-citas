<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!doctype html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <title>Ficha de atención — ArtDent</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css?v=20261107">
</head>
<body class="bg-light">
<%@include file="/header.jsp"%>
<main class="container py-4" style="max-width:820px">
    <div class="d-flex justify-content-between align-items-center flex-wrap gap-2 mb-3">
        <div>
            <h1 class="h3 mb-1 text-brand-dark"><i class="bi bi-clipboard2-pulse text-brand-primary me-2"></i>Ficha de atención</h1>
            <p class="text-muted mb-0">Cita <c:out value="${ficha.idCita}"/> · <c:out value="${ficha.paciente}"/></p>
        </div>
        <a class="btn btn-outline-secondary" href="${pageContext.request.contextPath}/ReservaController?accion=listarReservasPorDia">
            <i class="bi bi-arrow-left me-1"></i>Volver al calendario
        </a>
    </div>
    <c:if test="${param.guardado == '1'}"><p class="alert alert-success" role="status"><i class="bi bi-check-circle me-1"></i>Ficha guardada y atención finalizada.</p></c:if>
    <c:choose>
        <c:when test="${not empty ficha.Registrada}">
            <dl class="card border-0 shadow-sm p-4 mb-0">
                <dt>Diagnóstico</dt><dd style="white-space:pre-wrap"><c:out value="${ficha.Diagnostico}"/></dd>
                <dt>Tratamiento realizado</dt><dd style="white-space:pre-wrap"><c:out value="${ficha.Tratamiento}"/></dd>
                <dt>Observaciones</dt><dd style="white-space:pre-wrap"><c:out value="${ficha.Observaciones}"/></dd>
                <dt>Registrada por</dt><dd class="mb-0"><c:out value="${ficha.autor}"/> · <c:out value="${ficha.Registrada}"/></dd>
            </dl>
        </c:when>
        <c:when test="${ficha.Estado_idEstado == 3 || ficha.Estado_idEstado == 4}">
            <form action="${pageContext.request.contextPath}/AtencionController" method="post" class="card border-0 shadow-sm p-4">
                <input type="hidden" name="cita" value="${ficha.idCita}">
                <input type="hidden" name="formToken" value="${sessionScope.formToken}">
                <label for="diagnostico" class="form-label">Diagnóstico</label>
                <textarea id="diagnostico" name="diagnostico" class="form-control mb-3" maxlength="2000" rows="4" required></textarea>
                <label for="tratamiento" class="form-label">Tratamiento realizado</label>
                <textarea id="tratamiento" name="tratamiento" class="form-control mb-3" maxlength="2000" rows="4" required></textarea>
                <label for="observaciones" class="form-label">Observaciones (opcional)</label>
                <textarea id="observaciones" name="observaciones" class="form-control mb-3" maxlength="2000" rows="3"></textarea>
                <p class="text-muted small">Revise los datos antes de guardar. La ficha conserva el autor y la fecha y finaliza la atención.</p>
                <button class="btn btn-success"><i class="bi bi-check2-circle me-1"></i>Guardar ficha y finalizar atención</button>
            </form>
        </c:when>
        <c:otherwise><p class="alert alert-info">No hay ficha registrada. El estado de esta cita no permite finalizar una nueva atención.</p></c:otherwise>
    </c:choose>
</main>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
