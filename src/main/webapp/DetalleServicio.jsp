<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${not empty servicio ? servicio.tipoServicio : 'Detalle del Servicio'} - Art Dent</title>
    <!-- Bootstrap 5.3 & Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Open+Sans:wght@400;600;700&family=Roboto:wght@500;700;900&display=swap" rel="stylesheet">
    <!-- Hoja de Estilos Oficial de Marca Art Dent -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">

    <style>
        .service-hero {
            background-size: cover;
            background-position: center;
            min-height: 420px;
            display: flex;
            align-items: center;
            position: relative;
        }

        .service-hero-overlay {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: linear-gradient(135deg, rgba(33, 37, 41, 0.82), rgba(48, 164, 198, 0.75));
        }

        .detail-card {
            border: 1px solid var(--artdent-border);
            border-radius: 16px;
            background: #ffffff;
            box-shadow: var(--artdent-shadow-sm);
        }
    </style>
</head>

<body>
    <!-- Navbar Oficial -->
    <%@include file="header.jsp"%>

    <c:if test="${not empty servicio}">
        <!-- Hero del Servicio -->
        <section class="service-hero text-white" style="background-image: url('${servicio.linkimagen}');">
            <div class="service-hero-overlay"></div>
            <div class="container position-relative text-center px-4 py-5" style="z-index: 2;">
                <span class="badge bg-brand-accent text-white px-3 py-2 rounded-pill text-uppercase fw-bold mb-3 shadow">
                    Tratamiento Clínico Especializado
                </span>
                <h1 class="display-4 fw-bold mb-3 text-white">${servicio.tipoServicio}</h1>
                <p class="lead text-light mx-auto" style="max-width: 750px;">
                    ${not empty servicio.lema ? servicio.lema : 'Cuidamos cada detalle para devolverte salud, funcionalidad y estética.'}
                </p>
                <c:if test="${not empty servicio.costo}">
                    <div class="mt-3">
                        <span class="badge bg-white text-brand-dark fs-5 px-4 py-2 rounded-pill shadow">
                            Inversión referencial: <strong class="text-brand-primary">S/. ${servicio.costo}</strong>
                        </span>
                    </div>
                </c:if>
            </div>
        </section>

        <!-- Contenido y Preguntas Clínicas -->
        <main class="py-5 bg-brand-light">
            <div class="container px-4" style="max-width: 960px;">
                <div class="row g-4">
                    <div class="col-12 col-lg-8">
                        <!-- Artículo 1: Definición -->
                        <div class="card detail-card p-4 mb-4">
                            <h3 class="fw-bold text-brand-primary mb-3 d-flex align-items-center gap-2">
                                <i class="bi bi-info-circle-fill"></i> ¿En qué consiste este tratamiento?
                            </h3>
                            <p class="text-muted leading-relaxed fs-6 mb-0">
                                ${servicio.descripcion}
                            </p>
                        </div>

                        <!-- Artículo 2: Recomendaciones -->
                        <c:if test="${not empty servicio.respuesta}">
                        <div class="card detail-card p-4">
                            <h3 class="fw-bold text-brand-primary mb-3 d-flex align-items-center gap-2">
                                <i class="bi bi-question-diamond-fill"></i> Indicaciones y Preguntas Frecuentes
                            </h3>
                            <p class="text-muted leading-relaxed fs-6 mb-0">
                                ${servicio.respuesta}
                            </p>
                        </div>
                        </c:if>
                    </div>

                    <!-- Columna Lateral: Acción de Reserva -->
                    <div class="col-12 col-lg-4">
                        <div class="card detail-card p-4 text-center sticky-top" style="top: 20px;">
                            <div class="d-inline-flex p-3 rounded-circle bg-brand-light text-brand-primary mx-auto mb-3">
                                <i class="bi bi-calendar-check fs-1"></i>
                            </div>
                            <h4 class="fw-bold text-brand-dark mb-2">¿Deseas agendar este servicio?</h4>
                            <p class="text-muted small mb-4">Reserva tu cita médica en pocos pasos y elige tu horario ideal en nuestras sedes de Chosica o Chaclacayo.</p>
                            <a href="ServicioController?action=formreservaa" class="btn btn-primary rounded-pill py-2 w-100 fw-semibold mb-2 shadow-sm">
                                <i class="bi bi-calendar-plus me-1"></i> Reservar Cita Web
                            </a>
                            <a href="ServicioController?action=listar" class="btn btn-outline-secondary rounded-pill py-2 w-100 small">
                                <i class="bi bi-arrow-left me-1"></i> Ver otros servicios
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </main>
    </c:if>

    <c:if test="${empty servicio}">
        <div class="container py-5 text-center">
            <div class="alert alert-artdent-info d-inline-block p-4 my-5">
                <i class="bi bi-exclamation-triangle fs-3 text-brand-primary d-block mb-2"></i>
                <h5 class="fw-bold">No se encontró el servicio solicitado</h5>
                <p class="small text-muted mb-3">Por favor regresa al catálogo de servicios para seleccionar una opción válida.</p>
                <a href="ServicioController?action=listar" class="btn btn-primary rounded-pill px-4">Ir a Servicios</a>
            </div>
        </div>
    </c:if>

    <!-- Footer Oficial -->
    <%@include file="footer.jsp"%>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>