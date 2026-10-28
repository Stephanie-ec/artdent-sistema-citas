<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gestión de Servicios y Tarifario | Centro Odontológico ArtDent</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    <link rel="stylesheet" href="css/style.css">
</head>
<body class="d-flex flex-column min-vh-100 bg-light">
    <%
    HttpSession misesion = request.getSession();
    String usuario = (String) request.getSession().getAttribute("Nombre");
    if (usuario == null) {
        response.sendRedirect("iniciosesionerror.jsp");
        return;
    }
    %>

    <%@include file="NavPanel.jsp" %>
    <div class="container-fluid flex-grow-1 d-flex">
        <div class="row flex-grow-1 w-100 g-0">
            <!-- Sidebar Administrador -->
            <%@include file="ADMPSlidebar.jsp"%>

            <main class="col-md-9 ms-sm-auto col-lg-10 p-4">
                <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pb-3 mb-4 border-bottom">
                    <div>
                        <h2 class="h3 fw-bold mb-1" style="color: var(--artdent-primary);">
                            <i class="bi bi-hospital me-2" style="color: var(--artdent-accent);"></i>Catálogo de Servicios y Tarifas
                        </h2>
                        <p class="text-muted small mb-0">Gestión de tratamientos odontológicos, precios oficiales y disponibilidad en reservas.</p>
                    </div>
                    <button class="btn btn-primary d-inline-flex align-items-center gap-2 shadow-sm rounded-pill px-4" data-bs-toggle="modal" data-bs-target="#addServiceModal">
                        <i class="bi bi-plus-circle"></i> Nuevo Servicio
                    </button>
                </div>

                <div class="card border-0 shadow-sm rounded-4 overflow-hidden mb-4">
                    <div class="card-header bg-white py-3 border-bottom d-flex align-items-center justify-content-between">
                        <span class="fw-bold text-dark">Servicios Clínicos Registrados</span>
                        <span class="badge rounded-pill text-dark" style="background-color: var(--artdent-mint);">
                            <i class="bi bi-check2-circle me-1" style="color: var(--artdent-primary);"></i>Tarifario Oficial
                        </span>
                    </div>

                    <div class="table-responsive">
                        <table class="table table-hover align-middle mb-0">
                            <thead style="background-color: #edf7fa; color: var(--artdent-dark);">
                                <tr>
                                    <th class="ps-4 py-3">ID</th>
                                    <th class="py-3">Tratamiento</th>
                                    <th class="py-3">Lema / Subtítulo</th>
                                    <th class="py-3">Costo Base</th>
                                    <th class="py-3">Estado</th>
                                    <th class="py-3 text-center">Acciones</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="servicio" items="${listServicio}">
                                    <tr class="${!servicio.activo ? 'table-light opacity-75' : ''}">
                                        <td class="ps-4 fw-bold text-muted"><c:out value="${servicio.idServicio}" /></td>
                                        <td class="fw-bold text-dark">
                                            <i class="bi bi-heart-pulse-fill me-2" style="color: var(--artdent-primary);"></i><c:out value="${servicio.tipoServicio}" />
                                        </td>
                                        <td class="small text-muted"><c:out value="${servicio.lema}" /></td>
                                        <td class="fw-bold font-monospace" style="color: #278829;">S/ <c:out value="${servicio.costo}" /></td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${servicio.activo}">
                                                    <span class="badge rounded-pill px-3 py-2 bg-success text-white">
                                                        <i class="bi bi-check-circle me-1"></i>Activo
                                                    </span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge rounded-pill px-3 py-2 bg-secondary text-white">
                                                        <i class="bi bi-slash-circle me-1"></i>Inactivo
                                                    </span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td class="text-center">
                                            <div class="btn-group shadow-sm rounded-pill overflow-hidden" role="group">
                                                <a href="ServicioController?action=edit&id=<c:out value='${servicio.idServicio}' />" class="btn btn-sm btn-outline-primary" title="Editar">
                                                    <i class="bi bi-pencil-square"></i>
                                                </a>
                                                <c:choose>
                                                    <c:when test="${servicio.activo}">
                                                        <a href="ServicioController?action=delete&id=<c:out value='${servicio.idServicio}' />" 
                                                           class="btn btn-sm btn-outline-warning" 
                                                           onclick="return confirm('¿Desactivar este servicio? Dejará de ofrecerse en nuevas reservas pero se conserva en el historial.')" 
                                                           title="Desactivar">
                                                            <i class="bi bi-slash-circle"></i>
                                                        </a>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <a href="ServicioController?action=reactivar&id=<c:out value='${servicio.idServicio}' />" 
                                                           class="btn btn-sm btn-outline-success" 
                                                           onclick="return confirm('¿Reactivar este servicio para ofrecerlo nuevamente en reservas?')" 
                                                           title="Reactivar">
                                                            <i class="bi bi-arrow-counterclockwise"></i>
                                                        </a>
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </div>
            </main>
        </div>
    </div>

    <!-- Add Service Modal -->
    <div class="modal fade" id="addServiceModal" tabindex="-1" aria-labelledby="addServiceModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-lg modal-dialog-centered">
            <div class="modal-content border-0 shadow rounded-4 overflow-hidden">
                <div class="modal-header text-white" style="background: linear-gradient(135deg, var(--artdent-primary), #268da9);">
                    <h5 class="modal-title fw-bold" id="addServiceModalLabel">
                        <i class="bi bi-plus-circle me-2"></i>Registrar Nuevo Servicio Odontológico
                    </h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body p-4">
                    <form action="ServicioController?action=insert" method="post">
                        <div class="row g-3 mb-3">
                            <div class="col-md-6">
                                <label for="tipoServicio" class="form-label fw-semibold">Nombre del Servicio <span class="text-danger">*</span></label>
                                <input type="text" class="form-control" id="tipoServicio" name="tipoServicio" placeholder="Ej: Profilaxis Dental Avanzada" required>
                            </div>
                            <div class="col-md-6">
                                <label for="lema" class="form-label fw-semibold">Lema / Subtítulo Corto <span class="text-danger">*</span></label>
                                <input type="text" class="form-control" id="lema" name="lema" placeholder="Ej: Sonrisa radiante y sana" required>
                            </div>
                        </div>
                        <div class="mb-3">
                            <label for="descripcion" class="form-label fw-semibold">Descripción del Servicio <span class="text-danger">*</span></label>
                            <textarea class="form-control" id="descripcion" name="descripcion" rows="3" placeholder="Detalle clínico y procedimiento..." required></textarea>
                        </div>
                        <div class="mb-3">
                            <label for="respuesta" class="form-label fw-semibold">Beneficios o Respuesta al Paciente <span class="text-danger">*</span></label>
                            <textarea class="form-control" id="respuesta" name="respuesta" rows="2" placeholder="Orientación y cuidados para el paciente..." required></textarea>
                        </div>
                        <div class="row g-3 mb-4">
                            <div class="col-md-6">
                                <label for="costo" class="form-label fw-semibold">Costo Base (S/) <span class="text-danger">*</span></label>
                                <input type="number" step="0.01" class="form-control" id="costo" name="costo" placeholder="0.00" required>
                            </div>
                            <div class="col-md-6">
                                <label for="img" class="form-label fw-semibold">URL de la Imagen Referencial</label>
                                <input type="text" class="form-control" id="img" name="img" placeholder="https://ejemplo.com/foto.jpg">
                            </div>
                        </div>
                        <div class="d-flex justify-content-end gap-2 pt-2 border-top">
                            <button type="button" class="btn btn-outline-secondary px-4" data-bs-dismiss="modal">Cancelar</button>
                            <button type="submit" class="btn btn-primary px-4 fw-semibold shadow-sm">
                                <i class="bi bi-save me-1"></i> Guardar Servicio
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
