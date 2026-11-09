package pe.edu.utp.utils;
import java.util.Map;
import java.util.concurrent.*;
import java.util.logging.*;
import javax.servlet.*;
import javax.servlet.annotation.WebListener;
import pe.edu.utp.daoImpl.CorreoDao;

@WebListener
public class CorreoWorker implements ServletContextListener {
    private ScheduledExecutorService ejecutor;
    @Override public void contextInitialized(ServletContextEvent evento) {
        if(!"true".equalsIgnoreCase(ConfigLoader.getProperty("mail.enabled")))return;
        ejecutor=Executors.newSingleThreadScheduledExecutor(r->{Thread t=new Thread(r,"artdent-correos");t.setDaemon(true);return t;});
        ejecutor.scheduleWithFixedDelay(()->{
            try {
                CorreoDao dao=new CorreoDao();Map<String,Object> fila=dao.tomar();
                if(fila!=null)dao.resultado((Long)fila.get("id"),EmailService.sendEmail((String)fila.get("destino"),(String)fila.get("asunto"),(String)fila.get("mensaje")));
            } catch(java.sql.SQLException|RuntimeException e){Logger.getLogger(getClass().getName()).log(Level.WARNING,"No se pudo procesar la cola de correo; se conservará para reintento",e);}
        },5,5,TimeUnit.SECONDS);
    }
    @Override public void contextDestroyed(ServletContextEvent evento) {
        if(ejecutor!=null) {ejecutor.shutdownNow();try{ejecutor.awaitTermination(20,TimeUnit.SECONDS);}catch(InterruptedException e){Thread.currentThread().interrupt();}}
    }
}
