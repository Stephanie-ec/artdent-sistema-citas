# Cierre de pendientes y auditoría — ArtDent

Fecha: 7 de noviembre de 2026, America/Lima. Base: copia local, sin remoto Git.

## Dictamen y alcance

Se implementó y validó localmente el cierre solicitado, conservando las correcciones
F-01–F-18. **Alcance:** quedan fuera el despliegue en la nube, la tabla `Persona` y
la aceptación visual integral; los flujos locales de esta pasada se probaron por
HTTP real, suite automatizada y JSPC. La auditoría anterior cubría F-01–F-18.

El DOCX se trató como referencia, no como instrucciones de ejecución. Prevalecen
las decisiones del usuario: Yape/Plin manual por el importe completo, comprobante
adjunto y código de operación; ficha clínica mínima; IA con respaldo local;
registro clínico por titular o administrador; `Persona` diferida.

## Verificación en la PC de pruebas (7/11/2026)

Ejecutado en macOS arm64 con JDK 25/26, Maven 3.9.16, Node 24 y MySQL 8.4.7 local.

| Verificación | Resultado |
|---|---|
| `mvn -B clean package` | 56 unitarias, cero fallos; WAR generado. |
| `mvn -B clean verify -Pintegration` con `db_artdent_apf2_test` | 56 unitarias y 33 de integración, cero fallos. |
| `node --test scripts/test-ui-segura.cjs` | 5 pruebas correctas. |
| `jetty-jspc-maven-plugin:9.4.51.v20230217:jspc` | 38 JSP compilados, 0 errores. |
| `java scripts/HttpSmokeCheck.java` con Jetty y MySQL reales | 10 comprobaciones OK. |
| Base local `db_artdent_apf2` | Respaldo previo y delta aplicado; 19 citas, 15 pacientes, 4 usuarios y 8 pagos conservados. |

Se corrigieron dos defectos detectados en esta revisión: `CierreServiciosTest`
borraba `artdent.reniec.mode` (propiedad de Surefire), lo que hacía fallar una
prueba según el orden; y los botones «Completar atención» de `PDCSolicitudes.jsp`
enviaban el cambio de estado que el SQL rechaza, en lugar de abrir
`AtencionController`. `CompletarAtencionUiTest` fija ese segundo caso.

El estado actualizado de las PA está en `PA_ACEPTACION.md`; RENIEC quedó verificado
en la aplicación local, Carillas tiene precio de referencia y fórmula, y K2/K5 están
definidos. El correo externo/Gmail se retiró del alcance por decisión del usuario;
las notificaciones internas siguen en la base. Quedan como riesgos externos Gemini
y la aceptación visual de las PA marcadas. `Persona` sigue diferida.

## Cambios pequeños y forma de verificarlos

