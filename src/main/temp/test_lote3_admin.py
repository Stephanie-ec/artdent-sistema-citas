#!/usr/bin/env python3
import urllib.request
import urllib.parse
import http.cookiejar
import subprocess
import hashlib
import sys

BASE_URL = "http://localhost:8080/ArtDent"

def run_sql(query):
    cmd = [
        "mysql", "-u", "root", "-prootroot", "db_artdent_apf2",
        "-N", "-B", "-e", query
    ]
    res = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    if res.returncode != 0:
        raise Exception(f"SQL Error: {res.stderr}")
    return [line.split("\t") for line in res.stdout.strip().split("\n") if line]

def make_session():
    cj = http.cookiejar.CookieJar()
    opener = urllib.request.build_opener(urllib.request.HTTPCookieProcessor(cj))
    return opener

def sha256(val):
    return hashlib.sha256(val.encode('utf-8')).hexdigest()

def test_lote3():
    print("==================================================")
    print(" INICIANDO PRUEBAS AUTOMATIZADAS - LOTE 3")
    print(" RF17, RF13, RF12, RF08, RF11")
    print("==================================================")
    session = make_session()

    # 0. Login as Admin
    print("\n[PASO 0] Autenticación como Administrador (DNI: 48223344)...")
    login_data = urllib.parse.urlencode({
        "document": "48223344",
        "password": "123"
    }).encode('utf-8')
    req = urllib.request.Request(f"{BASE_URL}/InicioSesionController", data=login_data)
    with session.open(req) as resp:
        assert resp.status == 200, f"Fallo login admin: {resp.status}"
    print(" -> Admin autenticado exitosamente.")

    # 1. RF17: Gestión de Servicios (Desactivar y Reactivar)
    print("\n[PASO 1] RF17 - Gestión de Servicios (Desactivar y Reactivar)...")
    # Desactivar servicio ID 2 (Curación Dental) temporalmente
    with session.open(f"{BASE_URL}/ServicioController?action=delete&id=2") as resp:
        assert resp.status == 200

    rows = run_sql("SELECT Activo FROM Servicio WHERE idServicio = 2")
    assert len(rows) > 0 and rows[0][0] == '0', f"Error: Servicio 2 debería tener Activo=0, pero tiene {rows}"
    print(" -> Servicio ID 2 desactivado en MySQL (Activo = 0). Correcto.")

    # Verificar que el listado de reservas públicas no lo ofrezca
    with urllib.request.urlopen(f"{BASE_URL}/ServicioController?action=listar") as resp:
        html = resp.read().decode('utf-8', errors='ignore')
        assert "Curación Dental" not in html, "Error: Servicio inactivo no debe aparecer en catálogo público."
    print(" -> Verificado: Servicio inactivo NO se ofrece a pacientes.")

    # Reactivar servicio ID 2
    with session.open(f"{BASE_URL}/ServicioController?action=reactivar&id=2") as resp:
        assert resp.status == 200

    rows = run_sql("SELECT Activo FROM Servicio WHERE idServicio = 2")
    assert len(rows) > 0 and rows[0][0] == '1', f"Error: Servicio 2 debería tener Activo=1, pero tiene {rows}"
    print(" -> Servicio ID 2 reactivado en MySQL (Activo = 1). Correcto.")

    # 2. RF13: Gestión de Usuarios (CRUD del Personal)
    print("\n[PASO 2] RF13 - Gestión de Usuarios (Crear, Actualizar y Eliminar Personal)...")
    dni_test = "88991122"
    run_sql(f"DELETE FROM Usuario WHERE DNI = '{dni_test}'")

    # Crear nueva Asistente Dental / Secretaria
    add_user_data = urllib.parse.urlencode({
        "nombre": "Valeria",
        "apellido": "Gomez",
        "dni": dni_test,
        "telefono": "987654321",
        "email": "valeria.gomez@artdent.pe",
        "direccion": "Av. Brasil 450",
        "fechanacimiento": "1996-04-12",
        "clave": "valeria123",
        "rol": "2" # Secretaria
    }).encode('utf-8')
    req = urllib.request.Request(f"{BASE_URL}/UsuarioController?action=add", data=add_user_data)
    with session.open(req) as resp:
        assert resp.status == 200

    u_rows = run_sql(f"SELECT idUsuario, Clave, Rol_idRol FROM Usuario WHERE DNI = '{dni_test}'")
    assert len(u_rows) > 0, "Error: Usuario no fue insertado en MySQL."
    test_user_id = u_rows[0][0]
    hash_esperado = sha256("valeria123")
    assert u_rows[0][1] == hash_esperado, f"Error en hash clave: {u_rows[0][1]} vs {hash_esperado}"
    print(f" -> Usuario de prueba creado con ID {test_user_id} y clave SHA-256 verificada.")

    # Actualizar usuario sin tocar la contraseña (preservación de hash)
    upd_user_data = urllib.parse.urlencode({
        "id": str(test_user_id),
        "nombre": "Valeria Sofia",
        "apellido": "Gomez Perez",
        "dni": dni_test,
        "telefono": "987111222",
        "email": "valeria.gomez@artdent.pe",
        "direccion": "Av. Brasil 450 Dpto 301",
        "fechanacimiento": "1996-04-12",
        "clave": "", # Clave vacía no debe sobreescribir el hash
        "rol": "2"
    }).encode('utf-8')
    req = urllib.request.Request(f"{BASE_URL}/UsuarioController?action=update", data=upd_user_data)
    with session.open(req) as resp:
        assert resp.status == 200

    u_mod = run_sql(f"SELECT Nombre, Apellido, Clave FROM Usuario WHERE idUsuario = {test_user_id}")
    assert u_mod[0][0] == "Valeria Sofia"
    assert u_mod[0][2] == hash_esperado, "Error: La clave hash anterior debió preservarse al enviar clave vacía."
    print(" -> Usuario actualizado y clave hash previa preservada intacta.")

    # Probar login con el nuevo usuario
    sess_valeria = make_session()
    val_login_data = urllib.parse.urlencode({
        "document": dni_test,
        "password": "valeria123"
    }).encode('utf-8')
    req = urllib.request.Request(f"{BASE_URL}/InicioSesionController", data=val_login_data)
    with sess_valeria.open(req) as resp:
        val_html = resp.read().decode('utf-8', errors='ignore')
        assert resp.status == 200
        assert "PDCSolicitudes.jsp" in val_html or "Solicitudes" in val_html
    print(" -> Inicio de sesión verificado con el nuevo usuario de rol Secretaria.")

    # Eliminar usuario de prueba
    with session.open(f"{BASE_URL}/UsuarioController?action=delete&id={test_user_id}") as resp:
        assert resp.status == 200
    del_check = run_sql(f"SELECT idUsuario FROM Usuario WHERE idUsuario = {test_user_id}")
    assert len(del_check) == 0, "Error: El usuario no fue eliminado de MySQL."
    print(" -> Usuario eliminado exitosamente de la base de datos.")

    # 3. RF12: Gestión de Disponibilidad Médica
    print("\n[PASO 3] RF12 - Gestión de Disponibilidad (Horarios y Servicios por Odontólogo)...")
    id_odontologo = 4 # Dr. Ruben Cuadros
    # Asignar Horarios [1, 3, 5] y Servicios [1, 3, 4]
    disp_data = urllib.parse.urlencode([
        ("idUsuario", str(id_odontologo)),
        ("horarios", "1"),
        ("horarios", "3"),
        ("horarios", "5"),
        ("servicios", "1"),
        ("servicios", "3"),
        ("servicios", "4")
    ]).encode('utf-8')
    req = urllib.request.Request(f"{BASE_URL}/UsuarioController?action=guardarDisponibilidad", data=disp_data)
    with session.open(req) as resp:
        assert resp.status == 200

    h_rows = [int(r[0]) for r in run_sql(f"SELECT Horario_idHorario FROM Usuario_Horario WHERE Usuario_idUsuario = {id_odontologo} ORDER BY Horario_idHorario")]
    assert h_rows == [1, 3, 5], f"Error en asignación de horarios: {h_rows}"
    s_rows = [int(r[0]) for r in run_sql(f"SELECT idServicio FROM Usuario_Servicio WHERE idUsuario = {id_odontologo} ORDER BY idServicio")]
    assert s_rows == [1, 3, 4], f"Error en asignación de servicios: {s_rows}"
    print(" -> Disponibilidad asignada: Horarios [1, 3, 5] y Servicios [1, 3, 4] verificados en MySQL.")

    # Restaurar disponibilidad completa de Ruben Cuadros
    disp_full_data = urllib.parse.urlencode([
        ("idUsuario", str(id_odontologo)),
        ("horarios", "1"),
        ("horarios", "2"),
        ("horarios", "3"),
        ("horarios", "4"),
        ("horarios", "5"),
        ("servicios", "1"),
        ("servicios", "2"),
        ("servicios", "3"),
        ("servicios", "4"),
        ("servicios", "5"),
        ("servicios", "6"),
        ("servicios", "7")
    ]).encode('utf-8')
    req = urllib.request.Request(f"{BASE_URL}/UsuarioController?action=guardarDisponibilidad", data=disp_full_data)
    with session.open(req) as resp:
        assert resp.status == 200
    print(" -> Disponibilidad completa de Dr. Ruben Cuadros restaurada.")

    # 4. RF08: Reportes y Estadísticas
    print("\n[PASO 4] RF08 - Reportes y Estadísticas con KPIs...")
    with session.open(f"{BASE_URL}/ReporteController?accion=reportead") as resp:
        assert resp.status == 200
        rep_html = resp.read().decode('utf-8', errors='ignore')
        assert "Reportes y Estadísticas (RF08)" in rep_html
        assert "Total Ingresos" in rep_html
        assert "barChart" in rep_html
        assert "ingresosChart" in rep_html
    print(" -> Módulo de reportes cargado con éxito, KPIs y gráficos HTML/JS integrados.")

    # 5. RF11: Asistente Virtual con IA
    print("\n[PASO 5] RF11 - Asistente Virtual Recomendador de Servicios...")
    def call_bot(pregunta):
        data = urllib.parse.urlencode({"pregunta": pregunta}).encode('utf-8')
        req = urllib.request.Request(f"{BASE_URL}/api/chatbot", data=data)
        with urllib.request.urlopen(req) as resp:
            assert resp.status == 200
            return resp.read().decode('utf-8', errors='ignore')

    res_bot1 = call_bot("tengo dolor de muela intenso y punzante")
    assert "Endodoncia" in res_bot1
    assert "action=cargar&id=" in res_bot1
    print(" -> Prueba Síntoma 'dolor de muela' -> Recomendación: Endodoncia con enlace interactivo OK.")

    res_bot2 = call_bot("mis dientes estan manchados y amarillos")
    assert "Blanqueamiento" in res_bot2
    print(" -> Prueba Síntoma 'dientes manchados' -> Recomendación: Blanqueamiento Dental OK.")

    res_bot3 = call_bot("tengo dientes chuecos y mala mordida")
    assert "Ortodoncia" in res_bot3
    print(" -> Prueba Síntoma 'dientes chuecos' -> Recomendación: Ortodoncia OK.")

    print("\n==================================================")
    print(" TODAS LAS PRUEBAS DE LOTE 3 PASARON AL 100% (5/5)")
    print("==================================================")

if __name__ == "__main__":
    test_lote3()
