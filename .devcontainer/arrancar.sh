#!/usr/bin/env bash
# Se ejecuta cada vez que el Codespace se enciende: levanta Jetty en segundo plano.
cd "$(dirname "$0")/.."
mkdir -p target
nohup mvn -B jetty:run > target/jetty.log 2>&1 &
echo "Jetty arrancando en segundo plano (registro en target/jetty.log). Abre el puerto 8080 → /ArtDent"
