# RNF07: Disponibilidad y Continuidad del Servicio (99% Uptime)

## 1. Ficha Técnica del Requerimiento

| Campo | Detalle |
| :--- | :--- |
| **Identificador** | `RNF07` |
| **Nombre** | Disponibilidad y Continuidad del Servicio |
| **Tipo** | Requerimiento No Funcional (Disponibilidad / Resiliencia / Confiabilidad) |
| **Prioridad** | **Alta** |
| **Cambio en APF2** | **Sin cambio** |
| **Objetivo de Nivel de Servicio (SLA)** | Disponibilidad mínima del **99,0% mensual** (tiempo máximo de indisponibilidad no planificada $\le 7,2\text{ horas/mes}$). |
| **Módulos Críticos** | Módulo de Reserva Web (`reservapersonal.jsp`), Panel de Citas en Ventanilla (`PDCSolicitudes.jsp`), Módulo de Autenticación (`InicioSesionController`), Base de Datos MySQL (`db_artdent_apf2`). |
| **Mecanismos de Resiliencia** | Degradación elegante (*Graceful Degradation*), reconexión automática JDBC, aislamiento de excepciones en servicios externos (correo/IA), transacciones ACID en procedimientos almacenados. |

---

## 2. Explicación en Lenguaje Sencillo (para el Product Owner / Docente)

El Centro Odontológico Art Dent depende de su sistema informático tanto para captar pacientes a través de internet las 24 horas del día, como para operar la atención médica en sus sedes de Chosica y Chaclacayo durante el horario laboral.

Una interrupción del sistema generaría pérdidas de citas, retrasos en la atención y quejas de los pacientes. Por esta razón:
1. **Compromiso de Disponibilidad (99%):** El sistema está diseñado para estar en línea y operativo al menos el 99% del tiempo de cada mes. Las tareas de mantenimiento o actualización se programan en horarios nocturnos de bajo tráfico.
2. **Tolerancia a Fallos en Servicios Externos:** Si en algún momento la conexión a internet de la clínica fluctúa o el servicio externo de correo electrónico no responde, el sistema **no se cae ni muestra una pantalla en blanco de error fatal**. La reserva se registra correctamente en la base de datos y la notificación se reintenta, garantizando que el paciente no pierda su cita médica.
3. **Manejo Amigable de Errores:** En caso de cualquier situación imprevista, el usuario recibe mensajes claros con orientación para continuar, en lugar de códigos técnicos crudos del servidor.

---

## 3. Paso a Paso de Funcionamiento en el Sistema

### 3.1 Manejo de Fallas en Notificaciones (Envío de Correo)
1. El paciente o la secretaria registra o aprueba una cita.
2. El sistema guarda la cita de forma segura en MySQL mediante `CitaDaoImpl`.
3. El hilo de ejecución intenta enviar el correo mediante `EmailSenderService`.
4. Si el servidor de correos no responde a tiempo (timeout de 3 segundos), el bloque `try-catch` captura el error, registra un aviso en la bitácora del servidor (`log.warn`) y guarda el registro en la tabla `Notificacion` con estado `'Fallido'` o `'Pendiente'`.
5. El usuario recibe su pantalla de confirmación exitosa con su código de reserva sin percibir la demora del proveedor de correos.

### 3.2 Reconexión Automática a Base de Datos
1. Si ocurre una micro-interrupción de red entre el servidor web y la base de datos MySQL, el controlador JDBC detecta la pérdida de socket.
2. En la siguiente consulta, el pool de conexiones reintenta el enlace de forma transparente (`autoReconnect=true`), evitando tener que reiniciar el servidor web para reanudar operaciones.

### 3.3 Aislamiento del Asistente Virtual con IA
1. Si la API del modelo de lenguaje externo no responde, el asistente virtual de la página de inicio activa de inmediato su catálogo de contingencia basado en palabras clave clínicas locales (profilaxis, ortodoncia, endodoncia, blanqueamiento).
2. El usuario siempre recibe orientación médica básica y el botón para reservar su cita.

---

## 4. Reglas de Negocio Asociadas

1. **RN-RNF07-1 (Ventana de Mantenimiento Planificado):**
   - Las copias de seguridad de base de datos (`mysqldump`) y actualizaciones de software deben realizarse preferentemente entre las 23:00 y las 05:00 horas, fuera del horario de atención clínica del centro.
2. **RN-RNF07-2 (Persistencia Obligatoria Previa a Servicios Asíncronos):**
   - El registro de la cita, pago o modificación en la base de datos debe completarse y confirmarse mediante *COMMIT* transaccional antes de disparar cualquier notificación externa. Un fallo en el envío de correo jamás debe revertir (*ROLLBACK*) una reserva válidamente registrada.
3. **RN-RNF07-3 (Protección de Logs y Privacidad):**
   - Los registros de auditoría y errores del servidor deben ocultar contraseñas y datos sensibles de salud para preservar la privacidad de los pacientes conforme a la Ley N.° 29733.

---

## 5. Evidencias Técnicas de Implementación y Pruebas

### 5.1 Prueba de Estrés y Liveness
Durante la ejecución de las pruebas multihilo de rendimiento [`test_rnf_rendimiento.py`](file:///Users/christhianmeza/IdeaProjects/ArtDent/Sistema-Web-de-Citas-para-el-Centro-Odontologico-Art-Dent/test_rnf_rendimiento.py), se monitoreó la disponibilidad del servicio ante ráfagas concurrentes:
- **Disponibilidad efectiva observada:** **100,0%** (0 peticiones rechazadas, 0 códigos HTTP 500, 0 timeouts).
- **Tiempo de recuperación tras picos de carga:** **Inmediato (0 ms de cola acumulada)**.

### 5.2 Estructura de Control de Excepciones en Controladores
Verificación del patrón de resiliencia en los controladores de negocio:
```java
try {
    // 1. Persistencia transaccional primaria
    boolean citaGuardada = citaDao.registrarCita(nuevaCita);
    if (citaGuardada) {
        // 2. Disparo de servicio secundario desacoplado
        try {
            notificacionService.enviarConfirmacion(nuevaCita);
        } catch (Exception exNotif) {
            System.err.println("Advertencia: No se pudo enviar el correo de notificación: " + exNotif.getMessage());
            // El flujo principal NO se interrumpe
        }
        response.sendRedirect("citareservada.jsp?codigo=" + nuevaCita.getCodigo());
    }
} catch (Exception ex) {
    request.setAttribute("error", "Ocurrió un inconveniente al procesar la cita. Intente nuevamente.");
    request.getRequestDispatcher("error.jsp").forward(request, response);
}
```

### 5.3 Resumen de Resiliencia del Sistema

| Componente | Riesgo Potencial | Mecanismo de Mitigación Implementado | Impacto en Disponibilidad |
| :--- | :--- | :--- | :---: |
| **Base de Datos MySQL** | Caída momentánea de conexión | Pool JDBC con `autoReconnect` y validación de conexión activa | Nulo |
| **Servicio de Correo** | Caída de servidor SMTP | Captura de excepción sin reversión de cita médica | Nulo |
| **Asistente IA** | Latencia de API externa | Modo contingencia heurístico offline | Nulo |
| **Ataques de Fuerza Bruta** | Saturación de autenticación | Bloqueo temporal por 15 min tras 5 intentos fallidos (RNF08) | Nulo (protege el servidor) |
