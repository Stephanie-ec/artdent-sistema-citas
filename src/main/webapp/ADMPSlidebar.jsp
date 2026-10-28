<%@ page pageEncoding="UTF-8" %>
<!-- Sidebar de Administrador Art Dent -->
<%
    String currentAction = request.getParameter("action") != null ? request.getParameter("action") : "";
    String currentAccion = request.getParameter("accion") != null ? request.getParameter("accion") : "";
%>
<nav class="col-md-3 col-lg-2 d-md-block sidebar collapse bg-brand-dark p-0" style="min-height: 100vh; border-right: 1px solid rgba(255,255,255,0.08);">
    <div class="position-sticky pt-2">
        <!-- Logo e Identidad Admin -->
        <div class="d-flex align-items-center gap-2 px-3 py-3 border-bottom" style="border-color: rgba(255,255,255,0.1) !important;">
            <img src="https://logomaker.designfreelogoonline.com/media/productdesigner/logo/resized/0001036_dental_logo_maker_dentist_Logo-02.png" 
                 alt="Art Dent" width="34" height="34">
            <span class="fs-6 fw-bold text-white">Admin <span class="text-brand-primary">ArtDent</span></span>
        </div>

        <div class="sidebar-heading px-3 pt-3 pb-1 text-uppercase text-brand-mint small fw-bold" style="letter-spacing: 0.5px;">
            Gestión Central
        </div>

        <ul class="nav flex-column px-2 gap-1">
            <li class="nav-item">
                <a class="nav-link text-white rounded d-flex align-items-center <%= "dashboard".equals(currentAction) ? "active bg-brand-primary" : "" %>" 
                   href="DashboardController?action=dashboard">
                    <i class="bi bi-speedometer2 me-2 text-brand-primary"></i>
                    <span>Dashboard</span>
                </a>
            </li>
            <li class="nav-item">
                <a class="nav-link text-white rounded d-flex align-items-center <%= "list".equals(currentAction) && request.getRequestURI().contains("Usuario") ? "active bg-brand-primary" : "" %>" 
                   href="UsuarioController?action=list">
                    <i class="bi bi-people me-2 text-brand-primary"></i>
                    <span>Usuarios</span>
                </a>
            </li>
            <li class="nav-item">
                <a class="nav-link text-white rounded d-flex align-items-center <%= "list".equals(currentAction) && request.getRequestURI().contains("Servicio") ? "active bg-brand-primary" : "" %>" 
                   href="ServicioController?action=list">
                    <i class="bi bi-calendar-check me-2 text-brand-accent"></i>
                    <span>Servicios</span>
                </a>
            </li>
            <li class="nav-item">
                <a class="nav-link text-white rounded d-flex align-items-center <%= "disponibilidad".equals(currentAction) ? "active bg-brand-primary" : "" %>" 
                   href="UsuarioController?action=disponibilidad">
                    <i class="bi bi-clock-history me-2 text-brand-mint"></i>
                    <span>Disponibilidad</span>
                </a>
            </li>
            <li class="nav-item">
                <a class="nav-link text-white rounded d-flex align-items-center <%= "reportead".equals(currentAccion) ? "active bg-brand-primary" : "" %>" 
                   href="ReporteController?accion=reportead">
                    <i class="bi bi-bar-chart-line me-2 text-brand-primary"></i>
                    <span>Reportes</span>
                </a>
            </li>
        </ul>

        <div class="sidebar-heading px-3 pt-4 pb-1 text-uppercase text-muted small fw-bold" style="letter-spacing: 0.5px;">
            Accesos Rápidos
        </div>
        <ul class="nav flex-column px-2 gap-1 mb-4">
            <li class="nav-item">
                <a class="nav-link text-white-50 rounded d-flex align-items-center" href="ReservaController?accion=listarReservasPorDia">
                    <i class="bi bi-calendar-event me-2 text-brand-primary"></i>
                    <span>Panel de Citas</span>
                </a>
            </li>
            <li class="nav-item">
                <a class="nav-link text-white-50 rounded d-flex align-items-center" href="index.jsp">
                    <i class="bi bi-box-arrow-up-right me-2 text-brand-mint"></i>
                    <span>Portal Público</span>
                </a>
            </li>
            <li class="nav-item mt-3 pt-3 border-top" style="border-color: rgba(255,255,255,0.1) !important;">
                <a class="btn btn-outline-danger btn-sm w-100 d-flex align-items-center justify-content-center gap-2" href="CerrarSesionController">
                    <i class="bi bi-power"></i>
                    <span>Cerrar Sesión</span>
                </a>
            </li>
        </ul>
    </div>
</nav>
