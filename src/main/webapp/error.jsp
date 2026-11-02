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
    </head>
    <body class="bg-light d-flex align-items-center justify-content-center" style="min-height: 100vh;">
        <div class="card shadow-sm border-0 text-center p-4" style="max-width: 460px;">
            <i class="bi bi-shield-exclamation text-danger" style="font-size: 3rem;"></i>
            <h1 class="h4 mt-2">No se pudo completar la acción</h1>
            <p class="text-muted mb-4">
                <c:choose>
                    <c:when test="${not empty requestScope.error}"><c:out value="${requestScope.error}"/></c:when>
                    <c:otherwise>Ocurrió un problema al procesar su solicitud.</c:otherwise>
                </c:choose>
            </p>
            <div class="d-flex gap-2 justify-content-center">
                <a href="javascript:history.back()" class="btn btn-outline-secondary rounded-pill px-3">Volver</a>
                <a href="${pageContext.request.contextPath}/index.jsp" class="btn btn-primary rounded-pill px-3">Ir al inicio</a>
            </div>
        </div>
    </body>
</html>
