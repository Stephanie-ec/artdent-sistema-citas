# KPI K2 y K5 — definición operativa

El documento de fallas no incluye la fórmula de K2/K5. Se adopta esta definición
operativa como **fórmula del proyecto**, parametrizable por período. Las metas son
propuestas de gestión y deben ser confirmadas por la clínica; si el negocio usa
otra definición, solo se ajusta la consulta, no el modelo de datos.

## K2 — Tasa de atención efectiva

**Pregunta de negocio:** de las citas que ya tuvieron un desenlace, ¿qué
porcentaje terminó efectivamente en atención?

**Fórmula**

```
K2 = citas Completado / (citas Completado + Cancelado + Rechazado) × 100
```

No se incluyen `En espera`, `Confirmado` ni `Reprogramado` porque todavía no
tienen desenlace y distorsionarían el indicador del período.

**Fuente de datos**

| Dato | Tabla.columna |
|---|---|
| Estado de la cita | `Cita.Estado_idEstado` |
| Nombre del estado | `Estado.TipoEstado` |
| Fecha de la cita | `Cita.FechaCita` |
| Sede/odontólogo (filtro) | `Cita.Odontologo_idUsuario` |

**Meta:** ≥ 80 % de atención efectiva por mes.
**Periodicidad:** mensual, con corte al último día del mes.
**Responsable:** administración de la clínica.

**Consulta de verificación**

```sql
SELECT
  ROUND(
    100.0 * SUM(e.TipoEstado = 'Completado') /
    NULLIF(SUM(e.TipoEstado IN ('Completado','Cancelado','Rechazado')), 0),
    1
  ) AS k2_atencion_efectiva
FROM Cita c
JOIN Estado e ON e.idEstado = c.Estado_idEstado
WHERE c.FechaCita >= DATE_FORMAT(CURRENT_DATE, '%Y-%m-01')
  AND c.FechaCita <  DATE_FORMAT(CURRENT_DATE + INTERVAL 1 MONTH, '%Y-%m-01');
```

**Resultado local de octubre de 2026:** 4 Completado / (4 + 1 + 2) = **57,1 %**.
La muestra es pequeña (17 citas con fecha en octubre); el valor sirve como línea
base, no como conclusión estadística. Noviembre tiene 2 citas y aún no registra
un desenlace, por eso el cálculo mensual de noviembre sería 0 %/sin datos y no se
usa como base.

## K5 — Tasa de cancelación

**Pregunta de negocio:** ¿qué proporción de las citas registradas termina
cancelada?

**Fórmula**

```
K5 = citas Cancelado / total de citas registradas en el período × 100
```

El denominador incluye todos los estados porque mide la pérdida sobre la demanda
total agendada, no solo sobre las citas con desenlace.

**Fuente de datos**

| Dato | Tabla.columna |
|---|---|
| Estado de la cita | `Cita.Estado_idEstado` |
| Nombre del estado | `Estado.TipoEstado` |
| Fecha de registro | `Cita.FechaRegistro` |
| Fecha de la cita | `Cita.FechaCita` |

**Meta:** ≤ 10 % de cancelaciones por mes.
**Periodicidad:** mensual.
**Responsable:** secretaría / administración.

**Consulta de verificación**

```sql
SELECT
  ROUND(
    100.0 * SUM(e.TipoEstado = 'Cancelado') / NULLIF(COUNT(*), 0),
    1
  ) AS k5_cancelacion
FROM Cita c
JOIN Estado e ON e.idEstado = c.Estado_idEstado
WHERE c.FechaRegistro >= DATE_FORMAT(CURRENT_DATE, '%Y-%m-01')
  AND c.FechaRegistro <  DATE_FORMAT(CURRENT_DATE + INTERVAL 1 MONTH, '%Y-%m-01');
```

**Resultado local de octubre de 2026:** 2 canceladas / 19 citas registradas = **10,5 %**.
Queda 0,5 puntos por encima de la meta propuesta; con el volumen actual un solo
caso mueve el indicador, por lo que se recomienda leerlo junto con K2 y el motivo
de cancelación.

## Nota de implementación

Los indicadores se calculan con SQL sobre las tablas existentes. No se agregó una
tabla de KPI ni un job programado: el reporte se ejecuta bajo demanda y puede
incorporarse al panel administrativo cuando la clínica confirme las metas.
