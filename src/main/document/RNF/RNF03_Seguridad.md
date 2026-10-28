# RNF03: Seguridad de la Información y Protección de Datos

## 1. Ficha Técnica del Requerimiento

| Campo | Detalle |
| :--- | :--- |
| **Identificador** | RNF03 |
| **Nombre del Requerimiento** | Seguridad de la Información y Criptografía |
| **Categoría** | No Funcional / Seguridad y Privacidad |
| **Prioridad** | Alta |
| **Actores Involucrados** | Personal Administrativo, Odontólogos, Pacientes, Pasarela de Pago |
| **Estado en APF2** | **Modificado y Fortalecido:** Implementación de algoritmo BCrypt con salt, consultas 100% parametrizadas con `PreparedStatement`, estricto cumplimiento de la Ley N.° 29733 de Protección de Datos Personales, y procesamiento de pagos exclusivamente mediante pasarela externa segura. |

---

## 2. Explicación en Lenguaje Sencillo

Para garantizar que nadie pueda robar información confidencial ni acceder sin permiso al sistema de la clínica dental Art Dent, se han establecido cuatro niveles de protección digital de alto estándar:

1. **Contraseñas Indescifrables (BCrypt):** Las claves del personal (secretarias, médicos y administradores) nunca se guardan tal como se escriben. Se transforman usando una fórmula matemática avanzada llamada **BCrypt** que añade un código aleatorio único (llamado *salt*). Incluso si alguien tuviera acceso a la base de datos, no podría descifrar las contraseñas.
2. **Consultas Blindadas (`PreparedStatement`):** Cada vez que el sistema busca o guarda datos en MySQL, utiliza consultas preparadas con parámetros separados. Esto impide que ciberdelincuentes puedan inyectar comandos maliciosos para robar o borrar la base de datos (prevención total contra *SQL Injection*).
3. **Privacidad de los Pacientes (Ley N.° 29733):** Toda la información médica, citas, DNI, teléfono y correo electrónico de los pacientes se maneja bajo estrictos principios de confidencialidad médica y consentimiento informado, cumpliendo con la legislación peruana de protección de datos personales.
4. **Cero Almacenamiento de Tarjetas:** La clínica no guarda números de tarjeta de crédito, débito ni códigos CVV. Los pagos en línea son procesados directamente por la pasarela de pago certificada, evitando cualquier riesgo de clonación o fraude financiero.

---

## 3. Guía Paso a Paso para Verificar la Seguridad

Cualquier evaluador o auditor técnico puede comprobar estos controles siguiendo estos pasos:

### Paso 1: Verificación del Hash BCrypt en Base de Datos MySQL
1. Abra la terminal de MySQL y conéctese a la base de datos:
   ```bash
   mysql -u root -prootroot db_artdent_apf2
   ```
2. Consulte las contraseñas de la tabla `Usuario`:
   ```sql
   SELECT idUsuario, Nombre, DNI, Clave FROM Usuario WHERE DNI = '48223344';
   ```
3. Observe que la columna `Clave` inicia obligatoriamente con el prefijo `$2a$10$` o `$2b$10$` (formato estándar de BCrypt con 60 caracteres de longitud), demostrando que la contraseña ha sido encriptada con salt y no en texto legible ni en algoritmos obsoletos.

### Paso 2: Verificación de Consultas Parametrizadas (`PreparedStatement`)
1. Ingrese a la pantalla de inicio de sesión: `http://localhost:8080/ArtDent/iniciosesion.jsp`.
2. En el campo **Nro. de Documento**, intente ingresar una carga típica de inyección SQL: `' OR '1'='1`.
3. El sistema valida el formato numérico y, a nivel de backend, el `PreparedStatement` trata la cadena como texto literal sin alterar la estructura lógica de la consulta, denegando el acceso de forma segura sin arrojar errores de base de datos.

### Paso 3: Verificación de la Pasarela Externa de Pagos
1. Realice una reserva web como paciente en `http://localhost:8080/ArtDent/reservapersonal.jsp`.
2. En la pantalla de confirmación (`citareservada.jsp`), abra el modal de **Pagar en Línea Ahora**.
3. Observe que el formulario solicita datos de tarjeta para procesamiento en la pasarela segura, pero en la tabla `Pago` de MySQL únicamente se registra el método (`Tarjeta`), el monto y el código de transacción (`TXN-...`), asegurando que jamás se almacenen datos bancarios en el servidor local.

---

## 4. Reglas de Negocio y Estándares de Seguridad Validados

- **RNF03-RN01:** Toda nueva cuenta creada o actualizada desde el panel de administración debe encriptar la clave con `SecurityUtils.hashPassword()` utilizando BCrypt con factor de costo 10.
- **RNF03-RN02:** El sistema mantiene retrocompatibilidad transparente: si un usuario con clave heredada (SHA-256 o texto plano) inicia sesión con éxito, el sistema actualiza automáticamente su clave a BCrypt en MySQL sin interrumpir su experiencia de usuario.
- **RNF03-RN03:** El 100% de los accesos a datos en los DAOs (`CitaDao`, `UsuarioDao`, `PacienteDao`, `PagoDao`, etc.) deben ejecutarse a través de `PreparedStatement` o `CallableStatement`, quedando estrictamente prohibida la concatenación de variables en sentencias SQL.
- **RNF03-RN04:** Cumplimiento de la Ley N.° 29733: Los datos recolectados en el formulario web solo se destinan a la gestión de citas odontológicas y notificaciones oficiales del centro médico.

---

## 5. Evidencias Técnicas de Implementación

- **Criptografía:** Módulo [`SecurityUtils.java`](file:///Users/christhianmeza/IdeaProjects/ArtDent/Sistema-Web-de-Citas-para-el-Centro-Odontologico-Art-Dent/src/main/java/pe/edu/utp/utils/SecurityUtils.java) con métodos `hashPassword` (`BCrypt.hashpw`) y `verifyPassword` (`BCrypt.checkpw`).
- **Dependencia Maven:** Inclusión de `org.mindrot:jbcrypt:0.4` en [`pom.xml`](file:///Users/christhianmeza/IdeaProjects/ArtDent/Sistema-Web-de-Citas-para-el-Centro-Odontologico-Art-Dent/pom.xml).
- **Prueba Automatizada:** Suite [`test_rnf_seguridad_bloqueo.py`](file:///Users/christhianmeza/IdeaProjects/ArtDent/Sistema-Web-de-Citas-para-el-Centro-Odontologico-Art-Dent/test_rnf_seguridad_bloqueo.py) aprobada al 100%.
- **Evidencia Visual:** Captura de pantalla [`login_clean_ui.png`](file:///Users/christhianmeza/IdeaProjects/ArtDent/Sistema-Web-de-Citas-para-el-Centro-Odontologico-Art-Dent/login_clean_ui.png) con interfaz blindada y diseño corporativo.
