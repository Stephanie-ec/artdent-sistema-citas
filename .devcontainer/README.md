# Probar el sistema sin instalar nada (GitHub Codespaces)

1. En GitHub: botón verde **Code** → pestaña **Codespaces** → **Create codespace on develop**.
2. Esperar unos 5 minutos la primera vez (crea la base de datos y descarga dependencias).
3. Cuando aparezca el aviso del puerto 8080, abrirlo y entrar a `/ArtDent`.
   - Si no aparece, pestaña **PORTS** (abajo) → puerto 8080 → icono del globo.
4. Usuarios de prueba: ver `claude/continuidad_artdent.md` o el script de la BD.

Reiniciar el sistema: en la terminal, `bash .devcontainer/arrancar.sh`.
Reiniciar la base de datos desde cero: `mysql -h db -uroot -partdent < src/main/java/pe/edu/utp/bd/db_artdent_apf2_completo.sql`.

El Codespace se apaga solo tras 30 minutos sin uso y se puede volver a abrir desde la misma pestaña.
