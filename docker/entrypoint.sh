#!/usr/bin/env bash
# ---------------------------------------------------------------------
# ArtDent en contenedor
#
#  1. Escribe config.properties a partir de las variables ARTDENT_*.
#  2. Exporta ARTDENT_CONFIG para que ConfigLoader lo lea.
#  3. Ajusta el conector HTTP de Tomcat al puerto que inyecta la plataforma
#     (Railway define PORT).
#  4. Arranca Tomcat en primer plano.
#
# Nunca se hornea configuración ni credenciales en la imagen.
# ---------------------------------------------------------------------
set -euo pipefail

CONF_DIR="${ARTDENT_CONFIG_DIR:-/data/artdent}"
DATA_DIR="${ARTDENT_DATOS_DIR:-/data/artdent}"
CONF="$CONF_DIR/config.properties"
PORT="${PORT:-8080}"

mkdir -p "$CONF_DIR" "$DATA_DIR"

valor() { # nombre, valor por defecto
    local actual="${!1:-}"
    printf '%s' "${actual:-$2}"
}

{
    printf 'db.url=%s\n'            "$(valor ARTDENT_DB_URL '')"
    printf 'db.user=%s\n'           "$(valor ARTDENT_DB_USER 'root')"
    printf 'db.password=%s\n'       "$(valor ARTDENT_DB_PASSWORD '')"

    printf 'datos.dir=%s\n'         "$DATA_DIR"
    printf 'pagos.adjuntos.dir=%s\n' "$(valor ARTDENT_PAGOS_ADJUNTOS_DIR 'comprobantes-pagos')"
    printf 'pagos.titular=%s\n'     "$(valor ARTDENT_PAGOS_TITULAR 'Art Dent')"
    printf 'pagos.numero=%s\n'      "$(valor ARTDENT_PAGOS_NUMERO '')"

    printf 'mail.enabled=%s\n'      "$(valor ARTDENT_MAIL_ENABLED 'false')"
    printf 'mail.sender=%s\n'       "$(valor ARTDENT_MAIL_SENDER '')"
    printf 'mail.from.name=%s\n'    "$(valor ARTDENT_MAIL_FROM_NAME 'Art Dent')"
    printf 'mail.smtp.user=%s\n'    "$(valor ARTDENT_MAIL_SMTP_USER "${ARTDENT_MAIL_SENDER:-}")"
    printf 'mail.password=%s\n'     "$(valor ARTDENT_MAIL_PASSWORD '')"
    printf 'mail.smtp.host=%s\n'    "$(valor ARTDENT_MAIL_SMTP_HOST '')"
    printf 'mail.smtp.port=%s\n'    "$(valor ARTDENT_MAIL_SMTP_PORT '587')"
    printf 'mail.smtp.auth=%s\n'    "$(valor ARTDENT_MAIL_SMTP_AUTH 'true')"
    printf 'mail.smtp.starttls=%s\n' "$(valor ARTDENT_MAIL_SMTP_STARTTLS 'true')"
    printf 'mail.smtp.ssl=%s\n'     "$(valor ARTDENT_MAIL_SMTP_SSL 'false')"
    printf 'recordatorios.enabled=%s\n' "$(valor ARTDENT_RECORDATORIOS_ENABLED 'false')"

    printf 'reniec.api.url=%s\n'    "$(valor ARTDENT_RENIEC_API_URL '')"
    printf 'reniec.api.token=%s\n'  "$(valor ARTDENT_RENIEC_API_TOKEN '')"
    printf 'reniec.mode=%s\n'       "$(valor ARTDENT_RENIEC_MODE 'demo')"

    printf 'gemini.enabled=%s\n'    "$(valor ARTDENT_GEMINI_ENABLED 'false')"
    printf 'gemini.api.key=%s\n'    "$(valor ARTDENT_GEMINI_API_KEY '')"
    printf 'gemini.model=%s\n'      "$(valor ARTDENT_GEMINI_MODEL 'gemini-2.0-flash')"

    printf 'mp.enabled=%s\n'        "$(valor ARTDENT_MP_ENABLED 'false')"
    printf 'mp.public.key=%s\n'     "$(valor ARTDENT_MP_PUBLIC_KEY '')"
    printf 'mp.access.token=%s\n'   "$(valor ARTDENT_MP_ACCESS_TOKEN '')"
    printf 'mp.base.url=%s\n'       "$(valor ARTDENT_MP_BASE_URL '')"
    printf 'mp.api.url=%s\n'        "$(valor ARTDENT_MP_API_URL '')"
} > "$CONF"

chmod 600 "$CONF"
export ARTDENT_CONFIG="$CONF"

# Tomcat escucha en $PORT (la plataforma lo inyecta; por defecto 8080).
if [ "$PORT" != "8080" ]; then
    sed -i "s/port=\"8080\"/port=\"${PORT}\"/" /usr/local/tomcat/conf/server.xml
fi

echo "[artdent] config: $CONF | datos: $DATA_DIR | puerto: $PORT"
exec /usr/local/tomcat/bin/catalina.sh run
