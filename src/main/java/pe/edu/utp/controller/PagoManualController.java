package pe.edu.utp.controller;

import java.io.*;
import java.nio.file.*;
import java.sql.SQLException;
import java.util.*;
import javax.servlet.*;
import javax.servlet.annotation.*;
import javax.servlet.http.*;
import pe.edu.utp.daoImpl.PagoManualDao;
import pe.edu.utp.utils.*;

@WebServlet("/PagoManualController")
@MultipartConfig(maxFileSize=5242880,maxRequestSize=5505024,fileSizeThreshold=0)
public class PagoManualController extends HttpServlet {
    private final PagoManualDao dao=new PagoManualDao();
    private boolean personal(HttpServletRequest req) {
        HttpSession s=req.getSession(false);Object rol=s==null?null:s.getAttribute("TipoRol");
        return "Administrador".equals(rol)||"Secretaria".equals(rol);
    }
    private boolean propia(HttpServletRequest req,int cita) {
        HttpSession s=req.getSession(false);if(s==null)return false;
        Object ids=s.getAttribute("citasPropias"),creada=s.getAttribute("reservaIdCita");
        return (ids instanceof Set&&((Set<?>)ids).contains(cita))||(creada!=null&&String.valueOf(cita).equals(creada.toString()));
    }
    private boolean configurado() {
        String titular=ConfigLoader.getProperty("pagos.titular"),numero=ConfigLoader.getProperty("pagos.numero"),dir=ConfigLoader.getProperty("pagos.adjuntos.dir");
        return titular!=null&&!titular.trim().isEmpty()&&numero!=null&&numero.matches("9[0-9]{8}")&&dir!=null&&!dir.trim().isEmpty();
    }
    static boolean admiteSolicitud(Integer estado,boolean pagada,boolean pendiente) {
        return estado!=null&&Arrays.asList(1,3,4).contains(estado)&&!pagada&&!pendiente;
    }
    @Override protected void doGet(HttpServletRequest req,HttpServletResponse res) throws ServletException,IOException {
        try {
            HttpSession sesion=req.getSession(false);
            if(!personal(req)&&(sesion==null||(sesion.getAttribute("citasPropias")==null&&sesion.getAttribute("reservaIdCita")==null))){res.sendError(403);return;}
            if("adjunto".equals(req.getParameter("accion"))) {
                Map<String,Object> datos=dao.adjunto(Integer.parseInt(req.getParameter("id")));
                if(datos==null){res.sendError(404);return;}
                if(!personal(req)&&!propia(req,(Integer)datos.get("cita"))){res.sendError(403);return;}
                String nombre=String.valueOf(datos.get("archivo"));if(!nombre.matches("[a-f0-9-]{36}\\.png")){res.sendError(404);return;}
                Path ruta=ComprobanteAdjunto.directorio(getServletContext().getRealPath("/")).resolve(nombre);
                if(!Files.isRegularFile(ruta,LinkOption.NOFOLLOW_LINKS)){res.sendError(404);return;}
                res.setContentType("image/png");res.setHeader("X-Content-Type-Options","nosniff");res.setHeader("Content-Disposition","inline; filename=comprobante.png");
                Files.copy(ruta,res.getOutputStream());return;
            }
            Integer cita=null;
            if(req.getParameter("cita")!=null)cita=Integer.valueOf(req.getParameter("cita"));
            if(!personal(req)&&(cita==null||!propia(req,cita))){res.sendError(403);return;}
            req.setAttribute("personalPagos",personal(req));req.setAttribute("citaPago",cita);
            List<Map<String,Object>> solicitudes=dao.solicitudes(cita);
            req.setAttribute("solicitudes",solicitudes);req.setAttribute("devoluciones",dao.devoluciones(cita));
            req.setAttribute("canalConfigurado",configurado());req.setAttribute("titularPago",ConfigLoader.getProperty("pagos.titular"));req.setAttribute("numeroPago",ConfigLoader.getProperty("pagos.numero"));
            if(cita!=null) {
                pe.edu.utp.daoImpl.PagoDaoImpl pagos=new pe.edu.utp.daoImpl.PagoDaoImpl();
                req.setAttribute("importePago",pagos.obtenerCostoServicioPorCita(cita));
                req.setAttribute("permiteSolicitud",admiteSolicitud(pagos.obtenerEstadoCita(cita),pagos.tienePago(cita),solicitudes.stream().anyMatch(s->"PENDIENTE".equals(s.get("estado")))));
            }
            FormToken.obtener(req);req.getRequestDispatcher("/WEB-INF/pagos-manuales.jsp").forward(req,res);
        } catch(NumberFormatException e){res.sendError(400);}
          catch(SQLException|IllegalStateException e){error(req,res,503,"No se pudieron consultar los pagos. Intente nuevamente.");}
    }
    @Override protected void doPost(HttpServletRequest req,HttpServletResponse res) throws ServletException,IOException {
        req.setCharacterEncoding("UTF-8");Path guardada=null;boolean registrada=false;
        try {
            if(!FormToken.valido(req)){res.sendError(403);return;}
            String accion=req.getParameter("accion");
            if("solicitar".equals(accion)) {
                int cita=Integer.parseInt(req.getParameter("cita"));if(!propia(req,cita)){res.sendError(403);return;}
                if(!configurado()){error(req,res,409,"Yape/Plin está pendiente de configuración. Puede pagar en ventanilla.");return;}
                Part parte=req.getPart("comprobante");if(parte==null||parte.getSize()==0){error(req,res,400,"Adjunte su comprobante JPEG o PNG.");return;}
                byte[] imagen;try(InputStream in=parte.getInputStream()){imagen=ComprobanteAdjunto.validar(in);}
                String archivo=UUID.randomUUID().toString()+".png";
                guardada=ComprobanteAdjunto.directorio(getServletContext().getRealPath("/")).resolve(archivo);
                Files.write(guardada,imagen,StandardOpenOption.CREATE_NEW);
                dao.solicitar(cita,req.getParameter("canal"),texto(req,"codigo").toUpperCase(Locale.ROOT),archivo,texto(req,"nombre"),texto(req,"dni"));registrada=true;
                NotificacionService.notificar(cita,1,"Comprobante recibido",null,"Se recibió un comprobante de pago para revisión. Consulte el estado en el portal de ArtDent.");
                res.sendRedirect("PagoManualController?cita="+cita+"&guardado=1");
            } else {
                if(!personal(req)){res.sendError(403);return;}
                int actor=Integer.parseInt(String.valueOf(req.getSession().getAttribute("idUsuario")));
                if("aprobar".equals(accion)||"rechazar".equals(accion)) {
                    if("aprobar".equals(accion)&&!"si".equals(req.getParameter("verificado"))){error(req,res,400,"Confirme primero la verificación del movimiento bancario.");return;}
                    PagoManualDao.Revision revision=dao.revisarResultado(Integer.parseInt(req.getParameter("id")),actor,"aprobar".equals(accion),req.getParameter("motivo"));
                    if(revision.modificada)NotificacionService.notificar(revision.cita,"aprobar".equals(accion)?3:1,"aprobar".equals(accion)?"Pago verificado":"Comprobante rechazado",null,
                            "aprobar".equals(accion)?"Su pago fue verificado. Puede consultar su reserva y descargar su boleta.":"Su comprobante no pudo ser validado. Consulte el motivo en Mi reserva y adjunte un nuevo comprobante.");
                } else if("devolver".equals(accion)) {
                    int cita=dao.devolver(Integer.parseInt(req.getParameter("pago")),actor,req.getParameter("referencia"));
                    NotificacionService.notificar(cita,5,"Devolución registrada",null,"La clínica registró la devolución de su pago. Puede consultar la referencia en Mi reserva.");
                }
                else {res.sendError(400);return;}
                res.sendRedirect("PagoManualController?guardado=1");
            }
        } catch(NumberFormatException e){error(req,res,400,"Revise el identificador de la cita o solicitud.");}
          catch(SQLException e){error(req,res,"45000".equals(e.getSQLState())||"23000".equals(e.getSQLState())?409:503,
                  "45000".equals(e.getSQLState())?e.getMessage():"No se pudo guardar; verifique si la operación ya fue utilizada o la cita ya está pagada.");}
          catch(IllegalStateException e){error(req,res,400,"El archivo supera el tamaño permitido o el servicio no está disponible.");}
          catch(IOException e){error(req,res,400,"No se pudo procesar el comprobante. Use JPEG/PNG de hasta 5 MB y 12 megapíxeles.");}
        finally {if(guardada!=null&&!registrada)try{Files.deleteIfExists(guardada);}catch(IOException e){java.util.logging.Logger.getLogger(getClass().getName()).log(java.util.logging.Level.WARNING,"No se pudo retirar el adjunto huérfano",e);}}
    }
    private String texto(HttpServletRequest r,String clave){String v=r.getParameter(clave);return v==null?"":v.trim();}
    private void error(HttpServletRequest req,HttpServletResponse res,int status,String mensaje) throws ServletException,IOException {
        res.setStatus(status);req.setAttribute("error",mensaje);req.setAttribute("volverUrl","consultareserva.jsp");req.getRequestDispatcher("/error.jsp").forward(req,res);
    }
}
