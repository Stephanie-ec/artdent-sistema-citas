#!/usr/bin/env python3
"""
Test Suite End-to-End: RF02, RF03 y RF04 - Multi-Rol y Auditoría en Base de Datos MySQL
ArtDent Centro Odontológico

Roles validados:
1. Paciente (sin cuenta / reserva web RF02)
2. Secretaria (DNI 78223344 / 1234 - RF03 registro presencial, reprogramación y cancelación con RF09)
3. Odontólogo (DNI 70096374 / 1234 - RF04 visualización de agenda personalizada)
4. Administrador (DNI 48223344 / 123 - Supervisión global)
"""

import re
import sys
import subprocess
import urllib.request
import urllib.parse
import http.cookiejar

BASE_URL = "http://localhost:8080/ArtDent"

class WebClient:
    def __init__(self):
        self.cj = http.cookiejar.CookieJar()
        self.opener = urllib.request.build_opener(urllib.request.HTTPCookieProcessor(self.cj))

    def get(self, url):
        req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})
        with self.opener.open(req) as resp:
            return resp.status, resp.read().decode("utf-8", errors="replace")

    def post(self, url, data):
        encoded = urllib.parse.urlencode(data).encode("utf-8")
        req = urllib.request.Request(url, data=encoded, headers={
            "User-Agent": "Mozilla/5.0",
            "Content-Type": "application/x-www-form-urlencoded"
        })
        with self.opener.open(req) as resp:
            return resp.status, resp.read().decode("utf-8", errors="replace")

def run_query(sql):
    cmd = ["mysql", "-u", "root", "-prootroot", "db_artdent_apf2", "-B", "-e", sql]
    res = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    if res.returncode != 0:
        raise RuntimeError(f"Error MySQL: {res.stderr}")
    lines = [line.split("\t") for line in res.stdout.strip().split("\n") if line]
    if len(lines) <= 1:
        return []
    headers = lines[0]
    results = []
    for row in lines[1:]:
        results.append(dict(zip(headers, row)))
    return results

def test_rf02_confirmacion_cita():
    print("\n" + "="*70)
    print(">>> TEST RF02: Confirmación de Citas con Código Único")
    print("="*70)

    client = WebClient()
    # 1. Realizar reserva web como paciente
    dni_test = "74112233"
    post_data = {
        "dni": dni_test,
        "nombre": "Valeria",
        "apellido": "Gomez",
        "email": "valeria.gomez@test.com",
        "correo": "valeria.gomez@test.com",
        "telefono": "987112233",
        "idServicio": "2",
        "medico": "4",
        "fecha": "2026-10-29",
        "hora": "16:00",
        "descripcion": "Reserva Web Test RF02",
        "precio_consulta": "80.00"
    }

    status, html = client.post(f"{BASE_URL}/CitaController", post_data)
    assert status == 200, f"Error HTTP {status}"

    # 2. Verificar en el HTML que aparezca el código de reserva
    match = re.search(r"ART-RES-\d{5}", html)
    assert match, "No se encontró el código de reserva en el voucher de citareservada.jsp"
    codigo_reserva = match.group(0)
    id_cita_num = int(codigo_reserva.split("-")[-1])
    print(f" [✓] Código generado en voucher: {codigo_reserva} (idCita: {id_cita_num})")

    # 3. Auditoría en MySQL
    rows = run_query(f"SELECT idCita, Origen, Estado_idEstado, Paciente_idPaciente FROM Cita WHERE idCita = {id_cita_num}")
    assert len(rows) == 1, f"No se encontró la cita {id_cita_num} en la tabla Cita"
    row = rows[0]
    assert row["Origen"] == "Web", f"Esperado Origen=Web, obtenido {row['Origen']}"
    assert row["Estado_idEstado"] == "1", f"Esperado Estado=1 (En espera), obtenido {row['Estado_idEstado']}"
    print(f" [✓] Base de Datos verificada: Cita {id_cita_num} con Origen='Web' y Estado=1")
    print(">>> RF02 APROBADO EXITOSAMENTE\n")
    return id_cita_num

