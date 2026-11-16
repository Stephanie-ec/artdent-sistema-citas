#!/usr/bin/env bash
# Se ejecuta una sola vez al crear el Codespace: instala el cliente MySQL, carga la base y crea la configuración local.
set -e
cd "$(dirname "$0")/.."

sudo apt-get update -qq && sudo apt-get install -y -qq default-mysql-client >/dev/null

echo "Esperando a MySQL..."
for i in $(seq 1 60); do
  mysqladmin ping -h db -uroot -partdent --silent 2>/dev/null && break
  sleep 2
done

echo "Cargando la base de datos db_artdent_apf2..."
mysql -h db -uroot -partdent --default-character-set=utf8mb4 < src/main/java/pe/edu/utp/bd/db_artdent_apf2_completo.sql

mkdir -p /workspaces/artdent-privado/comprobantes
if [ ! -f src/main/resources/config.properties ]; then
cat > src/main/resources/config.properties <<'CFG'
# Configuración SOLO para el Codespace (base de pruebas en el contenedor "db")
db.url=jdbc:mysql://db:3306/db_artdent_apf2?serverTimezone=America/Lima&useUnicode=true&characterEncoding=UTF-8
db.user=root
db.password=artdent

mail.enabled=false
gemini.enabled=false
gemini.api.key=
gemini.model=
reniec.api.url=https://api.decolecta.com/v1/reniec/dni?numero={dni}
reniec.api.token=
reniec.mode=demo
pagos.titular=ART DENT SAC
pagos.numero=999999999
pagos.adjuntos.dir=/workspaces/artdent-privado/comprobantes
CFG
fi

echo "Descargando dependencias de Maven (solo la primera vez)..."
mvn -B -q -DskipTests dependency:go-offline || true
echo "Listo. El sistema arranca solo; abre el puerto 8080 cuando aparezca el aviso."
