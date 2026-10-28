<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Reportes y Estadísticas | Centro Odontológico ArtDent</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet">
        <link rel="stylesheet" href="css/style.css">
    </head>
    <body class="d-flex flex-column min-vh-100 bg-light">
        <%
            HttpSession misesion = request.getSession();
            String usuario = (String) request.getSession().getAttribute("Nombre");
            if (usuario == null) {
                response.sendRedirect("iniciosesionerror.jsp");
                return;
            }
        %>

        <%@include file="NavPanel.jsp" %>

        <!-- Contenido de la Página -->
        <div class="d-flex flex-grow-1">
            <!-- Sidebar -->
            <%@include file="Sidebar.jsp" %>

            <!-- Contenido Principal -->
            <main class="container-fluid p-4 d-flex flex-column flex-grow-1">
                <div class="mb-4 pb-2 border-bottom">
                    <h3 class="fw-bold mb-1" style="color: var(--artdent-primary);">
                        <i class="bi bi-bar-chart-line-fill me-2" style="color: var(--artdent-accent);"></i>Reportes y Estadísticas
                    </h3>
                    <p class="text-muted small mb-0">Métricas analíticas de rendimiento clínico, volumen de pacientes e ingresos consolidados.</p>
                </div>

                <!-- KPI Summary Cards -->
                <div class="row g-3 mb-4">
                    <div class="col-sm-6 col-xl-3">
                        <div class="card border-0 shadow-sm rounded-4 text-white p-3 h-100" style="background: linear-gradient(135deg, #30a4c6 0%, #268da9 100%);">
                            <div class="d-flex justify-content-between align-items-center">
                                <div>
                                    <div class="text-white-50 small text-uppercase fw-bold">Total Ingresos</div>
                                    <h3 class="mb-0 fw-bold mt-1">S/ ${kpiIngresos != null ? kpiIngresos : '0.00'}</h3>
                                </div>
                                <div class="p-3 rounded-circle bg-white bg-opacity-25 fs-3 d-flex align-items-center justify-content-center" style="width: 54px; height: 54px;">
                                    <i class="bi bi-cash-coin"></i>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="col-sm-6 col-xl-3">
                        <div class="card border-0 shadow-sm rounded-4 text-white p-3 h-100" style="background: linear-gradient(135deg, #9fcc3a 0%, #8bb532 100%);">
                            <div class="d-flex justify-content-between align-items-center">
                                <div>
                                    <div class="text-white-50 small text-uppercase fw-bold">Citas Completadas</div>
                                    <h3 class="mb-0 fw-bold mt-1">${kpiCompletadas != null ? kpiCompletadas : 0}</h3>
                                </div>
                                <div class="p-3 rounded-circle bg-white bg-opacity-25 fs-3 d-flex align-items-center justify-content-center" style="width: 54px; height: 54px;">
                                    <i class="bi bi-check-circle-fill"></i>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="col-sm-6 col-xl-3">
                        <div class="card border-0 shadow-sm rounded-4 text-white p-3 h-100" style="background: linear-gradient(135deg, #212529 0%, #343a40 100%);">
                            <div class="d-flex justify-content-between align-items-center">
                                <div>
                                    <div class="text-white-50 small text-uppercase fw-bold">Total Gestionadas</div>
                                    <h3 class="mb-0 fw-bold mt-1">${kpiTotal != null ? kpiTotal : 0}</h3>
                                </div>
                                <div class="p-3 rounded-circle bg-white bg-opacity-25 fs-3 d-flex align-items-center justify-content-center" style="width: 54px; height: 54px;">
                                    <i class="bi bi-calendar-event-fill"></i>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="col-sm-6 col-xl-3">
                        <div class="card border-0 shadow-sm rounded-4 text-white p-3 h-100" style="background: linear-gradient(135deg, #e05d5d 0%, #c93b3b 100%);">
                            <div class="d-flex justify-content-between align-items-center">
                                <div>
                                    <div class="text-white-50 small text-uppercase fw-bold">Canceladas</div>
                                    <h3 class="mb-0 fw-bold mt-1">${kpiCanceladas != null ? kpiCanceladas : 0}</h3>
                                </div>
                                <div class="p-3 rounded-circle bg-white bg-opacity-25 fs-3 d-flex align-items-center justify-content-center" style="width: 54px; height: 54px;">
                                    <i class="bi bi-x-circle-fill"></i>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Botón para mostrar u ocultar la tabla -->
                <div class="mb-3">
                    <button id="toggleButton" class="btn btn-outline-primary rounded-pill px-4 shadow-sm">
                        <i class="bi bi-table me-2"></i>Mostrar / Ocultar Matriz Mensual Detallada
                    </button>
                </div>

                <!-- Div que contiene la tabla -->
                <div id="tablaDiv" class="card border-0 shadow-sm rounded-4 overflow-hidden mb-4" style="display: none;">
                    <div class="card-header bg-white py-3 border-bottom">
                        <span class="fw-bold text-dark"><i class="bi bi-calendar3 me-2" style="color: var(--artdent-primary);"></i>Desglose Numérico por Periodo Mensual</span>
                    </div>
                    <div class="table-responsive">
                        <table class="table table-hover align-middle mb-0 text-center">
                            <thead style="background-color: #edf7fa; color: var(--artdent-dark);">
                                <tr>
                                    <th class="py-3">Mes</th>
                                    <th>Res. Completadas</th>
                                    <th>Res. En Espera</th>
                                    <th>Res. Reprogramadas</th>
                                    <th>Res. Confirmadas</th>
                                    <th>Res. Canceladas</th>
                                    <th class="fw-bold">Total Reservas</th>
                                    <th>Citas Completadas</th>                                 
                                    <th>Citas En Espera</th>
                                    <th>Citas Reprogramadas</th>
                                    <th>Citas Confirmadas</th>
                                    <th>Citas Canceladas</th>
                                    <th class="fw-bold">Total Citas</th>
                                    <th class="text-end pe-4">Ingresos (S/)</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="reporte" items="${reporteMensual}"> 
                                    <tr>
                                        <td class="fw-bold text-dark">${reporte.mes}</td>
                                        <td>${reporte.reservasCompletadas}</td>
                                        <td>${reporte.reservasEnEspera}</td>
                                        <td>${reporte.reservasReprogramadas}</td>
                                        <td>${reporte.reservasConfirmadas}</td>
                                        <td>${reporte.reservasCanceladas}</td>
                                        <td class="fw-bold text-primary">${reporte.totalReservas}</td>
                                        <td>${reporte.citasCompletadas}</td>
                                        <td>${reporte.citasEnEspera}</td>
                                        <td>${reporte.citasReprogramadas}</td>
                                        <td>${reporte.citasConfirmadas}</td>
                                        <td>${reporte.citasCanceladas}</td>
                                        <td class="fw-bold text-primary">${reporte.totalCitas}</td>
                                        <td class="text-end pe-4 fw-bold" style="color: #278829;">S/ ${reporte.totalIngresos}</td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </div>

                <!-- Gráficos Principales -->
                <div class="row g-4 mb-4">
                    <!-- Gráfico de Barras -->
                    <div class="col-lg-6">
                        <div class="card border-0 shadow-sm rounded-4 p-4 h-100">
                            <h6 class="fw-bold mb-3 text-dark d-flex align-items-center">
                                <i class="bi bi-bar-chart-fill me-2" style="color: var(--artdent-primary);"></i>Volumen de Reservas Web vs Citas Presenciales
                            </h6>
                            <div class="flex-grow-1" style="min-height: 280px;">
                                <canvas id="barChart"></canvas>
                            </div>
                        </div>
                    </div>
                    <!-- Gráfico Lineal -->
                    <div class="col-lg-6">
                        <div class="card border-0 shadow-sm rounded-4 p-4 h-100">
                            <h6 class="fw-bold mb-3 text-dark d-flex align-items-center">
                                <i class="bi bi-graph-up me-2" style="color: var(--artdent-accent);"></i>Curva Comparativa Temporal
                            </h6>
                            <div class="flex-grow-1" style="min-height: 280px;">
                                <canvas id="lineChart"></canvas>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="row g-4 mb-4">
                    <!-- Gráfico Circular -->
                    <div class="col-lg-4">
                        <div class="card border-0 shadow-sm rounded-4 p-4 h-100">
                            <h6 class="fw-bold mb-3 text-dark d-flex align-items-center">
                                <i class="bi bi-pie-chart-fill me-2" style="color: var(--artdent-primary);"></i>Efectividad de Atención
                            </h6>
                            <div class="flex-grow-1" style="min-height: 240px;">
                                <canvas id="pieChart"></canvas>
                            </div>
                        </div>
                    </div>
                    <!-- Gráfico de Línea para Citas -->
                    <div class="col-lg-4">
                        <div class="card border-0 shadow-sm rounded-4 p-4 h-100">
                            <h6 class="fw-bold mb-3 text-dark d-flex align-items-center">
                                <i class="bi bi-activity me-2" style="color: var(--artdent-accent);"></i>Tendencia Completadas vs Canceladas
                            </h6>
                            <div class="flex-grow-1" style="min-height: 240px;">
                                <canvas id="trendLineChart"></canvas>
                            </div>
                        </div>
                    </div>
                    <!-- Gráfico de Ingresos -->
                    <div class="col-lg-4">
                        <div class="card border-0 shadow-sm rounded-4 p-4 h-100">
                            <h6 class="fw-bold mb-3 text-dark d-flex align-items-center">
                                <i class="bi bi-currency-dollar me-2" style="color: #28a745;"></i>Evolución de Ingresos (S/)
                            </h6>
                            <div class="flex-grow-1" style="min-height: 240px;">
                                <canvas id="ingresosChart"></canvas>
                            </div>
                        </div>
                    </div>
                </div>

            </main>
        </div>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
        <script>
            // Datos dinámicos desde el servidor
            const meses = [];
            const totalReservas = [];
            const totalCitas = [];
            const totalIngresos = [];
            const citasCompletadas = [];
            const citasNoAtendidas = [];
            const citasCanceladas = [];

            <c:forEach var="reporte" items="${reporteMensual}">
            meses.push("${reporte.mes}");
            totalReservas.push(${reporte.totalReservas});
            totalCitas.push(${reporte.totalCitas});
            totalIngresos.push(${reporte.totalIngresos});
            citasCompletadas.push(${reporte.citasCompletadas + reporte.reservasCompletadas});
            citasCanceladas.push(${reporte.citasCanceladas + reporte.reservasCanceladas});
            citasNoAtendidas.push(${reporte.totalCitas + reporte.totalReservas - (reporte.citasCompletadas + reporte.reservasCompletadas)});
            </c:forEach>

            // Gráfico de Barras con colores de ArtDent
            const elBar = document.getElementById('barChart');
            if (elBar) {
                new Chart(elBar.getContext('2d'), {
                    type: 'bar',
                    data: {
                        labels: meses,
                        datasets: [{
                            label: 'Reservas Web',
                            data: totalReservas,
                            backgroundColor: 'rgba(48, 164, 198, 0.75)',
                            borderColor: '#30a4c6',
                            borderWidth: 1.5,
                            borderRadius: 6
                        }, {
                            label: 'Citas Presenciales',
                            data: totalCitas,
                            backgroundColor: 'rgba(159, 204, 58, 0.75)',
                            borderColor: '#9fcc3a',
                            borderWidth: 1.5,
                            borderRadius: 6
                        }]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        scales: { y: { beginAtZero: true } }
                    }
                });
            }

            // Gráfico Lineal con colores de ArtDent
            const elLine = document.getElementById('lineChart');
            if (elLine) {
                new Chart(elLine.getContext('2d'), {
                    type: 'line',
                    data: {
                        labels: meses,
                        datasets: [{
                            label: 'Reservas Web',
                            data: totalReservas,
                            borderColor: '#30a4c6',
                            backgroundColor: 'rgba(48, 164, 198, 0.15)',
                            tension: 0.3,
                            fill: true
                        }, {
                            label: 'Citas Presenciales',
                            data: totalCitas,
                            borderColor: '#9fcc3a',
                            backgroundColor: 'rgba(159, 204, 58, 0.15)',
                            tension: 0.3,
                            fill: true
                        }]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        scales: { y: { beginAtZero: true } }
                    }
                });
            }

            // Gráfico Circular (Pie Chart) con paleta ArtDent
            const elPie = document.getElementById('pieChart');
            if (elPie) {
                const totalComp = citasCompletadas.reduce((a, b) => a + b, 0);
                const totalNoAt = citasNoAtendidas.reduce((a, b) => a + b, 0);
                new Chart(elPie.getContext('2d'), {
                    type: 'doughnut',
                    data: {
                        labels: ['Completadas', 'Pendientes / Otras'],
                        datasets: [{
                            data: [totalComp, totalNoAt],
                            backgroundColor: ['#9fcc3a', '#b4ddc2'],
                            borderColor: ['#ffffff', '#ffffff'],
                            borderWidth: 2
                        }]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        plugins: { legend: { position: 'bottom' } }
                    }
                });
            }

            // Gráfico de Línea para Tendencias
            const elTrend = document.getElementById('trendLineChart');
            if (elTrend) {
                new Chart(elTrend.getContext('2d'), {
                    type: 'line',
                    data: {
                        labels: meses,
                        datasets: [{
                            label: 'Completadas',
                            data: citasCompletadas,
                            borderColor: '#9fcc3a',
                            backgroundColor: '#9fcc3a',
                            tension: 0.2
                        }, {
                            label: 'Canceladas',
                            data: citasCanceladas,
                            borderColor: '#e05d5d',
                            backgroundColor: '#e05d5d',
                            tension: 0.2
                        }]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        scales: { y: { beginAtZero: true } }
                    }
                });
            }

            // Gráfico de Ingresos
            const elIngresos = document.getElementById('ingresosChart');
            if (elIngresos) {
                new Chart(elIngresos.getContext('2d'), {
                    type: 'bar',
                    data: {
                        labels: meses,
                        datasets: [{
                            label: 'Ingresos (S/)',
                            data: totalIngresos,
                            backgroundColor: 'rgba(48, 164, 198, 0.75)',
                            borderColor: '#30a4c6',
                            borderWidth: 1.5,
                            borderRadius: 6
                        }]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        scales: { y: { beginAtZero: true } }
                    }
                });
            }

            // Toggle para tabla
            const toggleButton = document.getElementById("toggleButton");
            const tablaDiv = document.getElementById("tablaDiv");
            if (toggleButton && tablaDiv) {
                toggleButton.addEventListener("click", function () {
                    if (tablaDiv.style.display === "none") {
                        tablaDiv.style.display = "block";
                    } else {
                        tablaDiv.style.display = "none";
                    }
                });
            }
        </script>
    </body>
</html>