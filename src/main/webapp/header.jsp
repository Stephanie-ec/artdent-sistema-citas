<%@ page pageEncoding="UTF-8" %>
<!-- Header Institucional Art Dent -->
<nav class="navbar navbar-expand-lg navbar-light artdent-navbar shadow-sm w-100">
    <div class="container-fluid px-lg-4">
        <!-- Logo de Marca -->
        <a class="navbar-brand d-flex align-items-center gap-2" href="index.jsp">
            <img src="https://logomaker.designfreelogoonline.com/media/productdesigner/logo/resized/0001036_dental_logo_maker_dentist_Logo-02.png" 
                 alt="Art Dent Logo" width="46" height="46" class="d-inline-block align-text-top">
            <span class="fw-bold fs-4 text-brand-dark tracking-wide">Art <span class="text-brand-primary">Dent</span></span>
        </a>

        <!-- Botón colapsable para móviles -->
        <button class="navbar-toggler border-0 shadow-none" type="button" data-bs-toggle="collapse" 
                data-bs-target="#navbarNav" aria-controls="navbarNav" aria-expanded="false" aria-label="Toggle navigation">
            <span class="navbar-toggler-icon"></span>
        </button>

        <!-- Links del navbar -->
        <div class="collapse navbar-collapse justify-content-between" id="navbarNav">
            <ul class="navbar-nav mx-auto text-center gap-lg-3 py-2 py-lg-0">
                <li class="nav-item">
                    <a class="nav-link" aria-current="page" href="index.jsp">Inicio</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="ServicioController?action=listar">Servicios</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="nosotros.jsp">Nosotros</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="faq.jsp">FAQ</a>
                </li>
            </ul>

            <!-- Botón de Usuario / Autenticación -->
            <div class="d-flex justify-content-center align-items-center gap-2">
                <%
                    HttpSession sesionHeader = request.getSession(false);
                    Integer idUserHeader = (sesionHeader != null) ? (Integer) sesionHeader.getAttribute("idUsuario") : null;
                    String nombreHeader = (sesionHeader != null) ? (String) sesionHeader.getAttribute("Nombre") : null;
                    String tiporolHeader = (sesionHeader != null) ? (String) sesionHeader.getAttribute("TipoRol") : null;

                    if (idUserHeader == null) { 
                %>
                <!-- Botón de Iniciar Sesión para visitantes -->
                <a href="iniciosesion.jsp" class="btn btn-primary rounded-pill px-4 shadow-sm">
                    <i class="bi bi-box-arrow-in-right me-1"></i> Iniciar Sesión
                </a>
                <% } else { %>
                <!-- Menú desplegable si el usuario está autenticado -->
                <div class="dropdown">
                    <button class="btn btn-primary rounded-pill px-4 dropdown-toggle shadow-sm d-flex align-items-center gap-2" 
                            type="button" id="userDropdown" data-bs-toggle="dropdown" aria-expanded="false">
                        <i class="bi bi-person-circle"></i>
                        <span><%= (nombreHeader != null ? nombreHeader : "Mi Cuenta") %></span>
                    </button>
                    <ul class="dropdown-menu dropdown-menu-end shadow-sm border-0 mt-2" aria-labelledby="userDropdown">
                        <li class="dropdown-header text-muted small">Rol: <%= (tiporolHeader != null ? tiporolHeader : "Usuario") %></li>
                        <li><a class="dropdown-item" href="ReservaController?accion=listarReservasPorDia"><i class="bi bi-calendar-event me-2 text-brand-primary"></i>Panel de Control</a></li>
                        <% if ("Administrador".equalsIgnoreCase(tiporolHeader)) { %>
                            <li><a class="dropdown-item" href="DashboardController?action=dashboard"><i class="bi bi-speedometer2 me-2 text-brand-accent"></i>Panel Administrador</a></li>
                        <% } %>
                        <li><a class="dropdown-item" href="ReservaController?accion=formcita"><i class="bi bi-calendar-plus me-2 text-brand-primary"></i>Crear reserva</a></li>
                        <li><hr class="dropdown-divider"></li>
                        <li><a class="dropdown-item text-danger" href="CerrarSesionController"><i class="bi bi-power me-2"></i>Cerrar sesión</a></li>
                    </ul>
                </div>
                <% } %>
            </div>
        </div>
    </div>
</nav>

<!-- Google Translate Widget Fijo -->
<div id="google_translate_element" style="position: fixed; bottom: 20px; right: 20px; z-index: 1000;"></div>
<script type="text/javascript">
    function googleTranslateElementInit() {
        if (window.google && google.translate) {
            new google.translate.TranslateElement({
                pageLanguage: 'es', 
                includedLanguages: 'es,en',
                layout: google.translate.TranslateElement.InlineLayout.SIMPLE
            }, 'google_translate_element');
        }
    }
</script>
<script type="text/javascript" src="//translate.google.com/translate_a/element.js?cb=googleTranslateElementInit"></script>