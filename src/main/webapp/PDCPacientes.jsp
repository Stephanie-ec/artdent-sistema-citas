<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gestión de Pacientes - Art Dent</title>
    <!-- Bootstrap 5.3 & Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Open+Sans:wght@400;600;700&family=Roboto:wght@500;700;900&display=swap" rel="stylesheet">
    <!-- Hoja de Estilos Oficial de Marca Art Dent -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>

<body class="d-flex flex-column min-vh-100 bg-brand-light">
    <%
        HttpSession ses = request.getSession(false);
        String rolActual = (ses != null) ? (String) ses.getAttribute("TipoRol") : null;
        if (rolActual == null) {
            response.sendRedirect("iniciosesionerror.jsp");
            return;
        }
        boolean esSecretariaOAdmin = rolActual.equalsIgnoreCase("Secretaria") || rolActual.equalsIgnoreCase("Administrador");
        boolean esOdontologo = rolActual.equalsIgnoreCase("Odontologo");
    %>

    <%@include file="NavPanel.jsp" %>

    <div class="d-flex flex-grow-1">
        <%@include file="Sidebar.jsp" %>

        <main class="container-fluid p-4 d-flex flex-column flex-grow-1">
            <div class="mb-4">
                <div class="d-flex justify-content-between align-items-center flex-wrap gap-2">
                    <div>
                        <h3 class="fw-bold text-brand-dark mb-1">
                            <span class="text-brand-primary">Gestión Clínica</span> de Pacientes
                        </h3>
                        <p class="text-muted small mb-0">
                            <% if (esSecretariaOAdmin) { %>
                                Módulo de administración: la <strong>Secretaría</strong> registra y actualiza los datos de filiación y contacto de los pacientes.
                            <% } else { %>
                                Perfil clínico: el <strong>Odontólogo</strong> consulta el registro y el historial de citas de los pacientes (solo lectura).
                            <% } %>
                        </p>
                    </div>
                    <% if (esSecretariaOAdmin) { %>
                    <button type="button" class="btn btn-success rounded-pill px-4 shadow-sm fw-semibold" data-bs-toggle="modal" data-bs-target="#modalNuevoPaciente">
                        <i class="bi bi-person-plus me-1"></i> + Registrar Paciente
                    </button>
                    <% } %>
                </div>
            </div>

            <!-- Notificaciones -->
            <c:if test="${param.msg == 'updateOk'}">
                <div class="alert alert-artdent-mint alert-dismissible fade show d-flex align-items-center mb-3" role="alert">
                    <i class="bi bi-check-circle-fill fs-4 me-2 text-brand-accent"></i>
                    <div><strong>¡Éxito!</strong> Los datos del paciente han sido actualizados correctamente.</div>
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
            </c:if>
            <c:if test="${param.msg == 'createOk'}">
                <div class="alert alert-artdent-mint alert-dismissible fade show d-flex align-items-center mb-3" role="alert">
                    <i class="bi bi-check-circle-fill fs-4 me-2 text-brand-accent"></i>
                    <div><strong>¡Éxito!</strong> El nuevo paciente fue registrado satisfactoriamente en el sistema.</div>
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
            </c:if>

            <!-- Barra de Búsqueda -->
            <div class="card p-3 mb-4 border-0 shadow-sm" style="border-radius: 12px; background: #ffffff;">
                <form action="PacienteController" method="GET" class="row g-2 align-items-center">
                    <input type="hidden" name="action" value="search">
                    <div class="col-12 col-md-9 col-lg-10">
                        <div class="input-group">
                            <span class="input-group-text bg-light"><i class="bi bi-search"></i></span>
                            <input type="text" class="form-control" name="criterio" 
                                   placeholder="Buscar por DNI, Nombres o Apellidos..." 
                                   value="${criterioBusqueda}">
                        </div>
                    </div>
                    <div class="col-12 col-md-3 col-lg-2 d-flex gap-2">
                        <button type="submit" class="btn btn-primary w-100 rounded-pill fw-semibold">Buscar</button>
                        <a href="PacienteController?action=list" class="btn btn-outline-secondary rounded-pill" title="Restablecer"><i class="bi bi-arrow-clockwise"></i></a>
                    </div>
                </form>
            </div>

            <!-- Tabla de Pacientes -->
            <div class="card border-0 shadow-sm overflow-hidden flex-grow-1" style="border-radius: 12px;">
                <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0">
                        <thead>
                            <tr>
                                <th class="text-center">ID</th>
                                <th class="text-center">DNI</th>
                                <th>Nombres y Apellidos</th>
                                <th class="text-center">Teléfono / Celular</th>
                                <th>Correo Electrónico</th>
                                <th class="text-center pe-4">Acciones</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:choose>
                                <c:when test="${not empty listaPacientes}">
                                    <c:forEach var="p" items="${listaPacientes}">
                                        <tr>
                                            <td class="text-center font-monospace small text-muted">${p.idPaciente}</td>
                                            <td class="text-center fw-bold text-brand-primary font-monospace">${p.dni}</td>
                                            <td class="fw-semibold text-brand-dark">
                                                <i class="bi bi-person-fill text-brand-primary me-1"></i>
                                                ${p.nombre} ${p.apellido}
                                            </td>
                                            <td class="text-center font-monospace">${p.telefono}</td>
                                            <td class="small text-muted">${p.correo}</td>
                                            <td class="text-center pe-4">
                                                <div class="d-flex justify-content-center align-items-center gap-1">
                                                    <% if (esSecretariaOAdmin) { %>
                                                    <button class="btn btn-sm btn-outline-primary rounded-pill px-3" 
                                                            onclick="abrirModalEditar('${p.idPaciente}', '${p.nombre}', '${p.apellido}', '${p.dni}', '${p.telefono}', '${p.correo}')"
                                                            title="Actualizar Datos">
                                                        <i class="bi bi-pencil-square me-1"></i>Editar
                                                    </button>
                                                    <% } %>
                                                    <a href="HistorialController?accion=ListarHistorialCitas&pacienteNom=${p.nombre} ${p.apellido}" 
                                                       class="btn btn-sm btn-outline-secondary rounded-pill px-3" 
                                                       title="Consultar Historial de Citas">
                                                        <i class="bi bi-clock-history me-1 text-brand-primary"></i>Historial
                                                    </a>
                                                </div>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <tr>
                                        <td colspan="6" class="text-center py-5 text-muted">
                                            <i class="bi bi-inbox fs-1 d-block mb-2 text-brand-mint"></i>
                                            No se encontraron pacientes registrados con el criterio especificado.
                                        </td>
                                    </tr>
                                </c:otherwise>
                            </c:choose>
                        </tbody>
                    </table>
                </div>
            </div>
        </main>
    </div>

    <% if (esSecretariaOAdmin) { %>
    <!-- Modal Editar Paciente -->
    <div class="modal fade" id="modalEditarPaciente" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content border-0 shadow-lg" style="border-radius: 16px; overflow: hidden;">
                <form action="PacienteController" method="POST">
                    <input type="hidden" name="action" value="update">
                    <input type="hidden" name="idPaciente" id="edit_idPaciente">
                    <div class="modal-header bg-brand-primary text-white border-0 py-3">
                        <h5 class="modal-title fw-bold text-white d-flex align-items-center gap-2">
                            <i class="bi bi-pencil-square"></i> Actualizar Paciente
                        </h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body p-4">
                        <div class="mb-3">
                            <label class="form-label small fw-bold text-muted">DNI (No editable):</label>
                            <input type="text" class="form-control font-monospace bg-light" id="edit_dni" readonly disabled>
                        </div>
                        <div class="mb-3">
                            <label for="edit_nombre" class="form-label small fw-bold text-muted">Nombres <span class="text-danger">*</span></label>
                            <input type="text" class="form-control" id="edit_nombre" name="nombre" required>
                        </div>
                        <div class="mb-3">
                            <label for="edit_apellido" class="form-label small fw-bold text-muted">Apellidos <span class="text-danger">*</span></label>
                            <input type="text" class="form-control" id="edit_apellido" name="apellido" required>
                        </div>
                        <div class="mb-3">
                            <label for="edit_telefono" class="form-label small fw-bold text-muted">Teléfono / Celular <span class="text-danger">*</span></label>
                            <input type="tel" class="form-control font-monospace" id="edit_telefono" name="telefono" maxlength="9" pattern="\d{9}" required>
                        </div>
                        <div class="mb-3">
                            <label for="edit_correo" class="form-label small fw-bold text-muted">Correo Electrónico <span class="text-danger">*</span></label>
                            <input type="email" class="form-control" id="edit_correo" name="correo" required>
                        </div>
                    </div>
                    <div class="modal-footer bg-light border-0">
                        <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Cancelar</button>
                        <button type="submit" class="btn btn-primary fw-semibold px-4">
                            <i class="bi bi-save me-1"></i> Guardar Cambios
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Modal Nuevo Paciente -->
    <div class="modal fade" id="modalNuevoPaciente" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content border-0 shadow-lg" style="border-radius: 16px; overflow: hidden;">
                <form action="PacienteController" method="POST">
                    <input type="hidden" name="action" value="create">
                    <div class="modal-header bg-brand-primary text-white border-0 py-3">
                        <h5 class="modal-title fw-bold text-white d-flex align-items-center gap-2">
                            <i class="bi bi-person-plus"></i> Registrar Nuevo Paciente
                        </h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body p-4">
                        <div class="mb-3">
                            <label for="nuevo_dni" class="form-label small fw-bold text-muted">DNI <span class="text-danger">*</span></label>
                            <input type="text" class="form-control font-monospace" id="nuevo_dni" name="dni" maxlength="8" pattern="\d{8}" placeholder="8 dígitos" required>
                        </div>
                        <div class="mb-3">
                            <label for="nuevo_nombre" class="form-label small fw-bold text-muted">Nombres <span class="text-danger">*</span></label>
                            <input type="text" class="form-control" id="nuevo_nombre" name="nombre" placeholder="Nombres completos" required>
                        </div>
                        <div class="mb-3">
                            <label for="nuevo_apellido" class="form-label small fw-bold text-muted">Apellidos <span class="text-danger">*</span></label>
                            <input type="text" class="form-control" id="nuevo_apellido" name="apellido" placeholder="Apellidos completos" required>
                        </div>
                        <div class="mb-3">
                            <label for="nuevo_telefono" class="form-label small fw-bold text-muted">Teléfono / Celular <span class="text-danger">*</span></label>
                            <input type="tel" class="form-control font-monospace" id="nuevo_telefono" name="telefono" maxlength="9" pattern="\d{9}" placeholder="9 dígitos" required>
                        </div>
                        <div class="mb-3">
                            <label for="nuevo_correo" class="form-label small fw-bold text-muted">Correo Electrónico <span class="text-danger">*</span></label>
                            <input type="email" class="form-control" id="nuevo_correo" name="correo" placeholder="correo@ejemplo.com" required>
                        </div>
                    </div>
                    <div class="modal-footer bg-light border-0">
                        <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Cancelar</button>
                        <button type="submit" class="btn btn-success fw-semibold px-4">
                            <i class="bi bi-check-circle me-1"></i> Registrar Paciente
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>
    <% } %>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function abrirModalEditar(id, nombre, apellido, dni, telefono, correo) {
            document.getElementById('edit_idPaciente').value = id;
            document.getElementById('edit_dni').value = dni;
            document.getElementById('edit_nombre').value = nombre;
            document.getElementById('edit_apellido').value = apellido;
            document.getElementById('edit_telefono').value = telefono;
            document.getElementById('edit_correo').value = correo;
            var modal = new bootstrap.Modal(document.getElementById('modalEditarPaciente'));
            modal.show();
        }
    </script>
</body>
</html>
