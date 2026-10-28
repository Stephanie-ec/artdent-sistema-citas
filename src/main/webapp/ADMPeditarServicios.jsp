<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Editar Servicio Odontológico | Centro Odontológico ArtDent</title>
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
                            <i class="bi bi-pencil-square me-2" style="color: var(--artdent-accent);"></i>Modificar Servicio Clínico
                        </h2>
                        <p class="text-muted small mb-0">Actualice la información del tratamiento y la tarifa base oficial.</p>
                    </div>
                    <a href="ServicioController?action=list" class="btn btn-outline-secondary d-inline-flex align-items-center gap-1 shadow-sm px-3">
                        <i class="bi bi-arrow-left"></i> Volver a Servicios
                    </a>
                </div>

                <div class="row justify-content-center">
                    <div class="col-12 col-xl-9">
                        <div class="card border-0 shadow-sm rounded-4 overflow-hidden">
                            <div class="card-header bg-white py-3 border-bottom d-flex align-items-center justify-content-between">
                                <span class="fw-bold text-dark">
                                    <i class="bi bi-heart-pulse-fill me-2" style="color: var(--artdent-primary);"></i>Tratamiento: ${servicio.tipoServicio}
                                </span>
                                <span class="badge rounded-pill text-dark" style="background-color: var(--artdent-mint);">
                                    ID #${servicio.idServicio}
                                </span>
                            </div>
                            <div class="card-body p-4">
                                <form action="ServicioController?action=update" method="post">
                                    <input type="hidden" name="id" value="${servicio.idServicio}">
                                    
                                    <div class="row g-3 mb-3">
                                        <div class="col-md-6">
                                            <label for="tipoServicio" class="form-label fw-semibold">Nombre del Servicio <span class="text-danger">*</span></label>
                                            <input type="text" class="form-control" id="tipoServicio" name="tipoServicio" value="${servicio.tipoServicio}" required>
                                        </div>
                                        <div class="col-md-6">
                                            <label for="lema" class="form-label fw-semibold">Lema / Subtítulo Corto <span class="text-danger">*</span></label>
                                            <input type="text" class="form-control" id="lema" name="lema" value="${servicio.lema}" required>
                                        </div>
                                    </div>

                                    <div class="mb-3">
                                        <label for="descripcion" class="form-label fw-semibold">Descripción del Servicio <span class="text-danger">*</span></label>
                                        <textarea class="form-control" id="descripcion" name="descripcion" rows="3" required>${servicio.descripcion}</textarea>
                                    </div>

                                    <div class="mb-3">
                                        <label for="respuesta" class="form-label fw-semibold">Beneficios o Respuesta al Paciente <span class="text-danger">*</span></label>
                                        <textarea class="form-control" id="respuesta" name="respuesta" rows="3" required>${servicio.respuesta}</textarea>
                                    </div>

                                    <div class="row g-3 mb-4">
                                        <div class="col-md-6">
                                            <label for="costo" class="form-label fw-semibold">Costo Base (S/) <span class="text-danger">*</span></label>
                                            <input type="number" step="0.01" class="form-control" id="costo" name="costo" value="${servicio.costo}" required>
                                        </div>
                                        <div class="col-md-6">
                                            <label for="img" class="form-label fw-semibold">URL de la Imagen Referencial</label>
                                            <input type="text" class="form-control" id="img" name="img" value="${servicio.linkimagen}">
                                        </div>
                                    </div>

                                    <div class="d-flex justify-content-end gap-2 pt-2 border-top">
                                        <a href="ServicioController?action=list" class="btn btn-outline-secondary px-4">Cancelar</a>
                                        <button type="submit" class="btn btn-primary px-4 fw-semibold shadow-sm">
                                            <i class="bi bi-save me-1"></i> Actualizar Servicio
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