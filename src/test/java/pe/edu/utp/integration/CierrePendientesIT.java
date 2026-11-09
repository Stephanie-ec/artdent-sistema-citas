package pe.edu.utp.integration;
import java.sql.*;
import java.util.*;
import java.util.concurrent.*;
import org.junit.Test;
import static org.junit.Assert.*;
import pe.edu.utp.daoImpl.*;
import pe.edu.utp.entity.*;

public class CierrePendientesIT extends DbFixture {
    private PagoManualDao manual=new PagoManualDao();
    private int solicitud(int cita,String codigo) throws Exception {
        manual.solicitar(cita,"YAPE",codigo,UUID.randomUUID().toString()+".png","Paciente Prueba","12345678");
        return numero("SELECT MAX(idSolicitud) FROM SolicitudPago WHERE Cita_idCita="+cita);
    }
    @Test public void solicitudNoEsPagoYRechazoPermiteNuevoComprobante() throws Exception {
        int id=cita(1,"Web","10:00"),s=solicitud(id,"OP-1234");
        assertEquals(0,numero("SELECT COUNT(*) FROM Pago WHERE Cita_idCita="+id));
        assertEquals(1,numero("SELECT Estado_idEstado FROM Cita WHERE idCita="+id));
        assertThrows(SQLException.class,()->solicitud(id,"OTRA-123"));
        assertThrows(SQLException.class,()->manual.revisar(s,doctor,true,null));
        manual.revisar(s,2,false,"No se encontró el movimiento");
        assertThrows(SQLException.class,()->manual.revisar(s,2,true,null));
        assertEquals(1,numero("SELECT Estado_idEstado FROM Cita WHERE idCita="+id));
        int nueva=solicitud(id,"OP-1234");assertTrue(nueva>s);
    }
    @Test public void aprobacionRepetidaConfirmaUnaSolaBoletaYEvitaOperacionDuplicada() throws Exception {
        String codigo="OP-"+UUID.randomUUID().toString().substring(0,8).toUpperCase(Locale.ROOT);
        int a=cita(1,"Web","10:00"),b=cita(1,"Web","11:00"),sa=solicitud(a,codigo),sb=solicitud(b,codigo);
        manual.revisar(sa,2,true,null);manual.revisar(sa,2,true,null);
        assertFalse(manual.revisarResultado(sa,2,true,null).modificada);
        assertThrows(SQLException.class,()->manual.revisar(sa,2,false,"Revisión desde página antigua"));
        assertEquals(3,numero("SELECT Estado_idEstado FROM Cita WHERE idCita="+a));
        assertEquals(1,numero("SELECT COUNT(*) FROM Pago WHERE Cita_idCita="+a));
        assertThrows(SQLException.class,()->manual.revisar(sb,2,true,null));
        assertEquals(0,numero("SELECT COUNT(*) FROM Pago WHERE Cita_idCita="+b));
        assertEquals(1,numero("SELECT COUNT(*) FROM SolicitudPago WHERE idSolicitud="+sb+" AND Estado='PENDIENTE'"));
    }
    @Test public void carreraConEfectivoNoDuplicaPagoNiBoleta() throws Exception {
        int id=cita(1,"Web","10:00"),sol=solicitud(id,"CARRERA-"+UUID.randomUUID().toString().substring(0,8).toUpperCase(Locale.ROOT));
        ExecutorService pool=Executors.newFixedThreadPool(2);CountDownLatch listos=new CountDownLatch(2),salida=new CountDownLatch(1);
        try {
            Future<?> a=pool.submit(()->{listos.countDown();salida.await();try{manual.revisar(sol,2,true,null);}catch(SQLException e){assertEquals("45000",e.getSQLState());}return null;});
            Future<?> b=pool.submit(()->{listos.countDown();salida.await();Pago p=new Pago();p.setCita_idCita(id);p.setMetodoPago_idMetodo(2);Comprobante c=new Comprobante();c.setNombreCliente("Paciente Prueba");c.setDniCliente("12345678");new PagoDaoImpl().registrarPagoYComprobante(p,c);return null;});
            assertTrue(listos.await(5,TimeUnit.SECONDS));salida.countDown();a.get(10,TimeUnit.SECONDS);b.get(10,TimeUnit.SECONDS);
            assertEquals(1,numero("SELECT COUNT(*) FROM Pago WHERE Cita_idCita="+id));
            assertEquals(1,numero("SELECT COUNT(*) FROM Comprobante WHERE Pago_idPago IN(SELECT idPago FROM Pago WHERE Cita_idCita="+id+")"));
        }finally{salida.countDown();pool.shutdownNow();}
    }
    @Test public void canceladaRechazaAprobacionYDevolucionConservaBoleta() throws Exception {
        int id=cita(1,"Web","10:00"),sol=solicitud(id,"CANCEL-1234");
        new GestionCitaDao().cambiarEstado(id,5,2,true);
        assertThrows(SQLException.class,()->manual.revisar(sol,2,true,null));
        int otra=cita(3,"Presencial","11:00");pago(otra);new GestionCitaDao().cambiarEstado(otra,5,2,false);
        int pago=numero("SELECT idPago FROM Pago WHERE Cita_idCita="+otra);
        assertEquals(1,numero("SELECT COUNT(*) FROM Devolucion WHERE Pago_idPago="+pago+" AND Estado='PENDIENTE'"));
        assertThrows(SQLException.class,()->manual.devolver(pago,doctor,"DEV-1"));
        manual.devolver(pago,2,"DEV-1");manual.devolver(pago,2,"DEV-2");
        assertEquals(1,numero("SELECT COUNT(*) FROM Devolucion WHERE Pago_idPago="+pago+" AND Estado='REALIZADA' AND Referencia='DEV-1'"));
        assertEquals(1,numero("SELECT COUNT(*) FROM Comprobante WHERE Pago_idPago="+pago));
    }
    @Test public void fichaEsAtomicaExigeTitularYNoPermiteSobrescribir() throws Exception {
        AtencionDao dao=new AtencionDao();int id=cita(4,"Web","10:00");
        assertThrows(SQLException.class,()->dao.registrar(id,doctor,"Diagnóstico","Tratamiento",""));
        try(Statement s=db.createStatement()){s.executeUpdate("UPDATE Cita SET FechaCita='2000-01-03' WHERE idCita="+id);}
        assertThrows(SQLException.class,()->dao.registrar(id,doctor,"Diagnóstico","Tratamiento",""));
        pago(id);assertThrows(SQLException.class,()->dao.registrar(id,2,"Diagnóstico","Tratamiento",""));
        assertThrows(SQLException.class,()->new GestionCitaDao().cambiarEstado(id,2,doctor,true));
        assertNull(dao.consultar(id,2));assertNull(dao.consultar(id,4));
        assertThrows(SQLException.class,()->dao.registrar(id,doctor,"","Tratamiento",""));
        assertEquals(4,numero("SELECT Estado_idEstado FROM Cita WHERE idCita="+id));
        dao.registrar(id,doctor,"Diagnóstico","Tratamiento","Observación");
        assertEquals(2,numero("SELECT Estado_idEstado FROM Cita WHERE idCita="+id));
        assertEquals("Diagnóstico",dao.consultar(id,1).get("Diagnostico"));
        assertThrows(SQLException.class,()->dao.registrar(id,1,"Otro","Otro",""));
        assertEquals(1,numero("SELECT COUNT(*) FROM Atencion WHERE Cita_idCita="+id));
    }
    @Test public void correoTieneTresRolesDeduplicadosYReintentosPorDestinatario() throws Exception {
        int id=cita(1,"Web","10:00");CorreoDao dao=new CorreoDao();dao.encolar(id,1,"Reserva recibida","Su reserva fue recibida");dao.encolar(id,1,"Reserva recibida","Su reserva fue recibida");
        assertEquals(1,numero("SELECT COUNT(*) FROM CorreoPendiente WHERE Cita_idCita="+id+" AND Destinatario='paciente@example.test'"));
        assertEquals(1,numero("SELECT COUNT(*) FROM CorreoPendiente WHERE Cita_idCita="+id+" AND Destinatario='doctor@example.test'"));
        assertTrue(numero("SELECT COUNT(*) FROM CorreoPendiente WHERE Cita_idCita="+id)>=3);
        Map<String,Object> primero=dao.tomar(),segundo=dao.tomar();assertNotNull(primero);assertNotNull(segundo);assertNotEquals(primero.get("id"),segundo.get("id"));
        int correo=numero("SELECT MIN(idCorreo) FROM CorreoPendiente WHERE Cita_idCita="+id);
        dao.resultado(correo,false);assertEquals(1,numero("SELECT COUNT(*) FROM CorreoPendiente WHERE idCorreo="+correo+" AND Estado='PENDIENTE'"));
        dao.resultado(correo,true);dao.reintentar(correo);
        assertEquals(1,numero("SELECT COUNT(*) FROM CorreoPendiente WHERE idCorreo="+correo+" AND Estado='ENVIADO'"));
    }
    @Test public void dosRevisoresNoDuplicanLaBoleta() throws Exception {
        int id=cita(1,"Web","10:00"),sol=solicitud(id,"REV-"+UUID.randomUUID().toString().substring(0,8).toUpperCase(Locale.ROOT));
        ExecutorService pool=Executors.newFixedThreadPool(2);CountDownLatch listos=new CountDownLatch(2),salida=new CountDownLatch(1);
        Callable<Integer> revision=()->{listos.countDown();assertTrue(salida.await(5,TimeUnit.SECONDS));return manual.revisar(sol,2,true,null);};
        try {
            Future<Integer> a=pool.submit(revision),b=pool.submit(revision);assertTrue(listos.await(5,TimeUnit.SECONDS));salida.countDown();assertEquals(Integer.valueOf(id),a.get(10,TimeUnit.SECONDS));assertEquals(Integer.valueOf(id),b.get(10,TimeUnit.SECONDS));
            assertEquals(1,numero("SELECT COUNT(*) FROM Comprobante WHERE Pago_idPago IN(SELECT idPago FROM Pago WHERE Cita_idCita="+id+")"));
        }finally{salida.countDown();pool.shutdownNow();}
    }
    @Test public void luciaTieneFotoEnElListadoDinamicoSinExponerDni() {
        pe.edu.utp.entity.Usuario lucia=new UsuarioDaoImpl().obtenerMedicosDisponibles().stream().filter(u->u.getNombre().toLowerCase(Locale.ROOT).contains("luc")).findFirst().get();
        assertEquals("img/equipo/lucia.jpg",lucia.getFotoPerfil());assertEquals(0,lucia.getDni());
    }
    @Test public void carillasTienePrecioDeReferenciaYAsignacion() throws Exception {
        try(Statement s=db.createStatement();ResultSet r=s.executeQuery("SELECT Costo FROM Servicio WHERE idServicio=8")) {
            assertTrue(r.next());
            assertEquals(0,new java.math.BigDecimal("1500.00").compareTo(r.getBigDecimal(1)));
        }
        assertEquals(0,new java.math.BigDecimal("1500.00").compareTo(new pe.edu.utp.daoImpl.ServicioDaoImpl().ListService(8).getCosto()));
        assertEquals(2,numero("SELECT COUNT(*) FROM Usuario_Servicio WHERE idServicio=8 AND Disponibilidad=1"));
    }
}
