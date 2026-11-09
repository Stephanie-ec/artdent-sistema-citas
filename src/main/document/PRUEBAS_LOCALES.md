# ArtDent: probar la etapa F-08 en otra PC

> Registro histórico de la primera etapa. Para la versión actual completa, sigue
> [PRUEBAS_PLAN_COMPLETO.md](PRUEBAS_PLAN_COMPLETO.md).

Ejecuta los comandos en PowerShell, dentro de la carpeta que contiene `pom.xml`.
Copia el proyecto completo; no es necesario copiar `target` ni los programas
portátiles usados para verificarlo. Esta etapa valida fechas de nuevas citas
en `CitaController`; las demás fallas del plan siguen pendientes.

## 1. Comprobación sin MySQL

Necesitas JDK 17 y Maven 3.9.x en la otra PC. Si usas sus ZIP portátiles, basta
configurar `JAVA_HOME` y agregar sus carpetas `bin` al PATH de esa terminal.
No uses solo un JRE. Aunque el POM declara source 1.8, el chatbot existente usa
`java.net.http`, que requiere Java 11 o superior; el CI del proyecto usa 17.

```powershell
java -version
javac -version
mvn -version
mvn -B clean package
```

Resultado esperado: `BUILD SUCCESS`, 18 pruebas, 0 fallos, 0 errores y 0 omitidas.
El WAR queda en `target/ArtDent-1.0-SNAPSHOT.war`. Maven necesita Internet la
primera vez para descargar las dependencias. Estas pruebas no necesitan
MySQL, credenciales, RENIEC, SMTP ni un navegador.

Para ejecutar únicamente las pruebas de esta etapa:

```powershell
mvn -B '-Dtest=ValidadorFechaTest,CitaFechaTest' test
```

## 2. Base de datos de prueba

Solo para probar la aplicación completa: usa MySQL 8.0 en la otra PC, en una
instancia de pruebas sin datos que necesites conservar. **El SQL existente
empieza con `DROP DATABASE IF EXISTS db_artdent_apf2`: elimina esa base si existe.**
No lo ejecutes sobre una instalación con información real. Esta etapa no
requiere migraciones y no incluye todavía el delta de las etapas siguientes.

En el cliente de MySQL:

```powershell
mysql --default-character-set=utf8mb4 -u root -p
```

Dentro del cliente, usa la ruta real del proyecto con barras `/`:

```sql
SOURCE C:/ruta/artdent-sistema-citas-main/src/main/java/pe/edu/utp/bd/db_artdent_apf2_completo.sql;
USE db_artdent_apf2;
SHOW TABLES;
```

El nombre correcto de la base de este script es `db_artdent_apf2`, aunque el
ejemplo de configuración existente dice `db_artdent`.

```powershell
Copy-Item src/main/resources/config.properties.example src/main/resources/config.properties
notepad src/main/resources/config.properties
```

Edita estos valores con tus credenciales locales:

```properties
db.url=jdbc:mysql://localhost:3306/db_artdent_apf2?serverTimezone=America/Lima&useUnicode=true&characterEncoding=UTF-8
db.user=root
db.password=TU_CLAVE_LOCAL
reniec.api.token=
```

`config.properties` está excluido de Git. Deja vacío el token RENIEC para no
consultar al proveedor durante las pruebas locales. No necesitas configurar
Gemini ni SMTP para probar F-08. Los flujos que envían correos sí pueden
reportar problemas de envío si SMTP no está configurado.

## 3. Iniciar el sitio

Desde la raíz del proyecto:

```powershell
mvn jetty:run
```

Espera el mensaje de inicio del servidor y abre
[ArtDent local](http://localhost:8080/ArtDent/).
Conserva esa terminal abierta. Para detenerlo, pulsa Ctrl+C.

Si el puerto 8080 está ocupado:

```powershell
mvn '-Djetty.http.port=8081' jetty:run
```

En ese caso usa `http://localhost:8081/ArtDent/` en el navegador y las pruebas.
No es necesario desplegar el WAR además de ejecutar Jetty.

Las credenciales de demostración del SQL son administrador `48223344` / `123`,
secretaría `78223344` / `1234` y odontólogo `70096374` / `1234`. Son solo para
esta base de pruebas. El odontólogo de ejemplo tiene horario de lunes a viernes.

## 4. Probar F-08 por HTTP real

En una segunda terminal, desde la raíz del proyecto:

```powershell
./scripts/probar-f08-http.ps1
```

O para el puerto alternativo:

```powershell
./scripts/probar-f08-http.ps1 -BaseUrl 'http://localhost:8081/ArtDent'
```

Espera cuatro líneas `OK`: fecha pasada, domingo, fecha imposible y hora
imposible deben devolver HTTP 400 con un aviso. El script no sigue redirecciones:
una redirección al login no cuenta como una validación correcta. Si Windows
bloquea scripts por una política de tu organización, respétala y usa la prueba
manual del punto siguiente; no necesitas cambiar esa política para compilar.

Para comprobar que esos cuatro intentos no escribieron citas, ejecuta en MySQL
antes y después, sin que otras personas usen la instancia durante la prueba:

```sql
SELECT COUNT(*) AS total_citas FROM db_artdent_apf2.Cita;
```

El conteo debe permanecer igual. La prueba HTTP y este conteo quedan pendientes
de ejecución en la PC que tenga el servidor; no se ejecutaron en la PC original.

## 5. Prueba manual

1. Abre la reserva pública desde el catálogo de servicios.
2. Completa nombres, DNI, celular y correo válidos de un paciente de prueba.
3. Intenta enviar una fecha pasada o un domingo. Si el navegador lo bloquea,
   modifica temporalmente el campo con las herramientas del navegador para
   comprobar también el rechazo del servidor, o usa el script HTTP anterior.
4. Para la hora pasada del día actual, usa un día de lunes a sábado: fija una
   hora anterior a la actual en Lima. Espera HTTP 400 y aviso de fecha/hora pasada.
5. Prueba una fecha futura de lunes a viernes con un odontólogo y servicio
   disponibles; la reserva debe avanzar y aparecer en Solicitudes.

Los casos válidos dependen de MySQL y del horario del odontólogo. Una prueba
unitaria que acepta una fecha futura no demuestra que el registro en BD funcione.

## 6. Si algo falla

| Síntoma | Revisar |
|---|---|
| `mvn` o `javac` no reconocidos | JDK 17, Maven y PATH de esa terminal. |
| Falla al descargar dependencias | Conexión a Maven Central o proxy de la PC. |
| `Unknown database` | Debe existir `db_artdent_apf2` y coincidir en la URL JDBC. |
| `Access denied` | Usuario y clave MySQL en el archivo local de configuración. |
| HTTP 404 en las pruebas | Puerto y ruta `/ArtDent`; esperar el inicio de Jetty. |
| HTTP 500 | Revisar la excepción de la consola; no contarlo como rechazo válido. |
| No hay odontólogo disponible | Horario, servicio asignado y citas existentes; distinto de F-08. |

Referencias: [Maven](https://maven.apache.org/guides/getting-started/maven-in-five-minutes.html),
[MySQL: ejecutar un archivo SQL](https://dev.mysql.com/doc/refman/8.0/en/mysql-batch-commands.html),
[JDK portátil oficial](https://learn.microsoft.com/en-us/java/openjdk/download).
