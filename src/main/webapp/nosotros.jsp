<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Nosotros - Art Dent | Compromiso y Salud Bucal</title>
    <!-- Bootstrap 5.3 & Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Open+Sans:wght@400;600;700&family=Roboto:wght@500;700;900&display=swap" rel="stylesheet">
    <!-- Hoja de Estilos Oficial de Marca Art Dent -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">

    <style>
        .about-hero {
            background-image: linear-gradient(rgba(33, 37, 41, 0.7), rgba(33, 37, 41, 0.8)), 
                              url('https://www.flowww.es/hubfs/Q32024%20Septiembre/Blog/historia-clinica-dental-atencion-eficiente-paciente-clinicas-odontologicas.webp');
            background-size: cover;
            background-position: center;
            min-height: 420px;
            display: flex;
            align-items: center;
        }

        .img-card {
            border-radius: 20px;
            overflow: hidden;
            box-shadow: var(--artdent-shadow-md);
            transition: transform 0.3s ease;
        }

        .img-card:hover {
            transform: scale(1.02);
        }

        .value-card {
            border: 1px solid var(--artdent-border);
            border-radius: 16px;
            padding: 2rem;
            background: #ffffff;
            transition: all 0.3s ease;
            height: 100%;
        }

        .value-card:hover {
            border-color: var(--artdent-primary);
            box-shadow: 0 8px 24px rgba(48, 164, 198, 0.12);
            transform: translateY(-4px);
        }
    </style>
</head>

