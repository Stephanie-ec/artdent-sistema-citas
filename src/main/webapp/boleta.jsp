<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Boleta Electrónica ${comprobante.codigoBoletaCompleto} - Art Dent</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@400;500;700&family=Space+Mono:wght@400;700&family=Open+Sans:wght@400;600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        :root {
            --artdent-primary: #30a4c6;
            --artdent-white: #ffffff;
            --artdent-accent: #9fcc3a;
            --artdent-mint: #b4ddc2;
            --artdent-dark: #212529;
        }
        body {
            font-family: 'Open Sans', sans-serif;
            background-color: #f4f6f9;
            color: var(--artdent-dark);
        }
        .boleta-container {
            max-width: 820px;
            margin: 30px auto;
            background: var(--artdent-white);
            border-radius: 12px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.06);
            padding: 35px 40px;
            border: 1px solid #e2e8f0;
        }
        .header-box {
            border: 2px solid var(--artdent-primary);
            border-radius: 10px;
            padding: 15px;
            text-align: center;
            background: #f0f9fb;
        }
        .boleta-title {
            font-size: 1.05rem;
            font-weight: 700;
            color: var(--artdent-primary);
            letter-spacing: 0.8px;
        }
        .boleta-numero {
            font-family: 'Space Mono', monospace;
            font-size: 1.35rem;
            font-weight: 700;
            color: var(--artdent-dark);
        }
        .table-detalle th {
            background-color: #edf7fa;
            color: var(--artdent-dark);
            font-weight: 600;
            text-transform: uppercase;
            font-size: 0.8rem;
            letter-spacing: 0.5px;
            border-bottom: 2px solid var(--artdent-primary);
        }
        .badge-pago {
            background-color: var(--artdent-mint);
            color: var(--artdent-dark);
            font-weight: 600;
            padding: 6px 14px;
            border-radius: 20px;
        }
        .btn-artdent-primary {
            background-color: var(--artdent-primary);
            border-color: var(--artdent-primary);
            color: var(--artdent-white);
            font-weight: 600;
        }
        .btn-artdent-primary:hover {
            background-color: #268da9;
            border-color: #268da9;
            color: var(--artdent-white);
        }
        @media print {
            body { background: white !important; margin: 0; }
            .boleta-container { box-shadow: none !important; border: 1px solid #bbb !important; margin: 0 auto; padding: 20px; width: 100%; }
            .no-print { display: none !important; }
        }
    </style>
</head>
<body>

    <div class="container">
        <!-- Barra de Botones no imprimible -->
        <div class="no-print d-flex justify-content-between align-items-center max-w-820 mx-auto my-3" style="max-width: 820px;">
            <a href="javascript:history.back()" class="btn btn-outline-secondary">
                <i class="fa-solid fa-arrow-left me-1"></i> Regresar
            </a>
            <div class="d-flex gap-2">
                <button onclick="window.print()" class="btn btn-artdent-primary shadow-sm">
                    <i class="fa-solid fa-print me-1"></i> Imprimir Boleta
                </button>
                <a href="index.jsp" class="btn btn-outline-dark">
                    <i class="fa-solid fa-house me-1"></i> Inicio
                </a>
            </div>
        </div>

        <!-- Documento de Boleta de Venta Electrónica -->
        <div class="boleta-container">
            <!-- Encabezado de la Boleta con Identidad Real del Negocio -->
            <div class="row align-items-center mb-4">
                <div class="col-md-7">
                    <div class="d-flex align-items-center mb-2">
                        <img src="https://logomaker.designfreelogoonline.com/media/productdesigner/logo/resized/0001036_dental_logo_maker_dentist_Logo-02.png" 
                             alt="Logo ArtDent" style="width: 58px; height: 58px;" class="me-3">
                        <div>
                            <h4 class="fw-bold mb-0" style="color: var(--artdent-primary);">CENTRO ODONTOLÓGICO ART DENT</h4>
                            <small class="text-muted fw-semibold">ART DENT S.A.C.</small>
                        </div>
                    </div>
                    <p class="mb-1 text-muted small"><i class="fa-solid fa-location-dot me-1 text-primary"></i> <strong>Sede Chosica:</strong> Jr. Chiclayo 268, Chosica, Lima - Perú</p>
                    <p class="mb-1 text-muted small"><i class="fa-solid fa-location-dot me-1 text-primary"></i> <strong>Sede Chaclacayo:</strong> Las Palmeras 328, Chaclacayo 15472, Lima - Perú</p>
                    <p class="mb-1 text-muted small"><i class="fa-solid fa-phone me-1 text-primary"></i> <strong>Central:</strong> (01) 3613634 | <strong>Móvil / WhatsApp:</strong> +51 987 654 321</p>
                    <p class="mb-0 text-muted small"><i class="fa-solid fa-envelope me-1 text-primary"></i> contacto@artdent.pe | angelhuaringa@gmail.com</p>
                </div>
                <div class="col-md-5">
                    <div class="header-box">
                        <div class="fw-bold text-muted small">R.U.C. 20601234567</div>
                        <div class="boleta-title my-1">BOLETA DE VENTA ELECTRÓNICA</div>
                        <div class="boleta-numero">${comprobante.codigoBoletaCompleto}</div>
                        <small class="text-muted d-block mt-1">Conforme a normativa tributaria de comprobantes de pago</small>
                    </div>
                </div>
            </div>

            <hr class="my-3 text-muted">

            <!-- Datos del Paciente / Cliente y Operación -->
            <div class="row g-3 mb-4">
                <div class="col-sm-6">
                    <span class="text-muted small text-uppercase fw-bold d-block">Paciente / Cliente</span>
                    <span class="fw-bold fs-6 text-dark">${comprobante.nombreCliente}</span>
                </div>
                <div class="col-sm-6">
                    <span class="text-muted small text-uppercase fw-bold d-block">Documento de Identidad</span>
                    <span class="fw-bold fs-6 text-dark font-monospace">DNI: ${comprobante.dniCliente}</span>
                </div>
                <div class="col-sm-6">
                    <span class="text-muted small text-uppercase fw-bold d-block">Fecha y Hora de Emisión</span>
                    <span class="text-dark">${comprobante.fechaEmision}</span>
                </div>
                <div class="col-sm-6">
                    <span class="text-muted small text-uppercase fw-bold d-block">Medio de Pago</span>
                    <span class="badge-pago d-inline-block mt-1">
                        <i class="fa-solid fa-wallet me-1"></i> ${comprobante.metodoPago}
                    </span>
                </div>
            </div>

            <!-- Tabla de Detalle del Servicio Odontológico -->
            <div class="table-responsive mb-4">
                <table class="table table-bordered table-detalle align-middle">
                    <thead>
                        <tr class="text-center">
                            <th style="width: 10%;">Cant.</th>
                            <th style="width: 15%;">Unidad</th>
                            <th style="width: 45%;">Descripción del Servicio</th>
                            <th style="width: 15%;">P. Unit.</th>
                            <th style="width: 15%;">Total</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td class="text-center font-monospace">1</td>
                            <td class="text-center">ZZ (Servicio)</td>
                            <td>
                                <strong>${comprobante.tipoServicio}</strong>
                                <small class="text-muted d-block">Atención odontológica integral especializada en Centro Odontológico Art Dent</small>
                            </td>
                            <td class="text-end font-monospace">S/ <fmt:formatNumber value="${comprobante.monto}" minFractionDigits="2" maxFractionDigits="2"/></td>
                            <td class="text-end font-monospace fw-bold">S/ <fmt:formatNumber value="${comprobante.monto}" minFractionDigits="2" maxFractionDigits="2"/></td>
                        </tr>
                    </tbody>
                </table>
            </div>

            <!-- Totales -->
            <div class="row justify-content-end mb-4">
                <div class="col-md-6 col-lg-5">
                    <div class="card bg-light border-0">
                        <div class="card-body p-3">
                            <div class="d-flex justify-content-between mb-1 small">
                                <span class="text-muted">Operación Gravada:</span>
                                <span class="font-monospace">S/ <fmt:formatNumber value="${comprobante.monto / 1.18}" minFractionDigits="2" maxFractionDigits="2"/></span>
                            </div>
                            <div class="d-flex justify-content-between mb-2 small">
                                <span class="text-muted">I.G.V. (18%):</span>
                                <span class="font-monospace">S/ <fmt:formatNumber value="${comprobante.monto - (comprobante.monto / 1.18)}" minFractionDigits="2" maxFractionDigits="2"/></span>
                            </div>
                            <hr class="my-2">
                            <div class="d-flex justify-content-between align-items-center">
                                <span class="fw-bold fs-6">IMPORTE TOTAL:</span>
                                <span class="fw-bold fs-5 font-monospace" style="color: var(--artdent-primary);">S/ <fmt:formatNumber value="${comprobante.monto}" minFractionDigits="2" maxFractionDigits="2"/></span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Pie de Boleta Institucional -->
            <div class="p-3 bg-light rounded text-center small text-muted">
                <p class="mb-1"><strong>Representación impresa de la Boleta de Venta Electrónica</strong></p>
                <p class="mb-0">Comprobante emitido conforme a la normativa para servicios de salud dental. No se emiten facturas.</p>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
