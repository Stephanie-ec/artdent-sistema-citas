<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Preguntas Frecuentes - Art Dent | Respuestas y Orientación</title>
    <!-- Bootstrap 5.3 & Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Open+Sans:wght@400;600;700&family=Roboto:wght@500;700;900&display=swap" rel="stylesheet">
    <!-- Hoja de Estilos Oficial de Marca Art Dent -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">

    <style>
        .faq-hero {
            background-image: linear-gradient(rgba(33, 37, 41, 0.75), rgba(33, 37, 41, 0.85)), 
                              url('https://img.freepik.com/fotos-premium/medicos-pie-pasillo-hospital-brazos-cruzados_958192-31239.jpg');
            background-size: cover;
            background-position: center;
            min-height: 380px;
            display: flex;
            align-items: center;
        }

        .accordion-item {
            border: 1px solid var(--artdent-border);
            border-radius: 12px !important;
            overflow: hidden;
            margin-bottom: 1rem;
            box-shadow: var(--artdent-shadow-sm);
        }

        .accordion-button {
            font-weight: 700;
            color: var(--artdent-dark) !important;
            padding: 1.2rem 1.5rem;
            background-color: #ffffff;
            font-size: 1.05rem;
        }

        .accordion-button:not(.collapsed) {
            background-color: #f0fbfd !important;
            color: var(--artdent-primary) !important;
            box-shadow: none;
            border-bottom: 1px solid var(--artdent-border);
        }

        .accordion-button:focus {
            box-shadow: none;
            border-color: var(--artdent-primary);
        }

        .accordion-body {
            padding: 1.4rem 1.5rem;
            line-height: 1.7;
            color: #495057;
            background-color: #ffffff;
        }
    </style>
</head>

