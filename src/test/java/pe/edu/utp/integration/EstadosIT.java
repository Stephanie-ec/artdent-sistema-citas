package pe.edu.utp.integration;
import java.sql.*;
import org.junit.Test;
import static org.junit.Assert.*;

public class EstadosIT extends DbFixture {
    private void cambiar(int id,int destino,int actor,boolean web) throws SQLException {
        if(destino==2){new pe.edu.utp.daoImpl.AtencionDao().registrar(id,actor,"Diagnóstico de prueba","Tratamiento de prueba","");return;}
        new pe.edu.utp.daoImpl.GestionCitaDao().cambiarEstado(id,destino,actor,web);
    }
    private void pasado(int id) throws SQLException {
        try(Statement s=db.createStatement()){s.executeUpdate("UPDATE Cita SET FechaCita='2000-01-03' WHERE idCita="+id);}
    }
    @Test public void noSeApruebaWebSinPagoYNoSeRepiteTransicion() throws Exception {
        int id=cita(1,"Web","10:00");
        SQLException e=assertThrows(SQLException.class,()->cambiar(id,3,2,true));
        assertEquals("45000",e.getSQLState()); assertEquals("sinPago",e.getMessage());
        assertEquals(1,numero("SELECT Estado_idEstado FROM Cita WHERE idCita="+id));
        pago(id); cambiar(id,3,2,true);
        assertThrows(SQLException.class,()->cambiar(id,3,2,true));
    }
    @Test public void reprogramadoSeListaYFinalizaPorTitular() throws Exception {
        for(String origen:new String[]{"Web","Presencial"}) {
            int id=cita(4,origen,origen.equals("Web")?"10:00":"11:00");
            if(origen.equals("Web"))pago(id);
            String proc=origen.equals("Web")?"sp_ListarReservasPorUsuario":"sp_ListarCitasPorUsuario";
            try(CallableStatement st=db.prepareCall("{call "+proc+"(?)}")) {
                st.setInt(1,doctor); boolean existe=false;
                try(ResultSet rs=st.executeQuery()){while(rs.next())if(rs.getInt(1)==id)existe=true;}
                assertTrue("F-02: debe listar el reprogramado",existe);
            }
            pasado(id); cambiar(id,2,doctor,origen.equals("Web"));
            assertEquals(2,numero("SELECT Estado_idEstado FROM Cita WHERE idCita="+id));
        }
    }
    @Test public void noCompletaFuturaAjenaNiSecretaria() throws Exception {
        int id=cita(3,"Presencial","10:00");
        assertThrows(SQLException.class,()->cambiar(id,2,doctor,false));
        assertThrows(SQLException.class,()->cambiar(id,2,1,false));
        pasado(id);
        assertThrows(SQLException.class,()->cambiar(id,2,4,false));
        assertThrows(SQLException.class,()->cambiar(id,2,2,false));
        cambiar(id,2,1,false);
    }
    @Test public void reprogramacionNoSaltaAprobacionPendiente() throws Exception {
        int id=cita(1,"Web","10:00");
        new pe.edu.utp.daoImpl.GestionCitaDao().reprogramar(id,fecha.toString(),"11:00",true);
        assertEquals(1,numero("SELECT Estado_idEstado FROM Cita WHERE idCita="+id));
        assertThrows(SQLException.class,()->cambiar(id,3,2,true));
    }
    @Test public void cancelacionPagadaConservaHistoriaYRegistraDevolucionUnaVez() throws Exception {
        int id=cita(3,"Web","10:00"); pago(id); cambiar(id,5,2,true);
        assertEquals(1,numero("SELECT COUNT(*) FROM Notificacion WHERE Cita_idCita="+id+" AND Asunto LIKE 'Devolucion pendiente%'"));
        assertThrows(SQLException.class,()->cambiar(id,5,2,true));
        assertThrows(SQLException.class,()->new pe.edu.utp.daoImpl.GestionCitaDao().eliminar(id,2,true));
        assertEquals(1,numero("SELECT COUNT(*) FROM Pago WHERE Cita_idCita="+id));
        assertEquals(1,numero("SELECT COUNT(*) FROM Cita WHERE idCita="+id));
    }
    @Test public void eliminacionSinPagoSoloParaAnuladas() throws Exception {
        int id=cita(1,"Web","10:00");
        assertThrows(SQLException.class,()->new pe.edu.utp.daoImpl.GestionCitaDao().eliminar(id,2,true));
        cambiar(id,6,2,true); new pe.edu.utp.daoImpl.GestionCitaDao().eliminar(id,2,true);
        assertEquals(0,numero("SELECT COUNT(*) FROM Cita WHERE idCita="+id));
    }
}
