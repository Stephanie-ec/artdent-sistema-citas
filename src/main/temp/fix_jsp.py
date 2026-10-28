import codecs
import re

path = 'src/main/webapp/formularioreserva.jsp'

with open(path, 'rb') as f:
    data = f.read()

try:
    content = data.decode('utf-8')
    encoding = 'utf-8'
except UnicodeDecodeError:
    content = data.decode('latin1')
    encoding = 'latin1'

replacement = """                <div class="mb-3">
                    <label for="motivo" class="form-label">Motivo (Servicio)</label>
                    <select class="form-select" id="motivo" name="motivo" onchange="actualizarPrecio()" required>
                        <option value="">Seleccionar</option>
                        <%@page import="java.util.List"%>
                        <%@page import="pe.edu.utp.dao.ServicioDao"%>
                        <%@page import="pe.edu.utp.daoImpl.ServicioDaoImpl"%>
                        <%@page import="pe.edu.utp.entity.Servicio"%>
                        <%@page import="pe.edu.utp.dao.UsuarioDao"%>
                        <%@page import="pe.edu.utp.daoImpl.UsuarioDaoImpl"%>
                        <%@page import="pe.edu.utp.entity.Usuario"%>
                        <%
                            ServicioDao servicioDao = new ServicioDaoImpl();
                            List<Servicio> serviciosList = servicioDao.listarServicios();
                            request.setAttribute("serviciosList", serviciosList);

                            UsuarioDao usuarioDao = new UsuarioDaoImpl();
                            List<Usuario> doctoresList = usuarioDao.obtenerMedicosDisponibles();
                            request.setAttribute("doctoresList", doctoresList);
                        %>
                        <c:forEach var="serv" items="${serviciosList}">
                            <option value="${serv.tipoServicio}" data-costo="${serv.costo}" data-id="${serv.idServicio}">
                                ${serv.tipoServicio}
                            </option>
                        </c:forEach>
                    </select>
                </div>

                <input type="hidden" name="precio_consulta" id="precio_consulta">
                <input type="hidden" name="idServicio" id="idServicio">

                <div class="mb-3">
                    <label for="pago" class="form-label">Total a pagar</label>
                    <input type="number" class="form-control" id="pago" name="pago" readonly required>
                </div>
                <div class="mb-3">
                    
                    <label for="medico" class="form-label">Médico Asignado</label>
                    <select class="form-select" id="medico" name="medico">
                        <c:forEach var="doc" items="${doctoresList}">
                            <option value="${doc.idUsuario}">${doc.apellido}, ${doc.nombre}</option>
                        </c:forEach>
                    </select>
                </div>"""

pattern = re.compile(r'<div class="mb-3">\s*<label for="motivo".*?<select class="form-select" id="medico" name="medico">.*?</select>\s*</div>', re.DOTALL)

if pattern.search(content):
    content = pattern.sub(replacement, content)
    with open(path, 'wb') as f:
        f.write(content.encode(encoding))
    print('Replaced successfully')
else:
    print('Pattern not found')

