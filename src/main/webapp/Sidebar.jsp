<%@ page pageEncoding="UTF-8" %>
<!-- Sidebar Institucional Art Dent (Recepción y Odontología) -->
<%
    HttpSession ss = request.getSession(false);
    String userRol = (ss != null && ss.getAttribute("TipoRol") != null) ? ss.getAttribute("TipoRol").toString() : "";
    String activePage = request.getParameter("accion") != null ? request.getParameter("accion") : "";
    String activeAction = request.getParameter("action") != null ? request.getParameter("action") : "";
%>
<aside class="d-flex flex-column flex-shrink-0 p-3 text-white bg-brand-dark" style="width: 260px; min-height: 100vh; border-right: 1px solid rgba(255,255,255,0.08);">
    <!-- Encabezado de Navegación Lateral -->
    <div class="d-flex align-items-center mb-3 mb-md-0 me-md-auto text-white text-decoration-none px-2 py-3 border-bottom w-100" style="border-color: rgba(255,255,255,0.12) !important;">
        <i class="bi bi-hospital fs-4 text-brand-primary me-2"></i>
        <span class="fs-5 fw-bold text-white">Módulos <span class="text-brand-primary">PDC</span></span>
    </div>

    <!-- Menú Principal -->
    <ul class="nav nav-pills flex-column mb-auto mt-3 gap-1">
        <li class="nav-item">
            <a class="nav-link text-white d-flex align-items-center <%= "listar".equals(activePage) ? "active bg-brand-primary" : "" %>" 
               href="ReservaController?accion=listar">
                <i class="bi bi-inbox me-2 text-brand-primary"></i>
                <span>Solicitudes Web</span>
            </a>
        </li>
        <li class="nav-item">
            <a class="nav-link text-white d-flex align-items-center <%= "listarReservasPorDia".equals(activePage) ? "active bg-brand-primary" : "" %>" 
               href="ReservaController?accion=listarReservasPorDia">
                <i class="bi bi-calendar-week me-2 text-brand-primary"></i>
                <span>Calendario Citas</span>
            </a>
        </li>
        <li class="nav-item">
            <a class="nav-link text-white d-flex align-items-center <%= "ListarHistorialReservas".equals(activePage) ? "active bg-brand-primary" : "" %>" 
               href="HistorialController?accion=ListarHistorialReservas">
                <i class="bi bi-clock-history me-2 text-brand-primary"></i>
                <span>Historial Clínico</span>
            </a>
        </li>
        <li class="nav-item">
            <a class="nav-link text-white d-flex align-items-center <%= "listarReservas".equals(activePage) ? "active bg-brand-primary" : "" %>" 
               href="NotificacionesController?accion=listarReservas">
                <i class="bi bi-bell me-2 text-brand-primary"></i>
                <span>Notificaciones</span>
            </a>
        </li>
        <li class="nav-item">
            <a class="nav-link text-white d-flex align-items-center <%= "list".equals(activeAction) ? "active bg-brand-primary" : "" %>" 
               href="PacienteController?action=list">
                <i class="bi bi-people me-2 text-brand-accent"></i>
                <span>Pacientes</span>
            </a>
        </li>

        <% if (userRol.equalsIgnoreCase("Secretaria") || userRol.equalsIgnoreCase("Administrador")) { %>
        <li class="nav-item">
            <a class="nav-link text-white d-flex align-items-center <%= "formPresencial".equals(activePage) ? "active bg-brand-accent" : "" %>" 
               href="CitaController?accion=formPresencial">
                <i class="bi bi-calendar-plus me-2 text-brand-accent"></i>
                <span>Cita Presencial</span>
            </a>
        </li>
        <% } %>

        <li class="nav-item">
            <% if (userRol.equalsIgnoreCase("Administrador")) { %>
            <a class="nav-link text-white d-flex align-items-center <%= "reportead".equals(activePage) ? "active bg-brand-primary" : "" %>" 
               href="ReporteController?accion=reportead">
                <i class="bi bi-bar-chart-line me-2 text-brand-mint"></i>
                <span>Reportes</span>
            </a>
            <% } else if (userRol.equalsIgnoreCase("Secretaria")) { %>
            <a class="nav-link text-white d-flex align-items-center <%= "reporte".equals(activePage) ? "active bg-brand-primary" : "" %>" 
               href="ReporteController?accion=reporte">
                <i class="bi bi-bar-chart-line me-2 text-brand-mint"></i>
                <span>Reportes</span>
            </a>
            <% } %>
        </li>
    </ul>

    <!-- Pie del Sidebar: Salir -->
    <div class="pt-3 border-top mt-auto" style="border-color: rgba(255,255,255,0.12) !important;">
        <a class="btn btn-outline-danger w-100 d-flex align-items-center justify-content-center gap-2 py-2" 
           href="CerrarSesionController">
            <i class="bi bi-box-arrow-left"></i>
            <span>Cerrar Sesión</span>
        </a>
    </div>
</aside>
