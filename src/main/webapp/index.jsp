<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Inicio - Art Dent | Centro Odontológico</title>
    <!-- Bootstrap 5.3 & Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Open+Sans:wght@400;600;700&family=Roboto:wght@500;700;900&display=swap" rel="stylesheet">
    <!-- Hoja de Estilos Oficial de Marca Art Dent -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">

    <style>
        @keyframes fadeInEffect {
            0% { opacity: 0; transform: translateY(12px); }
            100% { opacity: 1; transform: translateY(0); }
        }

        .hero-banner {
            background-image: linear-gradient(rgba(33, 37, 41, 0.65), rgba(33, 37, 41, 0.75)), 
                              url('https://www.clinicadentalsonriemaslima.com/wp-content/themes/Sonriemas/img/slider2.jpg');
            background-size: cover;
            background-position: center;
            min-height: 560px;
            display: flex;
            align-items: center;
        }

        .section-title {
            position: relative;
            display: inline-block;
            font-weight: 800;
            color: var(--artdent-dark);
            margin-bottom: 1.5rem;
        }

        .section-title::after {
            content: '';
            position: absolute;
            bottom: -8px;
            left: 50%;
            transform: translateX(-50%);
            width: 60px;
            height: 4px;
            background-color: var(--artdent-primary);
            border-radius: 2px;
        }

        .doctor-card {
            border: 1px solid var(--artdent-border);
            border-radius: 16px;
            overflow: hidden;
            transition: all 0.3s ease;
            background: #fff;
        }

        .doctor-card:hover {
            transform: translateY(-6px);
            box-shadow: 0 12px 24px rgba(48, 164, 198, 0.15);
            border-color: var(--artdent-primary);
        }

        .sede-card {
            border-radius: 16px;
            overflow: hidden;
            border: 1px solid var(--artdent-border);
            box-shadow: var(--artdent-shadow-sm);
        }

        /* --- Chatbot Widget Integrado con Colores de Marca --- */
        .chat-widget {
            position: fixed;
            bottom: 25px;
            right: 25px;
            width: 380px;
            max-width: 90vw;
            height: 540px;
            background: #ffffff;
            border-radius: 16px;
            overflow: hidden;
            box-shadow: 0 12px 36px rgba(33, 37, 41, 0.22);
            transition: all 0.35s cubic-bezier(0.4, 0, 0.2, 1);
            z-index: 1050;
            display: flex;
            flex-direction: column;
            border: 1px solid var(--artdent-border);
        }

        .chat-widget.collapsed {
            height: 54px;
            width: 320px;
            border-radius: 27px;
            box-shadow: 0 6px 20px rgba(48, 164, 198, 0.35);
        }

        .chat-header {
            background: linear-gradient(135deg, var(--artdent-primary), var(--artdent-primary-hover));
            color: #ffffff;
            padding: 14px 18px;
            cursor: pointer;
            font-weight: 700;
            display: flex;
            align-items: center;
            justify-content: space-between;
            user-select: none;
        }

        .chat-body {
            flex: 1;
            overflow-y: auto;
            padding: 16px;
            background-color: #f8fafc;
            display: flex;
            flex-direction: column;
            gap: 10px;
        }

        .chat-input {
            height: 64px;
            background-color: #ffffff;
            padding: 10px 14px;
            display: flex;
            align-items: center;
            gap: 8px;
            border-top: 1px solid var(--artdent-border);
        }

        .chat-input input {
            flex-grow: 1;
            border: 1px solid var(--artdent-border);
            background-color: #f1f5f9;
            color: var(--artdent-dark);
            padding: 9px 14px;
            border-radius: 20px;
            outline: none;
            font-size: 0.9rem;
        }

        .chat-input input:focus {
            border-color: var(--artdent-primary);
            background-color: #ffffff;
        }

        .chat-input button {
            background-color: var(--artdent-accent);
            color: #ffffff;
            border: none;
            border-radius: 50%;
            width: 40px;
            height: 40px;
            display: flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            transition: all 0.2s ease;
        }

        .chat-input button:hover {
            background-color: var(--artdent-accent-hover);
            transform: scale(1.06);
        }

        .message {
            padding: 10px 14px;
            border-radius: 14px;
            max-width: 82%;
            font-size: 0.92rem;
            line-height: 1.45;
            animation: fadeInEffect 0.3s ease;
        }

        .user-message {
            background-color: var(--artdent-primary);
            color: #ffffff;
            align-self: flex-end;
            border-bottom-right-radius: 2px;
            box-shadow: 0 2px 6px rgba(48, 164, 198, 0.25);
        }

        .bot-message {
            background-color: #ffffff;
            color: var(--artdent-dark);
            align-self: flex-start;
            border-bottom-left-radius: 2px;
            box-shadow: 0 2px 6px rgba(33, 37, 41, 0.06);
            border-left: 3px solid var(--artdent-primary);
        }

        .loading-animation {
            display: none;
            padding: 8px 12px;
            align-self: flex-start;
        }

        .loading-animation span {
            display: inline-block;
            width: 8px;
            height: 8px;
            background-color: var(--artdent-primary);
            border-radius: 50%;
            margin: 0 3px;
            animation: bounce 1.4s infinite ease-in-out both;
        }

        .loading-animation span:nth-child(1) { animation-delay: -0.32s; }
        .loading-animation span:nth-child(2) { animation-delay: -0.16s; }

        @keyframes bounce {
            0%, 80%, 100% { transform: scale(0); }
            40% { transform: scale(1.0); }
        }
    </style>
