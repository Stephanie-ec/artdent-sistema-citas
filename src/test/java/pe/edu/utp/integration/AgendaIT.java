package pe.edu.utp.integration;
import java.sql.*;
import java.util.concurrent.*;
import org.junit.Test;
import static org.junit.Assert.*;

public class AgendaIT extends DbFixture {
    @Test public void reprogramacionRevalidaTurnoModificadoMientrasEsperaElBloqueo() throws Exception {
        int id=cita(3,"Web","10:00");ExecutorService pool=Executors.newSingleThreadExecutor();
        try(Connection otra=conexion(); Connection observador=conexion()) {
            int conexionId;
            try(Statement s=otra.createStatement();ResultSet r=s.executeQuery("SELECT CONNECTION_ID()")){r.next();conexionId=r.getInt(1);}
            db.setAutoCommit(false);
            try(Statement s=db.createStatement();ResultSet r=s.executeQuery("SELECT idUsuario FROM Usuario WHERE idUsuario="+doctor+" FOR UPDATE")){r.next();}
            Future<Boolean> resultado=pool.submit(()->{
                try(CallableStatement s=otra.prepareCall("{call ps_ReprogramarReserva(?,?,?)}")) {
                    s.setInt(1,id);s.setString(2,fecha.toString());s.setString(3,"11:00");
                    try{s.execute();return true;}catch(SQLException e){if(!"45000".equals(e.getSQLState()))throw e;return false;}
                }
            });
            long limite=System.nanoTime()+TimeUnit.SECONDS.toNanos(10);boolean esperando=false;
            while(System.nanoTime()<limite) {
                try(Statement st=observador.createStatement();ResultSet rs=st.executeQuery("SELECT COUNT(*) FROM performance_schema.data_lock_waits w JOIN performance_schema.threads t ON t.THREAD_ID=w.REQUESTING_THREAD_ID WHERE t.PROCESSLIST_ID="+conexionId)) {
                    rs.next();if(rs.getInt(1)>0){esperando=true;break;}
                }
                java.util.concurrent.locks.LockSupport.parkNanos(TimeUnit.MILLISECONDS.toNanos(20));
            }
            if(!esperando){db.rollback();db.setAutoCommit(true);fail("La prueba debe observar al escritor esperando el mutex");}
            try(Statement s=db.createStatement()){s.executeUpdate("DELETE FROM Usuario_Horario WHERE Usuario_idUsuario="+doctor);}
            db.commit();db.setAutoCommit(true);
            assertFalse("No debe usar un snapshot del turno anterior",resultado.get(10,TimeUnit.SECONDS));
        } finally { if(!db.getAutoCommit())db.rollback();db.setAutoCommit(true);pool.shutdownNow(); }
    }
    private void reprogramar(int id, String dia, String hora) throws SQLException {
        try (CallableStatement s = db.prepareCall("{call ps_ReprogramarReserva(?,?,?)}")) {
            s.setInt(1,id); s.setString(2,dia); s.setString(3,hora); s.execute();
        }
    }
    @Test public void rechazaPasadoYConservaFecha() throws Exception {
        int id=cita(3,"Web","10:00");
        assertThrows(SQLException.class, () -> reprogramar(id,"2000-01-03","10:00"));
        assertEquals(1,numero("SELECT COUNT(*) FROM Cita WHERE idCita="+id+" AND FechaCita='"+fecha+"'"));
    }
    @Test public void rechazaDomingoFueraDeTurnoYSolapamiento() throws Exception {
        int id=cita(3,"Web","10:00"); cita(3,"Web","11:00");
        assertThrows(SQLException.class, () -> reprogramar(id,fecha.plusDays(6).toString(),"10:00"));
        assertThrows(SQLException.class, () -> reprogramar(id,fecha.toString(),"07:30"));
        assertThrows(SQLException.class, () -> reprogramar(id,fecha.toString(),"18:15"));
        assertThrows(SQLException.class, () -> reprogramar(id,fecha.toString(),"10:30"));
    }
    @Test public void aceptaCitaContiguaSinAutoColision() throws Exception {
        int id=cita(3,"Web","10:00"); cita(3,"Web","11:00");
        reprogramar(id,fecha.toString(),"10:15");
        assertEquals(4,numero("SELECT Estado_idEstado FROM Cita WHERE idCita="+id));
        reprogramar(id,fecha.toString(),"10:15");
    }
    @Test public void dosReservasSimultaneasSoloCreanUna() throws Exception {
        ExecutorService pool=Executors.newFixedThreadPool(2);
        CountDownLatch listos=new CountDownLatch(2), iniciar=new CountDownLatch(1);
        Callable<Boolean> reservar=() -> {
            try(Connection cx=conexion(); CallableStatement s=cx.prepareCall("{call sp_crearreserva(?,?,?,?,?,?,?,?)}")) {
                s.setString(1,fecha.toString()); s.setString(2,"10:00"); s.setString(3,"Concurrencia");
                s.setInt(4,100); s.setInt(5,paciente); s.setInt(6,1); s.setInt(7,1); s.setInt(8,doctor);
                listos.countDown();
                if(!iniciar.await(5,TimeUnit.SECONDS))throw new AssertionError("No se inicio la carrera");
                try { s.execute(); return true; }
                catch(SQLException e) { if(!"45000".equals(e.getSQLState()))throw e; return false; }
            }
        };
        try {
            Future<Boolean> a=pool.submit(reservar),b=pool.submit(reservar);
            assertTrue(listos.await(5,TimeUnit.SECONDS)); iniciar.countDown();
            int exitos=(a.get(10,TimeUnit.SECONDS)?1:0)+(b.get(10,TimeUnit.SECONDS)?1:0);
            assertEquals("F-12: una sola reserva debe ganar",1,exitos);
            assertEquals(1,numero("SELECT COUNT(*) FROM Cita WHERE Odontologo_idUsuario="+doctor));
        } finally { iniciar.countDown(); pool.shutdownNow(); }
    }
    @Test public void disponibilidadPermiteExtremosContiguos() throws Exception {
        cita(3,"Web","10:00");
        assertTrue("F-13: 10:45 debe estar libre",new pe.edu.utp.daoImpl.UsuarioDaoImpl()
                .obtenerMedicosPorServicioYDisponibilidad(1,fecha,java.time.LocalTime.of(10,45))
                .stream().anyMatch(u -> u.getIdUsuario()==doctor));
        assertFalse(new pe.edu.utp.daoImpl.UsuarioDaoImpl()
                .obtenerMedicosPorServicioYDisponibilidad(1,fecha,java.time.LocalTime.of(10,30))
                .stream().anyMatch(u -> u.getIdUsuario()==doctor));
    }

