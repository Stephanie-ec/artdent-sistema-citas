package pe.edu.utp.utils;

import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.servlet.annotation.WebListener;

/** R-03: ejecuta la búsqueda de recordatorios una vez por hora. */
@WebListener
public class RecordatorioWorker implements ServletContextListener {

    private static final Logger LOG = Logger.getLogger(RecordatorioWorker.class.getName());
    private ScheduledExecutorService ejecutor;

    @Override
    public void contextInitialized(ServletContextEvent evento) {
        if (!RecordatorioService.habilitado()) {
            LOG.info("Recordatorios desactivados (mail.enabled y recordatorios.enabled en false)");
            return;
        }
        ejecutor = Executors.newSingleThreadScheduledExecutor(r -> {
            Thread t = new Thread(r, "artdent-recordatorios");
            t.setDaemon(true);
            return t;
        });
        ejecutor.scheduleWithFixedDelay(() -> {
            try {
                RecordatorioService.procesar();
            } catch (RuntimeException e) {
                LOG.log(Level.WARNING, "Fallo al procesar recordatorios; se reintentará en una hora", e);
            }
        }, 30, 60, TimeUnit.SECONDS);
    }

    @Override
    public void contextDestroyed(ServletContextEvent evento) {
        if (ejecutor != null) {
            ejecutor.shutdownNow();
        }
    }
}
