<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Política de privacidad - Art Dent</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Open+Sans:wght@400;600;700&family=Roboto:wght@500;700;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css?v=20261102b">
</head>
<body class="bg-light">
    <%@include file="header.jsp"%>

    <main class="container py-5" style="max-width: 900px;">
        <h1 class="fw-bold mb-2" style="color: var(--artdent-primary);">Política de privacidad</h1>
        <p class="text-muted mb-4">Tratamiento de datos personales conforme a la Ley N.º 29733, Ley de Protección de Datos Personales, y su reglamento.</p>

        <div class="alert alert-artdent-mint" role="note">
            <i class="bi bi-shield-check me-2"></i>
            El Centro Odontológico Art Dent solo usa sus datos para gestionar su atención dental, sus citas y sus comprobantes. No los vende ni los comparte con terceros ajenos al servicio.
        </div>

        <h2 class="h5 fw-bold mt-4">1. Responsable del tratamiento</h2>
        <p class="mb-1"><strong>Centro Odontológico Art Dent S.A.C.</strong> — R.U.C. 20601234567</p>
        <p class="mb-1">Sede Chosica: Jr. Chiclayo 268, Chosica, Lima — Perú.</p>
        <p class="mb-1">Sede Chaclacayo: Las Palmeras 328, Chaclacayo 15472, Lima — Perú.</p>
        <p>Correo para temas de privacidad: <a href="mailto:contacto@artdent.pe">contacto@artdent.pe</a></p>

        <h2 class="h5 fw-bold mt-4">2. Qué datos tratamos</h2>
        <ul>
            <li><strong>Identificación:</strong> nombres, apellidos y número de DNI.</li>
            <li><strong>Contacto:</strong> teléfono o celular y correo electrónico.</li>
            <li><strong>Datos de salud necesarios para la atención:</strong> motivo de consulta, diagnóstico, tratamiento y observaciones de la ficha clínica.</li>
            <li><strong>Datos de la cita y del pago:</strong> servicio, odontólogo, fecha, hora, importe y comprobante interno.</li>
        </ul>

        <h2 class="h5 fw-bold mt-4">3. Para qué los usamos</h2>
        <ul>
            <li>Registrar, confirmar, reprogramar o cancelar sus citas.</li>
            <li>Brindar la atención odontológica y mantener su historial clínico.</li>
            <li>Emitir el comprobante interno de pago y llevar el control de ingresos.</li>
            <li>Enviarle avisos sobre su cita al correo que usted registra.</li>
            <li>Verificar su identidad ante RENIEC cuando la validación esté habilitada, para evitar suplantaciones.</li>
            <li>Proteger la seguridad del sistema (por ejemplo, bloqueo de cuentas tras intentos fallidos) y elaborar estadísticas internas sin identificar a personas.</li>
        </ul>

        <h2 class="h5 fw-bold mt-4">4. Base legal</h2>
        <p>Tratamos sus datos con su <strong>consentimiento previo, expreso e informado</strong>, que usted otorga al marcar la casilla de la Política de privacidad en la reserva web o en el registro presencial, y con las obligaciones legales aplicables a la atención en salud y a los comprobantes de pago.</p>

        <h2 class="h5 fw-bold mt-4">5. Plazo de conservación</h2>
        <p>Conservamos sus datos mientras exista la relación con la clínica y hasta <strong>cinco (5) años</strong> después de su última atención, plazo necesario para atender requerimientos legales y clínicos. Cumplido el plazo, los datos se eliminan o se anonimizan, salvo que una norma exija conservarlos por más tiempo.</p>

        <h2 class="h5 fw-bold mt-4">6. Con quién se comparten</h2>
        <p>No vendemos ni cedemos sus datos. Solo acceden a ellos el personal autorizado de la clínica según su rol (administrador, secretaría u odontólogo) y los proveedores estrictamente necesarios para el servicio, como el envío de correos o la consulta de identidad en RENIEC, que actúan por encargo y con deber de confidencialidad. También podrían entregarse a una autoridad cuando exista una obligación legal.</p>

        <h2 class="h5 fw-bold mt-4">7. Sus derechos ARCO</h2>
        <p>Usted puede ejercer sus derechos de <strong>Acceso, Rectificación, Cancelación y Oposición</strong>, así como revocar su consentimiento, escribiendo a <a href="mailto:contacto@artdent.pe">contacto@artdent.pe</a> con su nombre completo, número de DNI y el pedido concreto. Responderemos en el plazo que establece la normativa. Si considera que no atendimos su solicitud, puede acudir a la Autoridad Nacional de Protección de Datos Personales.</p>

        <h2 class="h5 fw-bold mt-4">8. Seguridad</h2>
        <p>El acceso al sistema está restringido por roles, las contraseñas del personal se almacenan cifradas y los eventos relevantes de seguridad quedan registrados. Los comprobantes de pago y las fichas clínicas se guardan en ubicaciones privadas, sin acceso público.</p>

        <h2 class="h5 fw-bold mt-4">9. Aceptación</h2>
        <p>Al marcar la casilla de consentimiento, el sistema guarda la fecha y la hora de su aceptación junto con sus datos de paciente. Sin esa aceptación no es posible registrar una reserva ni una cita presencial.</p>

        <h2 class="h5 fw-bold mt-4">10. Cambios en esta política</h2>
        <p>Si modificamos esta política, publicaremos la nueva versión en esta misma página. Última actualización: noviembre de 2026.</p>

        <a href="javascript:history.back()" class="btn btn-outline-primary mt-4"><i class="bi bi-arrow-left me-1"></i>Volver</a>
    </main>

    <%@include file="footer.jsp"%>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
