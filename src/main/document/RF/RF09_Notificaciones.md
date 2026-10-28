# Guía de Usuario y Documentación Funcional: RF09 - Notificaciones Automatizadas al Paciente

---

## 1. Ficha del Requerimiento

| Campo | Detalle |
| :--- | :--- |
| **Identificador** | **RF09** |
| **Nombre del Requerimiento** | Notificaciones |
| **Prioridad** | **Media** |
| **Módulo** | Módulo de Comunicaciones, Alertas y Auditoría Clínica |
| **Roles Involucrados** | **Sistema** (Emisión desatendida automática), **Paciente** (Receptor de notificaciones por correo electrónico), **Secretaria / Odontólogo** (Disparadores de eventos clínicos) |
| **Cambio en APF2** | **Modificado:** Reemplaza la notificación interna por un **envío automático por correo electrónico directamente al paciente** cuando su reserva es aprobada o rechazada, y cuando su cita es registrada, reprogramada o cancelada (observación docente). Cada envío queda **estrictamente registrado con fines de trazabilidad y auditoría en la tabla `Notificacion`**. |

---

## 2. Descripción en Lenguaje Sencillo

Este requerimiento garantiza que el paciente se mantenga informado en tiempo real sobre cualquier novedad relativa a su cita o reserva, y que el centro odontológico cuente con un registro auditado de cada mensaje transmitido:

1. **Notificación Externa Directa (Correo Electrónico):**
   * El sistema se comunica de manera proactiva con el paciente a través de su correo electrónico consignado al momento de solicitar la cita.
   * Elimina la incertidumbre del paciente, notificándole al instante cuando la clínica toma una decisión sobre su cita.
2. **Eventos que Disparan el Envío Automático:**
   * **Cita Presencial Registrada (RF03):** Confirma la fecha, hora y odontólogo asignado con el código oficial de atención.
   * **Reserva Web Aprobada (RF14):** Confirma que el pago fue recibido y que la reserva web pasó a estado *Confirmado*.
   * **Reserva Web Rechazada (RF14):** Notifica de forma clara la causal o motivo del rechazo para que el paciente pueda rectificar sus datos o reagendar.
   * **Cita Reprogramada (RF03):** Comunica la nueva fecha y hora pactadas.
   * **Cita Cancelada (RF03):** Notifica la baja de la cita solicitada por el paciente o la clínica.
   * **Cita Completada (RF16):** Agradece al paciente tras la atención finalizada por el odontólogo.
3. **Registro y Trazabilidad en Base de Datos (Tabla `Notificacion`):**
   * Cada correo enviado genera una fila en la tabla relacional `Notificacion` de MySQL, registrando:
     * `Asunto`: Asunto y motivo exacto de la comunicación (ej. *"Reserva Rechazada: Cruce de horario con cita presencial"*).
     * `Fecha`: Fecha y hora de expedición.
     * `Estado_idEstado`: Estado de la cita al momento del envío (3: Confirmado, 4: Reprogramado, 5: Cancelado, 6: Rechazado, 2: Completado).
     * `Cita_idCita`: Vínculo relacional con la cita correspondiente.

---

## 3. Matriz de Eventos y Mensajes Emitidos

| Evento del Sistema | Estado Asociado | Asunto en Correo | Detalle Registrado en Tabla `Notificacion` |
| :--- | :---: | :--- | :--- |
| **Registro de Cita Presencial (RF03)** | `3` (Confirmado) | *Cita Presencial Confirmada - ArtDent* | `Cita Presencial Registrada` |
| **Aprobación de Reserva Web (RF14)** | `3` (Confirmado) | *Reserva Web Confirmada - ArtDent* | `Reserva Web Aprobada` |
| **Rechazo de Reserva Web (RF14)** | `6` (Rechazado) | *Reserva Rechazada - ArtDent* | `Reserva Rechazada: [Motivo Seleccionado]` |
| **Reprogramación de Cita (RF03)** | `4` (Reprogramado) | *Cita Reprogramada - ArtDent* | `Cita Reprogramada` (con nueva fecha/hora) |
| **Cancelación de Cita (RF03)** | `5` (Cancelado) | *Cita Cancelada - ArtDent* | `Cita Cancelada` |
| **Finalización de Atención (RF16)** | `2` (Completado) | *Atención Finalizada - ArtDent* | `Atención Odontológica Completada` |

---

## 4. Proceso Paso a Paso para el Usuario

### Flujo: Verificación de Notificaciones desde la Perspectiva del Paciente y de la Clínica

1. **Recepción por el Paciente:**
   * El paciente revisa su bandeja de entrada (o spam) del correo electrónico registrado.
   * Recibe un mensaje formal con el remitente del Centro Odontológico ArtDent con el detalle de la acción tomada, recordándole asistir 10 minutos antes con su DNI.
2. **Auditoría por la Clínica (Personal Administrativo):**
   * En caso de discrepancia o reclamo de un paciente que argumente no haber sido informado de un cambio o rechazo, el personal puede ingresar al panel y consultar el historial de auditoría de notificaciones en el sistema.
   * La tabla `Notificacion` almacena la fecha exacta y el contenido emitido, sirviendo como evidencia de comunicación fehaciente.

---

## 5. Arquitectura Técnica y Seguridad

1. **Servicio Centralizado de Correo (`EmailService`):**
   * Implementado en `pe.edu.utp.utils.EmailService` mediante JavaMail API (soporta servidor SMTP seguro con TLS/SSL o simulación controlada en entorno de pruebas/desarrollo).
2. **Persistencia en DAO (`CitaDao.registrarNotificacion`):**
   * Sentencia SQL parametrizada ejecutada en `CitaDaoImpl`:
     ```sql
     INSERT INTO Notificacion (Asunto, Fecha, Estado_idEstado, Cita_idCita) 
     VALUES (?, NOW(), ?, ?);
     ```
   * Evita inyección SQL y garantiza la integridad referencial con las llaves foráneas hacia `Estado` y `Cita`.

---

## 6. Evidencias de Validación y Auditoría

### 6.1 Auditoría en MySQL (`db_artdent_apf2`)

```sql
SELECT n.idNotificacion, n.Asunto, n.Fecha, e.EstadoNombre, n.Cita_idCita, p.Nombre, p.Correo
FROM Notificacion n
JOIN Estado e ON n.Estado_idEstado = e.idEstado
JOIN Cita c ON n.Cita_idCita = c.idCita
JOIN Paciente p ON c.Paciente_idPaciente = p.idPaciente
ORDER BY n.idNotificacion DESC LIMIT 5;
```

**Muestra de registros auditados en ejecución real:**
* `idNotificacion = 1`: `Reserva Web Aprobada` | Estado: `Confirmado` | Cita: `12` | Paciente: `Valeria Torres` (`valeria.torres@example.com`).
* `idNotificacion = 2`: `Reserva Rechazada: Cruce de horario con cita presencial` | Estado: `Rechazado` | Cita: `13` | Paciente: `Marcos Polo` (`marcos.polo@example.com`).

Todas las notificaciones se encuentran vinculadas a su respectiva cita y comprobadas tanto en base de datos como en los flujos de interfaz.
