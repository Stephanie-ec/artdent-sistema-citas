package pe.edu.utp.integration;
import java.nio.file.*;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.sql.*;
import java.util.*;
import org.junit.Test;
import static org.junit.Assert.*;

public class MigracionIT extends DbFixture {
    private Map<String,String> huellas() throws Exception {
        Map<String,String> resultado=new HashMap<>();
        for(String tabla:Arrays.asList("Cita","Pago","Comprobante","Usuario","Paciente","Notificacion","Atencion","SolicitudPago","Devolucion","CorreoPendiente")) {
            MessageDigest hash=MessageDigest.getInstance("SHA-256");
            try(Statement s=db.createStatement();ResultSet r=s.executeQuery("SELECT * FROM "+tabla+" ORDER BY 1")) {
                while(r.next())for(int i=1;i<=r.getMetaData().getColumnCount();i++) {
                    String valor=r.getString(i);String campo=valor==null?"N;":valor.length()+":"+valor+";";
                    hash.update(campo.getBytes(StandardCharsets.UTF_8));
                }
            }
            resultado.put(tabla,Base64.getEncoder().encodeToString(hash.digest()));
        }
        return resultado;
    }
    private void aplicarDelta() throws Exception {
        String delimitador=";";StringBuilder sql=new StringBuilder();
        for(String linea:Files.readAllLines(Paths.get("src/main/java/pe/edu/utp/bd/update_apf2_fallas.sql"),StandardCharsets.UTF_8)) {
            String limpia=linea.trim();
            if(limpia.startsWith("--")||limpia.isEmpty())continue;
            if(limpia.startsWith("DELIMITER ")){delimitador=limpia.substring(10).trim();continue;}
            sql.append(linea).append('\n');
            if(limpia.endsWith(delimitador)) {
                String comando=sql.toString().trim();comando=comando.substring(0,comando.length()-delimitador.length());
                try(Statement s=db.createStatement()){s.execute(comando);}
                sql.setLength(0);
            }
        }
        assertEquals("No debe quedar SQL sin ejecutar",0,sql.length());
    }
    @Test public void deltaRepetidoConservaTodosLosDatosExistentes() throws Exception {
        int id=cita(3,"Web","10:00");pago(id);
        new pe.edu.utp.daoImpl.GestionCitaDao().cambiarEstado(id,5,2,true);
        int pendiente=cita(1,"Web","11:00");
        new pe.edu.utp.daoImpl.PagoManualDao().solicitar(pendiente,"PLIN","MIGRACION-123",java.util.UUID.randomUUID()+".png","Paciente Prueba","12345678");
        int clinica=cita(3,"Presencial","12:00");
        try(Statement s=db.createStatement()){s.executeUpdate("UPDATE Cita SET FechaCita='2000-01-03' WHERE idCita="+clinica);}
        new pe.edu.utp.daoImpl.AtencionDao().registrar(clinica,doctor,"Diagnóstico","Tratamiento","");
        new pe.edu.utp.daoImpl.CorreoDao().encolar(pendiente,1,"Reserva recibida","Reserva de prueba");
        Map<String,String> antes=huellas();aplicarDelta();aplicarDelta();
        assertEquals("El delta no debe modificar las filas historicas",antes,huellas());
    }
}
