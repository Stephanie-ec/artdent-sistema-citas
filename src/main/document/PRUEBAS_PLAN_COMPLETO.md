# Probar ArtDent en otra PC

Guía del código actual, 7 de noviembre de 2026 (America/Lima).
Ver `CIERRE_PENDIENTES.md` para cobertura, bloqueos y límites de la auditoría.
Ejecute desde la carpeta que contiene `pom.xml`. Use datos de laboratorio.

## 1. Herramientas y primera prueba sin MySQL

Se verificó con JDK 17, Maven 3.9.9 y MySQL 8.0.44. Node es opcional para las
pruebas JS. JDK y Maven pueden extraerse desde ZIP a una carpeta del usuario;
configure JAVA_HOME y el PATH solo en su terminal. No cambie políticas del equipo.

```powershell
java -version
javac -version
mvn -version
mvn -B clean package
node --test scripts/test-ui-segura.cjs
mvn -B org.eclipse.jetty:jetty-jspc-maven-plugin:9.4.51.v20230217:jspc
```

Esperado: 55 pruebas unitarias, cinco JS, compilación de los JSP sin errores.
Node solo es necesario para el comando JS. El WAR es `target/ArtDent-1.0-SNAPSHOT.war`.
Estas pruebas no levantan el sitio ni prueban el correo externo/Gmail, RENIEC, Gemini o un banco.
No ejecute dos procesos Maven a la vez sobre la misma carpeta `target`.

## 2. Preparar MySQL

**Instalación nueva:** el canónico elimina y recrea `db_artdent_apf2`. Úselo en una
instancia de laboratorio sin datos que deba conservar. Abra el cliente:

```powershell
mysql --default-character-set=utf8mb4 -h 127.0.0.1 -P 3306 -u root -p
```

Dentro de MySQL, cambie la ruta por la de esta copia (barras `/`):

```sql
SOURCE C:/ruta/artdent-sistema-citas-main/src/main/java/pe/edu/utp/bd/db_artdent_apf2_completo.sql;
USE db_artdent_apf2;
SHOW TABLES;
SHOW CREATE TABLE SolicitudPago;
SHOW CREATE TABLE Atencion;
```

**Actualización con datos:** detenga la aplicación y haga respaldo antes del delta:

```powershell
mysqldump -h 127.0.0.1 -P 3306 -u root -p --routines --triggers --single-transaction --result-file=artdent-respaldo.sql db_artdent_apf2
```

Después, en el cliente MySQL, aplique únicamente:

```sql
USE db_artdent_apf2;
SOURCE C:/ruta/artdent-sistema-citas-main/src/main/java/pe/edu/utp/bd/update_apf2_fallas.sql;
```

El delta ya incluye pagos manuales, devoluciones, fichas y cola de correo; no borra
filas ni carga pacientes de prueba. MySQL hace commits implícitos en DDL: conserve
el respaldo y no permita usuarios durante la actualización. Una instalación nueva
con el canónico no necesita el delta después.

## 3. Configuración fuera del proyecto

Copie el ejemplo a una carpeta privada, fuera del proyecto y del directorio web.
No lo deje en `src/main/resources`: el código ya no lo carga desde el classpath.

```powershell
$carpetaArtDent=Join-Path $env:USERPROFILE 'ArtDent-local'
New-Item -ItemType Directory -Path $carpetaArtDent -Force
Copy-Item src/main/resources/config.properties.example (Join-Path $carpetaArtDent 'config.properties')
$env:ARTDENT_CONFIG=Join-Path $carpetaArtDent 'config.properties'
notepad $env:ARTDENT_CONFIG
```

No sobrescriba una configuración propia existente. Ajuste URL/usuario/clave MySQL,
puerto y nombre de base. Para laboratorio sin proveedores:

```properties
db.url=jdbc:mysql://127.0.0.1:3306/db_artdent_apf2?serverTimezone=America/Lima&useUnicode=true&characterEncoding=UTF-8
db.user=root
db.password=TU_CLAVE_LOCAL
reniec.mode=demo
mail.enabled=false
gemini.enabled=false
# Pago en línea retirado: solo Yape/Plin manual y caja
```

`demo` omite RENIEC y muestra un aviso. Sin ese modo explícito, RENIEC es obligatorio
y un fallo del proveedor impide registrar una identidad nueva. Cambie a
`reniec.mode=required` con token válido al verificar el flujo real.

Precedencia: `-Dartdent.clave` > variable `ARTDENT_CLAVE` > archivo externo.
Ejemplo: `db.url` se reemplaza con `ARTDENT_DB_URL`. La configuración se carga al
iniciar el proceso; reinicie Jetty cuando cambie el archivo.