| Etapa | Cambio implementado | Evidencia / aceptación pendiente |
|---|---|---|
| 1 | Matriz de cumplimiento y corrección del alcance de la auditoría anterior. | Este documento; todos los PA conservan su estado pendiente. |
| 2 | Configuración externa; exclusión del archivo privado del WAR; ZIP por lista permitida. | `ConfigExternaTest`; WAR probado con un secreto ficticio; `EmpaquetarEntrega.java`. |
| 3 | Foto existente de Lucía en el equipo dinámico; odontólogo visible en tarjetas Web y presenciales. | Prueba MySQL de la proyección pública y compilación JSP. Captura visual pendiente. |
| 4 | Normalización acotada de «ensias» y «cariez»; exclusión de limpieza doméstica. | `ChatbotSeguroTest`: tres fallos al retirar la corrección y verde al restaurarla. |
| 5 | Gemini opcional con modelo configurable, límites de red, respuesta validada y respaldo local. | `CierreServiciosTest` con proveedor simulado. Cuenta/modelo real pendientes. |
| 6 | RENIEC común también en alta de pacientes; modo demo explícito y visible; indisponibilidad bloquea por defecto. | Prueba de modo obligatorio sin proveedor y validación real 3/3 en `/ConsultaDniController` (DNI 74922215, 74922214 y 74922213). |
| 7 | Solicitud de pago, comprobante JPEG/PNG validado y recodificado, almacenamiento privado y consulta autorizada. | Pruebas de imágenes inválidas/tamaño, controles de acceso y solicitud sin Pago. Prueba visual y cuenta real pendientes. |
| 8 | Revisión manual transaccional, boleta y confirmación; operación aprobada única por canal/código. Simulación desactivada por defecto. | Pruebas MySQL: dos revisores, carrera con efectivo, repetición, operación duplicada y cancelación. |
| 9 | Devolución manual completa con referencia, fecha y actor; conserva pago y boleta. | Prueba MySQL de cancelación, registro y repetición sin sobrescribir la referencia. |
| 10 | Una ficha `Atencion` por cita; diagnóstico, tratamiento, observaciones, autor y fecha; finalización atómica. | Pruebas de cita futura, sin pago Web, autor ajeno, secretaría, campos vacíos y sobrescritura. |
| 11 | Cola por destinatario para paciente, odontólogo y secretaría; deduplicación y reintentos limitados; SMTP fuera de la transacción clínica. | Pruebas MySQL de destinatarios, deduplicación y reserva de mensajes. El correo externo/Gmail se retiró del alcance; la cola interna queda probada. |
| 12 | Canónico y delta consolidados; guía actualizada; diagrama y RF11 actualizados. | Migración repetida compara huellas de diez tablas, incluidas las nuevas. |

## Matriz F-01–F-18

«Automatizado» significa probado con Java/SQL/dobles DOM; la aceptación visual
de cada recorrido continúa pendiente.

| Falla | Implementación y prueba principal | Estado |
|---|---|---|
| F-01 | Fecha, domingo, turno completo y solapamiento; `AgendaIT`. | Automatizado. |
| F-02 | Reprogramadas visibles y finalización mediante ficha; `EstadosIT`. | Automatizado. |
| F-03 | Estado decidido en servidor/BD, no campo oculto; `EstadoManipuladoTest`, `EstadosIT`. | Automatizado. |
| F-04 | Desactivación conserva historial y pagos; `BajaLogicaIT`. | Automatizado. |
| F-05 | Validación y mensajes CRUD; `UsuarioGestionTest`. | Automatizado; RENIEC real verificado 3/3 en la aplicación local. |
| F-06 | No eliminar citas pagadas; `EstadosIT`. | Automatizado. Solicitudes de pago también conservan su referencia por FK. |
| F-07 | Titular/admin, fecha y ficha obligatoria; `CierrePendientesIT`. | Automatizado. |
| F-08 | Fecha/hora inválida o pasada rechazada; `CitaFechaTest`, `ValidadorFechaTest`. | Automatizado. |
| F-09 | Ingresos desde pagos; `IngresosIT`, `DashboardIT`. | Automatizado. |
| F-10 | Bloqueo de pagos anulados y seguimiento de devolución; `PagosIT`, `CierrePendientesIT`. | Automatizado; devolución bancaria real es manual. |
| F-11 | Mi reserva, pago pendiente/registrado, boleta y acceso a solicitudes/devoluciones; `PortalReservaTest`. | Servidor probado; recorrido visual pendiente. |
| F-12 | Bloqueos contra doble reserva; `AgendaIT`. | Automatizado. |
| F-13 | Intervalos adyacentes admitidos; `AgendaIT`. | Automatizado. |
| F-14 | Disponibilidad del nuevo odontólogo y equipo dinámico; `BajaLogicaIT`, `UsuarioGestionTest`. | Automatizado; captura pendiente. |
| F-15 | JSON escapado, cliente con texto y enlaces del catálogo; pruebas Java y JS. | Automatizado; proveedor IA real pendiente. |
| F-16 | Ruta de reserva legada rechazada; `ReservaLegadaTest`. | Automatizado. |
| F-17 | Errores contextualizados, sin exponer SQL al paciente; controladores y pruebas específicas. | Automatizado en los casos cubiertos; no se afirma cobertura universal. |
| F-18 | Descripción por defecto «Reserva Web» / «Cita Presencial» en `CitaController`; `AgendaIT` comprueba ambas. | Automatizado. |

