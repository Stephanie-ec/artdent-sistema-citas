# Auditoría del plan F-01 a F-18 y sesión

> Documento histórico del alcance F-01–F-18. Para el DOCX completo y el código
> actual, usar [CIERRE_PENDIENTES.md](CIERRE_PENDIENTES.md). Los conteos y el
> asistente exclusivamente local descritos aquí corresponden a la etapa anterior.

Fecha: 7 de noviembre de 2026, America/Lima.

**Estado:** las correcciones están implementadas y verificadas en compilación,
pruebas unitarias e integración MySQL. La aceptación por HTTP y navegador queda
pendiente en otra PC: Jetty no pudo iniciar en este equipo. No se declara una
verificación visual ni una certificación de seguridad de toda la aplicación.

## Evidencia final

| Verificación ejecutada | Resultado |
|---|---|
| `mvn -B clean verify -Pintegration` con BD de pruebas explícita | 39 unitarias y 23 de integración; cero fallos, errores u omitidas; `BUILD SUCCESS`. |
| `node --test scripts/test-ui-segura.cjs` | Cinco pruebas correctas. Dobles DOM, no navegador real. |
| Compilador JSP de Jetty 9.4.51 | 35 JSP compilados correctamente. |
| Instalación canónica en una segunda base vacía | Correcta; 15 citas de demostración iniciales. |
| Comparación instalación limpia / base actualizada | 41 rutinas coinciden al normalizar comentarios y formato. |
| Aplicación del delta dos veces | Huellas de Cita, Pago, Comprobante, Usuario, Paciente y Notificacion sin cambios. |
| Reposición temporal del código defectuoso | Las regresiones principales vuelven a fallar. Correcciones restauradas y compilación limpia posterior. |

Entorno usado: JDK 17 portátil, Maven 3.9.9 y MySQL 8.0.44 portátil en
`127.0.0.1:3307`. Las herramientas se extrajeron en una carpeta temporal, sin
instalar servicios ni modificar permanentemente el PATH. Se usaron bases
separadas terminadas en `_test`; no se aplicó el delta a una base de producción.

Los informes de la última compilación están en `target/surefire-reports` y
`target/failsafe-reports`. Los extractos persistentes están en
[evidencias/regresiones-red.txt](evidencias/regresiones-red.txt) y
[evidencias/verificacion-final.json](evidencias/verificacion-final.json).

## Cobertura de cada falla

