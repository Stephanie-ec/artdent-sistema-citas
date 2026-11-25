package pe.edu.utp.utils;

import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.servlet.annotation.WebListener;

/** R-15: registra el inicio y la detención de la aplicación en la tabla Evento. */
@WebListener
public class EventoArranqueListener implements ServletContextListener {

    @Override
    public void contextInitialized(ServletContextEvent evento) {
        EventoService.info("Aplicación", "Inicio de la aplicación " + AppVersion.completa());
    }

    @Override
    public void contextDestroyed(ServletContextEvent evento) {
        EventoService.info("Aplicación", "Detención de la aplicación " + AppVersion.completa());
    }
}
