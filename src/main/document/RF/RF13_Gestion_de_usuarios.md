# Guía de Usuario y Documentación Funcional: RF13 - Gestión de Cuentas de Personal

---

## 1. Ficha del Requerimiento

| Campo | Detalle |
| :--- | :--- |
| **Identificador** | **RF13** |
| **Nombre del Requerimiento** | Gestión de Usuarios del Personal |
| **Prioridad** | **Alta** |
| **Módulo** | Módulo de Seguridad y Administración de Personal |
| **Roles Autorizados** | **Administrador** |
| **Cambio en APF2** | **Nuevo:** El Administrador crea, actualiza, elimina y visualiza las cuentas de todo el personal (Secretaria, Odontólogo, Administrador). **No existe autorregistro** para garantizar la seguridad clínica del centro. |

---

## 2. Descripción en Lenguaje Sencillo

Este requerimiento centraliza el control de acceso y gestión del talento humano en ArtDent:

1. **Sin Autorregistro Público:**
   * Ningún usuario externo puede crear cuentas con privilegios administrativos o clínicos desde la web pública. Todas las cuentas del personal son dadas de alta por el Administrador.
2. **Tres Roles Diferenciados:**
   * **Administrador (Rol 1):** Gestión integral de usuarios, tarifas, horarios, disponibilidad y reportes económicos.
   * **Secretaria (Rol 2):** Gestión de reservas web, citas presenciales, cobro en efectivo y emisión de boletas.
   * **Odontólogo (Rol 3):** Visualización de agenda médica semanal, consulta de pacientes y cierre/finalización de citas atendidas.
3. **Criptografía Robusta (SHA-256):**
   * Las contraseñas se almacenan mediante hash criptográfico SHA-256 en la columna `Clave VARCHAR(255)` de la tabla `Usuario`.
   * Al editar un usuario, si el campo de contraseña se deja vacío, el sistema conserva intacta la clave anterior sin alterarla.
4. **Eliminación en Cascada Controlada:**
   * Al dar de baja un usuario, el procedimiento almacenado `sp_eliminarUsuario` limpia de forma consistente comprobantes, pagos, notificaciones y citas asociadas para evitar inconsistencias relacionales.

---

## 3. Proceso Paso a Paso para el Usuario

### Paso 1: Acceso a la Gestión de Usuarios
1. Iniciar sesión como **Administrador** (DNI `48223344` / Clave `123`).
2. En el menú lateral izquierdo, seleccionar **"Usuarios"**.
3. Se mostrará el directorio del personal con sus datos: ID, DNI, Nombre completo, Teléfono, Correo, Rol y Acciones.

### Paso 2: Registrar un Nuevo Empleado
1. En la parte superior de la página, hacer clic en el botón azul **"Agregar Usuario"**.
2. Completar el formulario con los datos requeridos:
   * **Nombre y Apellido:** Datos personales completos.
   * **DNI:** Documento Nacional de Identidad de 8 dígitos.
   * **Teléfono:** Celular de contacto de 9 dígitos.
   * **Email:** Correo institucional o personal.
   * **Dirección:** Residencia del colaborador.
   * **Fecha de Nacimiento:** En formato fecha.
   * **Rol:** Seleccionar del combo desplegable: *Administrador*, *Secretaria* u *Odontólogo*.
   * **Contraseña:** Clave de acceso inicial para el colaborador.
3. Hacer clic en **"Guardar Usuario"**. La contraseña se encriptará en SHA-256 y el usuario podrá iniciar sesión de inmediato según su rol (RF15).

### Paso 3: Editar Datos de un Colaborador
1. En la tabla de usuarios, localizar al colaborador y hacer clic en el botón azul **"Editar"** (icono de lápiz).
2. Se cargarán todos los datos en el formulario de edición.
3. Se pueden modificar teléfono, correo, dirección, rol, o nombre.
4. *Nota sobre la contraseña:* Si el colaborador no desea cambiar su contraseña, el campo de contraseña se deja en blanco y el sistema preservará su clave actual. Si se ingresa un nuevo texto, se hasheará automáticamente.
5. Hacer clic en **"Actualizar Usuario"**.

### Paso 4: Eliminar una Cuenta
1. Hacer clic en el botón rojo de papelera en la fila del colaborador.
2. Confirmar la alerta de seguridad: *"¿Está seguro de que desea eliminar este usuario?"*.
3. La cuenta será dada de baja y su acceso revocado inmediatamente.

---

## 4. Reglas de Negocio e Integridad Técnica

1. **Procedimientos Almacenados:**
   * Inserción: `sp_insertarUsuario(Nombre, Apellido, DNI, Telefono, Correo, Direccion, FechaNacimiento, Clave, Rol)`.
   * Actualización: `sp_actualizarUsuario(idUsuario, Nombre, Apellido, DNI, Telefono, Correo, Direccion, FechaNacimiento, Clave, Rol)`.
   * Eliminación: `sp_eliminarUsuario(idUsuario)`.
   * Listado: `sp_listarUsuarios()`.
2. **Seguridad:**
   * La clase `pe.edu.utp.utils.SecurityUtils.hashPassword` genera un hash SHA-256 hexadecimal seguro antes de enviar la clave a la base de datos.

---

## 5. Evidencias de Verificación y Auditoría

* **Suite de Pruebas Automatizada:** Ejecución exitosa de `test_lote3_admin.py` (Paso 2).
* **Auditoría MySQL:** Creación, validación de hash SHA-256, actualización sin pérdida de hash y eliminación en tabla `Usuario`.
* **Captura de Pantalla en Google Chrome:** Archivo `usuarios_admin_ui.png` generado mediante CDP en puerto 9222.
