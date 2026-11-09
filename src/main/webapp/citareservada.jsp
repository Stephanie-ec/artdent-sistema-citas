<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<% if(session.getAttribute("reservaIdCita")==null){response.sendRedirect(request.getContextPath()+"/consultareserva.jsp");return;} %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Comprobante de Reserva - Art Dent</title>
    <!-- Bootstrap 5.3 & Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Open+Sans:wght@400;600;700&family=Roboto:wght@500;700;900&family=Space+Mono:wght@700&display=swap" rel="stylesheet">
    <!-- Hoja de Estilos Oficial de Marca Art Dent -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css?v=20261102b">

    <style>
        .voucher-card {
            border: 2px dashed var(--artdent-primary);
            border-radius: 16px;
            background: #ffffff;
            box-shadow: var(--artdent-shadow-md);
            overflow: hidden;
        }

        .voucher-header {
            background: linear-gradient(135deg, var(--artdent-primary), var(--artdent-primary-hover));
            color: #ffffff;
            border-bottom: 3px solid var(--artdent-accent);
        }

        .code-box {
            background-color: #f0fbfd;
            border: 2px solid var(--artdent-primary);
            border-radius: 12px;
        }

        @page { size: A4 portrait; margin: 0; }
        * { -webkit-print-color-adjust: exact; print-color-adjust: exact; }
        @media print {
            .no-print { display: none !important; }
            html, body { background: #fff !important; }
            body { padding: 12mm 14mm !important; }
            main, .container, .row, [class*="col-"] { margin: 0 !important; padding: 0 !important; max-width: 100% !important; width: 100% !important; flex: 0 0 100% !important; }
            .voucher-card { border: 1px solid #333 !important; box-shadow: none !important; zoom: 0.86; break-inside: avoid; page-break-inside: avoid; }
            *, *::before, *::after { min-height: 0 !important; }
            html, body, main { height: auto !important; }
            .modal, .modal-backdrop { display: none !important; }
        }
    </style>
</head>

<body class="bg-brand-light">
    <!-- Navbar Oficial (oculta al imprimir) -->
    <div class="no-print">
        <%@include file="header.jsp"%>
    </div>

    <main class="container my-5">
        <div class="row justify-content-center">
            <div class="col-12 col-lg-8 col-md-10">

                <div class="card voucher-card mb-4">
                    <!-- Cabecera de Confirmación -->
                    <div class="p-4 p-md-5 text-center voucher-header">
                        <div class="d-inline-flex p-3 rounded-circle bg-white text-brand-accent mb-3 shadow">
                            <i class="bi bi-check-circle-fill fs-1"></i>
                        </div>
                        <h2 class="fw-bold mb-1 text-white">¡Reserva Registrada con Éxito!</h2>
                        <p class="mb-0 text-white-50">Centro Odontológico Art Dent &bull; Sedes Chosica y Chaclacayo</p>
                    </div>

                    <div class="card-body p-4 p-md-5">
                        <!-- Código Único Institucional -->
                        <div class="text-center p-3 mb-4 code-box">
                            <span class="text-brand-dark small text-uppercase fw-bold d-block mb-1">
                                <i class="bi bi-ticket-perforated-fill text-brand-primary me-1"></i>Código Único de Reserva
                            </span>
                            <span class="badge bg-brand-primary text-white px-4 py-2 fs-2 fw-bold font-monospace shadow-sm" style="letter-spacing: 1px;">
                                <c:out value="${sessionScope.reservaCodigo}"/>
                            </span>
                            <small class="d-block text-muted mt-2">
                                Guarda este código: con él y tu DNI puedes ver tu reserva y descargar tu boleta en <strong>Mi reserva</strong>.
                            </small>
                        </div>

                        <!-- Estado y Canal -->
                        <div class="d-flex justify-content-between align-items-center pb-3 mb-4 border-bottom flex-wrap gap-2">
                            <div>
                                <span class="text-muted small text-uppercase fw-bold">Estado de Atención</span>
                                <div class="mt-1">
                                    <span class="badge bg-mint text-dark px-3 py-2 fs-6">
                                        <i class="bi bi-clock-history me-1"></i> ${not empty sessionScope.reservaEstado ? sessionScope.reservaEstado : 'En espera'}
                                    </span>
                                </div>
                            </div>
                            <div class="text-md-end">
                                <span class="text-muted small text-uppercase fw-bold">Canal de Registro</span>
                                <div class="mt-1">
                                    <span class="badge bg-brand-primary text-white px-3 py-2 fs-6">
                                        <i class="bi bi-globe me-1"></i> Reserva Web Paciente
                                    </span>
                                </div>
                            </div>
                        </div>

                        <!-- Datos Clínicos y del Paciente -->
                        <div class="row g-4 mb-4">
                            <!-- Datos del Paciente -->
                            <div class="col-12 col-md-6">
                                <h5 class="fw-bold text-brand-primary mb-3 d-flex align-items-center gap-2">
                                    <i class="bi bi-person-fill"></i> Datos del Paciente
                                </h5>
                                <ul class="list-unstyled mb-0 small">
                                    <li class="mb-2"><strong>Paciente:</strong> <span class="text-brand-dark"><c:out value="${sessionScope.reservaNombre}"/></span></li>
                                    <li class="mb-2"><strong>DNI:</strong> <span class="text-brand-dark font-monospace"><c:out value="${sessionScope.reservaDni}"/></span></li>
                                    <c:if test="${not empty sessionScope.reservaTelefono}">
                                        <li class="mb-2"><strong>Celular:</strong> <span class="text-brand-dark"><c:out value="${sessionScope.reservaTelefono}"/></span></li>
                                    </c:if>
                                    <c:if test="${not empty sessionScope.reservaCorreo}">
                                        <li class="mb-2"><strong>Correo:</strong> <span class="text-brand-dark"><c:out value="${sessionScope.reservaCorreo}"/></span></li>
                                    </c:if>
                                </ul>
                            </div>

                            <!-- Datos de la Cita -->
                            <div class="col-12 col-md-6">
                                <h5 class="fw-bold text-brand-primary mb-3 d-flex align-items-center gap-2">
                                    <i class="bi bi-calendar2-check-fill"></i> Cita Médica
                                </h5>
                                <ul class="list-unstyled mb-0 small">
                                    <li class="mb-2"><strong>Tratamiento:</strong> <span class="text-brand-dark fw-bold"><c:out value="${sessionScope.reservaServicio}"/></span></li>
                                    <li class="mb-2"><strong>Odontólogo:</strong> <span class="text-brand-dark"><c:out value="${sessionScope.reservaDoctor}"/></span></li>
                                    <li class="mb-2"><strong>Fecha:</strong> <span class="text-brand-dark"><c:out value="${sessionScope.reservaFecha}"/></span></li>
                                    <li class="mb-2"><strong>Hora:</strong> <span class="text-brand-dark"><c:out value="${sessionScope.reservaHora}"/></span></li>
                                </ul>
                            </div>
                        </div>

                        <!-- Costo y opciones de pago -->
                        <div class="p-3 bg-brand-light rounded-3 border mb-4 text-center">
                            <span class="text-muted small text-uppercase fw-bold d-block mb-1">Costo Referencial del Tratamiento</span>
                            <span class="fs-3 fw-bold text-brand-primary">S/ <c:out value="${sessionScope.reservaPrecio}"/></span>
                            <div class="mt-3 no-print">
                                <a class="btn btn-success" href="PagoManualController?cita=${sessionScope.reservaIdCita}">Enviar comprobante Yape / Plin</a>
                                <small class="text-muted d-block mt-2">
                                    <i class="bi bi-cash-coin text-brand-accent me-1"></i> También puedes abonar en ventanilla física al acudir a tu cita.
                                </small>
                            </div>
                        </div>

                        <!-- Indicaciones de Atención -->
                        <div class="alert alert-artdent-mint p-3 mb-0">
                            <h6 class="fw-bold mb-1 text-brand-dark">
                                <i class="bi bi-info-circle-fill text-brand-primary me-1"></i> Indicaciones para tu atención
                            </h6>
                            <p class="mb-1 small text-brand-dark">
                                Tu reserva se encuentra <strong>En espera</strong> de verificación. Al efectuarse el pago (Yape/Plin o en caja presencial), se emitirá tu respectiva <strong>Boleta Electrónica (Serie B001)</strong>.
                            </p>
                            <p class="mb-0 small text-muted">
                                Te sugerimos acudir con 10 minutos de anticipación a la sede elegida portando tu documento de identidad.
                            </p>
                        </div>
                    </div>

                    <!-- Pie de Tarjeta con Botones de Acción -->
                    <div class="card-footer bg-white border-top p-3 d-flex justify-content-between align-items-center flex-wrap gap-2 no-print">
                        <a href="ServicioController?action=formreservaa" class="btn btn-outline-secondary">
                            <i class="bi bi-plus-circle me-1"></i> Reservar otra cita
                        </a>
                        <div class="d-flex gap-2">
                            <button onclick="window.print()" class="btn btn-outline-primary">
                                <i class="bi bi-printer me-1"></i> Imprimir Voucher
                            </button>
                            <a href="index.jsp" class="btn btn-primary">
                                <i class="bi bi-house-door me-1"></i> Ir al Inicio
                            </a>
                        </div>
                    </div>
                </div>

            </div>
        </div>
    </main>

    <!-- Footer Oficial (oculto al imprimir) -->
    <div class="no-print">
        <%@include file="footer.jsp"%>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

</body>
</html>