| Elemento | Cambio y evidencia | Límite de la verificación |
|---|---|---|
| F-01 | Validación temporal Java y guardas SQL de turno, servicio, domingo y solapamiento. `AgendaIT`. | Formulario compilado; interacción visual pendiente. |
| F-02 | Estado 4 incluido en listados y finalización; corregidas ramas de JSP que lo enviaban a confirmar. `EstadosIT`. | Botones revisados en código y JSP compilados. |
| F-03 | Se ignora el parámetro `estado`; la transición consulta estado y pago bajo bloqueo. `EstadoManipuladoTest` y `EstadosIT`. | Petición servlet con dobles HTTP; SQL real. |
| F-04 | `Usuario.Activo`, baja lógica, filtros de selección/login y revocación de sesiones. `BajaLogicaIT`, `AuthFilterTest`. | Login y conservación de registros probados con MySQL; sesión HTTP real pendiente. |
| F-05 | Validación, DNI duplicado, resultado de escritura, mensajes y desactivación mediante POST. `UsuarioGestionTest`. | Formularios y banners compilados; creación/edición visual pendiente. |
| F-06 | Eliminación pagada bloqueada en transacción y botón condicionado por Pago, incluso si falta una boleta histórica. `EstadosIT`, `PagosIT`. | Rama de interfaz revisada; rechazo SQL probado. |
| F-07 | Finalización solo por titular o administrador, con fecha/hora no futura. `EstadosIT`. | Control efectivo en MySQL. |
| F-08 | Fechas/horas válidas, no pasadas y no domingo; reloj de Lima. `ValidadorFechaTest`, `CitaFechaTest`. | HTTP 400 probado invocando el servlet; smoke real preparado. |
| F-09 | Dashboard y reporte usan Pago y BigDecimal. `IngresosIT`, `DashboardIT` con los controladores y DAO reales. | Comparación sobre el mismo conjunto, sin escrituras entre ambas lecturas. |
| F-10 | Pago/boleta atómicos, bloqueo contra anulación, correlativos y aviso de devolución. `PagosIT`, `EstadosIT`. | No hay cargos ni reembolsos bancarios: el pago en línea fue retirado; solo se registran Yape/Plin manual y caja. |
| F-11 | Mi reserva siempre muestra detalles, pago, estado y boleta; autorización previa al pago. `PortalReservaTest`, consultas MySQL. | Modal y navegación pendientes de revisión en navegador. |
| F-12 | Mutex por odontólogo y lectura de conflictos bajo bloqueo; IDs de la conexión. Carrera con dos conexiones en `AgendaIT`. | Protege las rutas oficiales; un administrador SQL puede modificar tablas directamente. |
| F-13 | Solapamiento estricto de intervalos; admite extremos contiguos. `AgendaIT`. | Probado con MySQL y con reposición del método antiguo. |
| F-14 | ID real del usuario creado, redirección a disponibilidad y especialistas activos desde BD. `UsuarioGestionTest`. | Lista pública compilada; presentación visual pendiente. |
| F-15 | Chatbot acotado al catálogo, JSON con escape y DOM por texto/enlaces numéricos. `ChatbotSeguroTest`, pruebas JS. | No se ejecutó un navegador; no se afirma cobertura de todo XSS de la aplicación. |
| F-16 | POST legado con forward al controlador oficial y JSP legados al formulario público. `ReservaLegadaTest`, `AuthFilterTest`. | Redirecciones JSP compiladas; recorrido HTTP preparado. |
| F-17 | Errores de negocio, entradas inválidas y fallo de BD con mensaje y retorno contextual. `EstadoManipuladoTest`. | No se probaron todas las interrupciones de infraestructura. |
| F-18 | Descripción por defecto sin estado, también en DAO. `AgendaIT`. | Verificación de los valores guardados en MySQL. |
| Sesión / prueba 15 | No-store antes de redirecciones, recarga por pageshow y rol/actividad vigente. `AuthFilterTest`, pruebas JS. | Botón Atrás y bfcache real pendientes. |

## Pruebas que sí detectaron los defectos

Se aplicó `red-green-proof` a las regresiones principales: ejecución sobre el
código defectuoso, corrección, reposición temporal y restauración. Los extractos
del segundo rojo incluyen:

```text
F-12: una sola reserva debe ganar expected:<1> but was:<2>
expected java.sql.SQLException to be thrown, but nothing was thrown
F-04: debe conservar la cita expected:<1> but was:<0>
F-10: cita cancelada no admite pagos
F-13: 10:45 debe estar libre
Wanted but not invoked: requestDispatcher.forward(...)
```

Los primeros cinco casos usan MySQL real. El último usa dobles servlet y prueba
que el POST legado debe llegar a la ruta oficial. La evidencia histórica de F-08
está en [AUDITORIA_F08.md](AUDITORIA_F08.md). Para las demás mejoras se reporta su
cobertura de comportamiento actual; no se inventa un ciclo rojo original que no
se haya observado.

## Decisiones revisadas críticamente

- **Bloqueo de agenda:** bloquear solo citas existentes no ofrece una fila común
  cuando el horario está vacío. Se usa la fila del odontólogo como mutex y una
  lectura de conflictos con `FOR UPDATE`; las operaciones oficiales comparten
  ese protocolo. La transacción termina con rollback ante error.
- **Separación de validaciones:** el validador Java se ocupa de formato y tiempo;
  la disponibilidad y la concurrencia se validan en la capa SQL. No se añadió una
  dependencia de BD al validador puro solo para cumplir un nombre de método.
- **Reservas pendientes:** reprogramar una reserva en espera conserva ese estado.
  La reprogramación no sustituye la aprobación ni permite saltar el pago.
