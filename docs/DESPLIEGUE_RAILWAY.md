# Despliegue en Railway (MySQL + Tomcat 9 + JSP)

Guía para publicar ArtDent en Railway con HTTPS y MySQL gestionado, sin secretos
en el repositorio. La aplicación se empaqueta como WAR y se ejecuta en **Tomcat 9**
(obligatorio: el código usa `javax.servlet`; Tomcat 10+ usa `jakarta.*` y no arranca).

Resumen de la arquitectura:

| Orden | Servicio en Railway | Función | Depende de |
|---|---|---|---|
| 1.º | **MySQL** | Tablas y datos | — |
| 2.º | **App JSP (Tomcat)** | Código Java + vistas JSP | Variables del servicio MySQL |

---

## Estado actual del despliegue (23/11/2026)

| Dato | Valor |
|---|---|
| URL pública | <https://artdent-production.up.railway.app> |
| Proyecto | `ArtDent` · entorno `production` · región `iad` |
| Repositorio | <https://github.com/ChristhianDBA/ArtDent> (rama `main`) |
| Servicios | `MySQL` (imagen `mysql:8`, volumen `mysql-volume`) y `ArtDent` (Dockerfile, volumen `artdent-volume` en `/data`) |
| Esquema en la base | importado con `scripts/importar-railway.sh` (20 tablas, 2 vistas, 44 rutinas) |
| Cómo se despliega | `railway up` desde el repo local; el servicio **no** está enlazado a GitHub |

Comprobado en esa instancia (por HTTP, sin tocar el servidor):

- `/salud` → `200` con `baseDatos.estado=ok` (latencia ~2 ms) y `HikariPool` inicializado.
- Login `48223344` / `123` → `302` a `DashboardController` y panel `200`.
- `ReporteController?accion=csv` → `text/csv`, `attachment` y BOM `EF BB BF`.
- Reserva web completa (`CitaController`) → `citareservada.jsp` → `PagoEnLinea` → preferencia
  real de Mercado Pago con `back_urls` y `notification_url` en `https://artdent-production.up.railway.app`.
- Los datos de esa prueba (cita, paciente y correos en cola) se borraron al terminar.

Limitaciones encontradas en Railway (no son fallos del código):

1. **SMTP bloqueado**: la conexión a `smtp.ethereal.email:587` muere con
   `SocketTimeoutException: Connect timed out`; los correos quedan `PENDIENTE` reintentando.
   Por eso el servicio tiene `ARTDENT_MAIL_ENABLED=false`. Para correo real hace falta un
   proveedor que envíe por HTTPS (API) o un relay permitido por la plataforma.
2. **Sin despliegue automático desde GitHub**: enlazar el repositorio requiere instalar la
   GitHub App de Railway en la cuenta; mientras tanto cada cambio se sube con `railway up`.
3. El plan actual es un **trial de 30 días / US$ 4,96**: si se agota, los servicios se pausan.

---

## 0. Requisitos

- Cuenta de Railway con un proyecto vacío.
- Repositorio en GitHub con este proyecto (incluye `Dockerfile`, `docker/entrypoint.sh`).
- Cliente `mysql` en tu equipo para importar las tablas (o usar `railway connect`).

Verifica localmente antes de subir:

```bash
mvn -B test                       # 91 pruebas
docker build -t artdent-railway . # opcional, valida la imagen
```

---

## 1. Crear el servicio MySQL

1. En el proyecto de Railway: **+ New → Database → MySQL**.
2. Railway crea el servicio y publica las variables `MYSQLHOST`, `MYSQLPORT`,
   `MYSQLUSER`, `MYSQLPASSWORD`, `MYSQLDATABASE` y `MYSQL_URL`.
3. La base se llama normalmente `railway`. **Anota el nombre del servicio MySQL**
   (por defecto `MySQL`): se usa en las Reference Variables del paso 4.

---

## 2. Subir las tablas

La base se crea privada. Para importar desde tu computadora:

1. Servicio MySQL → **Settings → Networking → Public Access**. Railway crea un
   *TCP Proxy* y publica `MYSQL_PUBLIC_URL`
   (`mysql://usuario:clave@host:puerto/base`).
2. Exporta esa URL y ejecuta el script del proyecto:

```bash
export MYSQL_PUBLIC_URL='mysql://root:CLAVE@metro.proxy.rlwy.net:12345/railway'
./scripts/importar-railway.sh
```

El script omite las líneas `DROP DATABASE` / `CREATE DATABASE` / `USE` del SQL
canónico (la base ya existe y se llama `railway`) y al final imprime el resumen:
**20 tablas, 2 vistas, 44 rutinas**, `Estado` 1..7, `MetodoPago` 1..3,
`BloqueoAgenda` e índice único `CodigoTransaccion_UNIQUE`.

> Alternativa desde el CLI de Railway (respeta el `CREATE DATABASE` del script):
> `railway connect MySQL < src/main/java/pe/edu/utp/bd/db_artdent_apf2_completo.sql`
>
> También puedes usar DBeaver/Workbench con los datos de `MYSQL_PUBLIC_URL` y
> ejecutar el archivo filtrado. El script canónico **borra** la base
> `db_artdent_apf2`: nunca lo corras contra producción.

