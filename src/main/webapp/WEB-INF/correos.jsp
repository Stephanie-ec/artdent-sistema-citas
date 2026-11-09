<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!doctype html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <title>Entregas de correo — ArtDent</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css?v=20261107">
</head>
<body class="bg-light">
<%@include file="/header.jsp"%>
<main class="container py-4" style="max-width:960px">
    <div class="d-flex justify-content-between align-items-center flex-wrap gap-2 mb-3">
        <div>
            <h1 class="h3 mb-1 text-brand-dark"><i class="bi bi-envelope-paper text-brand-primary me-2"></i>Entregas de correo</h1>
            <p class="text-muted mb-0">Hasta 100 entregas recientes. Se realizan hasta tres intentos automáticos por destinatario cuando el correo está habilitado.</p>
        </div>
        <a class="btn btn-outline-secondary" href="${pageContext.request.contextPath}/ReservaController?accion=listarReservasPorDia">
            <i class="bi bi-arrow-left me-1"></i>Volver al calendario
        </a>
    </div>
    <c:if test="${empty correos}"><div class="alert alert-info">Todavía no hay entregas registradas.</div></c:if>
    <c:forEach var="correo" items="${correos}">
        <section class="card border-0 shadow-sm p-3 mb-2">
            <div class="d-flex justify-content-between align-items-start gap-2 flex-wrap">
                <p class="mb-1"><span class="badge text-bg-light border me-1">Cita <c:out value="${correo.Cita_idCita}"/></span><strong><c:out value="${correo.Asunto}"/></strong></p>
                <span class="badge ${correo.Estado == 'ENVIADO' ? 'text-bg-success' : 'text-bg-warning'}"><c:out value="${correo.Estado}"/></span>
            </div>
            <p class="mb-1 small text-muted"><i class="bi bi-person me-1"></i><c:out value="${correo.Destinatario}"/> · Intentos: <c:out value="${correo.Intentos}"/></p>
            <c:if test="${not empty correo.UltimoError}"><p class="small text-danger mb-1"><c:out value="${correo.UltimoError}"/></p></c:if>
            <c:if test="${correo.Estado != 'ENVIADO'}">
                <form method="post" action="${pageContext.request.contextPath}/CorreoController" class="mt-2">
                    <input type="hidden" name="id" value="${correo.idCorreo}">
                    <input type="hidden" name="formToken" value="${sessionScope.formToken}">
                    <button class="btn btn-outline-primary btn-sm"><i class="bi bi-arrow-repeat me-1"></i>Reintentar entrega</button>
                </form>
                <p class="small text-muted mb-0 mt-1">Un envío en curso debe terminar o superar diez minutos antes de reintentarse.</p>
            </c:if>
        </section>
    </c:forEach>
</main>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
