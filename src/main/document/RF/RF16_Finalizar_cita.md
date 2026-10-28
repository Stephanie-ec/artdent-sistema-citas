# Guía de Usuario y Documentación Funcional: RF16 - Finalizar Cita

---

## 1. Ficha del Requerimiento

| Campo | Detalle |
| :--- | :--- |
| **Identificador** | **RF16** |
| **Nombre del Requerimiento** | Finalizar cita |
| **Prioridad** | **Media** |
| **Módulo** | Módulo de Cierre de Atención Clínica |
| **Roles Autorizados** | **Odontólogo** (Actor clínico principal), **Secretaría / Administrador** (Supervisión administrativa) |
| **Cambio en APF2** | **Nuevo:** Cierre de atención médica. Permite al Odontólogo marcar formalmente como **"Completado"** (`Estado_idEstado = 2`) la cita que atendió en el consultorio. Dispara una notificación de cierre y actualiza el ciclo de vida de la cita en la base de datos. |

---

## 2. Descripción en Lenguaje Sencillo

Cuando un paciente asiste a su turno y el odontólogo culmina el procedimiento dental programado (por ejemplo, una curación dental, profilaxis o colocación de brackets), la cita debe ser dada de baja del flujo de atenciones pendientes y archivada como culminada exitosamente:

1. **Cierre Clínico desde la Agenda Semanal:** El Odontólogo puede visualizar en su calendario semanal las citas que se encuentran en estado **"Confirmado"**.
2. **Acción de Finalización:** Al hacer clic sobre el bloque de la cita en el calendario, se abre el modal de detalles donde aparece el botón verde **"Finalizar Atención (Marcar Completado)"**.
3. **Actualización de Estado en Base de Datos:** Al presionar este botón, el estado de la cita cambia de `Confirmado` (`Estado_idEstado = 3`) a `Completado` (`Estado_idEstado = 2`).
4. **Registro de Notificación:** El sistema inserta un registro en la tabla `Notificacion` con el asunto `"Actualización de Cita: Confirmado"` y estado de entrega `1` (Enviado).
5. **Retorno Seguro a la Agenda:** Tras completar la atención, el odontólogo es retornado automáticamente a su agenda semanal con un banner verde confirmatorio: *"¡Atención Finalizada! La cita ha sido marcada como Completada con éxito (RF16)"*.

---

## 3. Proceso Paso a Paso para el Usuario (Odontólogo)

1. **Iniciar Sesión:**
   * Ingresar al sistema con su DNI y clave (ej. DNI: `70096374`, Clave: `1234`).
   * El sistema lo conduce de inmediato a su vista de agenda: `ReservaController?accion=listarReservasPorDia`.
2. **Ubicar la Cita en la Agenda Semanal:**
   * En el calendario semanal interactivo, ubicar el bloque correspondiente al paciente atendido (las citas confirmadas se muestran con su respectivo color y hora).
3. **Abrir el Detalle de la Cita:**
   * Hacer clic sobre la tarjeta de la cita en el calendario.
   * Se abrirá el modal de **Detalles de la Cita**, mostrando:
     * ID de la Cita.
     * Paciente asignado.
     * Servicio realizado e importe.
     * Estado actual: `Confirmado`.
4. **Marcar como Completada:**
   * En el pie del modal, presionar el botón verde **"Finalizar Atención (Marcar Completado)"**.
5. **Verificar el Resultado:**
   * El sistema procesa la solicitud en el servidor.
   * La vista se recarga mostrando el banner superior de alerta verde con el mensaje de confirmación de atención finalizada.
   * El estado de la cita en la base de datos pasa a `Completado`, alimentando los reportes estadísticos y el historial del paciente.

---

## 4. Reglas de Negocio y Control de Integridad

* **RN-FIN-01 (Transición Válida de Estado):** Solo pueden ser marcadas como completadas aquellas citas que se encuentren en estado previo `Confirmado`. Citas canceladas o rechazadas no permiten cierre de atención.
* **RN-FIN-02 (Identificador de Estado en MySQL):** En la tabla `Estado`, el estado `Completado` corresponde estrictamente a la clave primaria `idEstado = 2`.
* **RN-FIN-03 (Alimentación de Indicadores):** Las citas completadas son la fuente directa de conteo para los reportes gerenciales de productividad clínica e ingresos recaudados (RF08).

---

## 5. Auditoría y Evidencia Técnica en Base de Datos (MySQL)

### Verificación del Estado en Tabla `Cita` y `Estado`:

```sql
SELECT c.idCita, c.FechaCita, c.HoraCita, e.idEstado, e.TipoEstado, c.Origen 
FROM db_artdent_apf2.Cita c 
INNER JOIN db_artdent_apf2.Estado e ON c.Estado_idEstado = e.idEstado 
WHERE c.idCita = 1;
```

**Resultado obtenido tras la prueba clínica:**
```
+--------+------------+----------+----------+------------+------------+
| idCita | FechaCita  | HoraCita | idEstado | TipoEstado | Origen     |
+--------+------------+----------+----------+------------+------------+
|      1 | 2026-10-09 | 09:00:00 |        2 | Completado | Presencial |
+--------+------------+----------+----------+------------+------------+
```

### Verificación del Registro en Tabla `Notificacion`:

```sql
SELECT idNotificacion, Asunto, FechaEnvio, Enviado, Estado_idEstado, Cita_idCita 
FROM db_artdent_apf2.Notificacion 
WHERE Cita_idCita = 1 
ORDER BY idNotificacion DESC LIMIT 1;
```

**Resultado:**
```
+----------------+-----------------------------------+---------------------+---------+-----------------+-------------+
| idNotificacion | Asunto                            | FechaEnvio          | Enviado | Estado_idEstado | Cita_idCita |
+----------------+-----------------------------------+---------------------+---------+-----------------+-------------+
|              7 | Actualización de Cita: Confirmado | 2026-10-08 19:11:22 |       1 |               2 |           1 |
+----------------+-----------------------------------+---------------------+---------+-----------------+-------------+
```

### Script de Validación Automatizada:
El requerimiento fue verificado de punta a punta mediante el script `test_lote1_clinico.py`, asegurando la transición de estado `3 -> 2` e inserción en la tabla de notificaciones.