- **Ingresos:** el mes financiero corresponde a `FechaPago`, mientras los conteos
  clínicos corresponden a `FechaCita`. Los rótulos lo explican. Los pagos de citas
  anuladas siguen siendo ingresos registrados mientras no exista una devolución
  efectuada; se informa la gestión pendiente.
- **Contabilidad:** se reemplazó el cálculo concurrente `MAX(Numero)+1` por un
  correlativo de serie bloqueado. Se probó el rollback cuando falla la boleta:
  no quedan ni pago huérfano ni avance de correlativo.
- **Chatbot:** se sustituyó la generación HTML libre y la llamada externa por
  orientación local sobre el catálogo. El usuario no necesita una clave Gemini.
  No se infiere automáticamente un tratamiento a partir de dolor genérico.
- **Datos de pantalla:** nombre de servicio y costo se obtienen de BD. No se
  cambia silenciosamente un odontólogo elegido si ya no está disponible. Se
  quitaron datos ficticios y parámetros reflejados del voucher y se escapó la
  descripción de reserva en el panel, reprogramación e historial.
- **Usuarios desactivados:** además de impedir nuevos logins, el filtro revisa el
  rol y la actividad actuales. CSS, imágenes y scripts públicos no dependen de
  esa consulta, para conservar el acceso a los recursos cuando falla la BD.
- **Etapas:** los cambios que comparten la misma transacción/controlador se
  agruparon para no dejar una interfaz incompatible con su capa SQL. El historial
  Git identifica F-16, F-04, F-13, agenda, estados, usuarios, ingresos, pagos,
  chatbot, sesión y las correcciones encontradas durante esta auditoría.

## Errores e hipótesis descartadas durante la verificación

1. Se lanzaron dos procesos Maven sobre `target` y se interfirieron. Se detuvieron
   y se repitió todo con compilación limpia y ejecución secuencial.
2. Se investigó una posible lectura antigua del turno durante una espera. La
   primera prueba no observaba correctamente el bloqueo; se corrigió el observador
   con `performance_schema.data_lock_waits` y el ID de conexión. La versión actual
   ya rechaza el turno eliminado: no se afirmó como bug reproducido ni se cambió
   código productivo por esa hipótesis.
3. Una repetición de F-13 recogió primero el fallo de F-16 por una clase compilada
   conservada tras restaurar un archivo con timestamp anterior. Se descartó ese
   resultado, se forzó recompilación y se observó el fallo correcto de F-13. La
   última verificación fue `clean verify`, con todas las correcciones restauradas.
4. La comparación textual de rutinas reportó diferencias de comentarios y líneas
   vacías. Al normalizar únicamente formato/comentarios, las 41 rutinas coincidieron.

## Revisiones y pendientes reales

Se revisaron los cambios con las reglas universales y Java de `code-reviewer`,
en este mismo chat; no fue una revisión independiente. Sus analizadores Python
no se ejecutaron porque ese runtime no está disponible. El detector de
`impeccable` señaló tipografías y una animación heredadas; se conservaron porque
esta tarea corrige funcionalidad y no rediseña el sitio.

El intento de navegador mediante `computer-use` encontró conexión rechazada
porque Jetty terminó con `Unable to establish loopback connection`. La preferencia
IPv4 no resolvió el inicio. No se modificaron políticas del equipo ni se declaró
probado lo que no pudo observarse. El smoke Java quedó preparado y compilado;
el `.ps1` de la etapa anterior fue bloqueado por la política local.

El workflow de CI ahora prepara MySQL de laboratorio, ejecuta Java y JS y compila
los JSP. Se verificaron sus comandos equivalentes localmente; **no se ejecutó un
workflow remoto de GitHub** ni se publicó el proyecto.

Antes de aceptar el resultado completo, ejecutar en la otra PC el smoke HTTP y
la tabla manual de [PRUEBAS_PLAN_COMPLETO.md](PRUEBAS_PLAN_COMPLETO.md), especialmente
pagos/boletas, usuarios, reprogramación, roles y Atrás después de cerrar sesión.
Las pruebas de correo entregado requieren SMTP válido. No se hizo una auditoría
normativa, un pentest completo ni una revisión de todas las dependencias/CVE.
