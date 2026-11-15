# Pruebas de punta a punta (Playwright)

Un robot recorre el sistema como lo haría el docente: crea usuarios, reserva, paga, aprueba,
consulta "Mi reserva", prueba el DNI repetido, la seguridad y el asistente.
Corre solo en GitHub Actions (job `recorrido`) y guarda las capturas como artefacto `capturas-recorrido`.

Para correrlo a mano con el sistema levantado en http://localhost:8080/ArtDent:

```
cd e2e
npm install
npx playwright install chromium
npm test
```
Las capturas quedan en `e2e/capturas/`.
