# RNF08: Bloqueo de Cuenta por Intentos Fallidos

## 1. Ficha Técnica del Requerimiento

| Campo | Detalle |
| :--- | :--- |
| **Identificador** | RNF08 |
| **Nombre del Requerimiento** | Bloqueo Temporal de Cuenta por Intentos Fallidos |
| **Categoría** | No Funcional / Seguridad de Acceso |
| **Prioridad** | Alta |
| **Actores Involucrados** | Personal Administrativo (Secretaria, Odontólogo, Administrador) |
| **Estado en APF2** | **Nuevo (Sección 5.1):** Mecanismo de defensa contra ataques de fuerza bruta. Tras 5 intentos fallidos consecutivos, la cuenta se bloquea automáticamente durante 15 minutos exactos. |

---

## 2. Explicación en Lenguaje Sencillo

Para evitar que una persona o un programa automatizado intente adivinar la contraseña del personal probando combinaciones una y otra vez (ataque de fuerza bruta o diccionario), el sistema cuenta con un candado de seguridad:

1. **Contador de Oportunidades:** El usuario tiene hasta 5 oportunidades para escribir su contraseña correctamente. Si se equivoca, el sistema le muestra un mensaje claro indicándole cuántos intentos le quedan (por ejemplo: *"Le quedan 3 intentos antes del bloqueo"*).
2. **Bloqueo Automático por 15 Minutos:** Si llega al 5.° intento fallido consecutivo, la cuenta queda bloqueada de inmediato durante **15 minutos**.
3. **Denegación Total Durante el Bloqueo:** Mientras la cuenta permanezca bloqueada, el sistema no permitirá ingresar a nadie con ese DNI, **incluso si en ese momento escribe la contraseña correcta**. Esto protege al trabajador ante cualquier intruso que esté probando claves.
4. **Desbloqueo Automático:** Una vez transcurridos los 15 minutos, el sistema quita el bloqueo automáticamente y reinicia el contador de intentos a 0, permitiendo que el personal legítimo vuelva a ingresar sin necesidad de llamar a soporte técnico.

---

## 3. Guía Paso a Paso para Probar y Replicar el Bloqueo

Cualquier usuario o evaluador puede comprobar el funcionamiento del bloqueo en tiempo real:

### Paso 1: Ingresar Contraseñas Incorrectas
1. Abra el navegador web y vaya a: `http://localhost:8080/ArtDent/iniciosesion.jsp`.
2. Ingrese el DNI de una cuenta de prueba del personal (por ejemplo, `78223344`).
3. Ingrese una contraseña incorrecta y presione **INICIAR SESIÓN**.
4. Observe que la pantalla muestra la alerta en color corporativo indicando:
   > *"Usuario o contraseña incorrectos. Le quedan 4 intento(s) antes del bloqueo de cuenta."*
5. Repita este paso para los intentos 2, 3 y 4.

### Paso 2: Provocar el Bloqueo en el Quinto Intento
1. En el quinto intento, ingrese nuevamente una contraseña incorrecta y presione **INICIAR SESIÓN**.
2. El sistema detectará que se alcanzó el límite de 5 intentos y desplegará la pantalla de bloqueo con el ícono de candado rojo:
   > *"Cuenta Bloqueada Temporalmente: Ha superado los 5 intentos fallidos. Su cuenta ha sido bloqueada temporalmente por 15 minutos."*
3. Observe que el botón de **INICIAR SESIÓN** se inhabilita para prevenir envíos innecesarios.

### Paso 3: Comprobación de Seguridad en Bloqueo
1. Intente enviar el formulario ingresando ahora la contraseña correcta del usuario (`1234`).
2. El sistema rechazará la solicitud y mantendrá la alerta de bloqueo con el tiempo restante, demostrando que la seguridad activa prevalece sobre las credenciales.

### Paso 4: Desbloqueo y Acceso Normal
1. Una vez transcurridos los 15 minutos (o ejecutando el reinicio administrativo en base de datos), vuelva a ingresar con las credenciales correctas.
2. El sistema concederá el acceso de inmediato, dirigirá al usuario al módulo correspondiente a su rol y restablecerá el contador de intentos fallidos a 0.

---

## 4. Reglas de Negocio Validadas

- **RNF08-RN01:** El umbral de bloqueo es de exactamente 5 intentos fallidos consecutivos para el mismo número de documento (DNI).
- **RNF08-RN02:** El tiempo de penalización es de 15 minutos a partir del momento en que se produce el quinto error (`BloqueadoHasta = DATE_ADD(NOW(), INTERVAL 15 MINUTE)`).
- **RNF08-RN03:** Si el usuario ingresa su contraseña correcta en cualquier intento previo al quinto (por ejemplo, en el intento 3), el contador de intentos fallidos se restablece inmediatamente a 0.
- **RNF08-RN04:** El desbloqueo es automático y basado en el reloj del servidor MySQL (`NOW()`), evitando desfases de hora locales.

---

## 5. Evidencias Técnicas de Implementación

- **Base de Datos MySQL (`db_artdent_apf2`):** Columnas `IntentosFallidos` (`TINYINT`) y `BloqueadoHasta` (`DATETIME`) en la tabla `Usuario`.
- **Backend Java:** Lógica de evaluación y bloqueo en [`UsuarioDaoImpl.java`](file:///Users/christhianmeza/IdeaProjects/ArtDent/Sistema-Web-de-Citas-para-el-Centro-Odontologico-Art-Dent/src/main/java/pe/edu/utp/daoImpl/UsuarioDaoImpl.java) y [`InicioSesionController.java`](file:///Users/christhianmeza/IdeaProjects/ArtDent/Sistema-Web-de-Citas-para-el-Centro-Odontologico-Art-Dent/src/main/java/pe/edu/utp/controller/InicioSesionController.java).
- **Vistas JSP:** Pantalla de error con alerta dinámica de bloqueo en [`iniciosesionerror.jsp`](file:///Users/christhianmeza/IdeaProjects/ArtDent/Sistema-Web-de-Citas-para-el-Centro-Odontologico-Art-Dent/src/main/webapp/iniciosesionerror.jsp).
- **Prueba Automatizada:** Suite [`test_rnf_seguridad_bloqueo.py`](file:///Users/christhianmeza/IdeaProjects/ArtDent/Sistema-Web-de-Citas-para-el-Centro-Odontologico-Art-Dent/test_rnf_seguridad_bloqueo.py).
- **Evidencia Visual:** Captura de pantalla [`login_bloqueado_ui.png`](file:///Users/christhianmeza/IdeaProjects/ArtDent/Sistema-Web-de-Citas-para-el-Centro-Odontologico-Art-Dent/login_bloqueado_ui.png).
