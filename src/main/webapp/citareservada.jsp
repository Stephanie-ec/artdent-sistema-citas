<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
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
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">

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

        @media print {
            .no-print { display: none !important; }
            .voucher-card { border: 1px solid #333 !important; box-shadow: none !important; }
            body { background: #fff !important; }
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
                                ${not empty sessionScope.reservaCodigo ? sessionScope.reservaCodigo : (not empty param.codigo ? param.codigo : 'ART-RES-00007')}
                            </span>
                            <small class="d-block text-muted mt-2">
                                Guarda o captura este código para identificarte en la recepción del centro odontológico.
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
                                    <li class="mb-2"><strong>Paciente:</strong> <span class="text-brand-dark">${not empty sessionScope.reservaNombre ? sessionScope.reservaNombre : (not empty param.nombre ? param.nombre : 'Paciente Art Dent')}</span></li>
                                    <li class="mb-2"><strong>DNI:</strong> <span class="text-brand-dark font-monospace">${not empty sessionScope.reservaDni ? sessionScope.reservaDni : (not empty param.dni ? param.dni : '72345678')}</span></li>
                                    <c:if test="${not empty sessionScope.reservaTelefono || not empty param.telefono}">
                                        <li class="mb-2"><strong>Celular:</strong> <span class="text-brand-dark">${not empty sessionScope.reservaTelefono ? sessionScope.reservaTelefono : param.telefono}</span></li>
                                    </c:if>
                                    <c:if test="${not empty sessionScope.reservaCorreo || not empty param.correo}">
                                        <li class="mb-2"><strong>Correo:</strong> <span class="text-brand-dark">${not empty sessionScope.reservaCorreo ? sessionScope.reservaCorreo : param.correo}</span></li>
                                    </c:if>
                                </ul>
                            </div>

                            <!-- Datos de la Cita -->
                            <div class="col-12 col-md-6">
                                <h5 class="fw-bold text-brand-primary mb-3 d-flex align-items-center gap-2">
                                    <i class="bi bi-calendar2-check-fill"></i> Cita Médica
                                </h5>
                                <ul class="list-unstyled mb-0 small">
                                    <li class="mb-2"><strong>Tratamiento:</strong> <span class="text-brand-dark fw-bold">${not empty sessionScope.reservaServicio ? sessionScope.reservaServicio : (not empty param.servicio ? param.servicio : 'Consulta Odontológica')}</span></li>
                                    <li class="mb-2"><strong>Odontólogo:</strong> <span class="text-brand-dark">${not empty sessionScope.reservaDoctor ? sessionScope.reservaDoctor : (not empty param.doctor ? param.doctor : 'Dr. Asignado')}</span></li>
                                    <li class="mb-2"><strong>Fecha:</strong> <span class="text-brand-dark">${not empty sessionScope.reservaFecha ? sessionScope.reservaFecha : (not empty param.fecha ? param.fecha : '2026-10-22')}</span></li>
                                    <li class="mb-2"><strong>Hora:</strong> <span class="text-brand-dark">${not empty sessionScope.reservaHora ? sessionScope.reservaHora : (not empty param.hora ? param.hora : '15:00')}</span></li>
                                </ul>
                            </div>
                        </div>

                        <!-- Costo y Pasarela Digital -->
                        <div class="p-3 bg-brand-light rounded-3 border mb-4 text-center">
                            <span class="text-muted small text-uppercase fw-bold d-block mb-1">Costo Referencial del Tratamiento</span>
                            <span class="fs-3 fw-bold text-brand-primary">S/ ${not empty sessionScope.reservaPrecio ? sessionScope.reservaPrecio : (not empty param.precio ? param.precio : '100.00')}</span>
                            <div class="mt-3 no-print">
                                <button type="button" class="btn btn-success px-4 py-2 shadow-sm fw-semibold" data-bs-toggle="modal" data-bs-target="#modalPagarEnLinea">
                                    <i class="bi bi-credit-card-2-front-fill me-2"></i> Pagar en Línea Ahora
                                </button>
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
                                Tu reserva se encuentra <strong>En espera</strong> de verificación. Al efectuarse el pago (en línea o en caja presencial), se emitirá tu respectiva <strong>Boleta Electrónica (Serie B001)</strong>.
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

                <!-- Modal Pasarela de Pago Seguro -->
                <div class="modal fade no-print" id="modalPagarEnLinea" tabindex="-1" aria-labelledby="modalPagarEnLineaLabel" aria-hidden="true">
                    <div class="modal-dialog modal-dialog-centered">
                        <div class="modal-content border-0 shadow-lg" style="border-radius: 16px; overflow: hidden;">
                            <form action="PagoController" method="post">
                                <input type="hidden" name="action" value="pagarEnLinea" />
                                <input type="hidden" name="idCita" value="${not empty sessionScope.reservaIdCita ? sessionScope.reservaIdCita : (not empty param.idCita ? param.idCita : '0')}" />
                                <input type="hidden" name="monto" value="${not empty sessionScope.reservaPrecio ? sessionScope.reservaPrecio : (not empty param.precio ? param.precio : '100.00')}" />
                                <input type="hidden" name="codigoReserva" value="${not empty sessionScope.reservaCodigo ? sessionScope.reservaCodigo : param.codigo}" />

                                <div class="modal-header bg-brand-primary text-white border-0 py-3">
                                    <h5 class="modal-title fw-bold text-white d-flex align-items-center gap-2" id="modalPagarEnLineaLabel">
                                        <i class="bi bi-shield-lock-fill"></i> Pasarela de Pago Digital Art Dent
                                    </h5>
                                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Cerrar"></button>
                                </div>
                                <div class="modal-body p-4">
                                    <div class="p-3 bg-brand-light rounded-3 border d-flex justify-content-between align-items-center mb-3">
                                        <div>
                                            <small class="text-muted d-block">Monto a Facturar</small>
                                            <span class="fs-4 fw-bold text-brand-primary font-monospace">S/ ${not empty sessionScope.reservaPrecio ? sessionScope.reservaPrecio : (not empty param.precio ? param.precio : '100.00')}</span>
                                        </div>
                                        <span class="badge bg-mint text-dark px-3 py-2">
                                            <i class="bi bi-shield-check me-1"></i> Pago Seguro SSL
                                        </span>
                                    </div>

                                    <div class="mb-3">
                                        <label class="form-label small fw-bold text-muted">Nombre del Titular / Paciente</label>
                                        <input type="text" class="form-control" name="nombreCliente" 
                                               value="${not empty sessionScope.reservaNombre ? sessionScope.reservaNombre : (not empty param.nombre ? param.nombre : 'Paciente')}" required />
                                    </div>

                                    <div class="mb-3">
                                        <label class="form-label small fw-bold text-muted">DNI del Titular</label>
                                        <input type="text" class="form-control font-monospace" name="dniCliente" maxlength="8"
                                               value="${not empty sessionScope.reservaDni ? sessionScope.reservaDni : (not empty param.dni ? param.dni : '12345678')}" required />
                                    </div>

                                    <div class="mb-3">
                                        <label class="form-label small fw-bold text-muted">Número de Tarjeta</label>
                                        <div class="input-group">
                                            <span class="input-group-text"><i class="bi bi-credit-card"></i></span>
                                            <input type="text" class="form-control font-monospace" placeholder="4557 8901 2345 6789" value="4557 8901 2345 6789" required />
                                        </div>
                                    </div>

                                    <div class="row g-2 mb-3">
                                        <div class="col-6">
                                            <label class="form-label small fw-bold text-muted">Expiración</label>
                                            <input type="text" class="form-control font-monospace text-center" placeholder="MM/AA" value="12/28" required />
                                        </div>
                                        <div class="col-6">
                                            <label class="form-label small fw-bold text-muted">CVV</label>
                                            <input type="password" class="form-control font-monospace text-center" placeholder="123" maxlength="4" value="789" required />
                                        </div>
                                    </div>

                                    <div class="alert alert-artdent-mint py-2 px-3 small mb-0 text-center">
                                        Al procesar el pago se emitirá tu <strong>Boleta Electrónica Oficial (B001)</strong>.
                                    </div>
                                </div>
                                <div class="modal-footer bg-light p-3 border-0">
                                    <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Cancelar</button>
                                    <button type="submit" class="btn btn-success fw-bold px-4">
                                        <i class="bi bi-check-lg me-1"></i> Procesar Pago Seguro
                                    </button>
                                </div>
                            </form>
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