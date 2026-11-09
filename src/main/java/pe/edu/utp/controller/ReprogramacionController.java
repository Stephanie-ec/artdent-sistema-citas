package pe.edu.utp.controller;

import java.io.IOException;
import java.sql.SQLException;
import javax.servlet.ServletException;
import javax.servlet.http.*;
import pe.edu.utp.dao.*;
import pe.edu.utp.daoImpl.*;
import pe.edu.utp.utils.NotificacionService;
import pe.edu.utp.utils.Validador;

public class ReprogramacionController extends HttpServlet {
    private final GestionCitaDao gestion;
    private final CitaDao citas;
    private final ReservaDao reservas;

    public ReprogramacionController() { this(new GestionCitaDao(),new CitaDaoImpl(),new ReservaDaoImpl()); }
    ReprogramacionController(GestionCitaDao gestion,CitaDao citas,ReservaDao reservas) {
        this.gestion=gestion; this.citas=citas; this.reservas=reservas;
    }
    private boolean permitido(HttpServletRequest req,boolean completar) {
        HttpSession session=req.getSession(false);
        String rol=session==null?"":String.valueOf(session.getAttribute("TipoRol"));
        return "Administrador".equalsIgnoreCase(rol) || (completar?"Odontologo":"Secretaria").equalsIgnoreCase(rol);
    }
    private void error(HttpServletRequest req,HttpServletResponse res,int status,String mensaje) throws ServletException,IOException {
        res.setStatus(status); req.setAttribute("error",mensaje);
        req.setAttribute("volverUrl","ReservaController?accion=listarReservasPorDia");
        req.getRequestDispatcher("error.jsp").forward(req,res);
    }
    @Override protected void doGet(HttpServletRequest req,HttpServletResponse res) throws ServletException,IOException {
        if(!permitido(req,false)) { res.sendError(403); return; }
        try {
            String accion=req.getParameter("accion");
            int id=Integer.parseInt(req.getParameter("id"));
            if("VerReproRe".equals(accion)) {
                java.util.List<pe.edu.utp.entity.VerReserva> lista=reservas.DetalleReserva(id);
                if(lista.isEmpty()){error(req,res,404,"No se encontro la reserva indicada.");return;}
                req.setAttribute("VerReserva",lista); req.setAttribute("tipoLista","DetRe");
            } else if("VerReproCi".equals(accion)) {
                java.util.List<pe.edu.utp.entity.VerCita> lista=citas.DetalleCita(id);
                if(lista.isEmpty()){error(req,res,404,"No se encontro la cita indicada.");return;}
                req.setAttribute("VerCita",lista); req.setAttribute("tipoLista","DetCi");
            } else {error(req,res,400,"Seleccione una accion de reprogramacion valida.");return;}
            req.getRequestDispatcher("Reprogramacion.jsp").forward(req,res);
        } catch(NumberFormatException e) { error(req,res,400,"El identificador de la cita no es valido."); }
          catch(IllegalStateException e) { error(req,res,503,"No se pudo consultar la cita. Intente nuevamente."); }
    }
    @Override protected void doPost(HttpServletRequest req,HttpServletResponse res) throws ServletException,IOException {
        req.setCharacterEncoding("UTF-8");
        String accion=req.getParameter("accion");
        boolean completar="updateEstadoCompletado".equals(accion)||"updateEstadoCompletadoCita".equals(accion);
        if(!permitido(req,completar)) { res.sendError(403); return; }
        try {
            boolean web=accion!=null && !accion.endsWith("Cita") && !"UpdateCita".equals(accion);
            int id=Integer.parseInt(req.getParameter(web?"idReserva":"idCita"));
            int actor=Integer.parseInt(String.valueOf(req.getSession(false).getAttribute("idUsuario")));
            if(id<=0||actor<=0)throw new NumberFormatException();
            String msg; int estado; String asunto; String mensaje;
            if("UpdateReserva".equals(accion)||"UpdateCita".equals(accion)) {
                String fecha=req.getParameter("new-date"),hora=req.getParameter("new-time");
                String invalido=Validador.validarFechaHora(fecha,hora);
                if(invalido!=null) {error(req,res,400,invalido);return;}
                gestion.reprogramar(id,fecha,hora,web);
                msg="reprogramadoOk"; estado=4; asunto="Cita reprogramada";
                mensaje="Su cita se ha reprogramado para "+fecha+" a las "+hora+".";
            } else if("deleteReserva".equals(accion)||"deleteCita".equals(accion)) {
                gestion.eliminar(id,actor,web);
                res.sendRedirect("ReservaController?accion="+(web?"listar":"listarCitas")+"&msg=eliminadoOk"); return;
            } else {
                switch(String.valueOf(accion)) {
                    case "updateEstadoConfirmar": case "updateEstadoConfirmarCita":
                        estado=3; msg="aprobadoOk"; asunto="Cita confirmada"; mensaje="Su cita ha sido confirmada."; break;
                    case "updateEstadoCompletado": case "updateEstadoCompletadoCita":
                        estado=2; msg="completadoOk"; asunto="Atencion completada"; mensaje="Su atencion ha sido registrada como completada."; break;
                    case "updateEstadoCancelar": case "updateEstadoCanceladoCita":
                        estado=5; msg="canceladoOk"; asunto="Cita cancelada";
                        mensaje="Su cita ha sido cancelada. Si tiene un pago registrado, su devolucion queda pendiente de gestion por la clinica."; break;
                    case "rechazarReservaWeb":
                        estado=6; msg="rechazadoOk"; asunto="Reserva rechazada";
                        String motivo=req.getParameter("motivo");
                        mensaje="Su reserva ha sido rechazada. Motivo: "+(motivo==null?"No especificado":motivo.trim())
                                +". Si tiene un pago registrado, su devolucion queda pendiente de gestion por la clinica."; break;
                    default: error(req,res,400,"La accion solicitada no es valida.");return;
                }
                // F-03: nunca se lee el parametro 'estado'; la BD decide sobre el registro bloqueado.
                gestion.cambiarEstado(id,estado,actor,web);
            }
            String correo=notificar(id,estado,asunto,mensaje);
            res.sendRedirect("ReservaController?accion="+(completar||estado==4?"listarReservasPorDia":web?"listar":"listarCitas")+"&msg="+msg+correo);
        } catch(NumberFormatException e) {error(req,res,400,"El identificador o la sesion no son validos. Vuelva a iniciar sesion.");}
          catch(SQLException e) {falloSQL(req,res,e);}
          catch(IllegalStateException e) {error(req,res,503,"No se pudo guardar el cambio. Intente nuevamente.");}
    }
    protected String notificar(int id,int estado,String asunto,String mensaje) {
        try {
            NotificacionService.notificar(id,estado,asunto,gestion.correo(id),mensaje);
            return NotificacionService.sufijoCorreo();
        } catch(SQLException|RuntimeException e) {
            java.util.logging.Logger.getLogger(getClass().getName()).log(java.util.logging.Level.WARNING,"Cambio guardado; fallo al notificar",e);
            NotificacionService.sufijoCorreo(); return "&correo=0";
        }
    }
    private void falloSQL(HttpServletRequest req,HttpServletResponse res,SQLException e) throws ServletException,IOException {
        if("45000".equals(e.getSQLState())) {
            if("sinPago".equals(e.getMessage())) {res.sendRedirect("ReservaController?accion=listar&error=sinPago");return;}
            error(req,res,409,e.getMessage());
        } else {
            java.util.logging.Logger.getLogger(getClass().getName()).log(java.util.logging.Level.SEVERE,"No se pudo modificar la cita",e);
            error(req,res,500,"No se pudo guardar el cambio. Intente nuevamente o contacte al administrador.");
        }
    }
}