Datos demo incluidos: admin `48223344` / `123`, odontólogos, pacientes y citas.
**Cambia esa contraseña en cuanto entres** (menú «Cambiar mi contraseña»).

---

## 3. Subir el proyecto a GitHub

El repositorio debe incluir, en la raíz:

```
Dockerfile
docker/entrypoint.sh
```

`.env`, `src/main/resources/config.properties` y `datos-privados/` están en
`.gitignore`: no se suben. Railway solo necesita el código.

```bash
git add Dockerfile docker/entrypoint.sh .dockerignore .env.example docs/DESPLIEGUE_RAILWAY.md
git commit -m "Despliegue en Railway: Dockerfile Tomcat 9 y configuración por variables"
git push origin develop
```

---

## 4. Crear el servicio JSP y conectar variables

Hay dos caminos; el resultado es el mismo WAR en Tomcat 9.

**A. Sin GitHub (CLI, el que se usó aquí)**

```bash
railway login                # abre el navegador
railway init --name ArtDent
railway add --database mysql --service MySQL
# ... importar tablas (paso 2) y crear el servicio de la app:
railway add --service ArtDent
railway service ArtDent      # deja el servicio enlazado
railway volume add -m /data
# variables (paso 4) y luego:
railway up --detach
railway domain --service ArtDent --port 8080
```

**B. Con GitHub (despliegue automático en cada push)**

1. **+ New → GitHub Repo** → elige el repositorio (pide instalar la GitHub App de
   Railway en la cuenta si aún no está).
2. Railway detecta el Dockerfile y muestra `Using detected Dockerfile!`.
   (Si el archivo tuviera otro nombre, define `RAILWAY_DOCKERFILE_PATH`.)
3. En **Variables** del servicio, pega el bloque siguiente cambiando los nombres
   de servicio si los tuyos no son `MySQL` y `ArtDent`:

```properties
ARTDENT_DB_URL=jdbc:mysql://${{MySQL.MYSQLHOST}}:${{MySQL.MYSQLPORT}}/${{MySQL.MYSQLDATABASE}}?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=America/Lima&useUnicode=true&characterEncoding=UTF-8
ARTDENT_DB_USER=${{MySQL.MYSQLUSER}}
ARTDENT_DB_PASSWORD=${{MySQL.MYSQLPASSWORD}}

ARTDENT_DATOS_DIR=/data/artdent
ARTDENT_PAGOS_ADJUNTOS_DIR=comprobantes-pagos

ARTDENT_MP_ENABLED=true
ARTDENT_MP_BASE_URL=https://${{ArtDent.RAILWAY_PUBLIC_DOMAIN}}
ARTDENT_MP_ACCESS_TOKEN=TEST-xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
ARTDENT_MP_PUBLIC_KEY=TEST-xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx

ARTDENT_RENIEC_MODE=demo
ARTDENT_GEMINI_ENABLED=false

ARTDENT_MAIL_ENABLED=true
ARTDENT_MAIL_SENDER=tu-cuenta@ethereal.email
ARTDENT_MAIL_FROM_NAME=Art Dent
ARTDENT_MAIL_SMTP_USER=tu-cuenta@ethereal.email
ARTDENT_MAIL_PASSWORD=clave-de-ethereal
ARTDENT_MAIL_SMTP_HOST=smtp.ethereal.email
ARTDENT_MAIL_SMTP_PORT=587
ARTDENT_MAIL_SMTP_AUTH=true
ARTDENT_MAIL_SMTP_STARTTLS=true
ARTDENT_MAIL_SMTP_SSL=false
ARTDENT_RECORDATORIOS_ENABLED=true
```

Notas:

- `ARTDENT_MP_BASE_URL` es imprescindible detrás del proxy: sin él la app deduce
  `http://` y Mercado Pago descarta `back_urls`/`notification_url`.
- Marca **Seal** en `ARTDENT_DB_PASSWORD`, `ARTDENT_MP_ACCESS_TOKEN` y
  `ARTDENT_MAIL_PASSWORD` para que no se puedan leer desde la UI/API.
- `ARTDENT_RENIEC_MODE=demo` permite reservar sin consultar RENIEC. Si tienes
  token, usa `required` (ver `docs/`).
- `PORT` lo inyecta Railway; el entrypoint adapta el conector de Tomcat. No lo
  definas a mano.

4. **Settings → Deploy → Healthcheck Path**: `/salud` (responde JSON y 503 si la
   base no contesta; sube el timeout a 60 s para el primer arranque).
5. **Settings → Volumes → Add Volume**: monta un volumen en `/data`. Sin él, los
   comprobantes subidos se pierden en cada despliegue.
6. **Settings → Networking → Generate Domain**: obtienes
   `https://<nombre>.up.railway.app`.
7. Si el dominio definitivo cambia, actualiza `ARTDENT_MP_BASE_URL` y redepliega.

