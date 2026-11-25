# Correo en la aplicación desplegada

## El problema de Mailpit

Mailpit escucha en `127.0.0.1:1025`, es decir, dentro del equipo donde se ejecuta. Si la aplicación se
despliega en un servidor, ese buzón no existe: el servidor intentaría conectarse a su propio `localhost`
y no habría forma de abrir los correos desde el navegador del usuario. Por eso el envío ya no depende de
un buzón local, sino de un **servidor SMTP de Internet**.

## Modo demo actual: Ethereal (gratis, sin datos personales)

La configuración de `src/main/resources/config.properties` apunta a una cuenta de pruebas gratuita de
[Ethereal](https://ethereal.email) (`smtp.ethereal.email`, puerto 587, STARTTLS):

| Clave | Valor |
| :--- | :--- |
| `mail.sender` | `pw7nynbvow246yvt@ethereal.email` |
| `mail.smtp.user` | igual al remitente |
| `mail.password` | clave de la cuenta de pruebas |
| `mail.smtp.host` / `port` | `smtp.ethereal.email` / `587` |
| `mail.smtp.auth` / `starttls` | `true` / `true` |

Cómo ver los correos (desde cualquier equipo, también con la app desplegada):

1. Entrar a <https://ethereal.email> e iniciar sesión con `mail.sender` y `mail.password`.
2. Abrir *Messages*: ahí llegan los avisos reales que envió la aplicación, con el HTML completo.

Limitaciones: Ethereal **no entrega** el mensaje al destinatario (`mxEnabled: false`); funciona como una
bandeja temporal de Internet para la demostración, guarda los mensajes unos días y se puede reemplazar
por otra cuenta creada sin datos personales:

```bash
curl -s -X POST https://api.nodemailer.com/user -H "Content-Type: application/json" \
     -d '{"requestor":"artdent-demo","version":"1.0.0"}'
```

La respuesta trae `user`, `pass`, `smtp.host` y `smtp.port`; se copian a las claves `mail.*`.

## Entrega real gratis: Brevo (300 correos/día)

Para que un paciente reciba el correo en su bandeja real:

1. Crear una cuenta gratuita en <https://www.brevo.com>.
2. En *Senders & IP* → *Senders* añadir y verificar el correo desde el que se enviará (no hace falta
   tener un dominio propio; basta confirmar el enlace que llega al buzón).
3. En *SMTP & API* → *SMTP* copiar la **SMTP key** y el login.
4. Cambiar las claves:

```properties
mail.sender=correo-verificado@dominio.com
mail.from.name=Art Dent
mail.smtp.user=login-de-la-cuenta-brevo
mail.password=SMTP-KEY-de-brevo
mail.smtp.host=smtp-relay.brevo.com
mail.smtp.port=587
mail.smtp.auth=true
mail.smtp.starttls=true
mail.smtp.ssl=false
```

Alternativas equivalentes: Mailjet (200/día, `in-v3.mailjet.com:587`), Gmail con contraseña de aplicación
(`smtp.gmail.com:587`, solo para pruebas) o el SMTP del dominio de la clínica.

## Qué soporta `EmailService`

* `mail.smtp.auth=false` y `mail.smtp.starttls=false` → buzón local Mailpit (`127.0.0.1:1025`).
* Puerto `587` → STARTTLS. Puerto `465` → SSL directo (también `mail.smtp.ssl=true` en otro puerto).
* `mail.smtp.user` distinto de `mail.sender` para relays que autentican con un usuario y firman con otro.
* `mail.from.name` agrega el nombre visible («Art Dent <correo>»).
* Errores de red o autenticación devuelven `false`, se registran en `CorreoPendiente` (`Intentos`,
  `UltimoError`) y el worker reintenta: la reserva nunca se pierde por un correo.

## Secretos en el servidor

`config.properties` no entra al WAR. En producción las claves se pasan por entorno o propiedad del sistema
(`ConfigLoader` las antecede al archivo):

```bash
ARTDENT_MAIL_SENDER=correo-verificado@dominio.com
ARTDENT_MAIL_SMTP_USER=login-brevo
ARTDENT_MAIL_PASSWORD=SMTP-KEY
ARTDENT_MAIL_SMTP_HOST=smtp-relay.brevo.com
ARTDENT_MAIL_SMTP_PORT=587
ARTDENT_MAIL_SMTP_AUTH=true
ARTDENT_MAIL_SMTP_STARTTLS=true
```

## Verificación hecha (22/11/2026)

1. `EmailService.sendEmail(...)` desde la JVM → `true`, y el mensaje se leyó de vuelta por IMAP en el
   buzón Ethereal (`Art Dent <pw7nynbvow246yvt@ethereal.email>`).
2. Reserva real en el navegador `ART-RES-00025` (paciente 87654324, Limpieza Dental, 25/11/2026 10:00):
   3 avisos «Reserva recibida» (paciente, odontólogo y secretaría) llegaron al buzón de Internet con el
   código de reserva en el cuerpo HTML.
3. `mvn -B test`: 89 pruebas, 0 fallos. Los datos de la prueba se borraron después.

## Diagnóstico rápido

| Síntoma | Causa habitual |
| :--- | :--- |
| `AuthenticationFailedException` / `535` | `mail.smtp.user` o `mail.password` incorrectos (en Brevo es la SMTP key). |
| Timeout en 587 | El servidor bloquea ese puerto: usar `465` con `mail.smtp.ssl=true`. |
| `MailConnectException` a `127.0.0.1` | Quedó la configuración de Mailpit en un servidor. |
| El correo no aparece en el buzón web | Revisar `CorreoPendiente.Estado` y `UltimoError`, y que `mail.enabled=true`. |
