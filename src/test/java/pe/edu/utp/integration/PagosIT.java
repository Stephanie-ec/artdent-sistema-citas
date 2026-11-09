package pe.edu.utp.integration;
import pe.edu.utp.daoImpl.PagoDaoImpl;
import pe.edu.utp.entity.*;
import java.sql.Statement;
import java.util.concurrent.*;
import org.junit.Test;
import static org.junit.Assert.*;

public class PagosIT extends DbFixture {
    @Test public void falloDeBoletaReviertePagoYCorrelativo() throws Exception {
        int id=cita(1,"Web","10:00"),antes=numero("SELECT Ultimo FROM CorrelativoComprobante WHERE Serie='B001'");
        Pago p=new Pago();p.setCita_idCita(id);p.setMonto(100);p.setMetodoPago_idMetodo(2);
        Comprobante co=new Comprobante();co.setSerie("B001");co.setNombreCliente("Paciente Prueba");co.setDniCliente("DNI invalido");
        assertFalse(new PagoDaoImpl().registrarPagoYComprobante(p,co));
        assertEquals(0,numero("SELECT COUNT(*) FROM Pago WHERE Cita_idCita="+id));
        assertEquals(antes,numero("SELECT Ultimo FROM CorrelativoComprobante WHERE Serie='B001'"));
    }
    @Test public void carreraDePagoYCancelacionNoDejaPagoSinAvisoDeDevolucion() throws Exception {
        int id=cita(1,"Web","10:00");ExecutorService pool=Executors.newFixedThreadPool(2);
        CountDownLatch listos=new CountDownLatch(2),salida=new CountDownLatch(1);
        try {
            Future<Boolean> pago=pool.submit(()->{listos.countDown();assertTrue(salida.await(5,TimeUnit.SECONDS));return cobrar(id);});
            Future<?> cancelacion=pool.submit(()->{listos.countDown();assertTrue(salida.await(5,TimeUnit.SECONDS));new pe.edu.utp.daoImpl.GestionCitaDao().cambiarEstado(id,5,2,true);return null;});
            assertTrue(listos.await(5,TimeUnit.SECONDS));salida.countDown();boolean pagado=pago.get(10,TimeUnit.SECONDS);cancelacion.get(10,TimeUnit.SECONDS);
            assertEquals(5,numero("SELECT Estado_idEstado FROM Cita WHERE idCita="+id));
            assertEquals(pagado?1:0,numero("SELECT COUNT(*) FROM Pago WHERE Cita_idCita="+id));
            assertEquals(pagado?1:0,numero("SELECT COUNT(*) FROM Notificacion WHERE Cita_idCita="+id+" AND Asunto LIKE 'Devolucion pendiente%'"));
        } finally {salida.countDown();pool.shutdownNow();}
    }
    @Test public void pagoHistoricoSinBoletaTambienSeMarcaComoPagado() throws Exception {
        int a=cita(3,"Web","10:00"),b=cita(3,"Presencial","11:00");
        insertar("INSERT INTO Pago(Monto,MetodoPago_idMetodo,Cita_idCita) VALUES(100,2,"+a+")");
        insertar("INSERT INTO Pago(Monto,MetodoPago_idMetodo,Cita_idCita) VALUES(100,2,"+b+")");
        String dni=String.valueOf(numero("SELECT DNI FROM Paciente WHERE idPaciente="+paciente));
        java.util.Map<String,Object> consulta=new PagoDaoImpl().consultarReserva(a,dni);
        assertEquals(Boolean.TRUE,consulta.get("pagado"));assertEquals(Boolean.FALSE,consulta.get("boletaDisponible"));
        assertNull(new PagoDaoImpl().consultarReserva(a,"00000000"));
        assertTrue(new pe.edu.utp.daoImpl.ReservaDaoImpl().listarReservas(doctor).stream().filter(r->r.getIdReserva()==a).findFirst().get().isTienePago());
        assertTrue(new pe.edu.utp.daoImpl.CitaDaoImpl().listarCitas(doctor).stream().filter(c->c.getIdCita()==b).findFirst().get().isTienePago());
    }
    @Test public void cobraCitaLegadaConImporteCeroAlCostoDelServicio() throws Exception {
        int id=cita(1,"Web","10:00"),costo=numero("SELECT Costo FROM Servicio WHERE idServicio=1");
        try(Statement s=db.createStatement()){s.executeUpdate("UPDATE Cita SET Importe=0 WHERE idCita="+id);}
        assertTrue("Un importe guardado en cero debe cobrarse al costo del servicio",cobrar(id));
        assertEquals(1,numero("SELECT COUNT(*) FROM Pago WHERE Cita_idCita="+id));
        assertEquals(costo,numero("SELECT ROUND(Monto) FROM Pago WHERE Cita_idCita="+id));
    }

