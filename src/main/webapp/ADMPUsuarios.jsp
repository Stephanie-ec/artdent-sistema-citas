<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gestión de Usuarios | Centro Odontológico ArtDent</title>
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
            <!-- Sidebar -->
            <%@include file="ADMPSlidebar.jsp"%>

            <!-- Main Content -->
            <main class="col-md-9 ms-sm-auto col-lg-10 p-4">
                <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pb-3 mb-4 border-bottom">
                    <div>
                        <h2 class="h3 fw-bold mb-1" style="color: var(--artdent-primary);">
                            <i class="bi bi-people-fill me-2" style="color: var(--artdent-accent);"></i>Gestión de Personal y Cuentas
                        </h2>
                        <p class="text-muted small mb-0">Administración de usuarios autorizados (Administrador, Odontólogo, Secretaria).</p>
                    </div>
                    <button class="btn btn-primary d-inline-flex align-items-center gap-2 shadow-sm rounded-pill px-4" data-bs-toggle="modal" data-bs-target="#addUserModal">
                        <i class="bi bi-person-plus-fill"></i> Registrar Personal
                    </button>
                </div>

                <!-- User list table -->
                <div class="card border-0 shadow-sm rounded-4 overflow-hidden mb-4">
                    <div class="card-header bg-white py-3 border-bottom d-flex align-items-center justify-content-between">
                        <span class="fw-bold text-dark">Plantel del Centro Odontológico ArtDent</span>
                        <span class="badge rounded-pill text-dark" style="background-color: var(--artdent-mint);">
                            <i class="bi bi-shield-lock-fill me-1" style="color: var(--artdent-primary);"></i>Acceso Seguro
                        </span>
                    </div>

                    <div class="table-responsive">
                        <table class="table table-hover align-middle mb-0">
                            <thead style="background-color: #edf7fa; color: var(--artdent-dark);">
                                <tr>
                                    <th class="ps-4 py-3">ID</th>
                                    <th class="py-3">DNI</th>
                                    <th class="py-3">Personal</th>
                                    <th class="py-3">Teléfono</th>
                                    <th class="py-3">Correo</th>
                                    <th class="py-3">Rol</th>
                                    <th class="py-3">Estado</th>
                                    <th class="py-3 text-center">Acciones</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="usuario" items="${usuarios}">
                                    <tr>
                                        <td class="ps-4 fw-bold text-muted">${usuario.idUsuario}</td>
                                        <td><span class="badge bg-light text-dark border font-monospace px-2 py-1">${usuario.dni}</span></td>
                                        <td class="fw-semibold text-dark">
                                            <i class="bi bi-person-circle me-2" style="color: var(--artdent-primary);"></i>${usuario.nombre} ${usuario.apellido}
                                        </td>
                                        <td><i class="bi bi-telephone me-1 text-muted"></i>${usuario.telefono}</td>
                                        <td class="small text-muted">${usuario.correoElectronico}</td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${usuario.rol == 'Administrador'}">
                                                    <span class="badge px-3 py-2 text-white" style="background-color: var(--artdent-dark);">${usuario.rol}</span>
                                                </c:when>
                                                <c:when test="${usuario.rol == 'Secretaria'}">
                                                    <span class="badge px-3 py-2 text-white" style="background-color: var(--artdent-primary);">${usuario.rol}</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge px-3 py-2 text-white" style="background-color: var(--artdent-accent);">${usuario.rol}</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <span class="badge rounded-pill text-dark" style="background-color: var(--artdent-mint);">Activo</span>
                                        </td>
                                        <td class="text-center">
                                            <div class="btn-group shadow-sm rounded-pill overflow-hidden" role="group">
                                                <c:if test="${usuario.rol == 'Odontólogo' || usuario.rol == 'Odontologo'}">
                                                    <a href="UsuarioController?action=disponibilidad&id=${usuario.idUsuario}" class="btn btn-sm btn-outline-primary" title="Gestionar Horarios y Servicios">
                                                        <i class="bi bi-calendar-week"></i>
                                                    </a>
                                                </c:if>
                                                <a href="UsuarioController?action=edit&id=${usuario.idUsuario}" class="btn btn-sm btn-outline-primary" title="Editar"><i class="bi bi-pencil-square"></i></a>
                                                <a href="#" onclick="confirmDelete(${usuario.idUsuario})" class="btn btn-sm btn-outline-danger" title="Eliminar"><i class="bi bi-trash"></i></a>
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

    <!-- Add User Modal -->
    <div class="modal fade" id="addUserModal" tabindex="-1" aria-labelledby="addUserModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-lg modal-dialog-centered">
            <div class="modal-content border-0 shadow rounded-4 overflow-hidden">
                <div class="modal-header text-white" style="background: linear-gradient(135deg, var(--artdent-primary), #268da9);">
                    <h5 class="modal-title fw-bold" id="addUserModalLabel">
                        <i class="bi bi-person-plus-fill me-2"></i>Registrar Nuevo Personal
                    </h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body p-4">
                    <form action="UsuarioController?action=add" method="post">
                        <div class="row g-3 mb-3">
                            <div class="col-md-6">
                                <label for="nombre" class="form-label fw-semibold">Nombre <span class="text-danger">*</span></label>
                                <input type="text" class="form-control" id="nombre" name="nombre" placeholder="Nombres" required>
                            </div>
                            <div class="col-md-6">
                                <label for="apellido" class="form-label fw-semibold">Apellido <span class="text-danger">*</span></label>
                                <input type="text" class="form-control" id="apellido" name="apellido" placeholder="Apellidos" required>
                            </div>
                        </div>
                        <div class="row g-3 mb-3">
                            <div class="col-md-6">
                                <label for="dni" class="form-label fw-semibold">DNI <span class="text-danger">*</span></label>
                                <input type="text" class="form-control" id="dni" name="dni" maxlength="8" pattern="\d{8}" placeholder="8 dígitos" required>
                            </div>
                            <div class="col-md-6">
                                <label for="telefono" class="form-label fw-semibold">Teléfono / Celular <span class="text-danger">*</span></label>
                                <input type="tel" class="form-control" id="telefono" name="telefono" maxlength="9" placeholder="9 dígitos" required>
                            </div>
                        </div>
                        <div class="mb-3">
                            <label for="email" class="form-label fw-semibold">Correo Electrónico <span class="text-danger">*</span></label>
                            <input type="email" class="form-control" id="email" name="email" placeholder="usuario@artdent.pe" required>
                        </div>
                        <div class="mb-3">
                            <label for="direccion" class="form-label fw-semibold">Dirección</label>
                            <input type="text" class="form-control" id="direccion" name="direccion" placeholder="Av. / Jr. / Calle">
                        </div>
                        <div class="row g-3 mb-3">
                            <div class="col-md-6">
                                <label for="fechanacimiento" class="form-label fw-semibold">Fecha de Nacimiento</label>
                                <input type="date" class="form-control" id="fechanacimiento" name="fechanacimiento" required>
                            </div>
                            <div class="col-md-6">
                                <label for="rol" class="form-label fw-semibold">Rol del Personal <span class="text-danger">*</span></label>
                                <select class="form-select" id="rol" name="rol" required>
                                    <option value="" disabled selected>Seleccionar rol...</option>
                                    <c:forEach var="rolObj" items="${roles}">
                                        <option value="${rolObj.idRol}">${rolObj.tipoRol}</option>
                                    </c:forEach>
                                </select>
                            </div>
                        </div>
                        <div class="mb-4">
                            <label for="clave" class="form-label fw-semibold">Contraseña Inicial <span class="text-danger">*</span></label>
                            <input type="password" class="form-control" id="clave" name="clave" placeholder="Contraseña segura" required>
                            <small class="text-muted">Se almacenará encriptada con algoritmo seguro BCrypt.</small>
                        </div>
                        <div class="d-flex justify-content-end gap-2">
                            <button type="button" class="btn btn-outline-secondary px-4" data-bs-dismiss="modal">Cancelar</button>
                            <button type="submit" class="btn btn-primary px-4 fw-semibold shadow-sm">
                                <i class="bi bi-save me-1"></i> Guardar Usuario
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <script>
        function confirmDelete(id) {
            if (confirm("¿Está seguro de que desea eliminar este usuario del personal?")) {
                window.location.href = "UsuarioController?action=delete&id=" + id;
            }
        }
    </script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>