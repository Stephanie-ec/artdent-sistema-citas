# Auditoría de cierre — ArtDent

Fecha: 21/11/2026. Verificación sobre la base `db_artdent_apf2` local, servidor Jetty y consultas HTTP reales con sesión.
Compilación final: `mvn clean package` → **82 pruebas, 0 fallos, BUILD SUCCESS**.

## Matriz de cumplimiento

| Req. | Alcance | Estado | Evidencia |
| --- | --- | --- | --- |
| R-01 | Pago en línea (Mercado Pago) | **Implementado y verificado** | `MercadoPagoService` + `PagoEnLineaController` (Checkout Pro). Preferencia real creada con las credenciales de prueba y redirección a `checkout/v1/redirect`; el checkout muestra «Art Dent - Limpieza Dental (ART-RES-00014)» por S/ 40. Retorno con pago aprobado: Pago `MP:777` con `MetodoPago=1` (En línea), boleta `B001-00000011`, cita 14 a estado 3; repetir el retorno no duplica el cobro. Sin `payment_id` → aviso; pago desconocido → «Mercado Pago no reconoce ese pago». Importe pagado distinto al costo vigente → no se registra. `MercadoPagoServiceTest` (4 casos). |
| R-02 | Correos claros y best-effort | **Implementado y verificado (entrega real)** | Mensajes con código, fecha, hora, servicio, odontólogo y sede (`GestionCitaDao.detalle`, `CitaController`). Prueba con SMTP inaccesible: cita 21 guardada (302), cola con `Intentos=1` y `UltimoError`, evento ADVERTENCIA `Correo`; la cancelación dejó `Estado=5` y el correo con el detalle completo. Entrega real con la cuenta Gmail del equipo (contraseña de aplicación, 22/11/2026): confirmación de la cita 14 enviada a los 3 destinatarios (paciente, odontólogo y secretaría), los 3 quedaron `ENVIADO` con `Intentos=1` y `Notificacion.Enviado=1`; el correo llegó a la bandeja en menos de 1 minuto. |
| R-03 | Recordatorio 24 h antes | **Implementado y verificado** | `RecordatorioService` + `RecordatorioWorker` (cada hora, primera pasada a los 30 s). Prueba: cita confirmada a +24 h → un correo por destinatario con clave `recordatorio-<idCita>`; el mismo `INSERT` no duplica. `RecordatorioServiceTest` (3 casos). Se activa con `mail.enabled=true` o `recordatorios.enabled=true`. Entrega real verificada (22/11/2026) con una cita a +1440 minutos: un correo por destinatario, los 3 `ENVIADO` y sin duplicados al repetir la pasada. |
| R-04 | RENIEC: web bloquea, presencial continúa marcado | **Implementado y verificado** | `update_cierre_v4.sql` (`Paciente.IdentidadVerificada`). Con proveedor inaccesible: web → **400** \"No pudimos validar su DNI en este momento; intente en unos minutos o llame a la clínica.\"; presencial → **302**, cita 20 creada y paciente con `IdentidadVerificada=0`; badge \"Identidad por verificar\" visible en `PDCPacientes.jsp`; evento ADVERTENCIA `RENIEC`. `ReniecServiceTest` (5 casos). |
| R-05 | Comprobante interno, no SUNAT | **Implementado y verificado** | Textos \"Comprobante de pago\" y leyenda \"Documento interno de Art Dent. No es comprobante electrónico SUNAT\" en boleta, solicitudes, voucher y consulta. |
| R-06 | Consentimiento Ley 29733 | **Implementado y verificado** | `update_cierre_v1.sql`; casillas en reserva web y presencial; POST sin consentimiento → 400 sin crear paciente; con consentimiento → 302 y `ConsentimientoFecha` guardada; `politica-privacidad.jsp` pública enlazada desde el pie. |
| R-07 | Publicación en hosting | **Bloqueado** | Freebuff Sites no despliega WAR + MySQL; falta elegir hosting (Azure for Students u otro). |
| R-08 | Claves temporales y forzado de cambio | **Implementado y verificado** | `update_cierre_v2.sql`; desbloqueo y restablecimiento por HTTP; login con clave temporal → `/CambiarClaveController?forzado=1`; clave actual incorrecta rechazada; cambio exitoso y login con la nueva clave. |
| R-14 | Salud y métricas | **Implementado y verificado** | `/salud` público (200 y **503** con base inaccesible); `/estado` solo administrador; p95 de reservas; conteos de cola y eventos; números de versión. |
| R-15 | Eventos y alertas | **Implementado y verificado** | `update_cierre_v3.sql` (tabla `Evento`); eventos en arranque, login fallido, bloqueo, 5xx, cola de correo, RENIEC y pagos; banner de alertas en el panel; atención de alertas con auditoría. |
| R-16 | Respaldo | **Implementado y verificado** | `scripts/respaldo-bd.ps1`: ZIP de 14 KB en `%USERPROFILE%\\ArtDent\\Respaldos`, 7.9 s, evento INFO en `Evento`. Retención de 7 copias. |
| R-17 | Restauración y verificación | **Implementado y verificado** | `restaurar-bd.ps1`: `db_artdent_restaurada`, **RTO 10 s**, **RPO 0.0 h**. `verificar-conteos.ps1`: Paciente 9/9, Cita 15/15, Pago 10/10, Comprobante 10/10, Atencion 0/0. Login de administrador contra la base restaurada en el puerto 8081. |