---

## 5. Verificación posterior al despliegue

```bash
BASE=https://<tu-dominio>

curl -s $BASE/salud            # {"estado":"ok",...,"baseDatos":{"estado":"ok",...}}
curl -s -o /dev/null -w '%{http_code}\n' $BASE/iniciosesion.jsp   # 200
```

En el navegador:

1. Entrar con `48223344` / `123` y **cambiar la contraseña**.
2. Dashboard con 4 indicadores y sin `SQLException` en **Estado del servicio**.
3. Reserva web de punta a punta (portal público) → «Mi reserva» muestra el código.
4. Pago con Mercado Pago en sandbox (ver `docs/PAGO_EN_LINEA.md`).
5. Reportes → **Descargar CSV** (abre en Excel con tildes).
6. Bloqueos de agenda: crear uno y comprobar que el odontólogo no aparece en la
   búsqueda de disponibilidad de esa fecha.
7. Eventos y alertas: deben aparecer los `INFO` de inicio de sesión, pagos y
   bloqueos.

---

## 6. Problemas frecuentes

| Síntoma | Causa / solución |
|---|---|
| Build falla con `ClassNotFoundException: javax.servlet...` | Se cambió la imagen a Tomcat 10/11. Usa `tomcat:9.0-jdk17-temurin`. |
| `502` al abrir el dominio | El contenedor no escucha en `$PORT`; revisa el log del deploy y `docker/entrypoint.sh`. |
| `/salud` 503 y `baseDatos.estado=error` | `ARTDENT_DB_URL`/usuario/clave mal, o falta `allowPublicKeyRetrieval=true` (MySQL 8 + caching_sha2). |
| Login falla con `Unknown column 'DebeCambiarClave'` | Se importó un SQL viejo: vuelve a importar el canónico (paso 2). |
| El pago no vuelve al sitio ni llega el webhook | `ARTDENT_MP_BASE_URL` vacío o con `http://`: debe ser `https://<dominio>` sin barra final. |
| Los comprobantes desaparecen | Falta el volumen en `/data` o `ARTDENT_DATOS_DIR`. |
| El correo no llega en Railway | Railway **bloquea la salida SMTP** (587/465): `Connect timed out` y los correos quedan `PENDIENTE`. Usa un proveedor por API HTTPS (`ARTDENT_MAIL_ENABLED=false` mientras tanto). En local con Ethereal sí funciona. |
| Reserva web rechaza el DNI | `ARTDENT_RENIEC_MODE` quedó en `required` sin token: usa `demo`. |
| `Too many connections` | El pool es de 50 conexiones; si el plan limita, reduce `maximumPoolSize` en `Conexion`. |

---

## 7. Verificación hecha con la imagen real (sin Railway)

La imagen se construyó y ejecutó en Docker contra un MySQL 8.4 limpio, con el
mismo esquema importado con `scripts/importar-railway.sh`:

| Comprobación | Resultado |
|---|---|
| `docker build` | OK (multi-stage; sin `--mount=type=cache`, que el builder de Railway rechaza) |
| Arranque con `PORT=9090` | Tomcat escucha en `9090` (el entrypoint adapta el conector) |
| `/salud` | `200` con `baseDatos.estado=ok` |
| `config.properties` generada | `db.url`, `datos.dir=/data/artdent` y el resto desde variables, sin secretos en la imagen |
| Login admin | `POST /InicioSesionController` → `302` a Dashboard y panel renderizado |
| Reportes CSV | `text/csv`, `attachment`, BOM `EF BB BF` y totales del mes |
| Mercado Pago sin pago | `/?accion=retorno` muestra «No recibimos el identificador del pago»; `accion=notificacion` responde `200` |

Comandos usados (reproducibles):

```bash
docker network create artdent-test
docker run -d --name artdent-db --network artdent-test -p 33306:3306 \
  -e MYSQL_ROOT_PASSWORD=railway-test -e MYSQL_DATABASE=railway mysql:8.4
MYSQL_PUBLIC_URL='mysql://root:railway-test@127.0.0.1:33306/railway' \
  ./scripts/importar-railway.sh --si
docker run -d --name artdent-app --network artdent-test -p 9090:9090 \
  -e PORT=9090 \
  -e ARTDENT_DB_URL='jdbc:mysql://artdent-db:3306/railway?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=America/Lima&useUnicode=true&characterEncoding=UTF-8' \
  -e ARTDENT_DB_USER=root -e ARTDENT_DB_PASSWORD=railway-test \
  -e ARTDENT_RENIEC_MODE=demo artdent-railway
curl -s localhost:9090/salud
```

## 8. Costos y alcance

- MySQL y el servicio JSP consumen crédito del plan de Railway; el dominio y el
  HTTPS están incluidos.
- El TCP Proxy del MySQL genera egreso de red: desactívalo cuando termines de
  importar (`Settings → Networking → Public Access`).
- Esta guía no crea backups automáticos de la base: si la usas para datos reales,
  activa *Backups* del servicio MySQL o programa `scripts/respaldo-bd.sh`.
