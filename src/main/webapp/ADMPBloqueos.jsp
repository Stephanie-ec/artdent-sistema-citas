<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%
    if (request.getSession().getAttribute("Nombre") == null) {
        response.sendRedirect("iniciosesionerror.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Bloqueos de agenda | Centro Odontológico ArtDent</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet">
    <link rel="stylesheet" href="css/style.css?v=20261102b">
</head>
<body class="d-flex flex-column min-vh-100 bg-light">
<%@include file="NavPanel.jsp" %>
<div class="d-flex flex-grow-1">
    <%@include file="ADMPSlidebar.jsp" %>
    <main class="container-fluid p-4">
        <div class="mb-4 pb-2 border-bottom">
            <h3 class="fw-bold mb-1" style="color: var(--artdent-primary);">
                <i class="bi bi-calendar-x me-2" style="color: var(--artdent-accent);"></i>Bloqueos de agenda
            </h3>
            <p class="text-muted small mb-0">Feriados y vacaciones: la búsqueda de disponibilidad y la validación de agenda los excluyen.</p>
        </div>

        <c:if test="${param.msg == 'creadoOk'}">
            <div class="alert alert-success">Bloqueo registrado. Esa fecha ya no admite reservas.</div>
        </c:if>
        <c:if test="${param.msg == 'eliminadoOk'}">
            <div class="alert alert-success">Bloqueo eliminado. La fecha vuelve a estar disponible.</div>
        </c:if>
        <c:if test="${not empty param.error}">
            <div class="alert alert-warning"><c:out value="${param.error}"/></div>
        </c:if>

        <div class="card border-0 shadow-sm mb-4">
            <div class="card-body">
                <h5 class="fw-bold mb-3">Registrar bloqueo</h5>
                <form action="Bloqueos" method="post" class="row g-3">
                    <input type="hidden" name="formToken" value="${formToken}">
                    <input type="hidden" name="accion" value="crear">
                    <div class="col-12 col-md-3">
                        <label class="form-label" for="desde">Desde</label>
                        <input type="date" class="form-control" id="desde" name="desde" required>
                    </div>
                    <div class="col-12 col-md-3">
                        <label class="form-label" for="hasta">Hasta (opcional)</label>
                        <input type="date" class="form-control" id="hasta" name="hasta">
                    </div>
                    <div class="col-12 col-md-4">
                        <label class="form-label" for="usuarioId">Odontólogo (opcional)</label>
                        <select class="form-select" id="usuarioId" name="usuarioId">
                            <option value="">Toda la clínica</option>
                            <c:forEach var="o" items="${odontologos}">
                                <option value="${o.idUsuario}"><c:out value="${o.nombre}"/> <c:out value="${o.apellido}"/></option>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="col-12 col-md-2 d-flex align-items-end">
                        <button type="submit" class="btn btn-primary w-100">Registrar</button>
                    </div>
                    <div class="col-12">
                        <label class="form-label" for="motivo">Motivo</label>
                        <input type="text" class="form-control" id="motivo" name="motivo" minlength="3" maxlength="200" required
                               placeholder="Feriado, vacaciones, capacitación…">
                    </div>
                </form>
            </div>
        </div>

        <div class="card border-0 shadow-sm">
            <div class="card-body">
                <h5 class="fw-bold mb-3">Bloqueos registrados</h5>
                <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0">
                        <thead class="table-light">
                            <tr><th>Desde</th><th>Hasta</th><th>Odontólogo</th><th>Motivo</th><th>Acción</th></tr>
                        </thead>
                        <tbody>
                            <c:forEach var="b" items="${bloqueos}">
                                <tr>
                                    <td><c:out value="${b.desde}"/></td>
                                    <td><c:out value="${b.hasta}"/></td>
                                    <td><c:out value="${empty b.odontologo ? 'Toda la clínica' : b.odontologo}"/></td>
                                    <td><c:out value="${b.motivo}"/></td>
                                    <td>
                                        <form action="Bloqueos" method="post" class="d-inline" onsubmit="return confirm('¿Eliminar este bloqueo?');">
                                            <input type="hidden" name="formToken" value="${formToken}">
                                            <input type="hidden" name="accion" value="eliminar">
                                            <input type="hidden" name="id" value="${b.idBloqueo}">
                                            <button type="submit" class="btn btn-sm btn-outline-danger" title="Eliminar bloqueo">
                                                <i class="bi bi-trash"></i>
                                            </button>
                                        </form>
                                    </td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty bloqueos}">
                                <tr><td colspan="5" class="text-center py-4 text-muted">No hay bloqueos registrados.</td></tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </main>
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