## 4. Ejecutar el sitio

En la terminal que tiene ARTDENT_CONFIG:

```powershell
mvn jetty:run
```

Abra http://127.0.0.1:8080/ArtDent/ después del inicio del servidor. Si el puerto
está ocupado: `mvn '-Djetty.http.port=8081' jetty:run` y use 8081 en el navegador.
En otra terminal puede ejecutar la comprobación HTTP con JDK 17:

```powershell
java scripts/HttpSmokeCheck.java http://127.0.0.1:8080/ArtDent
```

Esperado: diez mensajes OK. El script no registra citas ni pagos; no reemplaza
la aceptación visual. En esta pasada Jetty sí inició y los flujos se probaron por
HTTP local; la validación visual queda sujeta a las capturas existentes.

## 5. Verificar Yape/Plin, devoluciones y ficha clínica

La demo local ya usa el titular `ART DENT SAC` y el número `986765235` (ficticios,
por decisión del usuario). Antes de producción, reemplace ambos por los datos
reales de la clínica y mantenga una ruta privada absoluta. En Windows use `/`
(ejemplo `C:/Users/MI_USUARIO/ArtDent-local/comprobantes`). No use una ruta dentro
de `src/main/webapp`, `target`, un ZIP o una carpeta servida por HTTP.

```properties
pagos.titular=ART DENT SAC
pagos.numero=986765235
pagos.adjuntos.dir=C:/ruta/privada/comprobantes
```

Estos datos permiten recorrer la pantalla y registrar comprobantes de laboratorio;
no demuestran un pago real. No apruebe un comprobante real sin revisar el
movimiento bancario por el importe completo.

1. Cree una reserva Web en un horario libre. Guarde su código y DNI.
2. Entre a Mi reserva, consulte ambos datos y abra «Enviar comprobante Yape/Plin».
3. Adjunte JPEG/PNG de hasta 5 MB y 12 megapíxeles y un código de operación.
   Debe quedar PENDIENTE: sin Pago, sin boleta y sin confirmación automática.
4. Desde otra sesión sin esa reserva, intente abrir la URL del adjunto. Debe denegar
   acceso. Un odontólogo tampoco puede revisar comprobantes bancarios ajenos.
5. Secretaría: abra «Pagos Yape/Plin y devoluciones», revise y rechace con motivo.
   La cita continúa pendiente y el paciente puede enviar otro comprobante.
6. En una solicitud válida, confirme la verificación bancaria y apruebe. Debe existir
   un pago y una boleta; la reserva pendiente pasa a confirmada. Repita el envío
   del formulario: no debe duplicar cobro ni boleta. Pruebe también dos revisores.
7. Cancele una cita pagada. Debe conservar pago/boleta y crear devolución PENDIENTE.
   Registre la referencia de la devolución efectuada. El paciente verá REALIZADA.
   El sistema registra una gestión manual; no transfiere dinero al banco.
8. Titular o administrador: abra una cita confirmada que ya comenzó, complete
   diagnóstico, tratamiento y observaciones y guarde. Debe guardar ficha y finalizar
   juntos. Una cita futura, ajena o Web sin pago debe ser rechazada sin cambios.
9. Consulte la ficha guardada: autor y fecha deben verse; no debe permitir sobrescribir.
   Secretaría no puede acceder. Las atenciones históricas sin ficha no se rellenan.

El antiguo pago simulado se rechaza por defecto (HTTP 410 para el titular).
No se solicitan números de tarjeta ni CVV en el flujo nuevo.

## 6. Proveedores externos y correo

- RENIEC: configure token/URL y modo `required`. Pruebe coincidencia, DNI inexistente,
  nombres distintos y caída del proveedor. La caída no debe guardar datos nuevos.
- IA: configure `gemini.enabled=true`, clave y `gemini.model` admitido por su cuenta.
  Pruebe consultas dentales; luego deshabilite la red/proveedor y compruebe el respaldo.
  «ensias» y «cariez» deben entenderse; pie y limpieza de casa no recomiendan servicios.
- Correo externo/Gmail: **retirado del alcance por decisión del usuario**. No se configura
  Gmail ni se envían correos reales; `mail.enabled=false`. Las notificaciones internas
  se siguen guardando en `Notificacion`/`CorreoPendiente` y se consultan en el panel.
  No reactive SMTP para la entrega; si se hiciera en el futuro, use una cuenta de prueba
  autorizada y una contraseña de aplicación, nunca las cuentas demo del SQL.

No comparta claves ni adjunte su configuración al paquete de entrega.

