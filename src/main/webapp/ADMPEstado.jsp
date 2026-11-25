<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="refresh" content="30">
    <title>Estado del servicio | Centro Odontológico ArtDent</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    <link rel="stylesheet" href="css/style.css?v=20261102b">
</head>
<body class="d-flex flex-column min-vh-100 bg-light">
    <%
    String usuarioEstado = (String) request.getSession().getAttribute("Nombre");
    if (usuarioEstado == null) {
        response.sendRedirect("iniciosesionerror.jsp");
        return;
    }
    %>
    <%@include file="NavPanel.jsp" %>

    <div class="container-fluid flex-grow-1 d-flex">
        <div class="row flex-grow-1 w-100 g-0">
            <%@include file="ADMPSlidebar.jsp"%>

            <main class="col-md-9 ms-sm-auto col-lg-10 p-4">
                <div class="d-flex justify-content-between flex-wrap align-items-center pb-3 mb-4 border-bottom">
                    <div>
                        <h2 class="h3 fw-bold mb-1" style="color: var(--artdent-primary);">
                            <i class="bi bi-activity me-2" style="color: var(--artdent-accent);"></i>Estado del servicio
                        </h2>
                        <p class="text-muted small mb-0">Se actualiza cada 30 segundos. Los datos personales nunca se muestran aquí.</p>
                    </div>
                    <a class="btn btn-outline-primary" href="salud" target="_blank" rel="noopener"><i class="bi bi-braces me-1"></i>Ver /salud (JSON)</a>
                </div>

                <div class="alert ${salud.baseDatosOk ? 'alert-success' : 'alert-danger'} d-flex align-items-center" role="status">
                    <i class="bi ${salud.baseDatosOk ? 'bi-check-circle-fill' : 'bi-x-octagon-fill'} fs-4 me-2"></i>
                    <div>
                        <strong>
                            <c:choose>
                                <c:when test="${salud.baseDatosOk}">Servicio operativo</c:when>
                                <c:otherwise>Servicio degradado: la base de datos no responde (/salud devuelve 503)</c:otherwise>
                            </c:choose>
                        </strong>
                        <div class="small">Latencia de la consulta de control: ${salud.latenciaMs} ms · Versión ${salud.version} · Activo hace ${salud.uptimeSegundos} s</div>
                    </div>
                </div>

                <div class="row g-3 mb-4">
                    <div class="col-md-6 col-xl-3">
                        <div class="card border-0 shadow-sm rounded-4 h-100">
                            <div class="card-body">
                                <div class="text-muted small text-uppercase fw-bold">1. Disponibilidad</div>
                                <div class="fs-3 fw-bold ${salud.baseDatosOk ? 'text-success' : 'text-danger'}">${salud.disponibilidad}</div>
                                <div class="small text-muted">Objetivo ≥ 99 % · método: consultas a /salud y caídas de BD registradas.</div>
                                <div class="small mt-1">Caídas de base de datos en 24 h: <strong>${salud.caidas24h}</strong></div>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-6 col-xl-3">
                        <div class="card border-0 shadow-sm rounded-4 h-100">
                            <div class="card-body">
                                <div class="text-muted small text-uppercase fw-bold">2. p95 de la reserva</div>
                                <div class="fs-3 fw-bold ${salud.p95ReservaMs <= 2000 ? 'text-success' : 'text-danger'}">${salud.p95ReservaMs} ms</div>
                                <div class="small text-muted">Objetivo ≤ 2 000 ms · método: duración de las últimas ${salud.muestrasReserva} reservas enviadas.</div>
                                <c:if test="${salud.muestrasReserva == 0}"><div class="small text-warning mt-1">Sin muestras todavía: realice una reserva para medir.</div></c:if>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-6 col-xl-3">
                        <div class="card border-0 shadow-sm rounded-4 h-100">
                            <div class="card-body">
                                <div class="text-muted small text-uppercase fw-bold">3. Correos fallidos</div>
                                <div class="fs-3 fw-bold ${salud.correosFallidos == 0 ? 'text-success' : 'text-danger'}">${salud.correosFallidos}</div>
                                <div class="small text-muted">Objetivo 0 en 24 h · método: cola de correos con reintentos agotados.</div>
                                <div class="small mt-1">Pendientes en cola: <strong>${salud.correosPendientes}</strong></div>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-6 col-xl-3">
                        <div class="card border-0 shadow-sm rounded-4 h-100">
                            <div class="card-body">
                                <div class="text-muted small text-uppercase fw-bold">4. Inicios de sesión fallidos</div>
                                <div class="fs-3 fw-bold ${salud.tasaFallosLogin <= 20 ? 'text-success' : 'text-danger'}">${salud.tasaFallosLogin} %</div>
                                <div class="small text-muted">Objetivo ≤ 20 % en 24 h · método: eventos de seguridad del registro.</div>
                                <div class="small mt-1">Intentos contabilizados: <strong>${salud.intentosLogin}</strong></div>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="card border-0 shadow-sm rounded-4">
                    <div class="card-header bg-white py-3 fw-bold">Infraestructura</div>
                    <div class="card-body">
                        <div class="row text-center g-3">
                            <div class="col-6 col-md-3"><div class="small text-muted">Pool HikariCP activas</div><div class="fs-4 fw-bold">${salud.poolActivas}</div></div>
                            <div class="col-6 col-md-3"><div class="small text-muted">Pool HikariCP inactivas</div><div class="fs-4 fw-bold">${salud.poolInactivas}</div></div>
                            <div class="col-6 col-md-3"><div class="small text-muted">Conexiones totales</div><div class="fs-4 fw-bold">${salud.poolTotal}</div></div>
                            <div class="col-6 col-md-3"><div class="small text-muted">Base de datos</div><div class="fs-4 fw-bold ${salud.baseDatosOk ? 'text-success' : 'text-danger'}">${salud.baseDatosOk ? 'OK' : 'CAÍDA'}</div></div>
                        </div>
                        <p class="small text-muted mb-0 mt-3">
                            Evidencia de disponibilidad: un monitor externo gratuito (por ejemplo UptimeRobot) puede consultar
                            <code>/salud</code> cada 5 minutos; su historial sirve como prueba del indicador 1.
                        </p>
                    </div>
                </div>
            </main>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
