# Guía de Usuario y Documentación Funcional: RF12 - Gestión de Disponibilidad Médica

---

## 1. Ficha del Requerimiento

| Campo | Detalle |
| :--- | :--- |
| **Identificador** | **RF12** |
| **Nombre del Requerimiento** | Gestión de Disponibilidad |
| **Prioridad** | **Alta** |
| **Módulo** | Módulo de Asignación de Horarios y Cartera de Servicios Médicos |
| **Roles Autorizados** | **Administrador** |
| **Cambio en APF2** | **Modificado:** La responsabilidad pasa formalmente del Odontólogo al **Administrador**. El Administrador asigna a cada odontólogo sus horarios de atención semanales y los servicios que está autorizado a realizar; el sistema los utiliza activamente para validar y filtrar la disponibilidad en nuevas reservas web y citas presenciales. |

---

## 2. Descripción en Lenguaje Sencillo

Este requerimiento garantiza una gestión ordenada y centralizada de los recursos clínicos de ArtDent:

1. **Horarios de Atención Semanales:**
   * El Administrador define en qué días de la semana y rangos horarios trabaja cada odontólogo del centro (lunes a viernes de 08:00 a 18:30).
   * La información se almacena en la tabla relacional `Usuario_Horario`.
2. **Cartera de Servicios Autorizados:**
   * No todos los odontólogos realizan todos los procedimientos. Un odontólogo puede ser especialista en ortodoncia, otro en endodoncia, etc.
   * El Administrador marca qué servicios puede atender cada médico en la tabla relacional `Usuario_Servicio` (`Disponibilidad = 1`).
3. **Validación Automática en Tiempo Real al Reservar:**
   * Cuando un paciente reserva por la web o la secretaria programa una cita presencial, al seleccionar el servicio, la fecha y la hora, el sistema invoca `obtenerMedicosPorServicioYDisponibilidad`.
   * El sistema verifica:
     1. Que el odontólogo esté asignado al servicio seleccionado (`Usuario_Servicio`).
     2. Que trabaje en el día de la semana correspondiente (`Usuario_Horario` y `Horario`).
     3. Que no tenga otra cita confirmada o pendiente en ese mismo bloque horario (`Cita`).
   * Solo si cumple estas tres condiciones, el médico aparece en la lista de opciones para la cita.

---

## 3. Proceso Paso a Paso para el Usuario

### Paso 1: Acceso a la Gestión de Disponibilidad
1. Iniciar sesión como **Administrador** (DNI `48223344` / Clave `123`).
2. En la barra lateral izquierda, hacer clic en **"Disponibilidad"** (o desde la tabla de usuarios, hacer clic en el botón **"Disponibilidad"** junto a un odontólogo).

### Paso 2: Seleccionar al Odontólogo
1. En el combo desplegable superior, seleccionar al médico a configurar (ej. *Dr(a). Ruben Cuadros*).
2. La página actualizará los datos del médico (DNI, correo) y marcará los horarios y servicios que tiene asignados actualmente.

### Paso 3: Asignar Días y Horarios de Atención
1. En el panel izquierdo (**Días y Horarios de Atención**), marcar o desmarcar los días en los que el médico estará de turno en el centro:
   * *Lunes (08:00 - 18:30)*
   * *Martes (08:00 - 18:30)*
   * *Miércoles (08:00 - 18:30)*
   * *Jueves (08:00 - 18:30)*
   * *Viernes (08:00 - 18:30)*

### Paso 4: Asignar Especialidades y Servicios
1. En el panel derecho (**Cartera de Servicios Autorizados**), marcar las casillas de verificación de los tratamientos clínicos que este médico está facultado a realizar:
   * *Limpieza Dental Profunda*
   * *Curación Dental con Resina*
   * *Ortodoncia*
   * *Blanqueamiento Dental*
   * *Extracción Dental / Cirugía*
   * *Prótesis Dental*
   * *Endodoncia*

### Paso 5: Guardar y Aplicar Cambios
1. Hacer clic en el botón azul **"Guardar Disponibilidad"**.
2. El sistema ejecutará una transacción segura en MySQL, actualizando las tablas `Usuario_Horario` y `Usuario_Servicio`.
3. Aparecerá un mensaje verde de confirmación: *"¡Disponibilidad actualizada exitosamente!"*.
4. A partir de ese instante, cualquier paciente que intente reservar solo verá disponible al odontólogo en los días y para los servicios seleccionados.

---

## 4. Reglas de Negocio e Integridad Técnica

1. **Tablas Involucradas:**
   * `Horario`: catálogo base de turnos (días y horas de operación).
   * `Usuario_Horario`: relación N:M entre `Usuario` y `Horario`.
   * `Usuario_Servicio`: relación N:M entre `Usuario` y `Servicio` con flag `Disponibilidad`.
2. **Procedimiento de Consulta:**
   * La consulta de validación de reservas une `usuario`, `Usuario_Servicio`, `Usuario_Horario`, `Horario` y `Cita` mediante subconsultas para prevenir solapamientos y citas cruzadas.

---

## 5. Evidencias de Verificación y Auditoría

* **Suite de Pruebas Automatizada:** Ejecución exitosa de `test_lote3_admin.py` (Paso 3).
* **Auditoría MySQL:** Verificación transaccional de inserción y borrado en `Usuario_Horario` y `Usuario_Servicio`.
* **Captura de Pantalla en Google Chrome:** Archivo `disponibilidad_admin_ui.png` generado mediante CDP en puerto 9222.
