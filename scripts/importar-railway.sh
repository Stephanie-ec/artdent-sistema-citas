#!/usr/bin/env bash
# ---------------------------------------------------------------------
# Importa el esquema canónico de ArtDent en la base de Railway.
#
# El script canónico empieza con DROP/CREATE DATABASE + USE db_artdent_apf2;
# en Railway la base se llama `railway`, así que esas tres líneas se omiten
# y todo se carga en la base indicada por MYSQL_PUBLIC_URL.
#
# Uso:
#   export MYSQL_PUBLIC_URL='mysql://root:CLAVE@metro.proxy.rlwy.net:12345/railway'
#   ./scripts/importar-railway.sh          # pide confirmación
#   ./scripts/importar-railway.sh --si     # sin preguntar (CI)
#
# Alternativa sin TCP Proxy (desde otra máquina con el CLI de Railway):
#   railway connect MySQL < src/main/java/pe/edu/utp/bd/db_artdent_apf2_completo.sql
# (esa variante sí respeta el DROP/CREATE del script)
# ---------------------------------------------------------------------
set -euo pipefail
cd "$(dirname "$0")/.."

SQL="src/main/java/pe/edu/utp/bd/db_artdent_apf2_completo.sql"
[ -f "$SQL" ] || { echo "No existe $SQL" >&2; exit 2; }

URL="${MYSQL_PUBLIC_URL:-}"
if [ -z "$URL" ]; then
    cat >&2 <<'AYUDA'
Falta MYSQL_PUBLIC_URL.

1. En Railway abre el servicio MySQL -> Settings -> Networking -> Public Access.
2. Copia la variable MYSQL_PUBLIC_URL (formato mysql://usuario:clave@host:puerto/base).
3. Expórtala y vuelve a ejecutar este script.
AYUDA
    exit 2
fi

resto="${URL#mysql://}"
credenciales="${resto%%@*}"
servidor="${resto#*@}"
DB_USER="${credenciales%%:*}"
DB_PASS="${credenciales#*:}"
DB_HOST="${servidor%%:*}"
resto_servidor="${servidor#*:}"
DB_PORT="${resto_servidor%%/*}"
DB_NAME="${servidor##*/}"
DB_NAME="${DB_NAME%%\?*}"

[ -n "$DB_HOST" ] && [ -n "$DB_PORT" ] && [ -n "$DB_NAME" ] || {
    echo "No se pudo interpretar MYSQL_PUBLIC_URL (¿la clave tiene '@' o ':'?)" >&2; exit 2; }

echo "Destino: $DB_USER@$DB_HOST:$DB_PORT/$DB_NAME"
echo "Origen : $SQL (sin DROP/CREATE DATABASE ni USE)"

if [ "${1:-}" != "--si" ]; then
    read -r -p "Esto reemplaza/actualiza las tablas de esa base. ¿Continuar? [s/N] " respuesta
    case "$respuesta" in
        s|S|si|SI|y|Y) ;;
        *) echo "Cancelado."; exit 1 ;;
    esac
fi

export MYSQL_PWD="$DB_PASS"
CLIENTE=(mysql --default-character-set=utf8mb4 -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" "$DB_NAME")

grep -v -E '^(DROP DATABASE|CREATE DATABASE|USE )' "$SQL" | "${CLIENTE[@]}"

consulta() { "${CLIENTE[@]}" -N -B -e "$1"; }

TABLAS=$(consulta "SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_TYPE='BASE TABLE'")
VISTAS=$(consulta "SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_TYPE='VIEW'")
RUTINAS=$(consulta "SELECT COUNT(*) FROM information_schema.ROUTINES WHERE ROUTINE_SCHEMA=DATABASE()")
ESTADOS=$(consulta "SELECT GROUP_CONCAT(idEstado ORDER BY idEstado) FROM Estado")
METODOS=$(consulta "SELECT GROUP_CONCAT(idMetodo ORDER BY idMetodo) FROM MetodoPago")
BLOQUEOS=$(consulta "SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='BloqueoAgenda'")
UNICO=$(consulta "SELECT COUNT(*) FROM information_schema.STATISTICS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='Pago' AND INDEX_NAME='CodigoTransaccion_UNIQUE'")

cat <<RESUMEN

Resumen de la importación
  Tablas ............ $TABLAS   (esperado 20)
  Vistas ............ $VISTAS   (esperado 2)
  Rutinas ........... $RUTINAS  (esperado 44)
  Estados ........... $ESTADOS  (esperado 1..7)
  Métodos de pago ... $METODOS  (esperado 1..3)
  BloqueoAgenda ..... $BLOQUEOS (esperado 1)
  Índice único MP ... $UNICO    (esperado 1)

Si algún valor no coincide, revisa que MYSQL_PUBLIC_URL apunte a la base correcta.
RESUMEN
