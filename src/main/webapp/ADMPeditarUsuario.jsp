<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Editar Usuario | Centro Odontológico ArtDent</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    <link rel="stylesheet" href="css/style.css">
</head>
<body class="d-flex flex-column min-vh-100 bg-light">
    <%
    HttpSession misesion = request.getSession();
    String usuarioSes = (String) request.getSession().getAttribute("Nombre");
    if (usuarioSes == null) {
        response.sendRedirect("iniciosesionerror.jsp");
        return;
    }
    %>

    <%@include file="NavPanel.jsp" %>

    <div class="container-fluid flex-grow-1 d-flex">
        <div class="row flex-grow-1 w-100 g-0">
            <%@include file="ADMPSlidebar.jsp"%>

            <main class="col-md-9 ms-sm-auto col-lg-10 p-4">
                <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pb-3 mb-4 border-bottom">
                    <div>
                        <h2 class="h3 fw-bold mb-1" style="color: var(--artdent-primary);">
                            <i class="bi bi-person-gear me-2" style="color: var(--artdent-accent);"></i>Modificar Datos del Personal
                        </h2>
                        <p class="text-muted small mb-0">Actualice la información y privilegios de acceso del usuario institucional.</p>
                    </div>
                    <a href="UsuarioController?action=list" class="btn btn-outline-secondary d-inline-flex align-items-center gap-1 shadow-sm px-3">
                        <i class="bi bi-arrow-left"></i> Volver a Usuarios
                    </a>
                </div>

                <div class="row justify-content-center">
                    <div class="col-12 col-xl-9">
                        <div class="card border-0 shadow-sm rounded-4 overflow-hidden">
                            <div class="card-header bg-white py-3 border-bottom d-flex align-items-center justify-content-between">
                                <span class="fw-bold text-dark">
                                    <i class="bi bi-pencil-square me-2" style="color: var(--artdent-primary);"></i>Ficha del Usuario: ${usuario.nombre} ${usuario.apellido}
                                </span>
                                <span class="badge rounded-pill text-dark" style="background-color: var(--artdent-mint);">
                                    ID #${usuario.idUsuario}
                                </span>
                            </div>
                            <div class="card-body p-4">
                                <form action="UsuarioController?action=update" method="post">
                                    <input type="hidden" name="id" value="${usuario.idUsuario}">
                                    
                                    <div class="row g-3 mb-3">
                                        <div class="col-md-6">
                                            <label for="nombre" class="form-label fw-semibold">Nombre <span class="text-danger">*</span></label>
                                            <input type="text" class="form-control" id="nombre" name="nombre" value="${usuario.nombre}" required>
                                        </div>
                                        <div class="col-md-6">
                                            <label for="apellido" class="form-label fw-semibold">Apellido <span class="text-danger">*</span></label>
                                            <input type="text" class="form-control" id="apellido" name="apellido" value="${usuario.apellido}" required>
                                        </div>
                                    </div>

                                    <div class="row g-3 mb-3">
                                        <div class="col-md-6">
                                            <label for="dni" class="form-label fw-semibold">DNI <span class="text-danger">*</span></label>
                                            <input type="number" class="form-control" id="dni" name="dni" value="${usuario.dni}" required>
                                        </div>
                                        <div class="col-md-6">
                                            <label for="telefono" class="form-label fw-semibold">Teléfono <span class="text-danger">*</span></label>
                                            <input type="tel" class="form-control" id="telefono" name="telefono" value="${usuario.telefono}" required>
                                        </div>
                                    </div>

                                    <div class="mb-3">
                                        <label for="email" class="form-label fw-semibold">Correo Electrónico <span class="text-danger">*</span></label>
                                        <input type="email" class="form-control" id="email" name="email" value="${usuario.correoElectronico}" required>
                                    </div>

                                    <div class="mb-3">
                                        <label for="direccion" class="form-label fw-semibold">Dirección</label>
                                        <input type="text" class="form-control" id="direccion" name="direccion" value="${usuario.direccion}" required>
                                    </div>

                                    <div class="row g-3 mb-3">
                                        <div class="col-md-6">
                                            <label for="fechanacimiento" class="form-label fw-semibold">Fecha de Nacimiento <span class="text-danger">*</span></label>
                                            <input type="date" class="form-control" id="fechanacimiento" name="fechanacimiento" value="${usuario.fechaNacimiento}" required>
                                        </div>
                                        <div class="col-md-6">
                                            <label for="rol" class="form-label fw-semibold">Rol del Personal <span class="text-danger">*</span></label>
                                            <select class="form-select" id="rol" name="rol" required>
                                                <c:forEach var="rolObj" items="${roles}">
                                                    <option value="${rolObj.idRol}" ${usuario.rol_idRol == rolObj.idRol ? 'selected' : ''}>${rolObj.tipoRol}</option>
                                                </c:forEach>
                                            </select>
                                        </div>
                                    </div>

                                    <div class="mb-4">
                                        <label for="clave" class="form-label fw-semibold">Nueva Contraseña (Opcional)</label>
                                        <input type="password" class="form-control" id="clave" name="clave" placeholder="Dejar en blanco para mantener la contraseña actual">
                                        <small class="text-muted">Si ingresa una nueva contraseña, se actualizará cifrada con BCrypt.</small>
                                    </div>

                                    <div class="d-flex justify-content-end gap-2 pt-2 border-top">
                                        <a href="UsuarioController?action=list" class="btn btn-outline-secondary px-4">Cancelar</a>
                                        <button type="submit" class="btn btn-primary px-4 fw-semibold shadow-sm">
                                            <i class="bi bi-save me-1"></i> Actualizar Usuario
                                        </button>
                                    </div>
                                </form>
                            </div>
                        </div>
                    </div>
                </div>
            </main>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>