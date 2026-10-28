import urllib.request
import urllib.parse
import http.cookiejar
import subprocess
import json
import sys

BASE_URL = "http://localhost:8080/ArtDent"

def run_mysql(query):
    cmd = ["mysql", "-u", "root", "-prootroot", "db_artdent_apf2", "-e", query]
    res = subprocess.run(cmd, capture_output=True, text=True)
    return res.stdout.strip()

def test_rnf_seguridad_bloqueo():
    print("=" * 70)
    print("TEST SUITE: ETAPA 1 (RNF03, RNF08, RNF09) - SEGURIDAD Y CONTROL")
    print("=" * 70)

    # ---------------------------------------------------------
    # TEST 1: RNF03 - BCrypt Hash y Migración Automática
    # ---------------------------------------------------------
    print("\n--- [TEST RNF03] BCRYPT HASHING Y MIGRACIÓN TRANSPARENTE ---")
    
    # Ver estado inicial de Juan David (48223344)
    clave_antes = run_mysql("SELECT Clave FROM Usuario WHERE DNI = '48223344';").split("\n")[-1].strip()
    print(f"Hash inicial de Juan David (DNI 48223344): {clave_antes[:20]}... (Longitud: {len(clave_antes)})")

    # Iniciar sesión con contraseña válida ('123')
    cj = http.cookiejar.CookieJar()
    opener = urllib.request.build_opener(urllib.request.HTTPCookieProcessor(cj))
    data = urllib.parse.urlencode({"document": "48223344", "password": "123"}).encode()
    req = urllib.request.Request(f"{BASE_URL}/InicioSesionController", data=data)
    resp = opener.open(req)
    url_final = resp.geturl()
    
    assert "DashboardController" in url_final or "dashboard" in url_final, f"Login falló: {url_final}"
    print("✓ [RNF03] Login exitoso de Administrador Juan David.")

    # Auditar en MySQL si se migró a BCrypt
    clave_despues = run_mysql("SELECT Clave FROM Usuario WHERE DNI = '48223344';").split("\n")[-1].strip()
    print(f"Hash en MySQL tras login: {clave_despues}")
    assert clave_despues.startswith("$2a$10$") or clave_despues.startswith("$2b$10$"), f"No se migró a BCrypt: {clave_despues}"
    print("✓ [RNF03] Contraseña migrada exitosamente a BCrypt ($2a$10$) en la base de datos MySQL.")

    # Iniciar sesión de nuevo con el hash BCrypt ya existente
    cj2 = http.cookiejar.CookieJar()
    opener2 = urllib.request.build_opener(urllib.request.HTTPCookieProcessor(cj2))
    req2 = urllib.request.Request(f"{BASE_URL}/InicioSesionController", data=data)
    resp2 = opener2.open(req2)
    assert "DashboardController" in resp2.geturl() or "dashboard" in resp2.geturl(), "Login con hash BCrypt falló."
    print("✓ [RNF03] Autenticación directa y nativa con BCrypt verificada exitosamente.")

    # ---------------------------------------------------------
    # TEST 2: RNF08 - Bloqueo de Cuenta a 5 Intentos Fallidos
    # ---------------------------------------------------------
    print("\n--- [TEST RNF08] BLOQUEO DE CUENTA TRAS 5 INTENTOS FALLIDOS (15 MIN) ---")
    
    # Preparar usuario Secretaria (DNI 78223344) en estado limpio
    run_mysql("UPDATE Usuario SET IntentosFallidos = 0, BloqueadoHasta = NULL WHERE DNI = '78223344';")
    
    for intento in range(1, 5):
        data_err = urllib.parse.urlencode({"document": "78223344", "password": "clave_incorrecta"}).encode()
        req_err = urllib.request.Request(f"{BASE_URL}/InicioSesionController", data=data_err)
        resp_err = urllib.request.urlopen(req_err)
        html = resp_err.read().decode('utf-8', errors='ignore')
        
        # Verificar en BD el incremento
        intentos_bd = run_mysql("SELECT IntentosFallidos FROM Usuario WHERE DNI = '78223344';").split("\n")[-1].strip()
        print(f"Intento fallido {intento}/5 -> En MySQL: IntentosFallidos = {intentos_bd}")
        assert intentos_bd == str(intento), f"Esperado {intento}, obtenido {intentos_bd}"
        assert "quedan" in html or "intento" in html, f"Mensaje no encontrado en HTML: {html[:200]}"
    
    print("✓ [RNF08] 4 intentos fallidos registrados y advertencias de intentos restantes mostradas.")

    # 5to intento fallido: DEBE BLOQUEAR LA CUENTA
    print("Ejecutando 5to intento fallido...")
    data_err5 = urllib.parse.urlencode({"document": "78223344", "password": "clave_incorrecta"}).encode()
    req_err5 = urllib.request.Request(f"{BASE_URL}/InicioSesionController", data=data_err5)
    resp_err5 = urllib.request.urlopen(req_err5)
    html5 = resp_err5.read().decode('utf-8', errors='ignore')

    # Auditar en MySQL: BloqueadoHasta no debe ser NULL y debe ser ~15 minutos en el futuro
    estado_bloqueo = run_mysql("SELECT IntentosFallidos, BloqueadoHasta, TIMESTAMPDIFF(MINUTE, NOW(), BloqueadoHasta) as min FROM Usuario WHERE DNI = '78223344';")
    print(f"Auditoría MySQL tras 5to intento:\n{estado_bloqueo}")
    assert "14" in estado_bloqueo or "15" in estado_bloqueo, "No se fijó BloqueadoHasta a 15 minutos."
    assert "bloqueada" in html5 or "Bloqueada" in html5 or "superado" in html5, "No se mostró alerta de bloqueo."
    print("✓ [RNF08] Cuenta bloqueada en MySQL con BloqueadoHasta = NOW() + 15 minutos.")

    # 6to intento: INCLUSO con la contraseña CORRECTA ('1234'), el acceso debe ser RECHAZADO por estar bloqueada
    print("Probando login con credenciales correctas mientras la cuenta está bloqueada...")
    data_correcta = urllib.parse.urlencode({"document": "78223344", "password": "1234"}).encode()
    req_bloq = urllib.request.Request(f"{BASE_URL}/InicioSesionController", data=data_correcta)
    resp_bloq = urllib.request.urlopen(req_bloq)
    html_bloq = resp_bloq.read().decode('utf-8', errors='ignore')
    assert "bloqueada" in html_bloq or "Bloqueada" in html_bloq, "El sistema permitió acceso a una cuenta bloqueada!"
    print("✓ [RNF08] Seguridad confirmada: Acceso denegado incluso con contraseña correcta por bloqueo activo.")

    # Restaurar y probar desbloqueo
    print("Restableciendo cuenta de Secretaria tras verificación...")
    run_mysql("UPDATE Usuario SET IntentosFallidos = 0, BloqueadoHasta = NULL WHERE DNI = '78223344';")
    resp_ok = opener.open(urllib.request.Request(f"{BASE_URL}/InicioSesionController", data=data_correcta))
    assert "ReservaController" in resp_ok.geturl() or "listar" in resp_ok.geturl(), "Login no funcionó tras desbloqueo"
    print("✓ [RNF08] Cuenta desbloqueada y login restaurado exitosamente.")

    # ---------------------------------------------------------
    # TEST 3: RNF09 - Expiración e Invalidación de Sesión
    # ---------------------------------------------------------
    print("\n--- [TEST RNF09] INVALIDACIÓN DE SESIÓN Y LOGOUT SEGURO ---")
    
    # Cerrar sesión en CerrarSesionController
    req_logout = urllib.request.Request(f"{BASE_URL}/CerrarSesionController")
    resp_logout = opener.open(req_logout)
    print(f"Redirección tras CerrarSesionController: {resp_logout.geturl()}")
    assert "index.jsp" in resp_logout.geturl() or "ArtDent" in resp_logout.geturl()
    
    # Verificar que el session ID previo ya no tiene acceso a sesión autenticada
    req_check = urllib.request.Request(f"{BASE_URL}/header.jsp")
    resp_check = opener.open(req_check)
    html_header = resp_check.read().decode('utf-8', errors='ignore')
    assert "Iniciar Sesi" in html_header, "La sesión no fue invalidada tras el logout!"
    print("✓ [RNF09] Sesión HTTP invalidada exitosamente tras logout (usuario deslogueado).")

    print("\n" + "=" * 70)
    print(">>> TODOS LOS TESTS DE LA ETAPA 1 (RNF03, RNF08, RNF09) PASARON AL 100% <<<")
    print("=" * 70)

if __name__ == "__main__":
    test_rnf_seguridad_bloqueo()
