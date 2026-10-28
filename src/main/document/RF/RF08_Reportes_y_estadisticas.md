# Guía de Usuario y Documentación Funcional: RF08 - Reportes y Estadísticas de Gestión

---

## 1. Ficha del Requerimiento

| Campo | Detalle |
| :--- | :--- |
| **Identificador** | **RF08** |
| **Nombre del Requerimiento** | Reportes y Estadísticas |
| **Prioridad** | **Media** |
| **Módulo** | Módulo de Inteligencia de Negocios y Analítica Operativa |
| **Roles Autorizados** | **Administrador** (Reportes globales de centro e ingresos), **Secretaria** (Reportes operativos de atención) |
| **Cambio en APF2** | **Sin cambio:** El Administrador genera reportes de citas completadas, canceladas, reprogramadas e ingresos; constituyen la fuente fundamental para los indicadores clave de desempeño (KPI) del centro. |

---

## 2. Descripción en Lenguaje Sencillo

Este requerimiento provee al equipo directivo y administrativo de ArtDent una visión analítica del desempeño del centro odontológico:

1. **Tarjetas de Métricas Clave (KPIs):**
   * **Total Ingresos (S/.):** Sumatoria de los ingresos efectivamente recaudados por servicios odontológicos atendidos o pagados.
   * **Citas Completadas:** Número total de atenciones cerradas exitosamente por el personal médico.
   * **Total Citas/Reservas Gestionadas:** Volumen global de solicitudes recibidas en la clínica.
   * **Citas Canceladas:** Número de atenciones que no prosperaron o fueron anuladas.
2. **Visualización Gráfica Interactiva (Chart.js):**
   * **Gráfico de Barras:** Comparativa mensual del volumen de reservas web vs. citas presenciales.
   * **Gráfico de Líneas:** Evolución temporal de reservas y citas.
   * **Gráfico Circular (Pie Chart):** Proporción de citas atendidas exitosamente vs. citas pendientes o no asistidas.
   * **Gráfico de Tendencias:** Líneas de atenciones completadas vs. canceladas a lo largo de los meses.
   * **Gráfico de Ingresos Económicos:** Ingresos mensuales en nuevos soles (S/.).
3. **Detalle Tabular Mensual:**
   * Tabla con desglose detallado mes a mes: Completadas, En espera, Reprogramadas, Confirmadas, Canceladas y Facturación mensual.
   * Botón interactivo para mostrar u ocultar la tabla de datos según se desee.

---

## 3. Proceso Paso a Paso para el Usuario

### Paso 1: Acceso al Módulo de Reportes
1. Iniciar sesión como **Administrador** (DNI `48223344` / Clave `123`) o como **Secretaria** (`78223344` / Clave `1234`).
2. En la barra lateral izquierda, hacer clic en la opción **"Reportes"**.

### Paso 2: Análisis de Tarjetas KPI Superiores
1. Al ingresar, se observan inmediatamente las 4 tarjetas de resumen estadístico:
   * Tarjeta Azul: **Total Ingresos Acumulados** en soles.
   * Tarjeta Verde: **Citas Completadas**.
   * Tarjeta Amarilla: **Total Gestionadas**.
   * Tarjeta Roja: **Canceladas**.

### Paso 3: Exploración de Gráficos Analíticos
1. Desplazarse por la pantalla para examinar los gráficos interactivos generados con Chart.js:
   * Pasar el cursor sobre las barras o líneas para ver los valores numéricos exactos de cada mes.
   * Hacer clic en las etiquetas de las leyendas para activar o desactivar series de datos comparativas.

### Paso 4: Consulta de la Tabla de Detalle Mensual
1. Para ver los datos numéricos tabulares, hacer clic en el botón **"Mostrar/Ocultar Detalle Mensual"**.
2. Se desplegará la tabla completa con el conteo desagregado por cada estado de reserva y cita médica.
3. Volver a hacer clic en el botón para colapsarla y priorizar la vista gráfica.

---

## 4. Reglas de Negocio e Integridad Técnica

1. **Fuentes de Datos:**
   * Las reservas provienen de la tabla `Cita` donde `Origen = 'Web'` (vía `ReservaDao.listarTodasReservasAd`).
   * Las citas presenciales provienen de la tabla `Cita` donde `Origen = 'Presencial'` (vía `CitaDao.listarTodasCitasAd`).
   * Los ingresos económicos se calculan considerando las atenciones en estado 'Completado' o con pago registrado en la tabla `Pago`.
2. **Control de Acceso por Rol:**
   * El Administrador accede con `accion=reportead` visualizando las métricas de toda la clínica.
   * La Secretaria accede con `accion=reporte` visualizando el rendimiento de atención operativa.

---

## 5. Evidencias de Verificación y Auditoría

* **Suite de Pruebas Automatizada:** Ejecución exitosa de `test_lote3_admin.py` (Paso 4).
* **Auditoría Técnica:** `ReporteController` genera KPIs y el HTML enlaza correctamente con Chart.js sin errores de consola.
* **Captura de Pantalla en Google Chrome:** Archivo `reportes_admin_ui.png` generado mediante CDP en puerto 9222.
