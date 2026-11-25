#!/usr/bin/env bash
# R-17: restaura un respaldo en una base de verificación y compara conteos.
# Nunca escribe sobre la base de producción: exige un destino _restaurada/_test/_check.
#
# Uso: ./scripts/restaurar-bd.sh respaldos/respaldo_db_20261123_020000.zip [db_artdent_restaurada]
set -euo pipefail
cd "$(dirname "$0")/.."

ARCHIVO="${1:-}"
DESTINO="${2:-db_artdent_restaurada}"
[ -n "$ARCHIVO" ] && [ -f "$ARCHIVO" ] || { echo "Uso: $0 <respaldo.zip|.sql> [base_destino]" >&2; exit 2; }
case "$DESTINO" in
  *_restaurada|*_test|*_check) ;;
  *) echo "Destino inseguro: use una base terminada en _restaurada, _test o _check" >&2; exit 2 ;;
esac

CFG="${ARTDENT_CONFIG:-src/main/resources/config.properties}"
get() { grep -E "^$1=" "$CFG" | head -1 | cut -d= -f2-; }
URL="$(get db.url)"; USER="$(get db.user)"; PASS="$(get db.password)"
ORIGEN="${URL%%\?*}"; ORIGEN="${ORIGEN##*/}"
export MYSQL_PWD="$PASS"

TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
case "$ARCHIVO" in
  *.zip) unzip -q "$ARCHIVO" '*.sql' -d "$TMP" ;;
  *.sql) cp "$ARCHIVO" "$TMP/" ;;
  *) echo "Formato no reconocido" >&2; exit 2 ;;
esac
SQL="$(find "$TMP" -name '*.sql' | head -1)"
[ -n "$SQL" ] || { echo "El respaldo no contiene un .sql" >&2; exit 2; }

INICIO=$(date +%s)
mysql -u"$USER" -e "DROP DATABASE IF EXISTS \`$DESTINO\`; CREATE DATABASE \`$DESTINO\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci"
mysql -u"$USER" --default-character-set=utf8mb4 "$DESTINO" < "$SQL"
FIN=$(date +%s)

TABLAS="Cita Pago Comprobante Atencion Paciente"
echo "Tabla            $ORIGEN   $DESTINO"
ok=1
for t in $TABLAS; do
  a=$(mysql -u"$USER" -N -B "$ORIGEN" -e "SELECT COUNT(*) FROM $t")
  b=$(mysql -u"$USER" -N -B "$DESTINO" -e "SELECT COUNT(*) FROM $t")
  printf '%-16s %8s %10s\n' "$t" "$a" "$b"
  [ "$a" = "$b" ] || ok=0
done
mysql -u"$USER" -N -B "$DESTINO" -e "INSERT INTO Evento(Nivel,Origen,Mensaje) VALUES('INFO','Restauracion','Restauración verificada desde $(basename "$ARCHIVO") en $DESTINO en $((FIN-INICIO)) s')" 2>/dev/null || true
echo "RTO medido: $((FIN - INICIO)) s (objetivo <= 1800 s)"
[ "$ok" = 1 ] || { echo "Conteos distintos: revise el respaldo" >&2; exit 1; }
echo "Restauración verificada en $DESTINO"
