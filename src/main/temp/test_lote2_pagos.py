#!/usr/bin/env python3
import urllib.request
import urllib.parse
import http.cookiejar
import subprocess
import json
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

def login(opener, dni, clave):
    url = f"{BASE_URL}/InicioSesionController"
    data = urllib.parse.urlencode({"document": dni, "password": clave}).encode("utf-8")
    req = urllib.request.Request(url, data=data, method="POST")
    resp = opener.open(req)
    content = resp.read().decode("utf-8", errors="ignore")
    return resp.status, resp.geturl(), content

def test_lote2():
    print("================================================================")
    print(" INICIO DE SUITE DE PRUEBAS AUTOMATIZADA: LOTE 2 (RF10, RF14, RF09)")
    print("================================================================")

    # 1. PACIENTE crea Reserva Web 1
    print("\n--- CASO 1: Paciente crea Reserva Web 1 (RF01 / RF02) ---")
    paciente_session = make_session()
    reserva_data = urllib.parse.urlencode({
        "accion": "create",
        "nombre": "Valeria",
        "apellido": "Torres",
        "dni": "73445566",
        "celular": "987112233",
        "correo": "valeria.torres@example.com",
        "servicio": "1", # Servicio id 1
        "odontologo": "1", # Ruben Cuadros
        "fecha": "2026-10-25",
        "hora": "11:00:00",
        "precio": "100.00",
        "descripcion": "Reserva de prueba para validacion de pagos y aprobacion"
    }).encode("utf-8")

    req = urllib.request.Request(f"{BASE_URL}/CitaController", data=reserva_data, method="POST")
    resp = paciente_session.open(req)
    assert resp.status == 200, f"Error al crear reserva: {resp.status}"
    print("[OK] Reserva web creada y redireccionada a voucher.")

    # Consultar idCita en BD
    rows = run_sql("SELECT idCita, Origen, Estado_idEstado, Servicio_idServicio FROM Cita WHERE Paciente_idPaciente IN (SELECT idPaciente FROM Paciente WHERE Dni = 73445566) ORDER BY idCita DESC LIMIT 1;")
    assert len(rows) > 0, "No se encontro la cita en MySQL"
    id_cita_1 = int(rows[0][0])
    origen_1 = rows[0][1]
    estado_1 = int(rows[0][2])
    print(f"[OK] Cita en BD: idCita={id_cita_1}, Origen='{origen_1}', Estado_idEstado={estado_1}")
    assert origen_1 == "Web", "El origen debe ser 'Web'"
    assert estado_1 == 1, "El estado debe ser 1 ('En espera')"

    # Verificar que NO tiene pago
    pago_rows = run_sql(f"SELECT COUNT(*) FROM Pago WHERE Cita_idCita = {id_cita_1};")
    assert int(pago_rows[0][0]) == 0, "La cita recien creada no debe tener pagos registrados"
    print("[OK] Verificado: Cita NO tiene pago registrado inicialmente.")

    # 2. SECRETARIA intenta Aprobar Reserva Web 1 SIN PAGO (RF14)
    print("\n--- CASO 2: Secretaria intenta Aprobar sin Pago (RF14 - Bloqueo de Integridad) ---")
    sec_session = make_session()
    login(sec_session, "78223344", "1234") # Secretaria

    # Intentar aprobar
    aprobar_data = urllib.parse.urlencode({
        "accion": "updateEstadoConfirmar",
        "idReserva": str(id_cita_1),
        "estado": "En espera"
    }).encode("utf-8")
    req = urllib.request.Request(f"{BASE_URL}/ReprogramacionController", data=aprobar_data, method="POST")
    resp = sec_session.open(req)
    url_final = resp.geturl()
    print(f"URL de respuesta tras intento de aprobacion: {url_final}")
    assert "error=sinPago" in url_final, "El sistema debio denegar la aprobacion con error=sinPago"

    # Verificar que en BD SIGUE en espera
    rows_despues = run_sql(f"SELECT Estado_idEstado FROM Cita WHERE idCita = {id_cita_1};")
    assert int(rows_despues[0][0]) == 1, "La cita debio mantenerse en estado 1 ('En espera')"
    print("[OK] Exito: Aprobacion bloqueada por regla de negocio RF14 (sin pago).")

    # 3. SECRETARIA registra Pago en Efectivo (RF10)
    print("\n--- CASO 3: Secretaria registra Pago en Efectivo y emite Boleta (RF10) ---")
    pago_data = urllib.parse.urlencode({
        "action": "registrarPagoEfectivo",
        "idCita": str(id_cita_1),
        "monto": "100.00",
        "nombreCliente": "Valeria Torres",
        "dniCliente": "73445566"
    }).encode("utf-8")
    req = urllib.request.Request(f"{BASE_URL}/PagoController", data=pago_data, method="POST")
    resp = sec_session.open(req)
    url_pago = resp.geturl()
    print(f"URL tras pago: {url_pago}")
    assert "pagoEfectivoOk" in url_pago, "Debio retornar msg=pagoEfectivoOk"

    # Verificar en BD: Pago y Comprobante
    pagos_db = run_sql(f"SELECT idPago, Monto, MetodoPago_idMetodo FROM Pago WHERE Cita_idCita = {id_cita_1};")
    assert len(pagos_db) > 0, "No se registro el pago en la tabla Pago"
    id_pago_1 = int(pagos_db[0][0])
    monto_pago = float(pagos_db[0][1])
    metodo_pago = int(pagos_db[0][2])
    print(f"[OK] Pago registrado: idPago={id_pago_1}, Monto={monto_pago}, Metodo={metodo_pago} (2=Efectivo)")
    assert metodo_pago == 2, "Metodo de pago debe ser 2 (Efectivo)"

    comp_db = run_sql(f"SELECT idComprobante, Serie, Numero, NombreCliente, DNICliente FROM Comprobante WHERE Pago_idPago = {id_pago_1};")
    assert len(comp_db) > 0, "No se genero el comprobante en la tabla Comprobante"
    serie = comp_db[0][1]
    numero = comp_db[0][2]
    nombre_cli = comp_db[0][3]
    dni_cli = comp_db[0][4]
    codigo_boleta = f"{serie}-{numero}"
    print(f"[OK] Boleta Electronica generada: {codigo_boleta} a nombre de {nombre_cli} (DNI {dni_cli})")
    assert serie == "B001", "La serie debe ser B001"
    assert len(numero) == 8, "El numero debe ser correlativo de 8 digitos"

    # 4. SECRETARIA Aprueba Reserva Web ahora que cuenta con pago verificado (RF14 & RF09)
    print("\n--- CASO 4: Secretaria Aprueba Reserva Pagada (RF14) y Notifica (RF09) ---")
    req = urllib.request.Request(f"{BASE_URL}/ReprogramacionController", data=aprobar_data, method="POST")
    resp = sec_session.open(req)
    url_aprobado = resp.geturl()
    print(f"URL tras aprobacion: {url_aprobado}")
    assert "aprobadoOk" in url_aprobado, "Debio retornar msg=aprobadoOk"

    # Verificar en BD que Estado_idEstado es 3 ('Confirmado')
    rows_aprobado = run_sql(f"SELECT Estado_idEstado FROM Cita WHERE idCita = {id_cita_1};")
    assert int(rows_aprobado[0][0]) == 3, "La cita debe pasar a Estado_idEstado = 3 ('Confirmado')"
    print(f"[OK] Cita {id_cita_1} aprobada formalmente: Estado_idEstado = 3 ('Confirmado')")

    # Verificar notificacion en BD (RF09)
    notif_rows = run_sql(f"SELECT idNotificacion, Asunto, Estado_idEstado FROM Notificacion WHERE Cita_idCita = {id_cita_1} ORDER BY idNotificacion DESC LIMIT 1;")
    assert len(notif_rows) > 0, "No se registro la notificacion en tabla Notificacion"
    asunto_notif = notif_rows[0][1]
    estado_notif = int(notif_rows[0][2])
    print(f"[OK] Notificacion registrada en BD: Asunto='{asunto_notif}', Estado={estado_notif}")
    assert "Aprobada" in asunto_notif, "El asunto de la notificacion debe indicar aprobacion"

    # 5. RECHAZO DE RESERVA CON MOTIVO (RF14 & RF09)
    print("\n--- CASO 5: Rechazo de Reserva Web con Motivo (RF14) y Notificacion (RF09) ---")
    # Crear Reserva 2
    reserva_2 = urllib.parse.urlencode({
        "accion": "create",
        "nombre": "Marcos",
        "apellido": "Polo",
        "dni": "74556677",
        "celular": "987445566",
        "correo": "marcos.polo@example.com",
        "servicio": "2",
        "odontologo": "1",
        "fecha": "2026-10-26",
        "hora": "14:00:00",
        "precio": "120.00",
        "descripcion": "Reserva de prueba para rechazo"
    }).encode("utf-8")
    req = urllib.request.Request(f"{BASE_URL}/CitaController", data=reserva_2, method="POST")
    resp = paciente_session.open(req)
    assert resp.status == 200

    rows_2 = run_sql("SELECT idCita, Estado_idEstado FROM Cita WHERE Paciente_idPaciente IN (SELECT idPaciente FROM Paciente WHERE Dni = 74556677) ORDER BY idCita DESC LIMIT 1;")
    id_cita_2 = int(rows_2[0][0])
    print(f"[OK] Cita 2 creada: idCita={id_cita_2}, Estado={rows_2[0][1]}")

    # Rechazar
    motivo_rechazo = "Cruce de horario con cita presencial"
    rechazar_data = urllib.parse.urlencode({
        "accion": "rechazarReservaWeb",
        "idReserva": str(id_cita_2),
        "motivo": motivo_rechazo
    }).encode("utf-8")
    req = urllib.request.Request(f"{BASE_URL}/ReprogramacionController", data=rechazar_data, method="POST")
    resp = sec_session.open(req)
    url_rechazo = resp.geturl()
    print(f"URL tras rechazo: {url_rechazo}")
    assert "rechazadoOk" in url_rechazo, "Debio retornar msg=rechazadoOk"

    # Verificar en BD
    rows_rechazada = run_sql(f"SELECT Estado_idEstado FROM Cita WHERE idCita = {id_cita_2};")
    assert int(rows_rechazada[0][0]) == 6, "La cita debe pasar a Estado_idEstado = 6 ('Rechazado')"
    print(f"[OK] Cita {id_cita_2} rechazada en BD: Estado_idEstado = 6 ('Rechazado')")

    notif_rechazo = run_sql(f"SELECT Asunto, Estado_idEstado FROM Notificacion WHERE Cita_idCita = {id_cita_2} ORDER BY idNotificacion DESC LIMIT 1;")
    assert len(notif_rechazo) > 0, "No se registro notificacion de rechazo"
    print(f"[OK] Notificacion de rechazo registrada: Asunto='{notif_rechazo[0][0]}', Estado={notif_rechazo[0][1]}")
    assert motivo_rechazo in notif_rechazo[0][0], "El motivo debe estar en el asunto de la notificacion"
    assert int(notif_rechazo[0][1]) == 6, "El idEstado en Notificacion debe ser 6"

    # 6. PACIENTE PAGA EN LINEA CON PASARELA (RF10) Y CONSULTA BOLETA
    print("\n--- CASO 6: Paciente Paga en Linea (RF10) y Emision de Boleta Electronica ---")
    reserva_3 = urllib.parse.urlencode({
        "accion": "create",
        "nombre": "Camila",
        "apellido": "Silva",
        "dni": "75667788",
        "celular": "987889900",
        "correo": "camila.silva@example.com",
        "servicio": "1",
        "odontologo": "1",
        "fecha": "2026-10-27",
        "hora": "16:00:00",
        "precio": "100.00",
        "descripcion": "Reserva de prueba para pago en linea"
    }).encode("utf-8")
    req = urllib.request.Request(f"{BASE_URL}/CitaController", data=reserva_3, method="POST")
    resp = paciente_session.open(req)
    assert resp.status == 200

    rows_3 = run_sql("SELECT idCita FROM Cita WHERE Paciente_idPaciente IN (SELECT idPaciente FROM Paciente WHERE Dni = 75667788) ORDER BY idCita DESC LIMIT 1;")
    id_cita_3 = int(rows_3[0][0])
    codigo_reserva_3 = f"ART-RES-{id_cita_3:05d}"
    print(f"[OK] Cita 3 creada para pago en linea: idCita={id_cita_3}, Codigo={codigo_reserva_3}")

    pago_online_data = urllib.parse.urlencode({
        "action": "pagarEnLinea",
        "idCita": str(id_cita_3),
        "monto": "100.00",
        "nombreCliente": "Camila Silva",
        "dniCliente": "75667788",
        "codigoReserva": codigo_reserva_3
    }).encode("utf-8")
    req = urllib.request.Request(f"{BASE_URL}/PagoController", data=pago_online_data, method="POST")
    resp = paciente_session.open(req)
    url_boleta = resp.geturl()
    content_boleta = resp.read().decode("utf-8", errors="ignore")
    print(f"URL tras pago en linea: {url_boleta}")
    assert "verBoleta" in url_boleta, "Debio redirigir a verBoleta"
    assert "BOLETA DE VENTA ELECTRÓNICA" in content_boleta or "Boleta" in content_boleta, "La vista boleta.jsp debe mostrar el encabezado de boleta"
    assert "Camila Silva" in content_boleta, "La boleta debe mostrar el nombre del cliente"
    assert "75667788" in content_boleta, "La boleta debe mostrar el DNI del cliente"

    # Verificar en BD
    pagos_3 = run_sql(f"SELECT idPago, MetodoPago_idMetodo, CodigoTransaccion FROM Pago WHERE Cita_idCita = {id_cita_3};")
    assert len(pagos_3) > 0
    id_pago_3 = int(pagos_3[0][0])
    metodo_3 = int(pagos_3[0][1])
    txn_3 = pagos_3[0][2]
    print(f"[OK] Pago en linea registrado: idPago={id_pago_3}, Metodo={metodo_3} (1=En linea), Txn='{txn_3}'")
    assert metodo_3 == 1, "Metodo de pago debe ser 1 ('En linea')"

    comp_3 = run_sql(f"SELECT Serie, Numero, NombreCliente FROM Comprobante WHERE Pago_idPago = {id_pago_3};")
    assert len(comp_3) > 0
    print(f"[OK] Boleta correlativa en BD: {comp_3[0][0]}-{comp_3[0][1]} para {comp_3[0][2]}")
    assert comp_3[0][0] == "B001"

    print("\n================================================================")
    print(" [EXITO TOTAL] TODAS LAS PRUEBAS DE LOTE 2 (RF10, RF14, RF09) PASARON AL 100%")
    print("================================================================")

if __name__ == "__main__":
    test_lote2()