    private boolean cobrar(int id) {
        Pago p=new Pago();p.setCita_idCita(id);p.setMonto(100);p.setMetodoPago_idMetodo(2);p.setCodigoTransaccion(java.util.UUID.randomUUID().toString());
        Comprobante c=new Comprobante();c.setSerie("B001");c.setNombreCliente("Paciente Prueba");c.setDniCliente("12345678");
        return new PagoDaoImpl().registrarPagoYComprobante(p,c);
    }
    @Test public void noCobraCanceladaNiRechazada() throws Exception {
        int a=cita(5,"Web","10:00"),b=cita(6,"Web","11:00");
        assertFalse("F-10: cita cancelada no admite pagos",cobrar(a));assertFalse(cobrar(b));
        assertEquals(0,numero("SELECT COUNT(*) FROM Pago WHERE Cita_idCita IN("+a+","+b+")"));
    }
    @Test public void dosCobrosDeLaMismaCitaCreanUnPagoYUnaBoleta() throws Exception {
        int id=cita(1,"Web","10:00");ExecutorService pool=Executors.newFixedThreadPool(2);
        CountDownLatch listos=new CountDownLatch(2),salida=new CountDownLatch(1);
        Callable<Boolean> intento=()->{listos.countDown();assertTrue(salida.await(5,TimeUnit.SECONDS));return cobrar(id);};
        try {
            Future<Boolean>a=pool.submit(intento),b=pool.submit(intento);assertTrue(listos.await(5,TimeUnit.SECONDS));salida.countDown();
            assertEquals(1,(a.get(10,TimeUnit.SECONDS)?1:0)+(b.get(10,TimeUnit.SECONDS)?1:0));
            assertEquals(1,numero("SELECT COUNT(*) FROM Pago WHERE Cita_idCita="+id));
            assertEquals(1,numero("SELECT COUNT(*) FROM Comprobante WHERE Pago_idPago IN(SELECT idPago FROM Pago WHERE Cita_idCita="+id+")"));
        } finally {salida.countDown();pool.shutdownNow();}
    }
    @Test public void cobrosDistintosConcurrentesObtienenCorrelativosDistintos() throws Exception {
        int a=cita(1,"Web","10:00"),b=cita(1,"Web","11:00");ExecutorService pool=Executors.newFixedThreadPool(2);
        CountDownLatch listos=new CountDownLatch(2),salida=new CountDownLatch(1);
        try {
            Future<Boolean>x=pool.submit(()->{listos.countDown();assertTrue(salida.await(5,TimeUnit.SECONDS));return cobrar(a);});
            Future<Boolean>y=pool.submit(()->{listos.countDown();assertTrue(salida.await(5,TimeUnit.SECONDS));return cobrar(b);});
            assertTrue(listos.await(5,TimeUnit.SECONDS));salida.countDown();assertTrue(x.get(10,TimeUnit.SECONDS));assertTrue(y.get(10,TimeUnit.SECONDS));
            assertEquals(2,numero("SELECT COUNT(DISTINCT Numero) FROM Comprobante WHERE Pago_idPago IN(SELECT idPago FROM Pago WHERE Cita_idCita IN("+a+","+b+"))"));
        } finally {salida.countDown();pool.shutdownNow();}
    }
}
