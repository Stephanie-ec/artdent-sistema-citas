/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package pe.edu.utp.controller;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.List;
import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import pe.edu.utp.dao.UsuarioDao;
import pe.edu.utp.daoImpl.UsuarioDaoImpl;
import pe.edu.utp.entity.Usuario;

/**
 *
 * @author alex0
 */
@WebServlet("/UsuarioController")
public class UsuarioController extends HttpServlet {

    private final UsuarioDao usuarioDAO;
    public UsuarioController() { this(new UsuarioDaoImpl()); }
    UsuarioController(UsuarioDao dao) { this.usuarioDAO=dao; }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        if (action == null || action.trim().isEmpty()) {
            action = "list";
        }
        switch (action) {
            case "list":
                listUsuarios(request, response);
                break;
            case "add":
                showAddForm(request, response);
                break;
            case "edit":
                showEditForm(request, response);
                break;
            case "delete":
                response.sendError(405,"Use el formulario para desactivar un usuario.");
                break;
            case "disponibilidad":
                showDisponibilidadForm(request, response);
                break;
            default:
                listUsuarios(request, response);
                break;
        }
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        if (action == null || action.trim().isEmpty()) {
            action = "list";
        }
        try { switch (action) {
            case "delete":
                deleteUsuario(request,response);
                break;
            case "add":
                addUsuario(request, response);
                break;
            case "update":
                updateUsuario(request, response);
                break;
            case "guardarDisponibilidad":
                guardarDisponibilidad(request, response);
                break;

            default:
                listUsuarios(request, response);
                break;
        }
        } catch(IllegalArgumentException e) { aviso(response,"El identificador o los datos enviados no son validos."); }
    }

    private void listUsuarios(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        RequestDispatcher dispatcher = request.getRequestDispatcher("ADMPUsuarios.jsp");
        request.setAttribute("usuarios", usuarioDAO.listarUsuarios());
        request.setAttribute("roles", new pe.edu.utp.daoImpl.RolDaoImpl().listarRoles());
        dispatcher.forward(request, response);
    }

    private void showAddForm(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        RequestDispatcher dispatcher = request.getRequestDispatcher("ADMPUsuarios.jsp");
        request.setAttribute("roles", new pe.edu.utp.daoImpl.RolDaoImpl().listarRoles());
        dispatcher.forward(request, response);
    }

    private void addUsuario(HttpServletRequest request,HttpServletResponse response) throws IOException {
        guardarUsuario(request,response,true);
    }

    private static String texto(HttpServletRequest r,String clave) {
        String valor=r.getParameter(clave);return valor==null?"":valor.trim();
    }
    private void aviso(HttpServletResponse res,String mensaje) throws IOException {
        res.sendRedirect("UsuarioController?action=list&error="+java.net.URLEncoder.encode(mensaje,"UTF-8"));
    }
    private void guardarUsuario(HttpServletRequest req,HttpServletResponse res,boolean nuevo) throws IOException {
        try {
            String dni=texto(req,"dni"),nombre=texto(req,"nombre"),apellido=texto(req,"apellido");
            String error=pe.edu.utp.utils.Validador.validarNombreApellido(nombre,apellido);
            if(error==null)error=pe.edu.utp.utils.Validador.validarDniTelefono(dni,texto(req,"telefono"));
            String correo=texto(req,"email"),direccion=texto(req,"direccion");
            if(error==null && (!correo.matches("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$") || correo.length()>100))error="Ingrese un correo electronico valido.";
            if(error==null && (direccion.isEmpty()||direccion.length()>100))error="Ingrese una direccion de hasta 100 caracteres.";
            String clave=req.getParameter("clave"); if(clave==null)clave="";
            if(error==null && ((nuevo||!clave.isEmpty()) && (clave.length()<6||clave.length()>30)))error="La contrasena debe tener entre 6 y 30 caracteres.";
            if(error!=null){aviso(res,error);return;}
            java.time.LocalDate nacimiento=java.time.LocalDate.parse(texto(req,"fechanacimiento"));
            if(nacimiento.isAfter(java.time.LocalDate.now(java.time.ZoneId.of("America/Lima")))){aviso(res,"La fecha de nacimiento no puede ser futura.");return;}
            int rol=Integer.parseInt(texto(req,"rol")),id=nuevo?0:Integer.parseInt(texto(req,"id"));
            if(rol<1||rol>3||(!nuevo&&id<=0)){aviso(res,"Seleccione un usuario y un rol validos.");return;}
            if(usuarioDAO.existeDni(dni,id)){aviso(res,"El DNI ya se encuentra registrado.");return;}
            if(nuevo) {
                error=pe.edu.utp.utils.ReniecService.validarIdentidad(dni,nombre,apellido);
                if(error!=null){aviso(res,error);return;}
            }
            Usuario usuario=new Usuario(id,nombre,apellido,Integer.parseInt(dni),texto(req,"telefono"),correo,direccion,nacimiento.toString(),clave,rol);
            boolean ok=nuevo?usuarioDAO.registrarUsuario(usuario):usuarioDAO.actualizarUsuario(usuario);
            if(!ok){aviso(res,"No se pudo guardar el usuario. Verifique el DNI e intente nuevamente.");return;}
            if(nuevo&&rol==3)res.sendRedirect("UsuarioController?action=disponibilidad&id="+usuario.getIdUsuario()+"&msg=configureDisponibilidad");
            else res.sendRedirect("UsuarioController?action=list&msg="+(nuevo?"usuarioCreadoOk":"usuarioActualizadoOk"));
        } catch(java.time.format.DateTimeParseException|NumberFormatException e) {
            aviso(res,"Revise la fecha de nacimiento, el DNI y el rol del usuario.");
        } catch(IllegalStateException e) { aviso(res,"No se pudo verificar o guardar el usuario. Intente nuevamente."); }
    }

    private void showEditForm(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        Usuario existingUsuario = getUsuario(id);
        RequestDispatcher dispatcher = request.getRequestDispatcher("ADMPeditarUsuario.jsp");
        request.setAttribute("usuario", existingUsuario);
        request.setAttribute("roles", new pe.edu.utp.daoImpl.RolDaoImpl().listarRoles());
        dispatcher.forward(request, response);
    }

    private void updateUsuario(HttpServletRequest req,HttpServletResponse res) throws IOException {
        guardarUsuario(req,res,false);
    }

    private Usuario getUsuario(int id) {
        return usuarioDAO.obtenerUsuarioPorId(id);
    }

    private void deleteUsuario(HttpServletRequest request, HttpServletResponse response) throws IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        if (id == Integer.parseInt(String.valueOf(request.getSession().getAttribute("idUsuario")))) { aviso(response,"No puede desactivar su propia cuenta."); return; }
        if (!usuarioDAO.eliminarUsuario(id)) { aviso(response,"No se pudo desactivar el usuario."); return; }
        response.sendRedirect("UsuarioController?action=list&msg=usuarioDesactivadoOk");
    }

    private void showDisponibilidadForm(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String idStr = request.getParameter("id");
        List<Usuario> odontologos = usuarioDAO.obtenerMedicosDisponibles();
        request.setAttribute("odontologos", odontologos);

        Usuario odontologoSeleccionado = null;
        if (idStr != null && !idStr.isEmpty()) {
            int id = Integer.parseInt(idStr);
            odontologoSeleccionado = usuarioDAO.obtenerUsuarioPorId(id);
        } else if (!odontologos.isEmpty()) {
            // Se carga el registro completo (DNI y correo), no solo el nombre de la lista
            odontologoSeleccionado = usuarioDAO.obtenerUsuarioPorId(odontologos.get(0).getIdUsuario());
        }

        if (odontologoSeleccionado != null) {
            request.setAttribute("odontologo", odontologoSeleccionado);
            request.setAttribute("horariosAsignados", usuarioDAO.obtenerHorariosPorUsuario(odontologoSeleccionado.getIdUsuario()));
            request.setAttribute("serviciosAsignados", usuarioDAO.obtenerServiciosPorUsuario(odontologoSeleccionado.getIdUsuario()));
        }

        request.setAttribute("todosHorarios", usuarioDAO.listarHorarios());
        request.setAttribute("todosServicios", new pe.edu.utp.daoImpl.ServicioDaoImpl().listarTodosLosServicios());

        RequestDispatcher dispatcher = request.getRequestDispatcher("ADMPDisponibilidad.jsp");
        dispatcher.forward(request, response);
    }

    private void guardarDisponibilidad(HttpServletRequest request, HttpServletResponse response) throws IOException {
        int idUsuario = Integer.parseInt(request.getParameter("idUsuario"));
        String[] horariosArr = request.getParameterValues("horarios");
        String[] serviciosArr = request.getParameterValues("servicios");

        List<Integer> horariosIds = new ArrayList<>();
        if (horariosArr != null) {
            for (String h : horariosArr) {
                horariosIds.add(Integer.parseInt(h));
            }
        }

        List<Integer> serviciosIds = new ArrayList<>();
        if (serviciosArr != null) {
            for (String s : serviciosArr) {
                serviciosIds.add(Integer.parseInt(s));
            }
        }

        if (!usuarioDAO.asignarDisponibilidad(idUsuario, horariosIds, serviciosIds)) { aviso(response,"No se pudo guardar la disponibilidad.");return; }
        response.sendRedirect("UsuarioController?action=disponibilidad&id=" + idUsuario + "&guardado=ok");
    }

}