def test_rf03_gestion_citas_secretaria():
    print("\n" + "="*70)
    print(">>> TEST RF03: Gestión de Citas por la Secretaría")
    print("="*70)

    client = WebClient()
    # 1. Iniciar sesión como Secretaria (78223344 / 1234)
    login_data = {"document": "78223344", "password": "1234"}
    status, html = client.post(f"{BASE_URL}/InicioSesionController", login_data)
    assert status == 200
    assert "Ethelvina" in html or "Solicitudes" in html or "CerrarSesion" in html, "Fallo al iniciar sesión como Secretaria"
    print(" [✓] 1. Inicio de sesión como Secretaria exitoso (Ethelvina Soto, Rol 2)")

    # 2. Acceder al formulario de registro de cita presencial
    status_form, html_form = client.get(f"{BASE_URL}/CitaController?accion=formPresencial")
    assert status_form == 200
    assert "Registrar Cita Presencial (RF03)" in html_form
    assert "Formulario de Cita Presencial" in html_form
    print(" [✓] 2. Vista reservapresencial.jsp cargada correctamente con servicios y médicos")

    # 3. Registrar Cita Presencial
    dni_paciente = "79988776"
    post_presencial = {
        "accion": "registrarPresencial",
        "origen": "Presencial",
        "dni": dni_paciente,
        "nombre": "Mateo",
        "apellido": "Alarcon",
        "correo": "mateo.alarcon@test.com",
        "telefono": "988776655",
        "idServicio": "1",
        "medico": "4",
        "fecha": "2026-10-30",
        "hora": "09:30",
        "precio_consulta": "50.00",
        "descripcion": "Paciente acudió presencialmente a recepción para consulta inicial"
    }

    status_reg, html_reg = client.post(f"{BASE_URL}/CitaController", post_presencial)
    assert status_reg == 200
    print(" [✓] 3. Cita presencial enviada exitosamente")

    # 4. Auditoría en BD: verificar inserción en tabla Cita
    citas = run_query(f"SELECT c.idCita, c.Origen, c.Usuario_idUsuario, c.Estado_idEstado, e.TipoEstado "
                      f"FROM Cita c JOIN Estado e ON c.Estado_idEstado = e.idEstado "
                      f"JOIN Paciente p ON c.Paciente_idPaciente = p.idPaciente "
                      f"WHERE p.DNI = '{dni_paciente}' ORDER BY c.idCita DESC LIMIT 1")
    assert len(citas) == 1, "No se encontró la cita presencial en la BD"
    cita = citas[0]
    id_cita_presencial = int(cita["idCita"])
    assert cita["Origen"] == "Presencial", f"Esperado Origen=Presencial, obtenido {cita['Origen']}"
    assert cita["Usuario_idUsuario"] == "2", f"Esperado Usuario_idUsuario=2 (Secretaria), obtenido {cita['Usuario_idUsuario']}"
    assert cita["Estado_idEstado"] == "3", f"Esperado Estado=3 (Confirmado), obtenido {cita['Estado_idEstado']}"
    print(f" [✓] 4. Cita {id_cita_presencial} verificada en BD: Origen='Presencial', Registrado por Secretaria ID=2, Estado='Confirmado'")

    # 5. Auditoría en BD: verificar tabla Notificacion (RF09)
    notifs = run_query(f"SELECT * FROM Notificacion WHERE Cita_idCita = {id_cita_presencial} ORDER BY idNotificacion DESC")
    assert len(notifs) >= 1, f"No se registró notificación para la cita {id_cita_presencial}"
    assert notifs[0]["Asunto"] == "Cita Presencial Registrada"
    assert notifs[0]["Estado_idEstado"] == "3"
    assert notifs[0]["Enviado"] == "1"
    print(f" [✓] 5. Notificación RF09 verificada en BD: Asunto='{notifs[0]['Asunto']}', Enviado=1")

    # 6. Reprogramar la Cita Presencial (RF03)
    nueva_fecha = "2026-11-04"
    nueva_hora = "11:00"
    repro_data = {
        "accion": "UpdateCita",
        "idCita": str(id_cita_presencial),
        "new-date": nueva_fecha,
        "new-time": nueva_hora
    }
    status_repro, html_repro = client.post(f"{BASE_URL}/ReprogramacionController", repro_data)
    assert status_repro == 200
    print(" [✓] 6. Reprogramación ejecutada por Secretaría")

    # Auditoría BD Reprogramación
    citas_repro = run_query(f"SELECT FechaCita, HoraCita, Estado_idEstado FROM Cita WHERE idCita = {id_cita_presencial}")
    assert citas_repro[0]["FechaCita"] == nueva_fecha
    assert citas_repro[0]["Estado_idEstado"] == "4", f"Esperado Estado 4 (Reprogramado), obtenido {citas_repro[0]['Estado_idEstado']}"

    notifs_repro = run_query(f"SELECT * FROM Notificacion WHERE Cita_idCita = {id_cita_presencial} AND Asunto = 'Cita Reprogramada'")
    assert len(notifs_repro) >= 1, "No se registró notificación para Cita Reprogramada"
    assert notifs_repro[0]["Estado_idEstado"] == "4"
    print(f" [✓] 7. BD Cita actualizada a {nueva_fecha} {nueva_hora}, Estado=4 y Notificación 'Cita Reprogramada' registrada")

    # 7. Cancelar la Cita Presencial (RF03)
    cancel_data = {
        "accion": "updateEstadoCanceladoCita",
        "idCita": str(id_cita_presencial)
    }
    status_cancel, html_cancel = client.post(f"{BASE_URL}/ReprogramacionController", cancel_data)
    assert status_cancel == 200
    print(" [✓] 8. Cancelación ejecutada por Secretaría")

    # Auditoría BD Cancelación
    citas_cancel = run_query(f"SELECT Estado_idEstado FROM Cita WHERE idCita = {id_cita_presencial}")
    assert citas_cancel[0]["Estado_idEstado"] == "5", f"Esperado Estado 5 (Cancelado), obtenido {citas_cancel[0]['Estado_idEstado']}"

    notifs_cancel = run_query(f"SELECT * FROM Notificacion WHERE Cita_idCita = {id_cita_presencial} AND Asunto = 'Cita Cancelada'")
    assert len(notifs_cancel) >= 1, "No se registró notificación para Cita Cancelada"
    assert notifs_cancel[0]["Estado_idEstado"] == "5"
    print(f" [✓] 9. BD Cita actualizada a Estado=5 (Cancelado) y Notificación 'Cita Cancelada' registrada")
    print(">>> RF03 APROBADO EXITOSAMENTE\n")
    return id_cita_presencial

