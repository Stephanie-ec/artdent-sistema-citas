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
                if(fila!=null){
                    long id=(Long)fila.get("id");
                    boolean entregado=EmailService.sendEmail((String)fila.get("destino"),(String)fila.get("asunto"),(String)fila.get("mensaje"));
                    dao.resultado(id,entregado);
                    if(entregado)dao.marcarNotificacionEnviada((Integer)fila.get("cita"),(String)fila.get("asunto"));
                    // R-15: mientras queden reintentos es una advertencia; al agotarlos es un ERROR
                    if(!entregado){
                        if(dao.intentos(id)>=3)EventoService.error("Correo","El correo id "+id+" agoto los 3 intentos de entrega; revise la configuracion SMTP y la cola");
                        else EventoService.advertencia("Correo","No se pudo entregar el correo id "+id+"; queda en cola para reintento");
                    }
                }
            } catch(java.sql.SQLException|RuntimeException e){Logger.getLogger(getClass().getName()).log(Level.WARNING,"No se pudo procesar la cola de correo; se conservará para reintento",e);}
        },5,5,TimeUnit.SECONDS);
    }
    @Override public void contextDestroyed(ServletContextEvent evento) {
        if(ejecutor!=null) {ejecutor.shutdownNow();try{ejecutor.awaitTermination(20,TimeUnit.SECONDS);}catch(InterruptedException e){Thread.currentThread().interrupt();}}
    }
}
