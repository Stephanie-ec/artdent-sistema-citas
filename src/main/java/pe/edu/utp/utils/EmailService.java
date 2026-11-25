package pe.edu.utp.utils;

import java.util.Properties;
import javax.mail.Message;
import javax.mail.MessagingException;
import javax.mail.PasswordAuthentication;
import javax.mail.Session;
import javax.mail.Transport;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;

public class EmailService {

    // Configuración del correo emisor se carga desde config.properties
    private static final String SENDER_EMAIL = sinEspacios(ConfigLoader.getProperty("mail.sender"));
    private static final String SENDER_PASSWORD = sinEspacios(ConfigLoader.getProperty("mail.password"));
    /** Un relay de Internet (Brevo, Mailjet, Ethereal, Gmail) pide usuario de login propio. */
    private static final String SMTP_USER = primerNoVacio(
            sinEspacios(ConfigLoader.getProperty("mail.smtp.user")), SENDER_EMAIL);
    private static final String FROM_NAME = ConfigLoader.getProperty("mail.from.name");
    /** Buzón local de pruebas (Mailpit/MailHog) trabaja sin autenticación ni TLS. */
    private static final boolean AUTH = !esFalso("mail.smtp.auth");
    private static final boolean STARTTLS = !esFalso("mail.smtp.starttls");

    /**
     * Gmail muestra la contraseña de aplicación como "xxxx xxxx xxxx xxxx"; el servidor SMTP
     * solo acepta las 16 letras sin espacios. Recortar también evita fallos por un salto de línea.
     */
    static String sinEspacios(String valor) {
        return valor == null ? null : valor.replaceAll("\\s+", "");
    }

    /** Una clave ausente conserva el comportamiento histórico (auth y TLS activos). */
    static boolean esFalso(String clave) {
        return "false".equalsIgnoreCase(String.valueOf(ConfigLoader.getProperty(clave)).trim());
    }

    static String primerNoVacio(String valor, String alternativa) {
        return valor == null || valor.isEmpty() ? alternativa : valor;
    }

    /**
     * Puerto 465 habla SSL/TLS directo; 587 y 1025 usan STARTTLS. `mail.smtp.ssl=true`
     * permite forzar el modo SSL en cualquier puerto.
     */
    static boolean usarSsl(String puerto) {
        return "true".equalsIgnoreCase(String.valueOf(ConfigLoader.getProperty("mail.smtp.ssl")).trim())
                || "465".equals(puerto);
    }

    public static boolean sendEmail(String recipientEmail, String subject, String body) {
        if (!"true".equalsIgnoreCase(ConfigLoader.getProperty("mail.enabled"))) return false;
        String host = ConfigLoader.getProperty("mail.smtp.host");
        if (SENDER_EMAIL == null || SENDER_EMAIL.isEmpty() || SENDER_EMAIL.startsWith("tu_correo")
                || host == null || host.trim().isEmpty()) {
            return false;
        }
        if (AUTH && (SENDER_PASSWORD == null || SENDER_PASSWORD.isEmpty() || SENDER_PASSWORD.startsWith("tu_token")
                || SMTP_USER == null || SMTP_USER.isEmpty())) {
            return false;
        }
        if (recipientEmail == null || recipientEmail.isEmpty()) {
            System.err.println("Correo de destino inválido.");
            return false;
        }

        String puerto = ConfigLoader.getProperty("mail.smtp.port");
        if (puerto == null || puerto.trim().isEmpty()) puerto = "25";
        puerto = puerto.trim();
        boolean ssl = usarSsl(puerto);
        boolean starttls = STARTTLS && !ssl;

        Properties props = new Properties();
        props.put("mail.smtp.connectiontimeout", "10000");
        props.put("mail.smtp.timeout", "10000");
        props.put("mail.smtp.writetimeout", "10000");
        props.put("mail.smtp.auth", String.valueOf(AUTH));
        props.put("mail.smtp.starttls.enable", String.valueOf(starttls));
        props.put("mail.smtp.starttls.required", String.valueOf(starttls));
        props.put("mail.smtp.host", host.trim());
        props.put("mail.smtp.port", puerto);
        if (starttls || ssl) props.put("mail.smtp.ssl.protocols", "TLSv1.2");
        if (ssl) {
            props.put("mail.smtp.ssl.enable", "true");
            props.put("mail.smtp.ssl.checkserveridentity", "true");
        }

        Session session = AUTH
                ? Session.getInstance(props, new javax.mail.Authenticator() {
                    protected PasswordAuthentication getPasswordAuthentication() {
                        return new PasswordAuthentication(SMTP_USER, SENDER_PASSWORD);
                    }
                })
                : Session.getInstance(props);

        try {
            Message message = new MimeMessage(session);
            message.setFrom(remitente());
            message.setRecipients(Message.RecipientType.TO,
                    InternetAddress.parse(recipientEmail));
            message.setSubject(subject);
            message.setContent(getHtmlTemplate(subject, body), "text/html; charset=utf-8");

            Transport.send(message);
            System.out.println("Correo enviado exitosamente a: " + recipientEmail);
            return true;

        } catch (MessagingException e) {
            System.err.println("Error al enviar el correo a " + recipientEmail);
            e.printStackTrace();
            return false;
        }
    }

