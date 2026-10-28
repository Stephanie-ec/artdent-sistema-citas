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
    private static final String SENDER_EMAIL = ConfigLoader.getProperty("mail.sender"); 
    private static final String SENDER_PASSWORD = ConfigLoader.getProperty("mail.password"); 

    public static void sendEmail(String recipientEmail, String subject, String body) {
        if (recipientEmail == null || recipientEmail.isEmpty()) {
            System.err.println("Correo de destino inválido.");
            return;
        }

        Properties props = new Properties();
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.host", ConfigLoader.getProperty("mail.smtp.host"));
        props.put("mail.smtp.port", ConfigLoader.getProperty("mail.smtp.port"));
        props.put("mail.smtp.ssl.protocols", "TLSv1.2");

        Session session = Session.getInstance(props,
                new javax.mail.Authenticator() {
                    protected PasswordAuthentication getPasswordAuthentication() {
                        return new PasswordAuthentication(SENDER_EMAIL, SENDER_PASSWORD);
                    }
                });

        try {
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(SENDER_EMAIL));
            message.setRecipients(Message.RecipientType.TO,
                    InternetAddress.parse(recipientEmail));
            message.setSubject(subject);
            message.setContent(getHtmlTemplate(subject, body), "text/html; charset=utf-8");

            Transport.send(message);
            System.out.println("Correo enviado exitosamente a: " + recipientEmail);

        } catch (MessagingException e) {
            System.err.println("Error al enviar el correo a " + recipientEmail);
            e.printStackTrace();
        }
    }

    private static String getHtmlTemplate(String subject, String bodyText) {
        return "<!DOCTYPE html>" +
               "<html>" +
               "<head><meta charset='UTF-8'></head>" +
               "<body style='margin:0;padding:0;font-family:Arial,sans-serif;background-color:#f4f7f6;'>" +
               "<div style='max-width:600px;margin:20px auto;background:#ffffff;border-radius:8px;overflow:hidden;box-shadow:0 4px 10px rgba(0,0,0,0.1);'>" +
               "  <div style='background-color:#0288d1;padding:20px;text-align:center;color:#ffffff;'>" +
               "    <h1 style='margin:0;font-size:24px;'>Consultorio Odontológico Art Dent</h1>" +
               "  </div>" +
               "  <div style='padding:30px;color:#333333;line-height:1.6;font-size:16px;'>" +
               "    <h2 style='color:#0288d1;margin-top:0;'>" + subject + "</h2>" +
               "    <p>" + bodyText + "</p>" +
               "  </div>" +
               "  <div style='background-color:#e1f5fe;padding:15px;text-align:center;font-size:12px;color:#01579b;'>" +
               "    <p style='margin:0;'>&copy; " + java.time.Year.now().getValue() + " Art Dent. Todos los derechos reservados.</p>" +
               "    <p style='margin:0;'>Este es un mensaje automático, por favor no responda a este correo.</p>" +
               "  </div>" +
               "</div>" +
               "</body>" +
               "</html>";
    }
}