</head>

<body>
    <!-- Navbar Oficial -->
    <%@include file="header.jsp"%>

    <!-- Hero Banner Principal -->
    <section class="hero-banner text-white">
        <div class="container px-4">
            <div class="row align-items-center">
                <div class="col-12 col-lg-8" style="animation: fadeInEffect 1s ease-in-out forwards;">
                    <span class="badge bg-brand-accent text-white px-3 py-2 rounded-pill text-uppercase fw-bold mb-3">
                        <i class="bi bi-star-fill me-1"></i> Excelencia en Odontología Integral
                    </span>
                    <h1 class="display-3 fw-bold mb-2">Art <span class="text-brand-primary">Dent</span></h1>
                    <h2 class="h2 fw-semibold mb-4 text-light">Ayudándote a sonreír con confianza</h2>
                    <p class="lead mb-4 text-white-50" style="max-width: 680px;">
                        Somos una clínica odontológica moderna comprometida con tu salud bucal. Brindamos atención personalizada en 
                        odontología preventiva, endodoncia, ortodoncia, cirugía bucal e implantes con especialistas certificados.
                    </p>
                    <div class="d-flex flex-wrap gap-3">
                        <a href="ServicioController?action=formreservaa" class="btn btn-success btn-lg px-4 py-3 rounded-pill shadow">
                            <i class="bi bi-calendar-check me-2"></i> Reserva tu cita aquí
                        </a>
                        <a href="ServicioController?action=listar" class="btn btn-outline-light btn-lg px-4 py-3 rounded-pill">
                            <i class="bi bi-info-circle me-2"></i> Conoce nuestros servicios
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Marcas y Aliados que Respaldan -->
    <section class="container my-5 py-4">
        <div class="text-center mb-4">
            <h3 class="section-title">Tecnología y Respaldos</h3>
            <p class="text-muted small">Trabajamos con insumos dentales de los laboratorios líderes a nivel mundial</p>
        </div>
        <div class="row justify-content-center align-items-center g-4 text-center">
            <div class="col-6 col-md-3">
                <img src="https://upload.wikimedia.org/wikipedia/commons/3/3f/Colgate.svg" class="img-fluid p-2" alt="Colgate" style="max-height: 55px; filter: grayscale(20%);">
            </div>
            <div class="col-6 col-md-3">
                <img src="https://assets.boots.com/content/dam/boots/brands/brand---s/sensodyne/sensodyne_bt/sensodyne_bt_2021-05/2021-05_sensodyne_brand-treatment_horizontal-nav_sensodyne.dam.ts%3D1626850968239.jpg" class="img-fluid p-2" alt="Sensodyne" style="max-height: 55px; filter: grayscale(20%);">
            </div>
            <div class="col-6 col-md-3">
                <img src="https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTSVfCmOuGgT9LsJlj-ZbzhIBZdjK6UZrq7Ap87lo-mFoQcHsuCNYDhdGDPmZmFDcPCqQ" class="img-fluid p-2" alt="Nestlé Healthcare" style="max-height: 55px; filter: grayscale(20%);">
            </div>
            <div class="col-6 col-md-3">
                <img src="https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQByTHpMwmvqMIdQ-GLSxd6rx6fls7MkQ__KA&s" class="img-fluid p-2" alt="Aliado Clínico" style="max-height: 55px; filter: grayscale(20%);">
            </div>
        </div>
    </section>

    <!-- Nuestras Sedes -->
    <section class="container my-5 py-4">
        <div class="text-center mb-5">
            <h2 class="section-title">Nuestras Sedes</h2>
            <p class="text-muted">Ubicados estratégicamente en Chosica y Chaclacayo para brindarte una atención rápida y cómoda</p>
        </div>

        <div class="row g-4">
            <!-- Sede Chosica -->
            <div class="col-12 col-lg-6">
                <div class="card sede-card h-100">
                    <div class="ratio ratio-16x9">
                        <iframe 
                            src="https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d4915.00775618888!2d-76.69852092397075!3d-11.936868239866305!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x9105ef0f5e97b5df%3A0xaa9268a039fb2297!2sCentro%20Odontologico%20Integral%20Art%20Dent%20SAC!5e1!3m2!1ses-419!2spe!4v1733294849910!5m2!1ses-419!2spe"
                            style="border: 0;" allowfullscreen="" loading="lazy">
                        </iframe>
                    </div>
                    <div class="card-body p-4">
                        <h4 class="card-title fw-bold text-brand-dark mb-2">
                            <i class="bi bi-geo-alt-fill text-brand-primary me-2"></i>Sede Chosica
                        </h4>
                        <p class="text-muted mb-2"><i class="bi bi-pin-map me-1"></i> Jr. Chiclayo 268, Chosica, Lima</p>
                        <p class="text-muted mb-3"><i class="bi bi-telephone-fill me-1"></i> Central: <strong>(01) 361-3634</strong></p>
                        <div class="bg-light p-3 rounded-3 small">
                            <strong class="text-brand-dark d-block mb-1"><i class="bi bi-clock me-1"></i> Horarios de Atención:</strong>
                            <span class="d-block text-muted">Lunes a Sábado: 8:00 AM - 7:00 PM</span>
                            <span class="d-block text-danger fw-semibold">Domingo: Cerrado</span>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Sede Chaclacayo -->
            <div class="col-12 col-lg-6">
                <div class="card sede-card h-100">
                    <div class="ratio ratio-16x9">
                        <iframe 
                            src="https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d4915.00775618888!2d-76.69852092397075!3d-11.936868239866305!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x9105ef0f5e97b5df%3A0xaa9268a039fb2297!2sCentro%20Odontologico%20Integral%20Art%20Dent%20SAC!5e1!3m2!1ses-419!2spe!4v1733294849910!5m2!1ses-419!2spe"
                            style="border: 0;" allowfullscreen="" loading="lazy">
                        </iframe>
                    </div>
                    <div class="card-body p-4">
                        <h4 class="card-title fw-bold text-brand-dark mb-2">
                            <i class="bi bi-geo-alt-fill text-brand-primary me-2"></i>Sede Chaclacayo
                        </h4>
                        <p class="text-muted mb-2"><i class="bi bi-pin-map me-1"></i> Av. Las Palmeras 328, Chaclacayo, Lima</p>
                        <p class="text-muted mb-3"><i class="bi bi-telephone-fill me-1"></i> Central: <strong>(01) 361-3634</strong></p>
                        <div class="bg-light p-3 rounded-3 small">
                            <strong class="text-brand-dark d-block mb-1"><i class="bi bi-clock me-1"></i> Horarios de Atención:</strong>
                            <span class="d-block text-muted">Lunes a Sábado: 8:00 AM - 7:00 PM</span>
                            <span class="d-block text-danger fw-semibold">Domingo: Cerrado</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Nuestro Equipo Médico -->
    <section class="container my-5 py-4">
        <div class="text-center mb-5">
            <h2 class="section-title">Especialistas Odontológicos</h2>
            <p class="text-muted">Profesionales de amplia trayectoria dedicados al cuidado de tu salud bucal</p>
        </div>

        <div class="row g-4 justify-content-center">
            <!-- Doctor 1 -->
            <div class="col-12 col-md-6 col-lg-4">
                <div class="card doctor-card h-100">
                    <img src="https://saluddata.com/wp-content/uploads/2024/07/Odontologo-Profesional-p.webp" 
                         class="card-img-top" alt="Dr. Luis Miguel Martínez" style="height: 250px; object-fit: cover;">
                    <div class="card-body text-center p-4">
                        <h5 class="fw-bold text-brand-dark mb-1">Dr. Luis Miguel Martínez</h5>
                        <span class="badge bg-mint text-dark mb-3">Especialista en Endodoncia</span>
                        <p class="text-muted small mb-0">
                            Más de 10 años de experiencia clínica en tratamientos de conducto, maestría en Odontología Restauradora y microcirugía apical.
                        </p>
                    </div>
                </div>
            </div>

            <!-- Doctor 2 -->
            <div class="col-12 col-md-6 col-lg-4">
                <div class="card doctor-card h-100">
                    <img src="https://colderechomedico.com/wp-content/uploads/2020/06/Cual-es-la-importancia-del-secreto-profesional-en-odontologia_colderecho.jpg" 
                         class="card-img-top" alt="Dr. Rubén Cuadros" style="height: 250px; object-fit: cover;">
                    <div class="card-body text-center p-4">
                        <h5 class="fw-bold text-brand-dark mb-1">Dr. Rubén Cuadros</h5>
                        <span class="badge bg-brand-primary text-white mb-3">Odontología Integral y Cirugía</span>
                        <p class="text-muted small mb-0">
                            Especialista apasionado por la odontología preventiva, rehabilitación oral y diseño digital de sonrisas para pacientes de todas las edades.
                        </p>
                    </div>
                </div>
            </div>

            <!-- Doctor 3 -->
            <div class="col-12 col-md-6 col-lg-4">
                <div class="card doctor-card h-100">
                    <img src="https://img.freepik.com/fotos-premium/retrato-hombre-dentista-pulgares-arriba-sonrisa-cuidado-bucal-especialista-felicidad-profesional-cara-hombre-o-empleado-higiene-dental-sector-salud-apoyo-revision_590464-191475.jpg" 
                         class="card-img-top" alt="Dr. Juan Gómez" style="height: 250px; object-fit: cover;">
                    <div class="card-body text-center p-4">
                        <h5 class="fw-bold text-brand-dark mb-1">Dr. Juan Gómez</h5>
                        <span class="badge bg-mint text-dark mb-3">Estética y Rehabilitación</span>
                        <p class="text-muted small mb-0">
                            Enfocado en devolver la función masticatoria y la armonía estética a través de prótesis fijas, carillas y blanqueamiento dental.
                        </p>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Métodos de Pago Seguros -->
    <section class="container my-5 py-4 border-top">
        <div class="text-center mb-4 pt-3">
            <h4 class="fw-bold text-brand-dark">Medios de Pago Aceptados</h4>
            <p class="text-muted small">Flexibilidad en ventanilla física y pasarela de pago digital segura</p>
        </div>
        <div class="row justify-content-center align-items-center g-4 text-center">
            <div class="col-4 col-md-2">
                <img src="${pageContext.request.contextPath}/img/visa.svg" class="img-fluid" alt="Visa" style="max-height: 40px;">
            </div>
            <div class="col-4 col-md-2">
                <img src="${pageContext.request.contextPath}/img/mastercard.svg" class="img-fluid" alt="MasterCard" style="max-height: 44px;">
            </div>
            <div class="col-4 col-md-2">
                <img src="${pageContext.request.contextPath}/img/paypal.svg" class="img-fluid" alt="PayPal" style="max-height: 40px;">
            </div>
            <div class="col-6 col-md-3">
                <div class="p-2 border rounded-pill bg-light small fw-bold text-brand-dark">
                    <i class="bi bi-cash-stack text-brand-accent me-1"></i> Efectivo en Ventanilla
                </div>
            </div>
        </div>
    </section>

    <!-- Asistente Virtual Inteligente (Chatbot Art Dent) -->
    <div class="chat-widget collapsed" id="chatWidget">
        <div class="chat-header" id="chatHeader">
            <span class="d-flex align-items-center gap-2">
                <i class="bi bi-robot fs-5 text-white"></i> 
                <span>Asistente Virtual Art Dent</span>
            </span>
            <button class="chat-toggle btn p-0 text-white" id="chatToggle" aria-label="Minimizar o expandir chat">
                <i class="fas fa-chevron-up"></i>
            </button>
        </div>
        <div class="chat-body" id="chat-body">
            <!-- Mensajes dinámicos -->
        </div>
        <div class="loading-animation" id="loading-animation">
            <span></span>
            <span></span>
            <span></span>
        </div>
        <div class="chat-input">
            <input type="text" id="pregunta" placeholder="Describe tus síntomas o dudas...">
            <button onclick="enviarPregunta()" title="Enviar mensaje">
                <i class="fas fa-paper-plane"></i>
            </button>
        </div>
    </div>

    <!-- Scripts de Interacción del Asistente Virtual -->
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

            // Mensaje de bienvenida institucional
            agregarMensajeBot('¡Hola! Soy el asistente virtual de Art Dent. ¿En qué puedo ayudarte hoy? Cuéntame tus síntomas o lo que necesitas y te recomendaré el tratamiento ideal.');

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
            mostrarAnimacion();

            try {
                const response = await fetch('${pageContext.request.contextPath}/api/chatbot', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded'
                    },
                    body: 'pregunta=' + encodeURIComponent(pregunta)
                });

                const data = await response.text();
                ocultarAnimacion();
                agregarMensajeBot(data);
            } catch (err) {
                ocultarAnimacion();
                agregarMensajeBot('Lo sentimos, hubo un inconveniente al conectar con el asistente. Por favor, comunícate al (01) 361-3634 o reserva directamente en el menú de Servicios.');
            }
        }

        function agregarMensajeUsuario(mensaje) {
            const chatBody = document.getElementById('chat-body');
            const mensajeDiv = document.createElement('div');
            mensajeDiv.className = 'message user-message';
            mensajeDiv.textContent = mensaje;
            chatBody.appendChild(mensajeDiv);
            scrollToBottom();
        }

        function agregarMensajeBot(mensaje) {
            const chatBody = document.getElementById('chat-body');
            const mensajeDiv = document.createElement('div');
            mensajeDiv.className = 'message bot-message';
            mensajeDiv.innerHTML = mensaje;
            chatBody.appendChild(mensajeDiv);
            scrollToBottom();
        }

        function scrollToBottom() {
            const chatBody = document.getElementById('chat-body');
            chatBody.scrollTop = chatBody.scrollHeight;
        }

        function mostrarAnimacion() {
            document.getElementById('loading-animation').style.display = 'block';
            scrollToBottom();
        }

        function ocultarAnimacion() {
            document.getElementById('loading-animation').style.display = 'none';
        }
    </script>

    <!-- Footer Institucional -->
    <%@include file="footer.jsp"%>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>