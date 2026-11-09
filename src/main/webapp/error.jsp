<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Art Dent | Aviso</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
        <link href="${pageContext.request.contextPath}/css/style.css?v=20261107" rel="stylesheet">
    </head>
    <body class="bg-light d-flex align-items-center justify-content-center" style="min-height: 100vh;">
        <div class="card shadow-sm border-0 text-center p-4" style="max-width: 460px;">
            <a class="d-inline-flex align-items-center justify-content-center gap-2 mb-3 text-decoration-none" href="${pageContext.request.contextPath}/index.jsp">
                <img src="${pageContext.request.contextPath}/img/logo-artdent.png" alt="Art Dent" width="44" height="44">
                <span class="fw-bold fs-4 text-brand-dark">Art <span class="text-brand-primary">Dent</span></span>
            </a>
            <i class="bi bi-shield-exclamation text-danger" style="font-size: 3rem;"></i>
            <h1 class="h4 mt-2">No se pudo completar la acción</h1>
            <p class="text-muted mb-4">
                <c:choose>
                    <c:when test="${not empty requestScope.error}"><c:out value="${requestScope.error}"/></c:when>
                    <c:otherwise>Ocurrió un problema al procesar su solicitud.</c:otherwise>
                </c:choose>
            </p>
            <div class="d-flex gap-2 justify-content-center">
                <c:choose>
                    <c:when test="${not empty volverUrl}"><a href="${pageContext.request.contextPath}/ReservaController?accion=listarReservasPorDia" class="btn btn-outline-secondary rounded-pill px-3">Volver a la agenda</a></c:when>
                    <c:otherwise><a href="${pageContext.request.contextPath}/index.jsp" class="btn btn-outline-secondary rounded-pill px-3">Volver</a></c:otherwise>
                </c:choose>
                <a href="${pageContext.request.contextPath}/index.jsp" class="btn btn-primary rounded-pill px-3">Ir al inicio</a>
            </div>
        </div>
    </body>
</html>
