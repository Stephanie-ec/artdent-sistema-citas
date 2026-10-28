# Guía de Usuario y Documentación Funcional: RF17 - Gestión de Servicios y Precios

---

## 1. Ficha del Requerimiento

| Campo | Detalle |
| :--- | :--- |
| **Identificador** | **RF17** |
| **Nombre del Requerimiento** | Gestión de Servicios |
| **Prioridad** | **Media** |
| **Módulo** | Módulo de Administración de Catálogo y Tarifario Clínico |
| **Roles Autorizados** | **Administrador** |
| **Cambio en APF2** | **Nuevo:** Los servicios y precios se gestionan directamente desde el sistema por el Administrador. Un servicio desactivado (`Activo = 0`) deja de ofrecerse en nuevas reservas web o presenciales, pero se conserva íntegro en el historial y base de datos para preservar la trazabilidad clínica y contable. |

---

## 2. Descripción en Lenguaje Sencillo

Este requerimiento permite al Administrador del centro odontológico gestionar todo el catálogo de tratamientos y tarifas disponibles en ArtDent:

1. **Alta de Nuevos Servicios:**
   * El Administrador puede incorporar nuevos procedimientos odontológicos especificando: Tipo de servicio, Lema promocional, Descripción técnica del procedimiento, Respuesta informativa al paciente, Costo base en soles y URL de fotografía ilustrativa.
2. **Actualización de Precios y Detalles:**
   * Permite ajustar las tarifas vigentes o refinar las descripciones clínicas de cada servicio cuando sea necesario.
3. **Desactivación Segura (Soft Delete):**
   * En lugar de borrar físicamente el servicio de la base de datos (lo que rompería las citas pasadas, comprobantes de pago y boletas emitidas), el sistema marca el servicio como inactivo (`Activo = 0`).
   * Al estar desactivado, el procedimiento ya no aparece en el combo desplegable de reservas para pacientes ni para la secretaria.
4. **Reactivación Inmediata:**
   * El Administrador puede volver a habilitar cualquier servicio previamente desactivado con un solo clic (`Activo = 1`).

---

## 3. Proceso Paso a Paso para el Usuario

### Paso 1: Acceso al Módulo de Servicios
1. Iniciar sesión como **Administrador** (DNI `48223344` / Clave `123`).
2. En la barra lateral izquierda, hacer clic en la opción **"Servicios"**.
3. Se desplegará la tabla completa de servicios con sus identificadores, nombres, lemas, costos base en soles y estado (`Activo` en verde / `Inactivo` en gris).

### Paso 2: Crear un Nuevo Servicio
1. En la parte superior derecha de la tabla, hacer clic en **"Nuevo Servicio"**.
2. Se abrirá una ventana modal solicitando:
   * **Tipo de Servicio:** Nombre clínico (ej. *Ortodoncia Invisible con Alineadores*).
   * **Lema:** Frase destacada para el paciente (ej. *Alinea tu sonrisa discretamente*).
   * **Descripción:** Detalle clínico del procedimiento.
   * **Respuesta:** Información para orientación al paciente.
   * **Costo:** Monto base en soles (ej. `250.00`).
   * **URL de Imagen:** Enlace a fotografía referencial.
3. Hacer clic en **"Guardar Servicio"**. El servicio quedará creado con estado **Activo** y disponible de inmediato en las opciones de reserva.

### Paso 3: Modificar un Servicio Existente
1. En la fila del servicio deseado, hacer clic en el botón azul **"Editar"** con icono de lápiz.
2. Modificar el precio, descripción o información del servicio.
3. Hacer clic en **"Actualizar Servicio"** para guardar los cambios.

### Paso 4: Desactivar o Reactivar un Servicio
1. **Para Desactivar:** En la fila de un servicio activo, hacer clic en el botón naranja **"Desactivar"**.
   * El sistema solicitará confirmación: *"¿Desactivar este servicio? Dejará de ofrecerse en nuevas reservas pero se conserva en el historial (RF17)"*.
   * Al aceptar, el estado cambiará a **Inactivo** y la fila se atenuará.
2. **Para Reactivar:** En un servicio con estado inactivo, el botón cambiará automáticamente a verde **"Reactivar"**. Al presionarlo, el servicio vuelve a habilitarse para reservas.

---

## 4. Reglas de Negocio e Integridad Técnica

1. **Persistencia y Trazabilidad:**
   * La tabla `Servicio` contiene la columna `Activo tinyint(1) NOT NULL DEFAULT 1`.
   * El procedimiento almacenado `sp_eliminarServicio` ejecuta `UPDATE Servicio SET Activo = 0 WHERE idServicio = ?`.
   * El procedimiento `sp_listarservicios` ejecuta `SELECT * FROM Servicio WHERE Activo = 1`, garantizando que las páginas públicas nunca ofrezcan procedimientos no disponibles.
2. **Seguridad y Roles:**
   * Solo el rol **Administrador** tiene permiso para crear, actualizar, desactivar o reactivar servicios.
   * Si una sesión de otro rol intenta invocar `ServicioController?action=delete`, la operación es rechazada.

---

## 5. Evidencias de Verificación y Auditoría

* **Suite de Pruebas Automatizada:** Ejecución exitosa de `test_lote3_admin.py` (Paso 1).
* **Auditoría MySQL (`db_artdent_apf2`):** Verificación de cambio de estado `Activo = 0` y `Activo = 1` en tabla `Servicio`.
* **Captura de Pantalla en Google Chrome:** Archivo `servicios_admin_ui.png` generado mediante CDP en puerto 9222.