    /** Nombre visible del remitente (`mail.from.name`); sin él queda solo la dirección. */
    private static InternetAddress remitente() throws MessagingException {
        String nombre = FROM_NAME == null ? "" : FROM_NAME.trim();
        try {
            return nombre.isEmpty()
                    ? new InternetAddress(SENDER_EMAIL)
                    : new InternetAddress(SENDER_EMAIL, nombre, "UTF-8");
        } catch (java.io.UnsupportedEncodingException e) {
            return new InternetAddress(SENDER_EMAIL);
        }
    }

    static String getHtmlTemplate(String subject, String bodyText) {
        String asunto = SecurityUtils.escaparHtml(subject);
        String cuerpo = parrafos(SecurityUtils.escaparHtml(bodyText));
        return "<!DOCTYPE html>" +
               "<html><head><meta charset='UTF-8'>" +
               "<meta name='viewport' content='width=device-width,initial-scale=1'></head>" +
               "<body style='margin:0;padding:0;background-color:#eef3f7;-webkit-text-size-adjust:100%;'>" +
               "<table role='presentation' width='100%' cellpadding='0' cellspacing='0' " +
               "style='background-color:#eef3f7;padding:24px 12px;'><tr><td align='center'>" +
               "<table role='presentation' width='600' cellpadding='0' cellspacing='0' " +
               "style='width:100%;max-width:600px;background:#ffffff;border-radius:12px;overflow:hidden;" +
               "font-family:Arial,Helvetica,sans-serif;'>" +
               "<tr><td style='background-color:#0288d1;padding:26px 30px;text-align:center;color:#ffffff;'>" +
               "<div style='font-size:12px;letter-spacing:2px;text-transform:uppercase;color:#e1f5fe;'>Consultorio Odontol&oacute;gico</div>" +
               "<div style='font-size:24px;font-weight:bold;margin-top:6px;'>Art Dent</div>" +
               "</td></tr>" +
               "<tr><td style='padding:32px 30px 10px 30px;color:#2b3a42;font-size:16px;line-height:1.6;'>" +
               "<h1 style='margin:0 0 18px 0;font-size:20px;line-height:1.35;color:#0277bd;'>" + asunto + "</h1>" +
               cuerpo +
               "</td></tr>" +
               "<tr><td style='padding:10px 30px 30px 30px;'>" +
               "<div style='border-top:1px solid #e3ebf1;padding-top:16px;font-size:13px;line-height:1.6;color:#607d8b;'>" +
               "<div>&copy; " + java.time.Year.now().getValue() + " Art Dent. Todos los derechos reservados.</div>" +
               "<div style='margin-top:6px;'>Este es un mensaje autom&aacute;tico, por favor no responda a este correo.</div>" +
               "</div></td></tr>" +
               "</table></td></tr></table>" +
               "</body></html>";
    }

    /** Cada salto de línea del mensaje se convierte en un párrafo separado. */
    static String parrafos(String texto) {
        StringBuilder html = new StringBuilder();
        for (String linea : texto.split("\\r?\\n")) {
            if (linea.trim().isEmpty()) continue;
            html.append("<p style='margin:0 0 14px 0;'>").append(linea.trim()).append("</p>");
        }
        return html.length() == 0 ? "<p style='margin:0 0 14px 0;'>&nbsp;</p>" : html.toString();
    }
}
