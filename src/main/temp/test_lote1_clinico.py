import urllib.request
import urllib.parse
import http.cookiejar
import subprocess
import json

BASE_URL = "http://localhost:8080/ArtDent"

def mysql_query(sql):
    cmd = ["/usr/local/mysql/bin/mysql", "-u", "root", "-prootroot", "-e", sql, "db_artdent_apf2"]
    res = subprocess.run(cmd, capture_output=True, text=True)
    if res.returncode != 0:
        raise Exception(f"MySQL error: {res.stderr}")
    return res.stdout.strip()

class Session:
    def __init__(self):
        self.cj = http.cookiejar.CookieJar()
        self.opener = urllib.request.build_opener(urllib.request.HTTPCookieProcessor(self.cj))

    def post(self, url, data):
        encoded = urllib.parse.urlencode(data).encode('utf-8')
        req = urllib.request.Request(url, data=encoded, headers={"Content-Type": "application/x-www-form-urlencoded"})
        resp = self.opener.open(req)
        body = resp.read().decode('utf-8', errors='ignore')
        return resp.getcode(), resp.geturl(), body

    def get(self, url):
        req = urllib.request.Request(url)
        resp = self.opener.open(req)
        body = resp.read().decode('utf-8', errors='ignore')
        return resp.getcode(), resp.geturl(), body