    @Test public void registroDaoDevuelveIdRealYDescripcionSinEstado() throws Exception {
        String dni;
        try(Statement st=db.createStatement(); ResultSet rs=st.executeQuery("SELECT DNI FROM Paciente WHERE idPaciente="+paciente)) {
            rs.next(); dni=rs.getString(1);
        }
        pe.edu.utp.entity.Paciente p=new pe.edu.utp.entity.Paciente(paciente,"Paciente","Prueba",Integer.parseInt(dni),987654321,"paciente@example.test");
        pe.edu.utp.daoImpl.CitaDaoImpl dao=new pe.edu.utp.daoImpl.CitaDaoImpl();
        int a=dao.createReservaWeb(p,new pe.edu.utp.entity.Cita(0,fecha.toString(),"10:00",1,paciente,1,doctor),100,"");
        int b=dao.createCitaPresencial(p,new pe.edu.utp.entity.Cita(0,fecha.toString(),"11:00",1,paciente,3,doctor),100,"",2);
        assertTrue(a>0); assertTrue(b>a);
        assertEquals(1,numero("SELECT COUNT(*) FROM Cita WHERE idCita="+a+" AND Descripcion='Reserva Web'"));
        assertEquals(1,numero("SELECT COUNT(*) FROM Cita WHERE idCita="+b+" AND Descripcion='Cita Presencial'"));
        assertThrows(pe.edu.utp.utils.ReservaNoDisponibleException.class, () -> dao.createReservaWeb(p,
                new pe.edu.utp.entity.Cita(0,fecha.toString(),"10:15",1,paciente,1,doctor),100,""));
    }
}
