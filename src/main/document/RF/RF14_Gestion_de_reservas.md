# Guía de Usuario y Documentación Funcional: RF14 - Gestión de Reservas Web

---

## 1. Ficha del Requerimiento

| Campo | Detalle |
| :--- | :--- |
| **Identificador** | **RF14** |
| **Nombre del Requerimiento** | Gestión de reservas |
| **Prioridad** | **Alta** |
| **Módulo** | Módulo de Solicitudes y Admisión Web |
| **Roles Autorizados** | **Secretaria** (Aprobación, rechazo y control de reservas web) |
| **Cambio en APF2** | **Nuevo:** La aprobación de reservas web se separa explícitamente de la gestión general de citas (RF03). La Secretaria revisa las solicitudes en estado *"En espera"*. **Solo puede aprobar una reserva que tenga un pago verificado registrado**; al aprobarla, la cita pasa a *"Confirmado"*. También puede rechazarla (estado *"Rechazado"*) registrando el motivo. El paciente es notificado en ambos casos (RF09). |

---

## 2. Descripción en Lenguaje Sencillo

Este requerimiento establece el flujo de control y admisión de solicitudes web realizadas por pacientes que no poseen cuenta en el sistema:

1. **Bandeja de Entrada de Reservas Web:**
   * Todas las citas solicitadas desde la web ingresan inicialmente con estado **"En espera"** (`Estado_idEstado = 1`) y origen **"Web"**.
2. **Candado de Aprobación Condicionada al Pago:**
   * La Secretaria **no puede aprobar** una reserva web si esta no cuenta con un pago registrado previamente en la tabla `Pago`.
   * Si la secretaria intenta aprobar una reserva impaga, la interfaz bloquea el botón y, a nivel de backend, el servidor valida la existencia del pago; si no existe, rebota la solicitud mostrando la advertencia: *"No se puede aprobar la reserva (RF14): Solo se puede aprobar una reserva que tenga un pago registrado"*.
3. **Paso a Estado "Confirmado":**
   * Una vez verificado el pago (sea en línea o cobrado en efectivo en caja), el botón **"Aprobar"** se desbloquea. Al presionarlo, el estado de la cita cambia automáticamente a **"Confirmado"** (`Estado_idEstado = 3`), integrándose a la agenda del médico y emitiendo una notificación por correo al paciente (RF09).
4. **Rechazo Justificado de Reservas:**
   * La Secretaria puede rechazar una reserva web que no cumpla los criterios clínicos o administrativos (por ejemplo: datos falsos o incompletos, cruce con citas presenciales ya agendadas, indisponibilidad del odontólogo, o servicios que requieren evaluación previa presencial).
   * Al rechazar, el estado de la cita pasa a **"Rechazado"** (`Estado_idEstado = 6`), se registra el motivo en la auditoría y se le envía un correo explicativo al paciente (RF09).

---

## 3. Proceso Paso a Paso para el Usuario

### Flujo 1: Secretaría - Revisión y Aprobación de Reserva Pagada

1. **Iniciar Sesión:**
   * Ingresar como Secretaria (`78223344` / `1234`).
2. **Acceder a la Bandeja de Reservas Web:**
   * En la barra lateral, hacer clic en **"Solicitudes"** y asegurarse de que la pestaña **"Reservas Web"** esté activa (`PDCSolicitudes.jsp`).
3. **Verificar Estado de Pago de la Solicitud:**
   * Ubicar la fila de la reserva que se encuentra en estado `[⌛ En espera]`.
   * Observar la columna **"Pago / Boleta (RF10)"**:
     * Si muestra `[⌛ Pendiente]`, el botón **"Aprobar"** aparecerá con icono de candado bloqueado `[🔒 Aprobar]`. Para aprobarla, primero se debe registrar el cobro en efectivo presionando **"Cobrar"** o esperar que el paciente pague en línea.
     * Si muestra `[✓ Pagado]` y el código de boleta `B001-XXXX`, el botón azul **"Aprobar"** estará completamente habilitado.
4. **Aprobar la Reserva:**
   * Presionar el botón azul **"Aprobar"** (`bi-check2`).
5. **Confirmación y Notificación:**
   * El sistema actualiza el estado a `[Confirmado]`.
   * Se muestra una alerta verde: *"¡Reserva web aprobada con éxito (RF14)! La cita ha pasado a estado Confirmado y se envió la notificación automática al paciente (RF09)"*.
   * Se registra el envío en la tabla `Notificacion` y el paciente recibe su correo de confirmación.