## Aceptación, bloqueos y riesgos residuales

| Elemento | Estado y condición de cierre |
|---|---|
| PA propias (PA-01 a PA-12) | Definidas y ejecutadas en `PA_ACEPTACION.md`. Por decisión del usuario no se requieren las fichas PA originales ni se declara correspondencia con numeraciones externas. |
| Recorridos manuales del DOCX | Guía reproducible en `PRUEBAS_PLAN_COMPLETO.md`. El flujo crítico reserva pagada → aprobación → ficha clínica se recorrió en navegador real el 2026-11-07 (capturas en `capturas/01` a `capturas/06`); la captura visual de los PA restantes queda como evidencia pendiente. |
| Cierre de sesión / Atrás | Verificado en navegador real el 2026-11-07: tras cerrar sesión, el botón Atrás vuelve al login y las URL directas (`ADMPUsuarios.jsp`, `AtencionController`, `ReservaController`) redirigen a `iniciosesion.jsp` sin sesión. Corresponde a la prueba 15 del DOCX, que figuraba como «falla». |
| Calendario de secretaría / diagrama de casos de uso | Resueltos: cada tarjeta muestra «Dr(a). Nombre Apellido» y `CASOS_DE_USO.md` incluye «Consultar mi reserva» y la cobertura del administrador sobre secretaría. |
| Carillas | Servicio 8 «Carillas Dentales» a S/ 1,500 por pieza de porcelana, con Rubén y Lucía asignados. Fórmula, fuentes y rango de mercado en `CARILLAS_PRECIO.md`; canónico y delta actualizados. |
| K2 / K5 | Fórmulas, metas propuestas y línea base definidas en `KPI_K2_K5.md`; octubre 2026: K2 **57,1 %** (4/7) y K5 **10,5 %** (2/19). Son supuestos operativos porque el DOCX no trae fórmula. |
| Nube | Bloqueado el despliegue: proveedor y cuenta no definidos. |
| Persona | Diferida por decisión expresa; no implementada ni marcada como cumplida. |
| RENIEC / Yape-Plin / correo | RENIEC real validado 3/3. Yape/Plin es manual con datos de demo `ART DENT SAC` / `986765235`; no se ejecutaron movimientos bancarios reales. El correo externo/Gmail se retiró del alcance y `mail.enabled=false`; las notificaciones internas se conservan en base. |

Auditoría crítica (solo si se reactivara el correo externo): SMTP no garantiza exactamente una entrega ante una caída justo
después de que el servidor acepte el mensaje y antes de registrar el resultado.
Se evitan filas duplicadas y envíos simultáneos mediante clave de evento y reserva
temporal; ese caso ambiguo puede requerir revisar la bandeja antes de reintentar.
Los eventos se encolan después de guardar la cita: un fallo al encolar se registra
en el log y en el aviso de error, pero requiere revisión operativa. No se afirma
una garantía transaccional de entrega de extremo a extremo.

La IA es orientación, no diagnóstico. El filtro de contexto es acotado, no una
comprensión universal del lenguaje. No transmite registros clínicos; evitar incluir
datos personales en el texto libre. Los importes y enlaces del servicio siempre
se construyen desde el catálogo del servidor.

Los pagos en efectivo preservan su aprobación clínica existente: cobrar no cambia
por sí solo el estado de una reserva Web. La aprobación manual Yape/Plin sí confirma
la reserva pendiente, dentro de la misma transacción del pago.

La ficha clínica es de solo lectura tras registrarse. Las citas históricas completadas
antes de esta actualización pueden no tener ficha; no se fabricaron datos clínicos.

