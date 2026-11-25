<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Eventos y alertas | Centro Odontológico ArtDent</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    <link rel="stylesheet" href="css/style.css?v=20261102b">
</head>
<body class="d-flex flex-column min-vh-100 bg-light">
    <%
    String usuarioEventos = (String) request.getSession().getAttribute("Nombre");
    if (usuarioEventos == null) {
        response.sendRedirect("iniciosesionerror.jsp");
        return;
    }
    %>
    <%@include file="NavPanel.jsp" %>

    <div class="container-fluid flex-grow-1 d-flex">
        <div class="row flex-grow-1 w-100 g-0">
            <%@include file="ADMPSlidebar.jsp"%>

            <main class="col-md-9 ms-sm-auto col-lg-10 p-4">
                <c:if test="${param.msg == 'atendido'}">
                    <div class="alert alert-success" role="status"><i class="bi bi-check-circle-fill me-2"></i>Alerta marcada como atendida con su acción y usuario.</div>
                </c:if>
                <c:if test="${param.msg == 'sinCambios'}">
                    <div class="alert alert-warning" role="status">La alerta ya estaba atendida o no existe.</div>
                </c:if>
                <c:if test="${not empty param.error}">
                    <div class="alert alert-danger" role="alert">
                        <c:choose>
                            <c:when test="${param.error == 'accion'}">Escriba la acción tomada (mínimo 5 caracteres) antes de marcar la alerta como atendida.</c:when>
                            <c:when test="${param.error == 'token'}">La solicitud expiró. Recargue la página e intente nuevamente.</c:when>
                            <c:otherwise>No se pudo completar la operación.</c:otherwise>
                        </c:choose>
                    </div>
                </c:if>

                <div class="d-flex justify-content-between flex-wrap align-items-center pb-3 mb-4 border-bottom">
                    <div>
                        <h2 class="h3 fw-bold mb-1" style="color: var(--artdent-primary);">
                            <i class="bi bi-journal-text me-2" style="color: var(--artdent-accent);"></i>Eventos y alertas
                        </h2>
                        <p class="text-muted small mb-0">Registro de lo que ocurre en el sistema. Las alertas son eventos de nivel ERROR sin atender.</p>
                    </div>
                </div>

                <form class="row g-2 align-items-end mb-3" action="EventoController" method="get">
                    <div class="col-sm-4 col-md-3">
                        <label class="form-label small fw-bold text-muted" for="nivel">Nivel</label>
                        <select class="form-select" id="nivel" name="nivel">
                            <option value="">Todos</option>
                            <option value="INFO" ${nivelFiltro == 'INFO' ? 'selected' : ''}>INFO</option>
                            <option value="ADVERTENCIA" ${nivelFiltro == 'ADVERTENCIA' ? 'selected' : ''}>ADVERTENCIA</option>
                            <option value="ERROR" ${nivelFiltro == 'ERROR' ? 'selected' : ''}>ERROR</option>
                        </select>
                    </div>
                    <div class="col-sm-4 col-md-3">
                        <div class="form-check mt-4">
                            <input class="form-check-input" type="checkbox" id="pendientes" name="pendientes" value="1" ${soloPendientes ? 'checked' : ''}>
                            <label class="form-check-label small" for="pendientes">Solo sin atender</label>
                        </div>
                    </div>
                    <div class="col-sm-4 col-md-3">
                        <button type="submit" class="btn btn-primary"><i class="bi bi-funnel me-1"></i>Filtrar</button>
                        <a href="EventoController" class="btn btn-outline-secondary">Limpiar</a>
                    </div>
                </form>

                <div class="card border-0 shadow-sm rounded-4 overflow-hidden">
                    <div class="table-responsive">
                        <table class="table table-hover align-middle mb-0">
                            <thead style="background-color: #edf7fa;">
                                <tr>
                                    <th class="ps-3 py-3">Fecha</th>
                                    <th class="py-3">Nivel</th>
                                    <th class="py-3">Origen</th>
                                    <th class="py-3">Mensaje</th>
                                    <th class="py-3">Estado</th>
                                    <th class="py-3 text-center">Acción</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="e" items="${eventos}">
                                    <tr>
                                        <td class="ps-3 small text-muted font-monospace"><fmt:formatDate value="${e.fecha}" pattern="dd/MM/yyyy HH:mm"/></td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${e.nivel == 'ERROR'}"><span class="badge bg-danger">ERROR</span></c:when>
                                                <c:when test="${e.nivel == 'ADVERTENCIA'}"><span class="badge bg-warning text-dark">ADVERTENCIA</span></c:when>
                                                <c:otherwise><span class="badge bg-secondary">INFO</span></c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td class="small fw-semibold"><c:out value="${e.origen}"/></td>
                                        <td class="small"><c:out value="${e.mensaje}"/></td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${e.atendido}">
                                                    <span class="badge bg-success">Atendido</span>
                                                    <div class="small text-muted mt-1">
                                                        <c:out value="${e.atendidoPorNombre}"/> · <fmt:formatDate value="${e.fechaAtencion}" pattern="dd/MM/yyyy HH:mm"/>
                                                    </div>
                                                    <div class="small text-muted"><c:out value="${e.accionTomada}"/></div>
                                                </c:when>
                                                <c:when test="${e.nivel == 'ERROR'}"><span class="badge bg-danger">Alerta pendiente</span></c:when>
                                                <c:otherwise><span class="badge bg-light text-dark border">Pendiente</span></c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td class="text-center">
                                            <c:if test="${not e.atendido}">
                                                <button class="btn btn-sm btn-outline-primary" type="button" data-bs-toggle="collapse" data-bs-target="#atender${e.idEvento}">
                                                    <i class="bi bi-check2-square me-1"></i>Atender
                                                </button>
                                            </c:if>
                                        </td>
                                    </tr>
                                    <c:if test="${not e.atendido}">
                                        <tr class="collapse" id="atender${e.idEvento}">
                                            <td colspan="6" class="bg-light">
                                                <form action="EventoController" method="post" class="row g-2 align-items-end">
                                                    <input type="hidden" name="formToken" value="${formToken}">
                                                    <input type="hidden" name="idEvento" value="${e.idEvento}">
                                                    <div class="col-md-8">
                                                        <label class="form-label small fw-bold" for="accion${e.idEvento}">Acción tomada</label>
                                                        <input type="text" class="form-control" id="accion${e.idEvento}" name="accionTomada" maxlength="500" minlength="5" required
                                                               placeholder="Por ejemplo: se reinició el servicio de base de datos y se validó el acceso.">
                                                    </div>
                                                    <div class="col-md-4">
                                                        <button type="submit" class="btn btn-success"><i class="bi bi-check-circle me-1"></i>Marcar como atendida</button>
                                                    </div>
                                                </form>
                                            </td>
                                        </tr>
                                    </c:if>
                                </c:forEach>
                                <c:if test="${empty eventos}">
                                    <tr><td colspan="6" class="text-center text-muted py-4">No hay eventos con ese filtro.</td></tr>
                                </c:if>
                            </tbody>
                        </table>
                    </div>
                </div>
            </main>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