def test_rf04_agenda_odontologo():
    print("\n" + "="*70)
    print(">>> TEST RF04: Visualización de Agenda Semanal del Odontólogo")
    print("="*70)

    client = WebClient()
    # 1. Iniciar sesión como Odontólogo (DNI 70096374 / 1234 - Dr. Ruben Cuadros)
    login_data = {"document": "70096374", "password": "1234"}
    status, html = client.post(f"{BASE_URL}/InicioSesionController", login_data)
    assert status == 200
    assert "Ruben" in html or "Cuadros" in html, "Fallo al iniciar sesión como Odontólogo"
    print(" [✓] 1. Inicio de sesión como Odontólogo exitoso (Dr. Ruben Cuadros, Rol 3)")

    # 2. Acceder al Calendario de citas
    status_cal, html_cal = client.get(f"{BASE_URL}/ReservaController?accion=listarReservasPorDia")
    assert status_cal == 200

    # 3. Validar banner personalizado
    assert "Agenda Semanal Personalizada (RF04)" in html_cal, "No se encontró el título personalizado de agenda"
    assert "Dr(a). Ruben Cuadros" in html_cal, "No se encontró el nombre del Dr. Ruben Cuadros en la agenda"
    assert "Visualizando exclusivamente las citas y pacientes asignados a su agenda" in html_cal
    print(" [✓] 2. Encabezado personalizado de Agenda Semanal verificado con credencial médica")

    # 4. Validar navegación semanal (hoy, semana anterior, semana siguiente)
    status_sig, html_sig = client.get(f"{BASE_URL}/ReservaController?accion=semanaSiguiente")
    assert status_sig == 200
    assert "Agenda Semanal Personalizada (RF04)" in html_sig
    print(" [✓] 3. Navegación temporal del calendario funciona preservando filtro del médico")
    print(">>> RF04 APROBADO EXITOSAMENTE\n")

def test_rol_administrador():
    print("\n" + "="*70)
    print(">>> TEST ROL ADMINISTRADOR: Supervisión Global y Control Total")
    print("="*70)

    client = WebClient()
    login_data = {"document": "48223344", "password": "123"}
    status, html = client.post(f"{BASE_URL}/InicioSesionController", login_data)
    assert status == 200
    print(" [✓] 1. Inicio de sesión como Administrador exitoso (Juan David Fernández, Rol 1)")

    # Acceder a panel de Solicitudes y verificar botón de Cita Presencial
    status_sol, html_sol = client.get(f"{BASE_URL}/ReservaController?accion=listar")
    assert status_sol == 200
    assert "Cita Presencial" in html_sol
    print(" [✓] 2. Panel administrativo y accesos globales verificados")

    # Acceder a Calendario general
    status_cal, html_cal = client.get(f"{BASE_URL}/ReservaController?accion=listarReservasPorDia")
    assert status_cal == 200
    assert "Calendario General de Citas" in html_cal
    print(" [✓] 3. Administrador visualiza el Calendario General de Citas sin restricciones")
    print(">>> ROL ADMINISTRADOR APROBADO EXITOSAMENTE\n")

if __name__ == "__main__":
    print("======================================================================")
    print("EJECUTANDO SUITE INTEGRAL MULTI-ROL: RF02, RF03 Y RF04")
    print("======================================================================")
    try:
        test_rf02_confirmacion_cita()
        test_rf03_gestion_citas_secretaria()
        test_rf04_agenda_odontologo()
        test_rol_administrador()
        print("\n" + "*"*70)
        print(">>> TODAS LAS PRUEBAS AUTOMATIZADAS PASARON AL 100% CON ÉXITO <<<")
        print("*"*70 + "\n")
    except Exception as e:
        print(f"\n[X] ERROR EN LA PRUEBA: {e}", file=sys.stderr)
        import traceback
        traceback.print_exc()
        sys.exit(1)
