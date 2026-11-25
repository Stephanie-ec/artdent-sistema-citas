<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Resultado del pago — ArtDent</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css?v=20261107">
</head>
<body class="bg-brand-light">
<%@include file="header.jsp"%>
<main class="container py-5" style="max-width:640px">
    <section class="card border-0 shadow-sm p-4 text-center">
        <c:choose>
            <c:when test="${estadoPago == 'APROBADO'}">
                <i class="bi bi-check-circle-fill text-success" style="font-size:3rem"></i>
                <h1 class="h4 mt-2">Pago aprobado</h1>
            </c:when>
            <c:when test="${estadoPago == 'PENDIENTE'}">
                <i class="bi bi-hourglass-split text-warning" style="font-size:3rem"></i>
                <h1 class="h4 mt-2">Pago en revisión</h1>
            </c:when>
            <c:otherwise>
                <i class="bi bi-x-circle-fill text-danger" style="font-size:3rem"></i>
                <h1 class="h4 mt-2">Pago no completado</h1>
            </c:otherwise>
        </c:choose>
        <p class="text-muted mt-3 mb-2"><c:out value="${mensaje}"/></p>
        <c:if test="${not empty codigoReserva}">
            <p class="mb-1">Reserva: <strong><c:out value="${codigoReserva}"/></strong></p>
        </c:if>
        <c:if test="${not empty codigoBoleta}">
            <p class="mb-3">Comprobante de pago interno: <strong><c:out value="${codigoBoleta}"/></strong></p>
        </c:if>
        <p class="small text-muted">Documento interno de Art Dent. No es comprobante electrónico SUNAT.</p>
        <div class="d-flex gap-2 justify-content-center flex-wrap mt-3">
            <c:if test="${estadoPago == 'APROBADO' and not empty codigoBoleta}">
                <a class="btn btn-primary" href="${pageContext.request.contextPath}/PagoController?action=verBoleta&amp;idCita=${idCita}&amp;yaPagado=1">Ver comprobante</a>
            </c:if>
            <a class="btn btn-outline-secondary" href="${pageContext.request.contextPath}/consultareserva.jsp">Mi reserva</a>
            <a class="btn btn-outline-secondary" href="${pageContext.request.contextPath}/index.jsp">Inicio</a>
        </div>
    </section>
</main>
<%@include file="footer.jsp"%>
</body>
</html>