## Cambios de base de datos

Deltas idempotentes en `src/main/java/pe/edu/utp/bd/` y espejo en `db_artdent_apf2_completo.sql`:

| Archivo | Cambio |
| --- | --- |
| `update_cierre_v1.sql` | `Paciente.ConsentimientoFecha` |
| `update_cierre_v2.sql` | `Usuario.DebeCambiarClave` |
| `update_cierre_v3.sql` | tabla `Evento` |
| `update_cierre_v4.sql` | `Paciente.IdentidadVerificada` (por defecto 1) |

## Configuración nueva

`src/main/resources/config.properties.example` documenta `recordatorios.enabled=false`. El recordatorio
se activa al habilitar el correo (`mail.enabled=true`) o forzando esa clave para probar la cola sin SMTP.
La contraseña de correo y los tokens de RENIEC/Mercado Pago no están en el repositorio.

## Pendiente por decisión o credenciales

1. **R-01 (paso manual)**: completar un pago con la cuenta de prueba de comprador en el checkout. En este equipo el checkout se abre y cobra, pero el inicio de sesión del comprador queda frenado por la verificación de Mercado Pago; la ruta de aprobación se verificó con una respuesta equivalente de la API. Detalle en `docs/PAGO_EN_LINEA.md`.
2. **R-07**: elegir el hosting (Azure for Students u otro con Java 17 + MySQL). También exige HTTPS para que Mercado Pago devuelva al sitio automáticamente.
3. **Tarea programada** de respaldo en Windows: se crea solo con autorización (`schtasks`, ver `scripts/RESPALDO_Y_RESTAURACION.md`).
4. **Publicación R-01**: el retorno automático de Mercado Pago necesita URL pública HTTPS; en local se abre con `payment_id`.

## Correo (R-02/R-03)

El envío sale por **Internet** con una cuenta gratuita de pruebas **Ethereal** (`smtp.ethereal.email:587`,
STARTTLS + autenticación), no con un buzón local: la misma configuración funciona con la app instalada en
cualquier servidor. Los mensajes se leen en <https://ethereal.email> con `mail.sender` / `mail.password`;
Ethereal **no entrega** al destinatario (`mxEnabled: false`), por lo que sirve para la demo. Para entrega real
basta cambiar a un relay gratuito (Brevo, 300/día) o al SMTP del dominio con las mismas claves; pasos en
`docs/CORREO_EN_DESPLIEGUE.md`.

`EmailService` admite SMTP sin autenticación para Mailpit local, STARTTLS en 587, SSL directo en 465
(`mail.smtp.ssl`), usuario de login distinto del remitente (`mail.smtp.user`) y nombre visible
(`mail.from.name`). Las claves se sobrescriben con `-Dartdent.<clave>` o `ARTDENT_<CLAVE>`
(p. ej. `ARTDENT_MAIL_PASSWORD`), así el servidor no guarda secretos en el WAR; las credenciales locales viven
solo en `src/main/resources/config.properties`, excluido del WAR y del control de versiones.

Verificado el 22/11/2026: la reserva `ART-RES-00025` creada en el navegador generó 3 avisos «Reserva recibida»
(paciente, odontólogo y secretaría) entregados por SMTP de Internet y leídos de vuelta por IMAP en el buzón
Ethereal, con remitente `Art Dent <pw7nynbvow246yvt@ethereal.email>` y el código de reserva en el cuerpo HTML.
Antes, la reserva `ART-RES-00024` y la aprobación de su comprobante Yape/Plin generaron «Comprobante recibido»
y «Pago verificado» con la plantilla HTML corregida (párrafos separados y pie con divisor).

## Almacenamiento de comprobantes

`pagos.adjuntos.dir` admite una ruta **relativa** que se resuelve dentro de `datos.dir` (por defecto
`<usuario>/artdent`), de modo que la misma configuración funciona en Windows y en el servidor. En producción
basta definir `-Dartdent.datos.dir` o `ARTDENT_DATOS_DIR` a una carpeta persistente y privada, fuera del
sitio público; el servidor rechaza cualquier ruta dentro de la raíz web. `scripts/respaldo-bd.ps1` resuelve la
misma regla al comprimir los comprobantes.
