# Etapa 1: F-08 — validación cronológica de nuevas citas

> Registro histórico. El estado posterior del plan está en
> [AUDITORIA_PLAN_COMPLETO.md](AUDITORIA_PLAN_COMPLETO.md).

Fecha: 7 de noviembre de 2026, America/Lima.

## Alcance y causa comprobada

El código original de `Validador.validarDatosPaciente` solo comprobaba que fecha
y hora no estuvieran vacías. La prueba ejecutada sobre ese código aceptó fecha
pasada, domingo, 30 de febrero y hora 25:00. Causa: **comprobada mediante ejecución**.

Se agregó una validación reutilizable de fecha/hora. La referencia de tiempo es
America/Lima y se obtiene una sola vez por validación para evitar comparar días
y horas provenientes de instantes distintos. Un reloj inyectable permite probar
límites sin depender de la hora del equipo. Se conserva el contrato del validador:
`null` si acepta; mensaje constante si rechaza.

`CitaController` ya llamaba al validador antes de RENIEC y de las operaciones
DAO. No fue necesario modificar ese controlador: ahora rechaza estos casos con
HTTP 400 y la vista de error existente. La dependencia JUnit es solo de pruebas.
El CI dejó de omitirlas al empaquetar.

## Evidencia ejecutada

1. Prueba inicial: cinco métodos de comportamiento sobre el validador real.
   Resultado original: `Tests run: 5, Failures: 4`.
2. Con la corrección: `OK (5 tests)`.
3. Reposición temporal del archivo original desde el commit base, sin cambiar
   esas cinco pruebas: `Tests run: 5, Failures: 4` otra vez. Entre los errores:
   `java.lang.AssertionError: F-08: no se puede aceptar una reserva pasada`.
4. Restauración de la corrección, ampliación de casos y `mvn -B -q clean package`:
   18 pruebas, cero fallos, errores u omitidas; WAR generado.

Para las primeras tres ejecuciones se usaron `javac` y `JUnitCore` directamente
contra los dos archivos reales, con JDK 17 portátil. La última ejecución compiló
todo el proyecto mediante Maven 3.9.9. Las herramientas se extrajeron en una
carpeta temporal, sin instalación del sistema ni cambios permanentes al PATH.

## Crítica y límites de la auditoría

- Las 14 pruebas del validador son de comportamiento. Cubren fechas imposibles,
  fecha pasada, domingo, sábado, año bisiesto, entradas vacías, hora futura y
  pasada de hoy, segundo anterior, instante exacto y cambio de día UTC/Lima.
- Las cuatro pruebas del servlet invocan `doPost` real con dobles de petición y
  respuesta. Exigen HTTP 400, mensaje contextual y envío a `error.jsp`. No prueban
  un contenedor servlet real, renderizado JSP ni persistencia.
- No se ejecutaron MySQL, Jetty ni navegador. La prueba HTTP preparada y la
  persistencia de una reserva válida requieren la otra PC. El WAR compilado no
  demuestra que la aplicación completa funcione con una base de datos real.
- El script PowerShell pasó el análisis sintáctico. Su intento de ejecución
  en Windows PowerShell 5.1 fue rechazado por la política local de scripts
  (`UnauthorizedAccess`). No se cambió ni eludió esa política. No se declara
  probado el funcionamiento del script HTTP; solo está preparado para la otra PC.
- Se usa la hora del servidor en Lima; no se confía en el reloj del navegador.
  Se permite un instante exactamente igual a ahora, conforme a la regla de
  rechazar solo valores anteriores. No se redondea ahora al minuto, porque eso
  permitiría reservar segundos ya transcurridos.
- Los métodos antiguos de creación y `ReservaController` todavía requieren
  F-16. Esta etapa cubre el flujo de `CitaController`; no declara protegidos todos
  los accesos legados ni la reprogramación.
- La comprobación de disponibilidad y concurrencia no se resuelve con fechas:
  sigue pendiente en F-01/F-12. Sería incorrecto declarar F-08 como solución a
  dobles reservas o a turnos del odontólogo.
- El SQL original elimina la base y el ejemplo JDBC nombra otra base. La guía
  señala ambos puntos; no se modificó el esquema en esta etapa.
- Se revisó el diff aplicando las reglas universales y Java de `code-reviewer`.
  No se ejecutaron sus analizadores Python: Python no está disponible. No se
  asigna una puntuación automática ni se presenta la revisión como independiente.

Veredicto de esta etapa: sin hallazgos bloqueantes en los cambios de F-08;
aceptación con servidor real pendiente. No equivale a aprobar el sistema completo.

## Estado del plan integral

| Elementos | Estado |
|---|---|
| F-08 | Implementado, 18 pruebas locales y empaquetado; HTTP real pendiente. |
| F-01 a F-07, F-09 a F-18 | Pendientes; no se declaran corregidos. |
| Chatbot y prueba 15 de sesión | Pendientes. |
| SQL canónico y delta no destructivo | Sin modificaciones; pendientes de su etapa. |

Continuación propuesta en cambios individuales: cerrar la ruta de creación
legada F-16, añadir las protecciones de agenda F-01/F-12 con pruebas MySQL de
concurrencia, y continuar con transiciones, pagos, usuarios, reportes y sesión.
Cada cambio debe tener evidencia propia y auditoría antes de marcarse terminado.

Para repetir las pruebas y probar en otra PC: [guía local](PRUEBAS_LOCALES.md).
