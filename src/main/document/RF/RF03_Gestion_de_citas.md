# Guía de Usuario y Documentación Funcional: RF03 - Gestión de Citas

---

## 1. Ficha del Requerimiento

| Campo | Detalle |
| :--- | :--- |
| **Identificador** | **RF03** |
| **Nombre del Requerimiento** | Gestión de citas |
| **Prioridad** | **Alta** |
| **Módulo** | Módulo de Gestión de Citas, Reprogramaciones y Cancelaciones (Secretaría) |
| **Roles Autorizados** | **Secretaria** (Rol operativo primario), **Administrador** (Supervisión) |
| **Cambio en APF2** | **Modificado:** Exclusividad del rol de Secretaría para el registro de citas presenciales (pacientes que acuden físicamente o llaman por teléfono), reprogramaciones y cancelaciones. Cada cambio emite automáticamente un registro en la tabla `Notificacion` (RF09) y envía correo electrónico al paciente. La aprobación de reservas web pasa formalmente a RF14. |

---

## 2. Descripción en Lenguaje Sencillo

Este módulo le permite al personal de recepción (**Secretaria**) tener control total y fluido del flujo de pacientes del centro odontológico:

1. **Atención Presencial y Telefónica:** Cuando un paciente se acerca a ventanilla o se comunica vía telefónica, la secretaria puede registrarlo inmediatamente sin necesidad de pagos previos en línea. La cita queda registrada con origen **"Presencial"** y estado **"Confirmado"**, ocupando de forma oficial el turno en el consultorio.
2. **Reprogramación de Fechas y Horas:** Si el paciente solicita cambiar el día u hora de su atención, la secretaria selecciona la nueva fecha/hora disponible y el sistema actualiza el estado a **"Reprogramado"**.
3. **Cancelación de Citas:** Ante imprevistos o cancelaciones del paciente, la secretaria cancela la cita liberando el espacio, quedando registrado el estado como **"Cancelado"**.
4. **Notificaciones Automáticas (RF09):** Cada vez que una cita es creada en ventanilla, reprogramada o cancelada, el sistema genera de forma transparente una notificación auditada en la base de datos y envía un correo electrónico de confirmación al paciente.

---

## 3. Proceso Paso a Paso para el Usuario (Secretaría)

### Flujo 1: Registro de una Cita Presencial (Ventanilla o Teléfono)

1. **Iniciar Sesión:**
   * Ingresar a `http://localhost:8080/ArtDent/iniciosesion.jsp`.
   * Digitar las credenciales de Secretaría (ej. DNI: `78223344`, Contraseña: `1234`).
   * Al ingresar, el sistema despliega el menú lateral con acceso al módulo.

2. **Abrir Formulario Presencial:**
   * Hacer clic en el menú lateral en **"Cita Presencial"** o en el botón verde destacado **"+ Registrar Cita Presencial (RF03)"** ubicado en la parte superior de la vista de Solicitudes.
   * La URL directa es: `http://localhost:8080/ArtDent/CitaController?accion=formPresencial`.

3. **Completar Datos del Paciente:**
   * **DNI:** Ingresar el número de documento (8 dígitos). Se puede presionar el botón de búsqueda para autocompletar si el paciente ya ha visitado la clínica previamente.
   * **Nombres y Apellidos:** Ingresar los datos de filiación del paciente.
   * **Teléfono:** Número de contacto (9 dígitos).
   * **Correo electrónico:** Dirección del paciente donde recibirá su comprobante y avisos.

4. **Programar el Turno:**
   * **Servicio Dental:** Seleccionar el tratamiento solicitado (ej. *Consulta General*, *Limpieza Dental*, *Ortodoncia*). El importe base se actualizará automáticamente.
   * **Odontólogo Tratante:** Seleccionar el médico especialista en turno (ej. *Dr. Ruben Cuadros*).
   * **Fecha y Hora:** Indicar el día y hora exactos coordinados con el paciente.
   * **Observaciones:** (Opcional) Anotar motivos de consulta específicos o comentarios de ventanilla.

5. **Guardar y Agendar:**
   * Presionar el botón **"Confirmar y Agendar Cita Presencial"**.
   * El sistema genera la cita con origen `Presencial`, asigna el estado `Confirmado`, emite la notificación RF09 y redirige a la lista de citas con un banner verde de confirmación y el código único asignado (ej. `ART-RES-00010`).

---

### Flujo 2: Reprogramación de Cita

1. **Ubicar la Cita:**
   * En el menú lateral, ingresar a **"Solicitudes"** y presionar el botón **"Citas"** para ver los registros vigentes.
2. **Seleccionar Acción:**
   * En la fila del paciente correspondiente, hacer clic en el botón azul **"Reprogramar"**.
3. **Indicar Nuevo Horario:**
   * Se abrirá la pantalla de reprogramación mostrando los datos del paciente y el médico asignado.
   * En los campos inferiores, seleccionar la **Nueva Fecha** y la **Nueva Hora**.
