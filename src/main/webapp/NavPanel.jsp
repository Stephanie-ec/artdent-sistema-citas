<%@ page pageEncoding="UTF-8" %>
<!-- NavPanel Institucional Art Dent (Panel Clínico) -->
<%
    HttpSession sesionNav = request.getSession(false);
    Integer idUserNav = (sesionNav != null) ? (Integer) sesionNav.getAttribute("idUsuario") : null;
    String nombreNav = (sesionNav != null) ? (String) sesionNav.getAttribute("Nombre") : null;
    String tiporolNav = (sesionNav != null) ? (String) sesionNav.getAttribute("TipoRol") : null;
%>
<!-- Paneles: sistema de botones unificado (observación del docente: botones muy coloridos).
     Acción principal = azul de la marca; acciones secundarias = contorno; eliminar/rechazar = rojo suave. -->
<style>
    .btn { font-weight: 500; box-shadow: none !important; }
    .btn.rounded-pill { border-radius: 8px !important; }
    .btn-primary, .btn-success, .btn-info, .btn-warning {
        background-color: var(--artdent-primary, #30a4c6) !important; border-color: var(--artdent-primary, #30a4c6) !important; color: #fff !important;
    }
    .btn-primary:hover, .btn-success:hover, .btn-info:hover, .btn-warning:hover {
        background-color: var(--artdent-primary-hover, #268da9) !important; border-color: var(--artdent-primary-hover, #268da9) !important;
    }
    .btn-outline-primary, .btn-outline-success, .btn-outline-info, .btn-outline-warning {
        color: var(--artdent-primary, #30a4c6) !important; border-color: #bfe3ee !important; background-color: #fff !important;
    }
    .btn-outline-primary:hover, .btn-outline-success:hover, .btn-outline-info:hover, .btn-outline-warning:hover {
        background-color: #eef8fb !important;
    }
    .btn-outline-secondary { color: #6c757d !important; border-color: #dee2e6 !important; background-color: #fff !important; }
    .btn-outline-secondary:hover { background-color: #f4f5f7 !important; }
    .btn-danger, .btn-outline-danger { color: #c0392b !important; border-color: #ebc0bb !important; background-color: #fff !important; }
    .btn-danger:hover, .btn-outline-danger:hover { background-color: #fdf1f0 !important; }
    .btn-secondary { background-color: #e9ecef !important; border-color: #e9ecef !important; color: #6c757d !important; }
</style>
<nav class="navbar navbar-expand-lg bg-white border-bottom shadow-sm px-4 py-2" style="border-bottom: 2px solid var(--artdent-primary) !important;">
    <div class="container-fluid d-flex justify-content-between align-items-center">
        <!-- Brand & Logotipo -->
        <a class="navbar-brand d-flex align-items-center gap-2" href="index.jsp">
            <img src="${pageContext.request.contextPath}/img/logo-artdent.png" 
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
                    <% if ("Administrador".equalsIgnoreCase(tiporolNav) || "Secretaria".equalsIgnoreCase(tiporolNav)) { %>
                        <li><a class="dropdown-item" href="CitaController?accion=formPresencial"><i class="bi bi-calendar-plus me-2 text-brand-primary"></i>Cita Presencial</a></li>
                    <% } %>
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

<script src="${pageContext.request.contextPath}/js/session-guard.js" defer></script>