Resultados ejecutados y evidencia de regresiones: ver `evidencias/cierre-verificacion.json`
y `evidencias/cierre-regresiones-red.txt`. No sustituir pendientes por «OK» al entregar.

### Recorrido manual del flujo crítico (2026-11-07)

Cita 11 (Valeria Torres, 2026-10-25 11:00, Limpieza, Web) recorrida en navegador real
sobre Jetty local, con la siguiente secuencia verificada:

1. Secretaría abre «Solicitudes Web» y ve la reserva en espera con pago pendiente.
2. Cobro en ventanilla con DNI 73445566: se emite la boleta `B001-00000009` por S/ 40.00,
   método Efectivo, transacción `EFEC-20261107133501` (capturas 02 y 03).
3. Aprobación desde la lista: la cita pasa a estado 3 «Confirmado» (captura 04).
4. Rubén Cuadros abre la ficha (`AtencionController?cita=11`), registra diagnóstico,
   tratamiento y observaciones (captura 05).
5. La ficha se guarda en solo lectura, con autor y fecha, y la cita queda en estado 2
   «Completado» (captura 06). En base: `Atencion` con `Autor_idUsuario=4` y
   `Registrada=2026-11-07 13:36:11`; un solo `Pago` de S/ 40.00 y un solo comprobante.

Defecto encontrado y corregido durante el recorrido: las citas heredadas con
`Importe = 0` no podían cobrarse porque `COALESCE(c.Importe, s.Costo)` aceptaba el cero
y el DAO lo rechazaba por importe no válido. Se cambió a
`COALESCE(NULLIF(c.Importe,0), s.Costo)` en `PagoDaoImpl` (bloqueo de cobro, costo
consultado y consulta de reserva) y en `PagoManualDao` (revisión Yape/Plin).
Verificado con el cobro real anterior, 56 pruebas unitarias y 33 de integración.

El modal de cobro ya muestra el importe real: las rutinas de listado entregan
`COALESCE(NULLIF(c.Importe,0), s.Costo)`, el monto se presenta en solo lectura y el
canónico se actualizó junto con el delta `update_apf2_importe_cero.sql`, aplicado a la
base local y a la de pruebas. `CompletarAtencionUiTest` fija que no exista un valor fijo
y `PagosIT` fija el cobro de una cita legada con `Importe = 0` al costo del servicio.

La suite vigente queda en 56 unitarias y 33 de integración, sin fallos (se retiraron las dos pruebas de la pasarela). El chatbot ya
rechaza consultas ajenas («me duele el pie») con el aviso de alcance, cubierto por
`ChatbotSeguroTest`; la prueba 6 del DOCX deja de estar a medias por ese motivo.

### Pruebas manuales 7, 9 y 12 del DOCX (2026-11-07)

| Prueba | Resultado | Evidencia |
|---|---|---|
| 7. El administrador crea una secretaria y entra con ella | OK | Usuario id 9 «Rosa Prueba Siete», DNI 79990077, rol Secretaria. Inicia sesión y ve todas las reservas web y presenciales. `capturas/07-creacion-secretaria.png`, `capturas/08-secretaria-nueva.png`. |
| 9. La secretaria cobra, rechaza, cancela y reprograma | OK | Cobro de la cita 3: boleta `B001-00000010` por S/ 40. Rechazo de la cita 8: estado 6 y notificación 15. Cancelación de la cita 4: estado 5 y notificación 16. Reprogramación de la cita 5 al 2026-11-16 11:00, con aviso «Cita reprogramada». `capturas/09-cobro-ventanilla.png`, `capturas/10-rechazo-cancelacion.png`, `capturas/11-reprogramacion.png`. |
| 12. El odontólogo ve su calendario y finaliza una cita propia | OK | Rubén ve únicamente su agenda (semana 41, cita del 10/10 a las 11:00). Ficha de la cita 16 guardada: cita en estado 2 «Completado», `Atencion` con autor 4 y fecha 2026-11-07 13:50:41. `capturas/12-calendario-doctor.png`, `capturas/13-ficha-completada.png`. |

