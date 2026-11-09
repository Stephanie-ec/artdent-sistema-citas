package pe.edu.utp.integration;
import java.math.BigDecimal;
import java.sql.*;
import org.junit.Test;
import static org.junit.Assert.*;
import static org.mockito.Mockito.*;
import pe.edu.utp.daoImpl.IngresosDao;
import pe.edu.utp.controller.GeneradorDeReporte;
import pe.edu.utp.dao.*;

public class IngresosIT extends DbFixture {
    @Test public void resumenYMesesCoincidenConPagosRealesAunqueNoEstenCompletados() throws Exception {
        int a=cita(3,"Web","10:00"), b=cita(5,"Presencial","11:00");pago(a);pago(b);
        try(Statement s=db.createStatement()) {
            s.executeUpdate("UPDATE Pago SET Monto=0.10,FechaPago='2026-01-31 23:59:00' WHERE Cita_idCita="+a);
            s.executeUpdate("UPDATE Pago SET Monto=0.20,FechaPago='2026-02-01 00:00:00' WHERE Cita_idCita="+b);
        }
        BigDecimal sql;
        try(Statement s=db.createStatement();ResultSet r=s.executeQuery("SELECT SUM(Monto) FROM Pago")){r.next();sql=r.getBigDecimal(1);}
        assertEquals(0,sql.compareTo(new IngresosDao().total()));
        GeneradorDeReporte reportes=new GeneradorDeReporte(mock(ReservaDao.class),mock(CitaDao.class));
        BigDecimal suma=reportes.generarReporteAd().stream().map(pe.edu.utp.entity.ReporteMensual::getTotalIngresos).reduce(BigDecimal.ZERO,BigDecimal::add);
        assertEquals("F-09: suma mensual igual al resumen",0,sql.compareTo(suma));
        assertEquals(0,new BigDecimal("0.30").compareTo(new IngresosDao().porMes(doctor).values().stream().reduce(BigDecimal.ZERO,BigDecimal::add)));
    }
}
