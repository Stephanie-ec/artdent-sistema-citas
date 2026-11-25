<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Cambiar contraseña | Art Dent</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    <link rel="stylesheet" href="css/style.css?v=20261102b">
</head>
<body class="bg-light d-flex align-items-center" style="min-height: 100vh;">
    <main class="container" style="max-width: 560px;">
        <div class="card border-0 shadow rounded-4 overflow-hidden">
            <div class="card-header text-white py-3" style="background: linear-gradient(135deg, var(--artdent-primary), #268da9);">
                <h1 class="h5 fw-bold mb-0"><i class="bi bi-key-fill me-2"></i>Cambiar contraseña</h1>
            </div>
            <div class="card-body p-4">
                <c:if test="${param.forzado == '1' or sessionScope.DebeCambiarClave}">
                    <div class="alert alert-warning" role="alert">
                        <i class="bi bi-exclamation-triangle-fill me-2"></i>
                        Su cuenta usa una contraseña temporal. Debe cambiarla para continuar.
                    </div>
                </c:if>
                <c:if test="${not empty error}">
                    <div class="alert alert-danger" role="alert">
                        <i class="bi bi-x-circle-fill me-2"></i><c:out value="${error}"/>
                    </div>
                </c:if>
                <p class="text-muted small">
                    Hola <strong><c:out value="${sessionScope.Nombre} ${sessionScope.Apellido}"/></strong>.
                    La nueva contraseña debe tener entre 6 y 30 caracteres.
                </p>
                <form action="CambiarClaveController" method="post" autocomplete="off">
                    <input type="hidden" name="formToken" value="${formToken}">
                    <div class="mb-3">
                        <label for="actual" class="form-label fw-semibold">Contraseña actual <span class="text-danger">*</span></label>
                        <input type="password" class="form-control" id="actual" name="actual" maxlength="30" required autofocus>
                    </div>
                    <div class="mb-3">
                        <label for="nueva" class="form-label fw-semibold">Nueva contraseña <span class="text-danger">*</span></label>
                        <input type="password" class="form-control" id="nueva" name="nueva" minlength="6" maxlength="30" required>
                    </div>
                    <div class="mb-3">
                        <label for="repetir" class="form-label fw-semibold">Repetir nueva contraseña <span class="text-danger">*</span></label>
                        <input type="password" class="form-control" id="repetir" name="repetir" minlength="6" maxlength="30" required>
                    </div>
                    <div class="d-flex justify-content-between align-items-center gap-2">
                        <a href="CerrarSesionController" class="btn btn-outline-secondary">Salir</a>
                        <button type="submit" class="btn btn-primary px-4"><i class="bi bi-check-circle me-1"></i>Guardar contraseña</button>
                    </div>
                </form>
            </div>
        </div>
    </main>
</body>
</html>
