<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@page import="java.util.Iterator"%>
<%@page import="pe.edu.utp.daoImpl.ServicioDaoImpl"%>
<%@page import="pe.edu.utp.entity.Servicio"%>
<%@page import="java.util.List"%>
<%@page import="pe.edu.utp.dao.ServicioDao"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Servicios - Art Dent | Tratamientos Odontológicos</title>
    <!-- Bootstrap 5.3 & Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Open+Sans:wght@400;600;700&family=Roboto:wght@500;700;900&display=swap" rel="stylesheet">
    <!-- Hoja de Estilos Oficial de Marca Art Dent -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">

    <style>
        .services-hero {
            background-image: linear-gradient(rgba(33, 37, 41, 0.72), rgba(33, 37, 41, 0.82)), 
                              url('https://images.unsplash.com/photo-1629909613654-28e377c37b09?auto=format&fit=crop&w=1920&q=80');
            background-size: cover;
            background-position: center;
            min-height: 380px;
            display: flex;
            align-items: center;
        }

        .service-card {
            border: 1px solid var(--artdent-border);
            border-radius: 16px;
            overflow: hidden;
            background: #ffffff;
            transition: all 0.3s ease;
            box-shadow: var(--artdent-shadow-sm);
        }

        .service-card:hover {
            transform: translateY(-5px);
            border-color: var(--artdent-primary);
            box-shadow: 0 12px 28px rgba(48, 164, 198, 0.16);
        }

        .service-card .card-img-top {
            height: 210px;
            object-fit: cover;
            transition: transform 0.4s ease;
        }

        .service-card:hover .card-img-top {
            transform: scale(1.04);
        }
    </style>
</head>

