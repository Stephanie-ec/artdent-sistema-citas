<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Error de Autenticación - Art Dent</title>
    <!-- Bootstrap 5.3 & Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Open+Sans:wght@400;600;700&family=Roboto:wght@500;700;900&display=swap" rel="stylesheet">
    <!-- Hoja de Estilos Oficial de Marca Art Dent -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">

    <style>
        .login-hero {
            background: linear-gradient(135deg, rgba(33, 37, 41, 0.90), rgba(48, 164, 198, 0.82)), 
                        url('https://www.clinicadentalsonriemaslima.com/wp-content/themes/Sonriemas/img/slider2.jpg');
            background-size: cover;
            background-position: center;
        }
    </style>
</head>

<body class="bg-brand-light m-0">
    <div class="container-fluid p-0">
        <div class="row g-0 min-vh-100">
            <!-- Columna Izquierda: Identidad Institucional -->
            <div class="col-lg-7 d-none d-lg-flex login-hero text-white align-items-center justify-content-center p-5">
                <div class="text-center" style="max-width: 500px;">
                    <img src="https://logomaker.designfreelogoonline.com/media/productdesigner/logo/resized/0001036_dental_logo_maker_dentist_Logo-02.png" 
                         alt="Logo Art Dent" style="width: 100px; filter: drop-shadow(0 4px 10px rgba(0,0,0,0.35));" class="mb-4">
                    <h1 class="display-5 fw-bold mb-2">Centro Odontológico Art <span class="text-brand-primary">Dent</span></h1>
                    <p class="lead mb-4 text-white-50">Plataforma Integral de Gestión Clínica, Citas y Auditoría Odontológica.</p>
                    <div class="d-flex justify-content-center gap-3">
                        <span class="badge bg-mint text-dark px-3 py-2">
                            <i class="bi bi-shield-lock-fill me-1"></i> Control de Seguridad
                        </span>
                        <span class="badge bg-brand-accent text-white px-3 py-2">
                            <i class="bi bi-clock-history me-1"></i> Bloqueo Anti-Fuerza Bruta
                        </span>
                    </div>
                </div>
            </div>

            <!-- Columna Derecha: Formulario y Alerta de Error -->
            <div class="col-lg-5 d-flex align-items-center justify-content-center p-4 p-md-5 bg-white">
                <div class="w-100" style="max-width: 420px;">
                    <div class="text-center mb-4">
                        <a href="index.jsp" title="Volver al Inicio">
                            <img src="https://logomaker.designfreelogoonline.com/media/productdesigner/logo/resized/0001036_dental_logo_maker_dentist_Logo-02.png" 
                                 alt="ArtDent" style="width: 70px;" class="mb-2">
                        </a>
                        <h3 class="fw-bold text-brand-dark mb-1">Acceso de Personal</h3>
                        <p class="text-muted small">Ingresa tus credenciales del personal institucional</p>
                    </div>

                    <!-- Alertas de Seguridad Dinámicas -->
                    <c:choose>
                        <c:when test="${bloqueado}">
                            <div class="alert alert-danger p-3 mb-4 shadow-sm border-0" role="alert" style="border-radius: 12px; background-color: #fee2e2; color: #991b1b;">
                                <div class="d-flex align-items-start">
                                    <i class="bi bi-shield-x fs-2 me-3 text-danger"></i>
                                    <div>
                                        <h6 class="fw-bold mb-1">Cuenta Bloqueada Temporalmente</h6>
                                        <p class="small mb-0 leading-tight">
                                            ${errorMensaje != null ? errorMensaje : 'Has superado los 5 intentos fallidos consecutivos. Por seguridad, la cuenta permanecerá bloqueada durante 15 minutos.'}
                                        </p>
                                    </div>
                                </div>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="alert alert-warning p-3 mb-4 shadow-sm border-0" role="alert" style="border-radius: 12px; background-color: #fef3c7; color: #92400e;">
                                <div class="d-flex align-items-start">
                                    <i class="bi bi-exclamation-triangle-fill fs-3 me-3 text-warning"></i>
                                    <div>
                                        <h6 class="fw-bold mb-1">Credenciales Incorrectas</h6>
                                        <p class="small mb-0 leading-tight">
                                            ${errorMensaje != null ? errorMensaje : 'El número de documento o la contraseña no coinciden con nuestros registros.'}
                                        </p>
                                    </div>
                                </div>
                            </div>
                        </c:otherwise>
                    </c:choose>

                    <form action="InicioSesionController" method="POST">
                        <div class="mb-3">
                            <label for="document" class="form-label fw-semibold small text-muted">Nro. de Documento (DNI)</label>
                            <div class="input-group">
                                <span class="input-group-text"><i class="bi bi-card-text"></i></span>
                                <input type="text" class="form-control" id="document" name="document" 
                                       placeholder="DNI (8 dígitos)" required maxlength="8" pattern="[0-9]{8}"
                                       value="${param.document}">
                            </div>
                        </div>

                        <div class="mb-3">
                            <label for="password" class="form-label fw-semibold small text-muted">Contraseña</label>
                            <div class="input-group">
                                <span class="input-group-text"><i class="bi bi-key-fill"></i></span>
                                <input type="password" class="form-control" id="password" name="password" 
                                       placeholder="••••••••" required>
                                <button class="btn btn-outline-secondary" type="button" onclick="togglePassword()" title="Mostrar u ocultar contraseña">
                                    <i class="bi bi-eye" id="toggleIcon"></i>
                                </button>
                            </div>
                        </div>

                        <div class="d-flex justify-content-between align-items-center mb-4">
                            <div class="form-check">
                                <input class="form-check-input" type="checkbox" id="rememberMe">
                                <label class="form-check-label small text-muted" for="rememberMe">Recordar credencial</label>
                            </div>
                            <a href="index.jsp" class="small text-decoration-none text-brand-primary fw-semibold">
                                <i class="bi bi-house-door me-1"></i> Volver al Inicio
                            </a>
                        </div>

                        <button type="submit" class="btn btn-primary w-100 py-3 fw-bold rounded-pill shadow-sm" ${bloqueado ? 'disabled' : ''}>
                            <i class="bi bi-box-arrow-in-right me-1"></i> INICIAR SESIÓN
                        </button>
                    </form>

                    <div class="text-center mt-4 pt-3 border-top">
                        <small class="text-muted">Centro Odontológico Art Dent &copy; <%= java.time.Year.now().getValue() %><br>Todos los derechos reservados.</small>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script>
        function togglePassword() {
            var passInput = document.getElementById("password");
            var icon = document.getElementById("toggleIcon");
            if (passInput.type === "password") {
                passInput.type = "text";
                icon.classList.remove("bi-eye");
                icon.classList.add("bi-eye-slash");
            } else {
                passInput.type = "password";
                icon.classList.remove("bi-eye-slash");
                icon.classList.add("bi-eye");
            }
        }
    </script>
</body>
</html>
