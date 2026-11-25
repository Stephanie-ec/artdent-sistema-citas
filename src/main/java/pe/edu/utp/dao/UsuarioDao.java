package pe.edu.utp.dao;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;
import pe.edu.utp.dto.InicioSesionDTO;
import pe.edu.utp.dto.LoginResultDTO;
import pe.edu.utp.entity.Usuario;

/**
 *
 * @author Christhian
 */
public interface UsuarioDao {

    public List<InicioSesionDTO> login(String dni, String password);

    LoginResultDTO autenticar(String dni, String password);

    boolean resetearBloqueo(int idUsuario);

    /** R-08: cambia la clave del propio usuario y retira la obligación de cambiarla. */
    boolean cambiarClave(int idUsuario, String nuevoHash);

    /** R-08: deja una clave temporal y obliga al cambio en el siguiente ingreso. */
    boolean restablecerClaveTemporal(int idUsuario, String hashTemporal);

    List<Usuario> obtenerMedicosDisponibles();

    List<Usuario> obtenerMedicosPorServicioYDisponibilidad(int idServicio, LocalDate fechaConv, LocalTime horaObj);

    public List<Usuario> listarUsuarios();

    public boolean registrarUsuario(Usuario usuario);
    boolean existeDni(String dni, int excluirId);

    public boolean actualizarUsuario(Usuario usuario);

    public boolean eliminarUsuario(int id);

    public Usuario obtenerUsuarioPorId(int id);

    List<pe.edu.utp.entity.Horario> listarHorarios();

    List<Integer> obtenerHorariosPorUsuario(int idUsuario);

    List<Integer> obtenerServiciosPorUsuario(int idUsuario);

    boolean asignarDisponibilidad(int idUsuario, List<Integer> horariosIds, List<Integer> serviciosIds);

}