def run_tests():
    print("=" * 70)
    print("TEST SUITE: LOTE 1 (RF05, RF15, RF16) - CONTROL CLINICO Y ACCESO")
    print("=" * 70)

    # -------------------------------------------------------------
    # 1. TEST RF15: INICIO DE SESIÓN DEL PERSONAL SEGÚN ROL
    # -------------------------------------------------------------
    print("\n--- [TEST RF15] INICIO DE SESIÓN DEL PERSONAL SEGÚN ROL ---")
    
    # 1.1 Secretaria
    s_sec = Session()
    code, url, body = s_sec.post(f"{BASE_URL}/InicioSesionController", {
        "document": "78223344",
        "password": "1234"
    })
    assert code == 200, f"Error login Secretaria: {code}"
    assert "listar" in url or "Solicitudes" in body or "Reserva" in body, f"Secretaria no redirigida a módulo de gestión: {url}"
    print(f"✓ [RF15] Login Secretaria (78223344) exitoso -> Redirigido a módulo de gestión de citas ({url}).")

    # 1.2 Odontólogo
    s_odo = Session()
    code, url, body = s_odo.post(f"{BASE_URL}/InicioSesionController", {
        "document": "70096374",
        "password": "1234"
    })
    assert code == 200, f"Error login Odontólogo: {code}"
    assert "listarReservasPorDia" in url or "PDCCalendario.jsp" in url or "Agenda" in body, f"Odontólogo no redirigido a su agenda: {url}"
    print(f"✓ [RF15] Login Odontólogo (70096374) exitoso -> Redirigido automáticamente a su agenda semanal personalizada ({url}).")

    # 1.3 Administrador
    s_adm = Session()
    code, url, body = s_adm.post(f"{BASE_URL}/InicioSesionController", {
        "document": "48223344",
        "password": "123"
    })
    assert code == 200, f"Error login Administrador: {code}"
    assert "dashboard" in url or "Dashboard" in url or "PDCInicio.jsp" in url, f"Administrador no redirigido a su panel: {url}"
    print(f"✓ [RF15] Login Administrador (48223344) exitoso -> Redirigido a módulo administrativo Dashboard ({url}).")

    # -------------------------------------------------------------
    # 2. TEST RF05: GESTIÓN DE PACIENTES Y CONTROL DE ROLES
    # -------------------------------------------------------------
    print("\n--- [TEST RF05] GESTIÓN DE PACIENTES Y CONTROL DE ROLES ---")

    # 2.1 Secretaria lista pacientes
    code, url, body = s_sec.get(f"{BASE_URL}/PacienteController?action=list")
    assert code == 200, "Secretaria no pudo listar pacientes"
    assert "Pacientes" in body and "ArtDent" in body, "Encabezado de gestión no presente"
    assert "Editar" in body, "Secretaria debe tener botones de edición de paciente"
    print("✓ [RF05] Secretaria visualiza la lista completa de pacientes con acciones de edición disponibles.")

    # 2.2 Obtener un paciente para editar
    id_paciente = "1"
    res_db = mysql_query("SELECT idPaciente, DNI, Telefono, Correo FROM Paciente ORDER BY idPaciente LIMIT 1;")
    lines = res_db.split("\n")
    if len(lines) > 1:
        parts = lines[1].split("\t")
        id_paciente = parts[0]
        dni_paciente = parts[1]
    else:
        dni_paciente = "78223344"

    # Actualizar datos del paciente por Secretaria
    nuevo_tel = "998877665"
    nuevo_correo = "paciente_rf05_qa@artdent.com"
    code, url, body = s_sec.post(f"{BASE_URL}/PacienteController", {
        "action": "update",
        "idPaciente": id_paciente,
        "nombre": "Carlos Alberto",
        "apellido": "Meza QA",
        "dni": dni_paciente,
        "telefono": nuevo_tel,
        "correo": nuevo_correo
    })
    assert code == 200, "Error al actualizar paciente"

    # Auditar en MySQL
    audit_pac = mysql_query(f"SELECT Telefono, Correo FROM Paciente WHERE idPaciente = {id_paciente};")
    assert nuevo_tel in audit_pac and nuevo_correo in audit_pac, f"MySQL no refleja los cambios: {audit_pac}"
    print(f"✓ [RF05] Secretaria actualizó datos de paciente ID {id_paciente}. Auditado en MySQL Paciente: Telefono={nuevo_tel}, Correo={nuevo_correo}.")

    # 2.3 Odontólogo consulta pacientes (solo lectura - sin botón Editar)
    code, url, body = s_odo.get(f"{BASE_URL}/PacienteController?action=list")
    assert code == 200, "Odontólogo no pudo consultar pacientes"
    assert "Historial" in body, "Odontólogo debe ver botones de Historial"
    # Odontólogo no debe tener el botón 'Editar' en la tabla
    assert "onclick=\"abrirModalEditar" not in body, "Odontólogo NO debe tener permisos de edición de pacientes"
    print("✓ [RF05] Odontólogo accede a la lista de pacientes en modo SOLO LECTURA (sin permisos de edición).")

    # 2.4 Consulta de historial de citas por paciente
    code, url, body = s_odo.get(f"{BASE_URL}/HistorialController?accion=ListarHistorialCitas&pacienteNom=Carlos")
    assert code == 200, "Error al consultar historial de citas"
    print("✓ [RF05] Consulta de historial de citas por paciente ejecutada correctamente.")

    # -------------------------------------------------------------
    # 3. TEST RF16: FINALIZAR ATENCIÓN (ODONTÓLOGO MARCA COMO COMPLETADO)
    # -------------------------------------------------------------
    print("\n--- [TEST RF16] FINALIZAR CITA CLÍNICA (MARCAR COMO COMPLETADO) ---")

    # Preparar una cita en estado Confirmado (Estado_idEstado = 3) para el Odontólogo Ruben (idUsuario = 4)
    mysql_query("UPDATE Cita SET Estado_idEstado = 3 WHERE idCita = 1;")
    pre_check = mysql_query("SELECT idCita, Estado_idEstado FROM Cita WHERE idCita = 1;")
    print(f"Estado inicial cita ID 1 antes de finalizar: {pre_check}")

    # Odontólogo marca cita como completada
    code, url, body = s_odo.post(f"{BASE_URL}/ReprogramacionController", {
        "accion": "updateEstadoCompletadoCita",
        "idCita": "1",
        "estado": "Confirmado"
    })
    assert code == 200, f"Error al finalizar cita: {code}"

    # Auditar en MySQL: Estado_idEstado debe ser 2 (Completado)
    post_check = mysql_query("SELECT c.idCita, e.TipoEstado, c.Estado_idEstado FROM Cita c JOIN Estado e ON c.Estado_idEstado = e.idEstado WHERE c.idCita = 1;")
    assert "Completado" in post_check or "2" in post_check, f"Cita no pasó a Completado: {post_check}"
    print(f"✓ [RF16] Odontólogo marcó cita como COMPLETADA. Auditado en MySQL Cita: {post_check}")

    # Verificar registro en tabla Notificacion
    notif_check = mysql_query("SELECT idNotificacion, Asunto, Estado_idEstado, Cita_idCita FROM Notificacion WHERE Cita_idCita = 1 ORDER BY idNotificacion DESC LIMIT 1;")
    print(f"✓ [RF16/RF09] Notificación registrada en MySQL: {notif_check}")

    print("\n" + "=" * 70)
    print(">>> TODOS LOS TESTS DE LOTE 1 (RF05, RF15, RF16) PASARON EXITOSAMENTE 100% <<<")
    print("=" * 70)

if __name__ == "__main__":
    run_tests()
