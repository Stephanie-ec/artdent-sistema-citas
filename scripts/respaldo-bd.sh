#!/usr/bin/env bash
# R-16: respaldo diario de la base y de los comprobantes, con retención de 7 días
# y registro del resultado en la tabla Evento. Equivalente a scripts/respaldo-bd.ps1.
#
# Uso:   ./scripts/respaldo-bd.sh
# Cron:  0 2 * * *  /ruta/al/proyecto/scripts/respaldo-bd.sh >> /var/log/artdent-respaldo.log 2>&1
# launchd (macOS): ver docs/RESPALDO.md
#
# Variables opcionales:
#   ARTDENT_CONFIG    ruta del config.properties (por defecto el del proyecto)
#   ARTDENT_RESPALDOS carpeta destino (por defecto $HOME/ArtDent/Respaldos)
#   ARTDENT_RETENCION días de retención (por defecto 7)
set -euo pipefail
cd "$(dirname "$0")/.."

CFG="${ARTDENT_CONFIG:-src/main/resources/config.properties}"
[ -f "$CFG" ] || { echo "No existe $CFG" >&2; exit 2; }
get() { grep -E "^$1=" "$CFG" | head -1 | cut -d= -f2-; }
URL="$(get db.url)"; USER="$(get db.user)"; PASS="$(get db.password)"
DB="${URL%%\?*}"; DB="${DB##*/}"
[ -n "$DB" ] || { echo "db.url sin nombre de base" >&2; exit 2; }
export MYSQL_PWD="$PASS"

DEST="${ARTDENT_RESPALDOS:-$HOME/ArtDent/Respaldos}"
RETENCION="${ARTDENT_RETENCION:-7}"
STAMP="$(date +%Y%m%d_%H%M%S)"
mkdir -p "$DEST"
SQL="$DEST/respaldo_${DB}_$STAMP.sql"
ZIP="$DEST/respaldo_${DB}_$STAMP.zip"

evento() { # nivel, mensaje
  mysql -u"$USER" --default-character-set=utf8mb4 "$DB" \
    -e "INSERT INTO Evento(Nivel,Origen,Mensaje) VALUES('$1','Respaldo','$2')" 2>/dev/null || true
}

fallo() { evento ERROR "Respaldo fallido ($STAMP): $1"; echo "ERROR: $1" >&2; exit 1; }
trap 'fallo "fallo inesperado en la línea $LINENO"' ERR

mysqldump -u"$USER" --single-transaction --routines --triggers --default-character-set=utf8mb4 "$DB" > "$SQL" \
  || fallo "mysqldump devolvió error"

EXTRA=()
for dir in datos-privados/comprobantes uploads/comprobantes; do
  [ -d "$dir" ] && EXTRA+=("$dir")
done
zip -q -j "$ZIP" "$SQL" ${EXTRA[@]+"${EXTRA[@]}"} || fallo "no se pudo comprimir el respaldo"
rm -f "$SQL"
sha256sum "$ZIP" > "$ZIP.sha256" 2>/dev/null || shasum -a 256 "$ZIP" > "$ZIP.sha256"

# Retención: se conservan los últimos N respaldos
ls -1t "$DEST"/respaldo_"$DB"_*.zip 2>/dev/null | tail -n +"$((RETENCION + 1))" | while read -r viejo; do
  rm -f "$viejo" "$viejo.sha256"
done

TAM="$(du -h "$ZIP" | cut -f1)"
evento INFO "Respaldo correcto ($STAMP): $(basename "$ZIP") $TAM"
echo "Respaldo: $ZIP ($TAM)"
