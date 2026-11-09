# Pruebas de aceptación (PA) — ArtDent APF2

Las PA de este documento son las pruebas de aceptación propias del proyecto,
definidas a partir de los flujos implementados. Por decisión del usuario, **no se
requieren las fichas PA originales** ni se declara una correspondencia con
numeraciones externas. Cada fila se marca solo con evidencia ejecutada.

| ID | Caso de aceptación | Precondición / pasos | Resultado esperado | Evidencia y estado |
|---|---|---|---|---|
| PA-01 | Acceso por rol | Iniciar sesión como administrador, secretaria y odontólogo | Cada rol ve solo sus opciones; URL ajena devuelve 403/redirección | Suite `AuthFilterTest` + sesión real de secretaria Rosa (DNI 79990077). **Aprobado** |
| PA-02 | Reserva web y pago | Paciente elige servicio, odontólogo, fecha y hora; secretaría cobra | Cita creada, pago registrado y boleta B001 emitida | Cita 11, pago B001-00000009 por S/ 40. **Aprobado** |
| PA-03 | Comprobante Yape/Plin | Paciente abre «Mi reserva» y envía imagen, código, titular y DNI | Solicitud PENDIENTE; secretaría aprueba o rechaza con motivo | Prueba completa: comprobante TESTYAPE01 por S/ 80, solicitud 1 APROBADA por secretaría y pago 11 con código YAPE:TESTYAPE01; cita 9 en Confirmado. Captura 15. **Aprobado** |
| PA-04 | Boleta electrónica | Abrir boleta de una cita pagada | Serie B001, importe, paciente y servicio correctos | B001-00000009 y B001-00000010 revisadas. **Aprobado** |
| PA-05 | Consulta de reserva | Paciente ingresa código y DNI en «Mi reserva» | Ve estado, pago y boleta; sin titularidad no ve datos | Capturas 07–13 de la ejecución manual. **Aprobado** |
| PA-06 | Aprobación de pago manual | Secretaría revisa solicitud y marca verificación | Pago aprobado, cita pagada y boleta disponible | Flujo de cita 11 aprobado en la ejecución anterior. **Aprobado** |
| PA-07 | Ficha clínica | Odontólogo atiende cita confirmada y guarda diagnóstico/tratamiento | Ficha guardada, autor/fecha conservados y cita Completado | Cita 16 completada por Rubén. **Aprobado** |
| PA-08 | Cancelación y reprogramación | Secretaría cancela una cita y reprograma otra | Estado y fecha/hora actualizados sin duplicar la cita | Citas 8 (rechazada), 4 (cancelada) y 5 (reprogramada al 2026-11-16 11:00). **Aprobado** |
| PA-09 | Cierre de sesión | Cerrar sesión y usar «Atrás» o URL directa al panel | No se recupera la sesión; redirección al login | Prueba 15 en navegador. **Aprobado** |
| PA-10 | Identidad visual | Abrir login, inicio, servicios, mi reserva, ficha, correos, pagos y error | Todas cargan `css/style.css` y muestran el logo | Corregidas ficha, correos, pagos manuales y error. Capturas 14 y 15; ficha/correos verificados por HTML y rol. **Aprobado** |
| PA-11 | RENIEC real | Registrar paciente con DNI 74922215, 74922214 y 74922213 | Autocompleta nombres y apellidos o muestra error controlado | Los tres DNIs respondieron 200 con nombres y apellidos reales; 74922215 ya era paciente. **Aprobado** |
| PA-12 | Carillas | Elegir Carillas Dentales en la reserva | Precio de referencia por pieza y odontólogos Rubén/Lucía disponibles | Servicio S/ 1,500 por pieza de porcelana, imagen local y dos odontólogos (Rubén y Lucía) en base local, canónico y delta. La ficha muestra la inversión y el formulario envía `data-costo="1500.00"`; `ListService` ya copia `Costo`. Fórmula y fuentes en `CARILLAS_PRECIO.md`. **Aprobado** |

## Criterio de cierre

Una PA se marca **Aprobado** solo con evidencia ejecutada (captura, log o prueba
automatizada). Las filas **En ejecución** no cuentan como aprobadas y se listan
como pendientes en `CIERRE_PENDIENTES.md`.
