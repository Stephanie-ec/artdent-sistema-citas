# Guía de Usuario y Documentación Funcional: RF05 - Gestión de Pacientes

---

## 1. Ficha del Requerimiento

| Campo | Detalle |
| :--- | :--- |
| **Identificador** | **RF05** |
| **Nombre del Requerimiento** | Gestión de pacientes |
| **Prioridad** | **Media** |
| **Módulo** | Módulo de Pacientes y Consulta de Historial Clínico |
| **Roles Autorizados** | **Secretaria** (Registro y actualización de datos de pacientes), **Odontólogo** (Consulta de pacientes e historial de citas en modo solo lectura), **Administrador** (Supervisión) |
| **Cambio en APF2** | **Modificado:** La gestión administrativa de pacientes (registro y actualización de datos de filiación y contacto) es competencia exclusiva de la **Secretaría**. El **Odontólogo** y la **Secretaría** consultan el historial de citas de los pacientes, pero el odontólogo no tiene permisos de edición. |

---

## 2. Descripción en Lenguaje Sencillo

Este requerimiento garantiza que la clínica mantenga un directorio fidedigno y centralizado de todos sus pacientes, regulando quién puede modificar información y quién puede consultarla:

1. **Registro Centralizado de Pacientes:** La Secretaria puede inscribir nuevos pacientes que acuden a la clínica o que solicitan atención presencial, capturando su DNI, nombres completos, teléfono y correo electrónico.
2. **Actualización de Datos de Contacto:** Cuando un paciente cambia de número celular o correo electrónico, la Secretaria puede actualizar su información de manera inmediata mediante un formulario modal, asegurando que las notificaciones (RF09) y recordatorios lleguen correctamente.
3. **Control de Acceso Clínico vs. Administrativo:**
   * La **Secretaría** dispone de botones para editar y registrar pacientes.
   * El **Odontólogo** tiene acceso de consulta a la lista de pacientes y sus datos básicos, pero los botones de edición están deshabilitados/ocultos para su rol, garantizando la integridad de los datos de filiación.
4. **Consulta de Historial de Citas por Paciente:** Tanto la Secretaría como el Odontólogo pueden hacer clic en el botón **"Historial"** de cualquier paciente para revisar todas las atenciones previas, diagnósticos y servicios recibidos por dicha persona a lo largo del tiempo.

---

## 3. Proceso Paso a Paso para el Usuario

### Flujo 1: Secretaría - Registrar un Nuevo Paciente

1. **Iniciar Sesión:**
   * Ingresar al sistema con credenciales de Secretaria (DNI: `78223344`, Clave: `1234`).
2. **Acceder al Módulo de Pacientes:**
   * En la barra lateral izquierda, hacer clic en la opción **"Pacientes"** (o navegar a `PacienteController?action=list`).
3. **Abrir Modal de Registro:**
   * En la esquina superior derecha, presionar el botón verde **"+ Registrar Nuevo Paciente"**.
4. **Ingresar Información:**
   * **DNI:** Ingresar el documento nacional de identidad (8 dígitos numéricos).
   * **Nombres:** Nombres del paciente (ej. *María Elena*).
   * **Apellidos:** Apellidos completos (ej. *Ramos Delgado*).
   * **Teléfono / Celular:** Número de 9 dígitos.
   * **Correo Electrónico:** Dirección de correo activa.
5. **Guardar Paciente:**
   * Presionar **"Guardar Paciente"**. El sistema valida que el DNI no esté duplicado, inserta el registro en la base de datos y actualiza la tabla con un mensaje de éxito.

---

### Flujo 2: Secretaría - Actualizar Datos de un Paciente

1. **Buscar al Paciente:**
   * En la barra de búsqueda superior, escribir el DNI o apellido del paciente y presionar **"Buscar"**.
2. **Abrir Edición:**
   * En la columna de *Acciones* de la fila del paciente, presionar el botón azul **"Editar"** (`bi-pencil-square`).
3. **Modificar Información:**
   * El sistema precarga los datos actuales en una ventana modal.
   * Modificar el teléfono, correo electrónico o nombres según lo solicitado por el paciente.
4. **Guardar Cambios:**
   * Presionar el botón **"Guardar Cambios"**.
   * El sistema ejecuta la actualización en la tabla `Paciente` de MySQL y recarga la vista mostrando los datos actualizados.

---

### Flujo 3: Odontólogo - Consultar Historial de Citas de un Paciente (Solo Lectura)

1. **Iniciar Sesión:**
   * Ingresar con credenciales de Odontólogo (DNI: `70096374`, Clave: `1234`).
2. **Acceder a Pacientes:**
   * Hacer clic en **"Pacientes"** en el menú lateral.
   * Notar que el perfil se identifica como *Perfil clínico (Odontólogo)* y no se muestran los botones de registrar ni de editar.
3. **Ver Historial Clínico:**
   * En la fila del paciente que se desea evaluar, hacer clic en el botón celeste **"Historial"** (`bi-clock-history`).
   * El sistema redirige al módulo de historial filtrando exclusivamente las citas correspondientes a dicho paciente, permitiendo ver fechas pasadas, servicios realizados y estados de atención.

---

## 4. Reglas de Negocio y Control de Integridad

* **RN-PAC-01 (Unicidad de DNI):** No se permite duplicar el número de DNI en la tabla `Paciente`. Si el DNI ya existe, el sistema previene la duplicidad y solicita actualizar el registro existente.
* **RN-PAC-02 (Segregación de Funciones):** La edición y creación de fichas de pacientes está restringida a los roles administrativos (`Secretaria` y `Administrador`). El rol asistencial (`Odontologo`) solo posee privilegios de lectura y consulta de historial.
* **RN-PAC-03 (Filtro por Paciente):** Al invocar la consulta de historial desde la fila de un paciente, el sistema envía el parámetro `pacienteNom` al controlador para filtrar sus atenciones pasadas de forma personalizada.

---

## 5. Auditoría y Evidencia Técnica en Base de Datos (MySQL)

### Tabla Afectada: `Paciente`

```sql
DESCRIBE db_artdent_apf2.Paciente;
```

| Campo | Tipo | Nulo | Clave | Predeterminado |
| :--- | :--- | :--- | :--- | :--- |
| `idPaciente` | int | NO | PRI | auto_increment |
| `Nombre` | varchar(50) | NO | | NULL |
| `Apellido` | varchar(50) | NO | | NULL |
| `DNI` | char(8) | NO | UNI | NULL |
| `Telefono` | char(9) | NO | | NULL |
| `Correo` | varchar(100) | NO | | NULL |

### Verificación de Actualización Realizada en Pruebas QA:

```sql
SELECT idPaciente, DNI, Nombre, Apellido, Telefono, Correo 
FROM db_artdent_apf2.Paciente 
WHERE idPaciente = 1;
```

**Resultado obtenido:**
```
+------------+----------+----------------+---------------+-----------+-----------------------------+
| idPaciente | DNI      | Nombre         | Apellido      | Telefono  | Correo                      |
+------------+----------+----------------+---------------+-----------+-----------------------------+
|          1 | 48915516 | Carlos Alberto | Meza QA       | 998877665 | paciente_rf05_qa@artdent.com|
+------------+----------+----------------+---------------+-----------+-----------------------------+
```

### Script de Prueba Automatizada:
El requerimiento cuenta con verificación continua en el script `test_lote1_clinico.py`, comprobando el aislamiento de permisos por rol, actualización en base de datos y consulta de historial con 100% de éxito.
