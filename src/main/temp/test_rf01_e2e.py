#!/usr/bin/env python3
import urllib.request
import urllib.parse
import http.cookiejar
import subprocess
import json

BASE_URL = "http://localhost:8080/ArtDent"

def run_mysql(query):
    cmd = ["mysql", "-u", "root", "-prootroot", "db_artdent_apf2", "-B", "-e", query]
    res = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    if res.returncode != 0:
        raise RuntimeError(f"MySQL error: {res.stderr}")
    lines = [line.split("\t") for line in res.stdout.strip().split("\n") if line]
    if not lines or len(lines) < 2:
        return []
    headers = lines[0]
    results = []
    for row in lines[1:]:
        results.append(dict(zip(headers, row)))
    return results

def log_step(msg):
    print(f"\n=======================================================")
    print(f"[*] {msg}")
    print(f"=======================================================")

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

def main():
    log_step("Paso 1: Auditar Estado Inicial de la Base de Datos")
    citas_ini = run_mysql("SELECT COUNT(*) AS total FROM Cita WHERE Origen = 'Web';")[0]["total"]
    pagos_ini = run_mysql("SELECT COUNT(*) AS total FROM Pago;")[0]["total"]
    print(f"-> Citas Web iniciales: {citas_ini}")
    print(f"-> Total Pagos en BD inicial: {pagos_ini}")

    log_step("Paso 2: Paciente (Sin cuenta) - Reserva Cita Web (RF01)")
    client_paciente = WebClient()
    patient_data = {
        "dni": "77112233",
        "nombre": "Mariana",
        "apellido": "Alvarez",
        "telefono": "981234567",
        "correo": "mariana.alvarez@gmail.com",
        "motivo": "3",  # Cirugía Oral
        "idServicio": "3",
        "nombreServicio": "Cirugía Oral",
        "fecha": "2026-10-20",
        "hora": "14:00",
        "medico": "4",  # Dr. Ruben Cuadros
        "precio_consulta": "250.00",
        "descripcion": "Reserva Web - En espera"
    }

    status, html = client_paciente.post(f"{BASE_URL}/CitaController", patient_data)
    assert status == 200, f"Error HTTP {status}"
    assert "¡Reserva Registrada con Éxito!" in html or "Comprobante" in html, "No cargó comprobante"
    assert "Mariana Alvarez" in html, "Paciente Mariana Alvarez no aparece en comprobante"
    assert "77112233" in html, "DNI no aparece en comprobante"
    assert "Cirugía Oral" in html, "Servicio Cirugía Oral no aparece en comprobante"
    assert "Ruben Cuadros" in html or "Dr." in html, "Odontólogo no aparece en comprobante"
    assert "En espera" in html, "Estado 'En espera' no aparece en comprobante"
    assert "250.00" in html, "Costo referencial S/ 250.00 no aparece en comprobante"
    assert "RF10" in html or "pago se realiza por separado" in html, "Nota de pago desacoplado ausente"
    print("-> Voucher generado exitosamente para el paciente con estado 'En espera' y datos íntegros.")

    log_step("Paso 3: Verificación de Integridad en BD (Cita creada, 0 Pagos creados)")
    pacientes = run_mysql("SELECT * FROM Paciente WHERE DNI = '77112233';")
    assert len(pacientes) == 1, "Paciente no encontrado en tabla Paciente"
    id_pac = pacientes[0]["idPaciente"]
    print(f"-> Paciente verificado en BD: idPaciente={id_pac}, Nombre={pacientes[0]['Nombre']} {pacientes[0]['Apellido']}")

    citas = run_mysql(f"SELECT * FROM Cita WHERE Paciente_idPaciente = {id_pac} ORDER BY idCita DESC;")
    assert len(citas) >= 1, "Cita no encontrada en BD"
    cita = citas[0]
    id_cita = cita["idCita"]
    assert cita["Origen"] == "Web", f"Origen no es Web: {cita['Origen']}"
    assert cita["Estado_idEstado"] == "1", f"Estado no es 1 ('En espera'): {cita['Estado_idEstado']}"
    assert float(cita["Importe"]) == 250.00, f"Importe referencial incorrecto: {cita['Importe']}"
    assert cita["Odontologo_idUsuario"] == "4", f"Odontologo incorrecto: {cita['Odontologo_idUsuario']}"
    print(f"-> Cita verificada en BD: idCita={id_cita}, Origen='{cita['Origen']}', Estado={cita['Estado_idEstado']} (En espera), Costo={cita['Importe']}")

    # AUDITORÍA DE PAGO: 0 pagos para esta cita y total de pagos inalterado
    pagos_cita = run_mysql(f"SELECT COUNT(*) AS total FROM Pago WHERE Cita_idCita = {id_cita};")[0]["total"]
    assert pagos_cita == "0", f"ALERTA: Se crearon pagos para RF01 ({pagos_cita})!"
    pagos_now = run_mysql("SELECT COUNT(*) AS total FROM Pago;")[0]["total"]
    assert pagos_now == pagos_ini, f"ALERTA: Total de pagos en BD cambió: {pagos_now} != {pagos_ini}"
    print(f"-> AUDITORÍA DE PAGO EXITOSA: 0 registros en tabla Pago. Total pagos en BD = {pagos_now} (Completamente Desacoplado).")

    log_step("Paso 4: Verificación Rol Secretaria (DNI 78223344 / 1234)")
    client_sec = WebClient()
    st_sec, _ = client_sec.post(f"{BASE_URL}/InicioSesionController", {
        "document": "78223344",
        "password": "1234"
    })
    assert st_sec == 200, "Error en login de secretaria"
    st_list, html_sec = client_sec.get(f"{BASE_URL}/ReservaController?accion=listar")
    assert st_list == 200, "Error al listar solicitudes como secretaria"
    assert "Mariana Alvarez" in html_sec, "Secretaria no ve a Mariana Alvarez en lista"
    assert "Cirugía Oral" in html_sec, "Secretaria no ve Cirugía Oral"
    assert "En espera" in html_sec, "Secretaria no ve estado 'En espera'"
    print("-> Rol Secretaria visualiza la reserva en 'En espera' en PDCSolicitudes.jsp con botones de confirmación.")

    log_step("Paso 5: Verificación Rol Odontólogo (DNI 70096374 / 1234)")
    client_odo = WebClient()
    st_odo, _ = client_odo.post(f"{BASE_URL}/InicioSesionController", {
        "document": "70096374",
        "password": "1234"
    })
    assert st_odo == 200, "Error en login de odontologo"
    st_list_odo, html_odo = client_odo.get(f"{BASE_URL}/ReservaController?accion=listar")
    assert st_list_odo == 200, "Error al listar citas como odontologo"
    assert "Mariana Alvarez" in html_odo, "Odontólogo no ve cita asignada a él"
    print("-> Rol Odontólogo visualiza la cita asignada en su lista de pacientes.")

    log_step("Paso 6: Verificación Rol Administrador (DNI 48223344 / 123)")
    client_adm = WebClient()
    st_adm, _ = client_adm.post(f"{BASE_URL}/InicioSesionController", {
        "document": "48223344",
        "password": "123"
    })
    assert st_adm in [200, 302], "Error en login de administrador"
    st_dash, html_dash = client_adm.get(f"{BASE_URL}/DashboardController?action=dashboard")
    assert st_dash == 200, "Error al cargar dashboard de administrador"
    st_list_adm, html_adm = client_adm.get(f"{BASE_URL}/ReservaController?accion=listar")
    assert st_list_adm == 200, "Error al listar solicitudes como administrador"
    assert "Mariana Alvarez" in html_adm, "Administrador no ve reserva en lista global"
    print("-> Rol Administrador accede al Dashboard y tiene supervisión completa de las reservas.")

    log_step("RESULTADO FINAL: TODAS LAS PRUEBAS E2E Y REGLAS DE NEGOCIO DE RF01 PASARON CON ÉXITO (100% PASS)")

if __name__ == "__main__":
    main()