<body>
    <!-- Navbar Oficial -->
    <%@include file="header.jsp"%>

    <!-- Banner Principal -->
    <section class="services-hero text-white text-center">
        <div class="container px-4">
            <span class="badge bg-brand-accent text-white px-3 py-2 rounded-pill text-uppercase fw-bold mb-3">
                <i class="bi bi-patch-check-fill me-1"></i> Catálogo Clínico
            </span>
            <h1 class="display-4 fw-bold mb-3">Nuestros <span class="text-brand-primary">Servicios</span></h1>
            <p class="lead text-white-50 mx-auto" style="max-width: 800px;">
                Ofrecemos una amplia cartera de tratamientos odontológicos con especialistas de primer nivel, tecnología digital y los más altos estándares de bioseguridad.
            </p>
        </div>
    </section>

    <!-- Catálogo de Servicios Dinámico -->
    <section class="py-5 bg-brand-light">
        <div class="container px-4">
            <div class="d-flex justify-content-between align-items-center mb-4 flex-wrap gap-2">
                <div>
                    <h3 class="fw-bold text-brand-dark m-0">Tratamientos Disponibles</h3>
                    <p class="text-muted small m-0">Selecciona el tratamiento para ver detalles médicos y reservar tu cita</p>
                </div>
                <a href="ServicioController?action=formreservaa" class="btn btn-success px-4 py-2 rounded-pill shadow-sm">
                    <i class="bi bi-calendar-plus me-1"></i> Reservar Ahora
                </a>
            </div>

            <div class="row g-4">
                <c:set var="itemsToDisplay" value="${not empty listServicio ? listServicio : servicios}" />
                <c:forEach var="servicio" items="${itemsToDisplay}">
                    <div class="col-12 col-md-6 col-lg-3">
                        <div class="card service-card h-100">
                            <div class="overflow-hidden position-relative">
                                <img src="${servicio.linkimagen}" 
                                     onerror="fallbackDentalImg(this, '${servicio.tipoServicio}');" 
                                     class="card-img-top img-fluid" 
                                     alt="${servicio.tipoServicio}">
                                <c:if test="${not empty servicio.costo}">
                                    <span class="position-absolute bottom-0 end-0 m-2 badge bg-brand-primary fs-6 shadow">
                                        S/. ${servicio.costo}
                                    </span>
                                </c:if>
                            </div>
                            <div class="card-body d-flex flex-column p-4">
                                <h5 class="card-title fw-bold text-brand-dark mb-2">${servicio.tipoServicio}</h5>
                                <p class="card-text text-muted flex-grow-1 small leading-relaxed">
                                    <c:choose>
                                        <c:when test="${fn:length(servicio.descripcion) > 110}">
                                            ${fn:substring(servicio.descripcion, 0, 110)}...
                                        </c:when>
                                        <c:otherwise>
                                            ${servicio.descripcion}
                                        </c:otherwise>
                                    </c:choose>
                                </p>
                                <a href="ServicioController?action=cargar&id=${servicio.idServicio}" 
                                   class="btn btn-outline-primary rounded-pill mt-3 py-2 fw-semibold w-100">
                                    <i class="bi bi-info-circle me-1"></i> Conoce más
                                </a>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </div>
        </div>
    </section>

    <!-- Script de Fallback de Imágenes Clínicas -->
    <script>
    function fallbackDentalImg(img, title) {
        img.onerror = null;
        var t = (title || '').toLowerCase();
        if (t.indexOf('blanqueamiento') !== -1) {
            img.src = 'https://img.freepik.com/foto-gratis/primer-plano-mujer-dientes-blancos-perfectos_186202-4573.jpg';
        } else if (t.indexOf('caries') !== -1) {
            img.src = 'https://img.freepik.com/foto-gratis/dentista-examinando-dientes-paciente-femenino-espejo-bucal_23-2149176709.jpg';
        } else if (t.indexOf('endodoncia') !== -1) {
            img.src = 'https://img.freepik.com/foto-gratis/dentista-tratando-paciente-clinica_23-2149176729.jpg';
        } else if (t.indexOf('prótesis') !== -1 || t.indexOf('protesis') !== -1) {
            img.src = 'https://img.freepik.com/foto-gratis/dentista-sosteniendo-protesis-dental_23-2149176719.jpg';
        } else if (t.indexOf('cirug') !== -1) {
            img.src = 'https://img.freepik.com/foto-gratis/medico-examinando-dientes-paciente-femenino-usando-herramientas-dentales_23-2149176721.jpg';
        } else if (t.indexOf('ortodoncia') !== -1) {
            img.src = 'https://img.freepik.com/foto-gratis/paciente-femenina-que-muestra-sus-nuevos-frenillos-dental-clinica_23-2149301072.jpg';
        } else {
            img.src = 'https://img.freepik.com/foto-gratis/primer-plano-dentista-limpiando-dientes-paciente_23-2149176713.jpg';
        }
    }
    </script>

    <!-- Chatbot Widget Oficial -->
    <div class="chat-widget collapsed" id="chatWidget" style="position: fixed; bottom: 25px; right: 25px; z-index: 1050;">
        <div class="chat-header" id="chatHeader" style="background: linear-gradient(135deg, var(--artdent-primary), var(--artdent-primary-hover)); color: #fff; padding: 14px 18px; cursor: pointer; font-weight: bold; display: flex; align-items: center; justify-content: space-between;">
            <span class="d-flex align-items-center gap-2">
                <i class="bi bi-robot fs-5"></i> 
                <span>Asistente Virtual Art Dent</span>
            </span>
            <button class="btn p-0 text-white" id="chatToggle" aria-label="Toggle chat">
                <i class="fas fa-chevron-up"></i>
            </button>
        </div>
        <div class="chat-body" id="chat-body" style="flex: 1; overflow-y: auto; padding: 16px; background-color: #f8fafc; display: flex; flex-direction: column; gap: 10px;"></div>
        <div class="chat-input" style="height: 64px; background: #fff; padding: 10px 14px; display: flex; align-items: center; gap: 8px; border-top: 1px solid var(--artdent-border);">
            <input type="text" id="pregunta" placeholder="¿Dudas sobre un servicio? Escribe aquí..." style="flex-grow: 1; border: 1px solid var(--artdent-border); border-radius: 20px; padding: 8px 14px; outline: none;">
            <button onclick="enviarPregunta()" class="btn btn-success rounded-circle d-flex align-items-center justify-content-center" style="width: 40px; height: 40px;">
                <i class="fas fa-paper-plane text-white"></i>
            </button>
        </div>
    </div>

    <!-- Scripts Chatbot -->
    <script>
        document.addEventListener('DOMContentLoaded', function () {
            const chatWidget = document.getElementById('chatWidget');
            const chatHeader = document.getElementById('chatHeader');
            const chatToggle = document.getElementById('chatToggle');
            const chatBody = document.getElementById('chat-body');

            function toggleChat() {
                chatWidget.classList.toggle('collapsed');
                chatToggle.innerHTML = chatWidget.classList.contains('collapsed')
                        ? '<i class="fas fa-chevron-up"></i>'
                        : '<i class="fas fa-chevron-down"></i>';
            }

            chatHeader.addEventListener('click', toggleChat);
            chatToggle.addEventListener('click', function (e) {
                e.stopPropagation();
                toggleChat();
            });

            agregarMensajeBot('¡Hola! Si no estás seguro de qué tratamiento necesitas, describe tus molestias y te orientaré.');

            const preguntaInput = document.getElementById('pregunta');
            if (preguntaInput) {
                preguntaInput.addEventListener('keypress', function (e) {
                    if (e.key === 'Enter') {
                        e.preventDefault();
                        enviarPregunta();
                    }
                });
            }
        });

        async function enviarPregunta() {
            const preguntaInput = document.getElementById("pregunta");
            const pregunta = preguntaInput.value.trim();
            if (pregunta === '') return;

            agregarMensajeUsuario(pregunta);
            preguntaInput.value = '';

            try {
                const response = await fetch('${pageContext.request.contextPath}/api/chatbot', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                    body: 'pregunta=' + encodeURIComponent(pregunta)
                });
                const data = await response.text();
                agregarMensajeBot(data);
            } catch (err) {
                agregarMensajeBot('No fue posible conectar con el asistente. Comunícate al (01) 361-3634.');
            }
        }

        function agregarMensajeUsuario(mensaje) {
            const chatBody = document.getElementById('chat-body');
            const mensajeDiv = document.createElement('div');
            mensajeDiv.className = 'message user-message';
            mensajeDiv.textContent = mensaje;
            chatBody.appendChild(mensajeDiv);
            chatBody.scrollTop = chatBody.scrollHeight;
        }

        function agregarMensajeBot(mensaje) {
            const chatBody = document.getElementById('chat-body');
            const mensajeDiv = document.createElement('div');
            mensajeDiv.className = 'message bot-message';
            mensajeDiv.innerHTML = mensaje;
            chatBody.appendChild(mensajeDiv);
            chatBody.scrollTop = chatBody.scrollHeight;
        }
    </script>

    <!-- Footer Oficial -->
    <%@include file="footer.jsp"%>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>