<body>
    <!-- Navbar Oficial -->
    <%@include file="header.jsp"%>

    <!-- Banner Principal -->
    <section class="about-hero text-white text-center">
        <div class="container px-4">
            <span class="badge bg-brand-accent text-white px-3 py-2 rounded-pill text-uppercase fw-bold mb-3">
                <i class="bi bi-heart-pulse-fill me-1"></i> Nuestra Filosofía
            </span>
            <h1 class="display-4 fw-bold mb-3">Acerca de <span class="text-brand-primary">Art Dent</span></h1>
            <p class="lead text-white-50 mx-auto" style="max-width: 700px;">
                Cuidamos de tu sonrisa con tecnología médica avanzada, vocación de servicio y el trato cálido que tú y tu familia merecen.
            </p>
        </div>
    </section>

    <!-- Sección 1: Propósito -->
    <section class="py-5">
        <div class="container px-4">
            <div class="row align-items-center g-5">
                <div class="col-12 col-lg-6">
                    <span class="text-brand-primary fw-bold text-uppercase small tracking-wide">Vocación & Calidad</span>
                    <h2 class="display-6 fw-bold text-brand-dark mt-2 mb-4">Nuestro sueño es transformar tu salud bucal</h2>
                    <p class="text-muted leading-relaxed mb-4">
                        En nuestro centro odontológico, nos dedicamos a elevar el estándar de vida de cada paciente mediante tratamientos dentales de alta precisión. Creemos firmemente que una sonrisa sana abre puertas y genera confianza duradera.
                    </p>
                    <p class="text-muted leading-relaxed mb-4">
                        Contamos con consultorios equipados en Chosica y Chaclacayo, integrando esterilización rigurosa, radiología digital y materiales biocompatibles certificados.
                    </p>
                    <div class="d-flex gap-3">
                        <a href="ServicioController?action=formreservaa" class="btn btn-primary px-4 py-2 rounded-pill">
                            <i class="bi bi-calendar-check me-1"></i> Reserva una Cita
                        </a>
                        <a href="ServicioController?action=listar" class="btn btn-outline-primary px-4 py-2 rounded-pill">
                            Nuestros Tratamientos
                        </a>
                    </div>
                </div>
                <div class="col-12 col-lg-6">
                    <div class="img-card">
                        <img src="https://odontologiaespecializadasevilla.com/wp-content/uploads/2018/07/dentista-sevilla.jpg" 
                             class="img-fluid w-100" alt="Consultorio dental moderno" style="object-fit: cover; max-height: 440px;">
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Sección 2: Misión y Valores -->
    <section class="py-5 bg-brand-light">
        <div class="container px-4">
            <div class="row align-items-center g-5 flex-lg-row-reverse">
                <div class="col-12 col-lg-6">
                    <span class="text-brand-accent fw-bold text-uppercase small tracking-wide">Compromiso Total</span>
                    <h2 class="display-6 fw-bold text-brand-dark mt-2 mb-4">Tu sonrisa, nuestra máxima misión</h2>
                    <p class="text-muted leading-relaxed mb-4">
                        Sabemos que cada paciente es único. Por ello, adaptamos cada plan de tratamiento a tus necesidades y presupuesto, garantizando un acompañamiento cálido desde el diagnóstico inicial hasta el alta clínica.
                    </p>
                    <div class="row g-3">
                        <div class="col-6">
                            <div class="d-flex align-items-center gap-2">
                                <i class="bi bi-check-circle-fill text-brand-accent fs-5"></i>
                                <span class="fw-semibold text-brand-dark">Diagnóstico Digital</span>
                            </div>
                        </div>
                        <div class="col-6">
                            <div class="d-flex align-items-center gap-2">
                                <i class="bi bi-check-circle-fill text-brand-accent fs-5"></i>
                                <span class="fw-semibold text-brand-dark">Protocolo Sin Dolor</span>
                            </div>
                        </div>
                        <div class="col-6">
                            <div class="d-flex align-items-center gap-2">
                                <i class="bi bi-check-circle-fill text-brand-accent fs-5"></i>
                                <span class="fw-semibold text-brand-dark">Especialistas Certificados</span>
                            </div>
                        </div>
                        <div class="col-6">
                            <div class="d-flex align-items-center gap-2">
                                <i class="bi bi-check-circle-fill text-brand-accent fs-5"></i>
                                <span class="fw-semibold text-brand-dark">Precios Transparentes</span>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-12 col-lg-6">
                    <div class="img-card">
                        <img src="https://vital.com.co/wp-content/uploads/2019/02/15-Dise%C3%B1o-De-Sonrisa-Seguro-Y-Confiable.jpg" 
                             class="img-fluid w-100" alt="Diseño de sonrisa confiable" style="object-fit: cover; max-height: 440px;">
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Pilares Institucionales -->
    <section class="py-5">
        <div class="container px-4">
            <div class="text-center mb-5">
                <h3 class="fw-bold text-brand-dark">Nuestros Pilares de Atención</h3>
                <p class="text-muted small">Lo que nos distingue y garantiza la satisfacción de nuestros pacientes</p>
            </div>
            <div class="row g-4">
                <div class="col-12 col-md-4">
                    <div class="value-card text-center">
                        <div class="d-inline-flex p-3 rounded-circle bg-brand-light text-brand-primary mb-3">
                            <i class="bi bi-shield-lock-fill fs-2"></i>
                        </div>
                        <h5 class="fw-bold text-brand-dark mb-2">Bioseguridad Estricta</h5>
                        <p class="text-muted small mb-0">Cumplimos los más rigurosos estándares de desinfección y esterilización en instrumental clínico para tu completa tranquilidad.</p>
                    </div>
                </div>
                <div class="col-12 col-md-4">
                    <div class="value-card text-center">
                        <div class="d-inline-flex p-3 rounded-circle bg-brand-light text-brand-accent mb-3">
                            <i class="bi bi-person-hearts fs-2"></i>
                        </div>
                        <h5 class="fw-bold text-brand-dark mb-2">Atención Humanizada</h5>
                        <p class="text-muted small mb-0">Entendemos los temores dentales; nuestro equipo brinda paciencia, contención y explicaciones claras en cada paso.</p>
                    </div>
                </div>
                <div class="col-12 col-md-4">
                    <div class="value-card text-center">
                        <div class="d-inline-flex p-3 rounded-circle bg-brand-light text-brand-primary mb-3">
                            <i class="bi bi-award-fill fs-2"></i>
                        </div>
                        <h5 class="fw-bold text-brand-dark mb-2">Garantía Clínica</h5>
                        <p class="text-muted small mb-0">Utilizamos insumos restaurativos y prótesis de laboratorios reconocidos internacionalmente con soporte post-tratamiento.</p>
                    </div>
                </div>
            </div>
        </div>
    </section>

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
        <div class="loading-animation" id="loading-animation" style="display: none; padding: 8px 12px;">
            <span style="display: inline-block; width: 8px; height: 8px; background: var(--artdent-primary); border-radius: 50%;"></span>
        </div>
        <div class="chat-input" style="height: 64px; background: #fff; padding: 10px 14px; display: flex; align-items: center; gap: 8px; border-top: 1px solid var(--artdent-border);">
            <input type="text" id="pregunta" placeholder="Describe tus síntomas o dudas..." style="flex-grow: 1; border: 1px solid var(--artdent-border); border-radius: 20px; padding: 8px 14px; outline: none;">
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

            agregarMensajeBot('¡Hola! Soy el asistente virtual de Art Dent. ¿En qué podemos ayudarte hoy?');

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
                agregarMensajeBot('En este momento no podemos responder automáticamente. Llámanos al (01) 361-3634.');
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