<body>
    <!-- Navbar Oficial -->
    <%@include file="header.jsp"%>

    <!-- Banner Principal FAQ -->
    <section class="faq-hero text-white text-center">
        <div class="container px-4">
            <span class="badge bg-brand-mint text-dark px-3 py-2 rounded-pill text-uppercase fw-bold mb-3">
                <i class="bi bi-question-circle-fill me-1"></i> Centro de Ayuda
            </span>
            <h1 class="display-4 fw-bold mb-3">Preguntas <span class="text-brand-primary">Frecuentes</span></h1>
            <p class="lead text-white-50 mx-auto" style="max-width: 750px;">
                Encuentra respuestas claras y rápidas sobre citas, costos, procedimientos dentales y cuidados preventivos.
            </p>
        </div>
    </section>

    <!-- Acordeón de Preguntas Frecuentes -->
    <section class="py-5 bg-brand-light">
        <div class="container px-4" style="max-width: 900px;">
            <div class="accordion" id="faqAccordion">

                <!-- Pregunta 1 -->
                <div class="accordion-item">
                    <h2 class="accordion-header" id="headingOne">
                        <button class="accordion-button" type="button" data-bs-toggle="collapse" 
                                data-bs-target="#collapseOne" aria-expanded="true" aria-controls="collapseOne">
                            <i class="bi bi-calendar-x text-brand-primary me-3 fs-5"></i>
                            ¿Qué hago si no puedo presentarme a mi cita reservada?
                        </button>
                    </h2>
                    <div id="collapseOne" class="accordion-collapse collapse show" aria-labelledby="headingOne" data-bs-parent="#faqAccordion">
                        <div class="accordion-body">
                            Te recomendamos comunicarte con nuestra secretaría con al menos <strong>2 horas de anticipación</strong> al teléfono <strong>(01) 361-3634</strong> o vía WhatsApp. Podrás solicitar una reprogramación sin costo alguno según los horarios disponibles de tu odontólogo de preferencia.
                        </div>
                    </div>
                </div>

                <!-- Pregunta 2 -->
                <div class="accordion-item">
                    <h2 class="accordion-header" id="headingTwo">
                        <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" 
                                data-bs-target="#collapseTwo" aria-expanded="false" aria-controls="collapseTwo">
                            <i class="bi bi-currency-dollar text-brand-accent me-3 fs-5"></i>
                            ¿Cuál es el costo de una consulta o evaluación diagnóstica?
                        </button>
                    </h2>
                    <div id="collapseTwo" class="accordion-collapse collapse" aria-labelledby="headingTwo" data-bs-parent="#faqAccordion">
                        <div class="accordion-body">
                            La consulta de evaluación general con odontograma tiene un costo base de <strong>S/ 50.00</strong>. Si inicias un tratamiento el mismo día (profilaxis, curación o endodoncia), dicho monto puede abonarse como parte de pago del procedimiento según las promociones vigentes.
                        </div>
                    </div>
                </div>

                <!-- Pregunta 3 -->
                <div class="accordion-item">
                    <h2 class="accordion-header" id="headingThree">
                        <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" 
                                data-bs-target="#collapseThree" aria-expanded="false" aria-controls="collapseThree">
                            <i class="bi bi-clock-history text-brand-primary me-3 fs-5"></i>
                            ¿Con qué frecuencia debo acudir a revisión dental?
                        </button>
                    </h2>
                    <div id="collapseThree" class="accordion-collapse collapse" aria-labelledby="headingThree" data-bs-parent="#faqAccordion">
                        <div class="accordion-body">
                            La Organización Mundial de la Salud y nuestro equipo médico recomiendan chequeos preventivos cada <strong>6 meses</strong>. Esta frecuencia previene caries avanzadas, gingivitis y permite realizar limpiezas con ultrasonido antes de que el sarro afecte el hueso alveolar.
                        </div>
                    </div>
                </div>

                <!-- Pregunta 4 -->
                <div class="accordion-item">
                    <h2 class="accordion-header" id="headingFour">
                        <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" 
                                data-bs-target="#collapseFour" aria-expanded="false" aria-controls="collapseFour">
                            <i class="bi bi-shield-exclamation text-brand-accent me-3 fs-5"></i>
                            ¿Qué debo hacer si presento dolor dental intenso o una urgencia?
                        </button>
                    </h2>
                    <div id="collapseFour" class="accordion-collapse collapse" aria-labelledby="headingFour" data-bs-parent="#faqAccordion">
                        <div class="accordion-body">
                            Si tienes dolor agudo o inflamación, comunícate inmediatamente a nuestro centro para coordinar una <strong>atención de urgencia presencial</strong>. Evita colocarte pastillas o alcohol directamente sobre la encía, ya que causan quemaduras químicas, y consulta a nuestro asistente virtual para orientación previa.
                        </div>
                    </div>
                </div>

                <!-- Pregunta 5 -->
                <div class="accordion-item">
                    <h2 class="accordion-header" id="headingFive">
                        <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" 
                                data-bs-target="#collapseFive" aria-expanded="false" aria-controls="collapseFive">
                            <i class="bi bi-stars text-brand-mint me-3 fs-5"></i>
                            ¿El blanqueamiento dental daña el esmalte de los dientes?
                        </button>
                    </h2>
                    <div id="collapseFive" class="accordion-collapse collapse" aria-labelledby="headingFive" data-bs-parent="#faqAccordion">
                        <div class="accordion-body">
                            No. Cuando se realiza bajo supervisión odontológica profesional con geles biocompatibles y luz LED certificada, el esmalte conserva intacta su microestructura. Puede presentarse una ligera sensibilidad transitoria de 24 a 48 horas que se controla con cremas desensibilizantes.
                        </div>
                    </div>
                </div>

            </div>

            <!-- Caja de Consulta Directa -->
            <div class="card mt-5 p-4 text-center border-0 shadow-sm" style="border-radius: 16px; background: #ffffff;">
                <h5 class="fw-bold text-brand-dark mb-2">¿Tienes alguna pregunta adicional?</h5>
                <p class="text-muted small mb-3">Utiliza nuestro asistente virtual con IA o contáctanos directamente a nuestra central telefónica.</p>
                <div class="d-flex justify-content-center gap-3">
                    <a href="ServicioController?action=formreservaa" class="btn btn-primary rounded-pill px-4">
                        <i class="bi bi-calendar-check me-1"></i> Agendar Cita
                    </a>
                    <a href="https://wa.me/51987654321" target="_blank" class="btn btn-outline-success rounded-pill px-4">
                        <i class="bi bi-whatsapp me-1"></i> Chatear por WhatsApp
                    </a>
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
        <div class="chat-input" style="height: 64px; background: #fff; padding: 10px 14px; display: flex; align-items: center; gap: 8px; border-top: 1px solid var(--artdent-border);">
            <input type="text" id="pregunta" placeholder="Escribe tu consulta..." style="flex-grow: 1; border: 1px solid var(--artdent-border); border-radius: 20px; padding: 8px 14px; outline: none;">
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

            agregarMensajeBot('¡Hola! Si tienes preguntas sobre tratamientos o citas, pregúntame aquí.');

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
                agregarMensajeBot('No fue posible conectar con el asistente. Llámanos al (01) 361-3634.');
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