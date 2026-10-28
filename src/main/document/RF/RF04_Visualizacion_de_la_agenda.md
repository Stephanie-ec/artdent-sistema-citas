# Guía de Usuario y Documentación Funcional: RF04 - Visualización de la Agenda

---

## 1. Ficha del Requerimiento

| Campo | Detalle |
| :--- | :--- |
| **Identificador** | **RF04** |
| **Nombre del Requerimiento** | Visualización de la agenda |
| **Prioridad** | **Alta** |
| **Módulo** | Agenda Clínica y Calendario Semanal de Citas |
| **Rol Autorizado** | **Odontólogo** (Rol clínico titular), **Administrador** (Supervisión) |
| **Cambio en APF2** | **Modificado:** Se precisa formalmente el actor clínico (**Odontólogo**). El sistema garantiza que cada médico visualice exclusivamente su propia agenda de citas y pacientes en un calendario semanal interactivo, protegiendo la privacidad y organización del consultorio. |

---

## 2. Descripción en Lenguaje Sencillo

Este módulo está diseñado especialmente para los odontólogos del centro médico:

1. **Agenda Semanal Personalizada:** Al ingresar al sistema con su usuario y contraseña, el odontólogo ve de un vistazo su programación completa de lunes a domingo.
2. **Aislamiento de Citas (Privacidad Clínica):** El profesional visualiza **únicamente** los turnos y pacientes asignados a su persona y especialidad, evitando confusiones o cruces con citas de otros odontólogos.
3. **Detalle Visual del Turno:** Cada bloque en el calendario muestra el horario exacto, el nombre completo del paciente, el tratamiento dental programado y el estado de la cita.
4. **Navegación Temporal Intuitiva:** El médico puede alternar fácilmente entre la semana actual, semanas anteriores y semanas futuras usando los controles interactivos del calendario, sin perder el filtro personalizado.

---

## 3. Proceso Paso a Paso para el Usuario (Odontólogo)

### Paso 1: Iniciar Sesión en el Sistema
1. Ingresar a la página de acceso clínico:  
   `http://localhost:8080/ArtDent/iniciosesion.jsp`
2. Digitar el DNI y clave asignada al odontólogo:
   * **DNI:** `70096374`
   * **Contraseña:** `1234`
3. Al hacer clic en **"Iniciar Sesión"**, el sistema reconoce el rol de odontólogo y lo redirige automáticamente a su calendario de atención.

### Paso 2: Visualizar la Agenda Semanal
1. La pantalla principal muestra un encabezado distintivo:  
   **`Agenda Semanal Personalizada (RF04) — Dr(a). Ruben Cuadros • Odontología`**
2. Se muestra el rango de fechas de la semana en curso (por ejemplo: *Semana 44 - Del 26 de Octubre al 1 de Noviembre de 2026*).
3. Cada día (Lunes a Domingo) muestra los bloques horarios desde las 8:00 a.m. hasta el cierre:
   * Las citas confirmadas se despliegan en tarjetas de colores con el nombre del paciente, servicio y hora pactada.

### Paso 3: Navegación Temporal
* **Botón "Hoy":** Regresa inmediatamente a la semana correspondiente a la fecha actual.
* **Flecha Izquierda (<):** Desplaza la visualización a la semana previa para revisar atenciones pasadas.
* **Flecha Derecha (>):** Desplaza la visualización a la semana posterior para planificar las atenciones de los próximos días.

---

## 4. Auditoría Técnica y Base de Datos (MySQL)

### A. Consultas de Agenda y Asignación de Médico
El calendario semanal se nutre de los procedimientos almacenados optimizados de la base de datos `db_artdent_apf2`:
* `ListarCitasPorDiaSemana(dia, semana)`: Citas presenciales confirmadas (`Estado = 3`).
* `ListarReservasPorDiaSemana(dia, semana)`: Reservas web confirmadas (`Estado = 3`).

Ambos procedimientos efectúan el cruce directo con el usuario médico asignado:
```sql
SELECT c.idCita, c.FechaCita, c.HoraCita, c.Origen,
       CONCAT(p.Nombre, ' ', p.Apellido) AS Paciente,
       s.TipoServicio,
       CONCAT(od.Nombre, ' ', od.Apellido) AS Odontologo
FROM Cita c
INNER JOIN Paciente p ON c.Paciente_idPaciente = p.idPaciente
INNER JOIN Servicio s ON c.Servicio_idServicio = s.idServicio
INNER JOIN Usuario od ON c.Odontologo_idUsuario = od.idUsuario
WHERE od.idUsuario = 4 AND c.Estado_idEstado = 3
ORDER BY c.FechaCita ASC, c.HoraCita ASC;
```

### B. Filtro Estricto en el Controlador (`ReservaController.java`)
En la capa controladora Java, el método `listarReservasPorSemana` comprueba la sesión activa:
1. Detecta `session.getAttribute("TipoRol") == "Odontologo"`.
2. Lee `Nombre` y `Apellido` del médico conectado.
3. Filtra las colecciones `citasPorDia` y `reservasPorDia` asegurando que ninguna cita de otro facultativo sea transferida a la vista JSP (`PDCCalendario.jsp`).

---

## 5. Pruebas y Validación Multi-Rol

| Rol Evaluado | Usuario de Prueba | Resultado Obtenido |
| :--- | :--- | :--- |
| **Odontólogo** | `70096374` (Dr. Ruben Cuadros) | **APROBADO:** Visualiza exclusivamente sus citas clínicas bajo el encabezado de agenda personalizada. La navegación temporal preserva su filtro individual. |
| **Secretaria** | `78223344` (Ethelvina Soto) | **APROBADO:** Tiene acceso al calendario general de citas y a la pestaña de solicitudes operativas para gestionar la recepción de la clínica. |
| **Administrador** | `48223344` (Juan David F.) | **APROBADO:** Visualiza el **"Calendario General de Citas"** con visión global de todos los médicos y turnos programados en el centro. |
| **Paciente** | Sin sesión | **APROBADO:** No tiene acceso al panel clínico interno; su interacción se mantiene acotada a la reserva web y voucher (RF01/RF02). |

---

## 6. Ejecución de la Suite Automatizada

Para ejecutar la verificación programática del requerimiento RF04:
```bash
python3 test_rf02_rf03_rf04_e2e.py
```
Salida validada del módulo clínico:
* `[✓] 1. Inicio de sesión como Odontólogo exitoso (Dr. Ruben Cuadros, Rol 3)`
* `[✓] 2. Encabezado personalizado de Agenda Semanal verificado con credencial médica`
* `[✓] 3. Navegación temporal del calendario funciona preservando filtro del médico`
* `>>> RF04 APROBADO EXITOSAMENTE`
