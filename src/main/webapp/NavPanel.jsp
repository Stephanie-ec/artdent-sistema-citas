<%@ page pageEncoding="UTF-8" %>
<!-- NavPanel Institucional Art Dent (Panel Clínico) -->
<%
    HttpSession sesionNav = request.getSession(false);
    Integer idUserNav = (sesionNav != null) ? (Integer) sesionNav.getAttribute("idUsuario") : null;
    String nombreNav = (sesionNav != null) ? (String) sesionNav.getAttribute("Nombre") : null;
    String tiporolNav = (sesionNav != null) ? (String) sesionNav.getAttribute("TipoRol") : null;
%>
<nav class="navbar navbar-expand-lg bg-white border-bottom shadow-sm px-4 py-2" style="border-bottom: 2px solid var(--artdent-primary) !important;">
    <div class="container-fluid d-flex justify-content-between align-items-center">
        <!-- Brand & Logotipo -->
        <a class="navbar-brand d-flex align-items-center gap-2" href="index.jsp">
            <img src="https://logomaker.designfreelogoonline.com/media/productdesigner/logo/resized/0001036_dental_logo_maker_dentist_Logo-02.png" 
                 alt="Art Dent Logo" width="46" height="46">
            <span class="d-none d-sm-inline fw-bold text-brand-dark fs-5">Art <span class="text-brand-primary">Dent</span></span>
        </a>

        <!-- Título Central de Panel -->
        <div class="text-center">
            <h5 class="m-0 fw-bold text-brand-dark">
                <span class="text-brand-primary">Panel de Control</span> Clínico
            </h5>
            <small class="text-muted d-none d-md-inline">Centro Odontológico Art Dent</small>
        </div>

        <!-- Perfil y Acciones de Usuario -->
        <div class="d-flex align-items-center gap-2">
            <% if (idUserNav == null) { %>
            <a href="iniciosesion.jsp" class="btn btn-primary rounded-pill px-4 shadow-sm">
                <i class="bi bi-box-arrow-in-right me-1"></i> Iniciar Sesión
            </a>
            <% } else { %>
            <div class="dropdown">
                <button class="btn btn-primary rounded-pill px-3 py-2 dropdown-toggle shadow-sm d-flex align-items-center gap-2" 
                        type="button" id="panelUserDropdown" data-bs-toggle="dropdown" aria-expanded="false">
                    <i class="bi bi-person-circle fs-5"></i>
                    <div class="text-start d-none d-md-block" style="line-height: 1.2;">
                        <span class="d-block fw-semibold small text-white"><%= (nombreNav != null ? nombreNav : "Usuario") %></span>
                        <span class="d-block text-white-50" style="font-size: 0.72rem;"><%= (tiporolNav != null ? tiporolNav : "Personal") %></span>
                    </div>
                </button>
                <ul class="dropdown-menu dropdown-menu-end shadow-sm border-0 mt-2" aria-labelledby="panelUserDropdown">
                    <li class="dropdown-header text-muted small">Rol Activo: <%= (tiporolNav != null ? tiporolNav : "Personal") %></li>
                    <li><a class="dropdown-item" href="index.jsp"><i class="bi bi-house-door me-2 text-brand-primary"></i>Página Principal</a></li>
                    <% if ("Administrador".equalsIgnoreCase(tiporolNav)) { %>
                        <li><a class="dropdown-item" href="DashboardController?action=dashboard"><i class="bi bi-speedometer2 me-2 text-brand-accent"></i>Panel Administrador</a></li>
                        <li><a class="dropdown-item" href="ReservaController?accion=listarReservasPorDia"><i class="bi bi-calendar-event me-2 text-brand-primary"></i>Panel de Citas</a></li>
                    <% } %>
                    <li><a class="dropdown-item" href="ReservaController?accion=formcita"><i class="bi bi-calendar-plus me-2 text-brand-primary"></i>Nueva Reserva</a></li>
                    <li><hr class="dropdown-divider"></li>
                    <li><a class="dropdown-item text-danger" href="CerrarSesionController"><i class="bi bi-power me-2"></i>Cerrar Sesión</a></li>
                </ul>
            </div>
            <% } %>
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
