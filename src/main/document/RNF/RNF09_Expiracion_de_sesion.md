# RNF09: Expiración e Invalidación de Sesión

## 1. Ficha Técnica del Requerimiento

| Campo | Detalle |
| :--- | :--- |
| **Identificador** | RNF09 |
| **Nombre del Requerimiento** | Control de Vida y Expiración de Sesión |
| **Categoría** | No Funcional / Seguridad de Sesiones |
| **Prioridad** | Alta |
| **Actores Involucrados** | Todo el Personal (Secretaria, Odontólogo, Administrador) |
| **Estado en APF2** | **Nuevo (Sección 5.5):** La sesión del usuario expira automáticamente tras 30 minutos continuos de inactividad o de manera inmediata al hacer clic en "Cerrar sesión". |

---

## 2. Explicación en Lenguaje Sencillo

Cuando un trabajador de la clínica dental inicia sesión en una computadora, el sistema mantiene activa su cuenta mientras esté trabajando. Sin embargo, para evitar que otra persona use su cuenta indebidamente si deja la computadora desatendida o se retira del consultorio, el sistema aplica dos reglas de seguridad:

1. **Cierre Automático por Inactividad (30 Minutos):** Si el usuario no realiza ninguna acción en el sistema durante 30 minutos (no hace clics ni cambia de página), el servidor destruye automáticamente la sesión. Al intentar hacer cualquier cosa posterior, el sistema le pedirá que vuelva a iniciar sesión.
2. **Cierre de Sesión Seguro e Instantáneo:** Cuando el trabajador hace clic en la opción **"Cerrar sesión"** del menú de usuario, el sistema no solo lo redirige a la página principal, sino que destruye por completo los permisos y datos temporales guardados en la memoria del servidor (`HttpSession.invalidate()`). Aunque alguien use el botón "Atrás" del navegador, no podrá ver información protegida ni realizar operaciones clínicas.

---

## 3. Guía Paso a Paso para Verificar la Expiración y Cierre de Sesión

### Paso 1: Cierre de Sesión Manual Seguro
1. Inicie sesión con cualquier rol del personal (por ejemplo, Administrador DNI `48223344`, clave `123`).
2. Una vez en el sistema, ubique en la barra superior o menú desplegable su nombre de usuario y haga clic en **"Cerrar sesión"**.
3. El sistema invocará al controlador `CerrarSesionController`, invalidará la sesión en el servidor y lo dirigirá limpiamente a `index.jsp`.
4. Intente regresar presionando el botón de retroceso del navegador o accediendo directamente a una URL administrativa protegida (como `http://localhost:8080/ArtDent/DashboardController?action=dashboard`).
5. Compruebe que el sistema no permite el acceso administrativo y requiere autenticarse nuevamente.

### Paso 2: Verificación del Tiempo Límite de Inactividad (30 Minutos)
1. Inicie sesión en el sistema.
2. Deje la pestaña sin interactuar durante más de 30 minutos.
3. Al transcurrir dicho tiempo, intente hacer clic en cualquier función clínica (como consultar agenda o aprobar reserva).
4. El contenedor web de Java (`Jetty`) habrá descartado la sesión expirada, requiriendo un nuevo inicio de sesión.

---

## 4. Reglas de Negocio Validadas

- **RNF09-RN01:** El tiempo máximo de inactividad de una sesión HTTP es de 30 minutos, configurado a nivel de descriptor de despliegue (`web.xml`).
- **RNF09-RN02:** Toda invocación a `CerrarSesionController` debe ejecutar `session.invalidate()` antes de cualquier redirección, eliminando cualquier atributo de usuario (`idUsuario`, `Nombre`, `TipoRol`, etc.).
- **RNF09-RN03:** Las vistas que requieren privilegios de acceso deben validar la existencia de la sesión activa en el servidor.

---

## 5. Evidencias Técnicas de Implementación

- **Configuración de Despliegue:** Parámetro `<session-config><session-timeout>30</session-timeout></session-config>` en [`src/main/webapp/WEB-INF/web.xml`](file:///Users/christhianmeza/IdeaProjects/ArtDent/Sistema-Web-de-Citas-para-el-Centro-Odontologico-Art-Dent/src/main/webapp/WEB-INF/web.xml).
- **Controlador de Salida:** Invalidación en [`CerrarSesionController.java`](file:///Users/christhianmeza/IdeaProjects/ArtDent/Sistema-Web-de-Citas-para-el-Centro-Odontologico-Art-Dent/src/main/java/pe/edu/utp/controller/CerrarSesionController.java).
- **Prueba Automatizada:** Suite [`test_rnf_seguridad_bloqueo.py`](file:///Users/christhianmeza/IdeaProjects/ArtDent/Sistema-Web-de-Citas-para-el-Centro-Odontologico-Art-Dent/test_rnf_seguridad_bloqueo.py) (Test 3 aprobado al 100%).