## 7. Suite MySQL aislada

La suite rechaza bases que no terminen en `_test`; necesita MySQL de laboratorio y
lectura de `performance_schema` e `information_schema.INNODB_TRX` para observar bloqueos.
Genere el SQL de laboratorio sin tocar MySQL:

```powershell
node scripts/preparar-bd-pruebas.cjs
```

Sin Node puede generar el mismo archivo con PowerShell:

```powershell
New-Item -ItemType Directory -Path target -Force
$sqlPruebas=(Get-Content src/main/java/pe/edu/utp/bd/db_artdent_apf2_completo.sql -Raw).Replace('db_artdent_apf2','db_artdent_apf2_test')
[IO.File]::WriteAllText((Join-Path (Get-Location) 'target/test-bootstrap.sql'),$sqlPruebas,[Text.UTF8Encoding]::new($false))
```

En el cliente MySQL importe `SOURCE C:/ruta/proyecto/target/test-bootstrap.sql;`.
Esto reinicia solo `db_artdent_apf2_test`. Después, en una terminal nueva:

```powershell
$env:ARTDENT_DB_URL='jdbc:mysql://127.0.0.1:3306/db_artdent_apf2_test?serverTimezone=America/Lima'
$env:ARTDENT_DB_USER='root'
$env:ARTDENT_DB_PASSWORD=Read-Host 'Clave MySQL local' -MaskInput
mvn -B clean verify -Pintegration
```

`-MaskInput` requiere PowerShell 7. En PowerShell 5 use el archivo externo privado
y ARTDENT_CONFIG para la clave; mantenga la URL `_test` en la variable de entorno.
Esperado: **56 unitarias y 33 de integración**, cero fallos/errores/omitidas.
La prueba de fallo de boleta genera una advertencia esperada: verifica rollback.
Los informes quedan en `target/surefire-reports` y `target/failsafe-reports`.
No use esa base simultáneamente para pruebas manuales. Cierre esa terminal al terminar.

## 8. Aceptación visual y paquete

Solo en la base de demostración: administrador `48223344` / `123`, secretaría
`78223344` / `1234`, Rubén `70096374` / `1234`, Lucía `71458236` / `1234`.

- Recorra campos vacíos, nombres inválidos, DNI duplicado/nombre distinto, alta
  válida, disponibilidad DNI/correo y creación de secretaría con acceso correcto.
- Recorra reserva pendiente, Mi reserva, comprobante, verificación manual, efectivo,
  aprobación sin pago, rechazo, cancelación, reprogramación y ficha clínica.
- Pruebe fechas pasadas, domingos, turnos, citas de 45 minutos, solapamientos y adyacencia.
- Compruebe foto de Lucía, equipo dinámico, sábado 09–13, colores y leyenda del calendario,
  nombre del odontólogo en ambas clases de tarjeta y canceladas superpuestas ocultas.
- Compruebe solicitudes recientes primero, notificaciones por rol, menú/reportes del
  administrador, campos de servicios sin números y boleta con regreso a la reserva.
- Secretaría no debe abrir ADMPUsuarios; un odontólogo solo finaliza sus propias citas.
- Cierre sesión y use Atrás en cada panel. Recargue y pruebe URL directa: no debe exponer
  información protegida. No cambie el reloj para finalizar citas futuras.
- Registre capturas con fecha y resultado para las PA propias de `PA_ACEPTACION.md`.
  Por decisión del usuario no se requieren las fichas PA originales; no se declara
  correspondencia con numeraciones externas ni se marca OK sin evidencia.

Para crear la entrega desde una compilación vigente:

```powershell
mvn -B clean package
java scripts/EmpaquetarEntrega.java target/artdent-entrega.zip
```

La herramienta incluye código, documentación, pruebas y WAR desde ubicaciones
permitidas, y rechaza configuración privada en el WAR. No sobrescribe un ZIP
existente; elija otro nombre si ya existe. No comprima a mano todo el directorio:
`src/main/temp`, configuraciones y herramientas temporales no forman parte de la entrega.
Respalde por separado la carpeta privada de comprobantes y la BD para conservar
sus referencias. Carillas quedó con precio de referencia y fórmula en
`CARILLAS_PRECIO.md`; K2/K5 están definidos en `KPI_K2_K5.md`. La nube sigue fuera
de este alcance local.

Detenga Jetty con Ctrl+C. No use el canónico para revertir una actualización con datos;
restaure el respaldo. Referencias: [Maven](https://maven.apache.org/install.html),
[MySQL](https://dev.mysql.com/doc/refman/8.0/en/mysql-batch-commands.html).