---

### Flujo 2: Secretaría - Rechazo de una Reserva Web con Motivo

1. **Identificar la Reserva a Rechazar:**
   * En la bandeja de reservas web en estado `[⌛ En espera]`, ubicar la cita del paciente.
2. **Presionar el Botón de Rechazo:**
   * En la columna de *Acciones (RF14)*, hacer clic en el botón rojo **"Rechazar"** (`bi-x-circle`).
3. **Seleccionar el Motivo del Rechazo:**
   * Se abrirá la ventana modal **"Rechazar Reserva Web (RF14)"**.
   * En la lista desplegable *Motivo del Rechazo*, seleccionar la causal aplicable:
     * *Datos falsos o incompletos del paciente.*
     * *Cruce de horario con cita presencial.*
     * *Indisponibilidad imprevista del odontólogo.*
     * *Servicio requiere evaluación previa presencial.*
     * *Reserva duplicada por el mismo usuario.*
     * *Falta de pago oportuno en ventanilla.*
4. **Confirmar el Rechazo:**
   * Presionar el botón rojo **"Confirmar Rechazo"**.
5. **Resultado Inmediato:**
   * La reserva pasa de forma definitiva al estado `[Rechazado]` (`Estado_idEstado = 6`).
   * La tabla muestra la alerta: *"Reserva web rechazada (RF14): La reserva se actualizó a estado Rechazado y el motivo fue notificado por correo electrónico al paciente (RF09)"*.
   * El sistema registra el evento en la tabla `Notificacion` y emite el correo con la justificación seleccionada.

---

## 4. Reglas de Negocio e Integridad Técnica

1. **Validación Servidor Obligatoria (Backend Security):**
   * En `ReprogramacionController.UpdateReservaEstado`:
     ```java
     if ("En espera".equalsIgnoreCase(estadoActual)) {
         PagoDao pagoDao = new PagoDaoImpl();
         if (!pagoDao.tienePago(idReserva)) {
             response.sendRedirect("ReservaController?accion=listar&error=sinPago");
             return;
         }
     }
     ```
   * Aunque un usuario intente enviar una petición directa por HTTP POST, el backend valida contra la base de datos la existencia del registro en la tabla `Pago` antes de modificar el estado.
2. **Estados en Base de Datos (`Estado`):**
   * ID `1`: `En espera` (Estado inicial de reserva web).
   * ID `3`: `Confirmado` (Estado alcanzado tras aprobación formal).
   * ID `6`: `Rechazado` (Estado final tras rechazo fundamentado).
3. **Auditoría Automatizada de Notificaciones:**
   * Todo cambio a "Confirmado" o "Rechazado" inserta automáticamente un registro en la tabla `Notificacion` vinculando el `idCita`, el `idEstado` y el asunto con el motivo detallado.

---

## 5. Evidencias de Validación y Auditoría

### 5.1 Verificación en Base de Datos MySQL (`db_artdent_apf2`)

```sql
-- Verificar cita aprobada tras pago
SELECT c.idCita, c.Origen, e.EstadoNombre, p.idPago, comp.Numero 
FROM Cita c
JOIN Estado e ON c.Estado_idEstado = e.idEstado
JOIN Pago p ON p.Cita_idCita = c.idCita
JOIN Comprobante comp ON comp.Pago_idPago = p.idPago
WHERE c.idCita = 12;

-- Verificar cita rechazada
SELECT c.idCita, c.Origen, e.EstadoNombre, n.Asunto
FROM Cita c
JOIN Estado e ON c.Estado_idEstado = e.idEstado
JOIN Notificacion n ON n.Cita_idCita = c.idCita
WHERE c.idCita = 13;
```

**Resultado verificado:**
* Cita 12: Origen `Web`, Estado `Confirmado`, Pago `idPago = 3`, Boleta `B001-00000003`.
* Cita 13: Origen `Web`, Estado `Rechazado`, Notificación: `Reserva Rechazada: Cruce de horario con cita presencial`.

### 5.2 Verificación Visual en Google Chrome

* **Bandeja de Solicitudes (`solicitudes_secretaria_ui.png`):** Muestra el candado de seguridad `[🔒 Aprobar]` para citas sin pago y el botón de rechazo con modal explicativo.