4. **Confirmar Cambio:**
   * Hacer clic en **"Confirmar reprogramación"**.
   * La base de datos actualiza el turno, cambia el estado a **"Reprogramado"** (código de estado 4), registra el evento en la tabla `Notificacion` y despacha un correo de confirmación al paciente con los nuevos horarios.

---

### Flujo 3: Cancelación de Cita

1. **Ubicar la Cita:**
   * En la pestaña **"Citas"** de las Solicitudes, ubicar al paciente que no asistirá o canceló.
2. **Ejecutar Cancelación:**
   * Hacer clic en el botón verde/rojo **"Cancelar"**.
3. **Resultado:**
   * La cita cambia inmediatamente su estado a **"Cancelado"** (código de estado 5).
   * El espacio en el calendario queda liberado y se guarda la notificación en auditoría (`Notificacion`).

---

## 4. Auditoría Técnica y Base de Datos (MySQL)

### A. Registro de Citas Presenciales en la Tabla `Cita`
La cita presencial se distingue de la web por el campo `Origen` y el usuario administrativo responsable:

```sql
SELECT c.idCita, c.FechaCita, c.HoraCita, c.Origen, 
       c.Usuario_idUsuario AS idSecretaria, e.TipoEstado, 
       CONCAT(p.Nombre, ' ', p.Apellido) AS Paciente,
       CONCAT(od.Nombre, ' ', od.Apellido) AS Odontologo
FROM Cita c
JOIN Estado e ON c.Estado_idEstado = e.idEstado
JOIN Paciente p ON c.Paciente_idPaciente = p.idPaciente
JOIN Usuario od ON c.Odontologo_idUsuario = od.idUsuario
WHERE c.Origen = 'Presencial'
ORDER BY c.idCita DESC LIMIT 5;
```

* **Campos clave verificados:**
  * `Origen`: `'Presencial'`
  * `Estado_idEstado`: `3` (`Confirmado` inicial)
  * `Usuario_idUsuario`: `2` (Identificador del personal de secretaría en turno)

### B. Notificaciones Auditadas en la Tabla `Notificacion` (RF09)
Cada modificación operativa crea un registro inmutable en MySQL:

```sql
SELECT n.idNotificacion, n.Asunto, n.FechaEnvio, n.Enviado, 
       e.TipoEstado, n.Cita_idCita
FROM Notificacion n
JOIN Estado e ON n.Estado_idEstado = e.idEstado
WHERE n.Cita_idCita = 10
ORDER BY n.idNotificacion ASC;
```

* **Evidencia obtenida en pruebas:**
  1. `Cita Presencial Registrada` -> Estado `Confirmado` (ID 3), `Enviado = 1`.
  2. `Cita Reprogramada` -> Estado `Reprogramado` (ID 4), `Enviado = 1`.
  3. `Cita Cancelada` -> Estado `Cancelado` (ID 5), `Enviado = 1`.

---

## 5. Pruebas y Validación Multi-Rol

| Rol Evaluado | Usuario de Prueba | Resultado Obtenido |
| :--- | :--- | :--- |
| **Secretaria** | `78223344` (Ethelvina Soto) | **APROBADO:** Acceso concedido al formulario presencial, registro exitoso en BD (`Origen='Presencial'`), reprogramación y cancelación funcionales. |
| **Administrador** | `48223344` (Juan David F.) | **APROBADO:** Visualización y supervisión global de todas las citas y solicitudes presenciales. |
| **Odontólogo** | `70096374` (Ruben Cuadros) | **APROBADO:** Sus citas presenciales confirmadas aparecen inmediatamente en su calendario semanal. No tiene acceso a crear citas en rol administrativo. |
| **Paciente** | Sin sesión | **APROBADO:** Sin acceso a las rutas operativas internas de ventanilla; sus reservas se gestionan vía web pública (RF01/RF02). |

---

## 6. Ejecución de la Suite Automatizada

Para reproducir y validar de extremo a extremo todo el ciclo de vida de RF03:
```bash
python3 test_rf02_rf03_rf04_e2e.py
```
Resultado del script:
* `[✓] 1. Inicio de sesión como Secretaria exitoso`
* `[✓] 2. Vista reservapresencial.jsp cargada correctamente con servicios y médicos`
* `[✓] 3. Cita presencial enviada exitosamente`
* `[✓] 4. Cita verificada en BD: Origen='Presencial', Secretaria ID=2, Estado='Confirmado'`
* `[✓] 5. Notificación RF09 verificada en BD: Asunto='Cita Presencial Registrada', Enviado=1`
* `[✓] 6. Reprogramación ejecutada por Secretaría`
* `[✓] 7. BD Cita actualizada a nueva fecha/hora, Estado=4 y Notificación registrada`
* `[✓] 8. Cancelación ejecutada por Secretaría`
* `[✓] 9. BD Cita actualizada a Estado=5 (Cancelado) y Notificación registrada`
