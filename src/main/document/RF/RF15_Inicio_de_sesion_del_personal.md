# Guía de Usuario y Documentación Funcional: RF15 - Inicio de Sesión del Personal

---

## 1. Ficha del Requerimiento

| Campo | Detalle |
| :--- | :--- |
| **Identificador** | **RF15** |
| **Nombre del Requerimiento** | Inicio de sesión del personal |
| **Prioridad** | **Alta** |
| **Módulo** | Módulo de Autenticación, Control de Acceso y Redirección por Rol |
| **Roles Autorizados** | **Secretaria**, **Odontólogo**, **Administrador** |
| **Cambio en APF2** | **Nuevo:** El inicio de sesión del personal no contaba con requerimiento formal propio en APF1. En APF2 se formaliza como requerimiento de alta prioridad, exigiendo autenticación mediante DNI y Contraseña (con cifrado SHA-256), asignación de variables de sesión y redirección inteligente al módulo operativo correspondiente a cada rol. No existe autorregistro de usuarios (ver RF13). |

---

## 2. Descripción en Lenguaje Sencillo

Este requerimiento constituye la puerta de entrada segura y controlada al sistema ArtDent para todos los colaboradores de la institución:

1. **Autenticación Unificada por DNI:** En lugar de utilizar nombres de usuario complejos o correos difíciles de recordar, todo el personal ingresa utilizando su número de DNI de 8 dígitos y su contraseña asignada.
2. **Cifrado Seguro de Contraseñas (SHA-256):** Las contraseñas del personal se procesan con funciones criptográficas unidireccionales (SHA-256). El sistema soporta compatibilidad hacia atrás con migración automática y transparente de contraseñas legadas.
3. **Redirección Inmediata según el Rol del Usuario:**
   * **Secretaria:** Redirigida directamente a **Solicitudes y Gestión de Citas** (`ReservaController?accion=listar`), donde revisa solicitudes web, registra citas presenciales y atiende a los pacientes que llegan al centro.
   * **Odontólogo:** Redirigido automáticamente a su **Agenda Semanal Personalizada** (`ReservaController?accion=listarReservasPorDia`), visualizando inmediatamente el cronograma de pacientes y tratamientos de su turno de la semana actual.
   * **Administrador:** Redirigido al **Panel de Administración y Métricas** (`DashboardController?action=dashboard`), donde supervisa los indicadores de desempeño, citas e ingresos.
4. **Manejo Seguro de Sesión:** Al autenticarse, el sistema guarda en la sesión HTTP los atributos del usuario (`idUsuario`, `Nombre`, `Apellido`, `Dni`, `TipoRol`), utilizándolos como barrera para la autorización en cada vista y servlet.

---

## 3. Proceso Paso a Paso para el Usuario

### Flujo de Acceso al Sistema

1. **Ingresar a la Pantalla de Login:**
   * Abrir el navegador Google Chrome e ingresar a la URL: `http://localhost:8080/ArtDent/iniciosesion.jsp`.
2. **Introducir Credenciales:**
   * **Nro de Documento:** Digitar el DNI de 8 dígitos.
   * **Contraseña:** Digitar la clave de acceso.
3. **Presionar "Iniciar Sesión":**
   * Hacer clic en el botón azul **"INICIAR SESIÓN"**.
4. **Verificación de Redirección según Perfil:**

#### Caso A: Acceso como Secretaria (DNI: `78223344`)
* **Destino:** Se carga inmediatamente la vista `PDCSolicitudes.jsp` a través de `ReservaController?accion=listar`.
* **Identificación:** En la barra superior se muestra el avatar con el nombre `Ethelvina Georgina` y el menú lateral con opciones de recepción: *Solicitudes*, *Calendario de citas*, *Historial*, *Notificaciones*, *Pacientes* y *Cita Presencial*.

#### Caso B: Acceso como Odontólogo (DNI: `70096374`)
* **Destino:** Se carga inmediatamente la vista `PDCCalendario.jsp` a través de `ReservaController?accion=listarReservasPorDia`.
* **Identificación:** En la parte superior se despliega la insignia `Dr(a). Ruben Cuadros • Odontología` con el cronograma semanal de sus citas asignadas.

#### Caso C: Acceso como Administrador (DNI: `48223344`)
* **Destino:** Se carga la vista general de métricas `PDCInicio.jsp` mediante `DashboardController?action=dashboard`.
* **Identificación:** Despliega el resumen de citas totales, reservas recientes e ingresos acumulados del centro odontológico.

---

## 4. Reglas de Negocio y Control de Integridad

* **RN-SEC-01 (Credenciales Inválidas):** Si el DNI no existe o la contraseña no coincide, el sistema redirige a `iniciosesionerror.jsp`, informando al usuario en color rojo: *"Usuario y/o contraseña incorrectos"*.
* **RN-SEC-02 (Aislamiento de Menú y Vistas):** Las opciones del menú lateral (`Sidebar.jsp`) y las acciones permitidas en los formularios se condicionan estrictamente al atributo `session.getAttribute("TipoRol")`.
* **RN-SEC-03 (No Autorregistro):** No existen formularios públicos de registro para personal. Todas las cuentas son provisionadas exclusivamente por el Administrador (RF13).

---

## 5. Auditoría y Evidencia Técnica en Base de Datos (MySQL)

### Tablas Involucradas: `Usuario` y `Rol`

```sql
SELECT u.idUsuario, u.DNI, u.Nombre, u.Apellido, r.TipoRol 
FROM db_artdent_apf2.Usuario u 
INNER JOIN db_artdent_apf2.Rol r ON u.Rol_idRol = r.idRol;
```

**Resultado de cuentas del personal auditadas:**
```
+-----------+----------+--------------------+------------------+---------------+
| idUsuario | DNI      | Nombre             | Apellido         | TipoRol       |
+-----------+----------+--------------------+------------------+---------------+
|         1 | 48223344 | Juan David         | Fernández Gomez  | Administrador |
|         2 | 78223344 | Ethelvina Georgina | Soto Vergara     | Secretaria    |
|         4 | 70096374 | Ruben              | Cuadros          | Odontologo    |
+-----------+----------+--------------------+------------------+---------------+
```

### Procedimiento Almacenado de Autenticación:
```sql
CREATE PROCEDURE `sp_iniciosesion`(IN i_DNI VARCHAR(100), IN i_clave VARCHAR(255))
BEGIN
  SELECT u.idUsuario, u.Nombre, u.Apellido, u.DNI, r.TipoRol 
  FROM Usuario u 
  INNER JOIN Rol r ON u.Rol_idRol = r.idRol 
  WHERE u.DNI = i_DNI AND u.Clave = i_clave;
END;
```

### Automatización de Pruebas:
Validado al 100% en `test_lote1_clinico.py` con verificación de sesiones HTTP y redirección automática para cada uno de los tres roles del sistema.