Datos de prueba modificados por estas pruebas: cita 3 pagada, cita 8 rechazada, cita 4
cancelada, cita 5 reprogramada, cita 16 completada y usuario 9 creado. No se enviaron
correos reales: el correo externo/Gmail se retiró del alcance. Las notificaciones quedan encoladas en la base.
La prueba 10 quedó validada con RENIEC real 3/3 y la 15 ya se verificó.


## Segunda pasada del DOCX (7/11/2026)

| Pendiente | Resultado |
|---|---|
| CSS y logos | Se agregó `css/style.css`, Bootstrap Icons y el encabezado con logo a `WEB-INF/atencion.jsp`, `WEB-INF/correos.jsp`, `WEB-INF/pagos-manuales.jsp` y `error.jsp`. El barrido de los 34 JSP confirma hoja de estilos en todas las pantallas reales; las páginas legado `reserva.jsp`, `reservacita.jsp` y `formularioreserva.jsp` son redirecciones. Evidencias `capturas/14-error-css-logo.png` y `capturas/15-pagos-yape-css-logo.png`. |
| Correo externo | Retirado del alcance por decisión del usuario. Se eliminaron las credenciales y el bloque Gmail de `config.properties`; `mail.enabled=false`. Las notificaciones internas siguen guardándose en `Notificacion`/`CorreoPendiente`. |
| RENIEC real | `reniec.mode=required`, token Decolecta y URL configurados. Los tres DNIs respondieron 200 en la API y en `/ConsultaDniController` de la aplicación local: Meylin Alessa Szabo Ramirez, Josue Jacob Bohorquez Quispe y Anthony Arthur Zapata Valentin. El 74922215 ya existe como paciente, por lo que el modo personal devuelve sus datos locales. |
| Yape/Plin | Titular `ART DENT SAC`, número `986765235` y carpeta privada `src/main/temp/comprobantes`. La sesión de paciente de la cita 9 mostró el bloque de envío y se completó la prueba: comprobante TESTYAPE01 por S/ 80, solicitud 1 APROBADA, pago 11 con código `YAPE:TESTYAPE01` y cita 9 en Confirmado. En esta pasada, la cita 5 sin pago mostró `Titular: ART DENT SAC · Número: 986765235` en `PagoManualController?cita=5`. |
| Pasarela de pago | Se eliminó `pagarEnLinea` del controlador, su case, la excepción del filtro, el texto del voucher y las dos pruebas asociadas. `pagos.demo.enabled` ya no se usa. Compilación y suite en verde. |
| Carillas | Servicio 8 «Carillas Dentales», S/ 1,500 por pieza de porcelana, imagen `img/servicios/carillas.png`, asignado a Rubén y Lucía. La ficha muestra `S/ 1500.00` y el formulario envía `data-costo="1500.00"`; `ListService` ya copia `Costo`. Fórmula y fuentes en `CARILLAS_PRECIO.md`; actualizados el canónico y el delta `update_apf2_carillas.sql`. |
| KPI K2/K5 | Definidos en `KPI_K2_K5.md` con fórmula, tablas, meta, consulta y línea base de octubre 2026: K2 **57,1 %** (4/7) y K5 **10,5 %** (2/19). Son supuestos operativos porque el DOCX no trae fórmula. |
| PA | `PA_ACEPTACION.md` define 12 casos propios; RENIEC, Carillas y las pantallas se marcan aprobados con la evidencia de esta pasada. Por decisión del usuario no se requieren las fichas originales. |

Verificación de esta pasada: 56 unitarias y 33 de integración sin fallos, `jetty:jspc` sin errores,
Jetty local en 8080, RENIEC 3/3, Yape/Plin visible y capturas 14–15 generadas.
No se desplegó nada en la nube ni se enviaron correos.
