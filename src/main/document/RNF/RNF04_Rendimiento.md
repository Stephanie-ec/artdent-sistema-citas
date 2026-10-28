# RNF04: Rendimiento y Soporte de Solicitudes Simultáneas

## 1. Ficha Técnica del Requerimiento

| Campo | Detalle |
| :--- | :--- |
| **Identificador** | `RNF04` |
| **Nombre** | Rendimiento y Soporte de Solicitudes Simultáneas |
| **Tipo** | Requerimiento No Funcional (Performance / Carga / Tiempos de Respuesta) |
| **Prioridad** | **Alta** |
| **Cambio en APF2** | **Sin cambio** |
| **Módulos Afectados** | Portal de Inicio (`index.jsp`), Reserva Web (`reservapersonal.jsp`), Panel de Citas (`PDCSolicitudes.jsp`), Emisión de Boleta (`PagoController`), Autenticación (`iniciosesion.jsp`). |
| **Umbral de Aceptación** | Tiempo de carga < 1.500 ms (1,5 segundos) bajo concurrencia normal y alta; soporte de múltiples peticiones en paralelo sin bloqueos de servidor. |
| **Tecnologías Evaluadas** | Servidor Web Jetty / Tomcat, JDBC Connection Pooling, Índices B-Tree en MySQL (`db_artdent_apf2`), Script de Benchmark Multihilo en Python (`concurrent.futures`). |

---

## 2. Explicación en Lenguaje Sencillo (para el Product Owner / Docente)

Cuando varios pacientes ingresan al mismo tiempo a separar citas desde sus teléfonos, o cuando la secretaria consulta la lista del día mientras el administrador revisa los reportes de ingresos, el sistema debe responder de inmediato:
- **Cero Esperas:** Ninguna pantalla debe tardar segundos en cargar o quedar "congelada".
- **Respuesta Instantánea en Caja:** La generación de la boleta de venta electrónica debe ser inmediata tras hacer clic en "Cobrar".
- **Estabilidad bajo Carga:** El servidor no debe caerse ni degradar su velocidad si varias personas realizan reservas en el mismo minuto.

Para lograr esto, las consultas a la base de datos están optimizadas con índices estratégicos (por fecha, DNI y estado de cita), las hojas de estilo y tipografías están optimizadas en caché, y las conexiones a la base de datos se reutilizan eficientemente mediante un pool de conexiones JDBC.

---

## 3. Paso a Paso de Funcionamiento en el Sistema

### 3.1 Carga Rápida de Vistas Públicas
1. El usuario solicita la página de reserva web (`reservapersonal.jsp`).
2. El servidor procesa la vista JSP en memoria y entrega el HTML compilado en menos de **20 ms**.
3. Los recursos gráficos ligeros y fuentes se descargan de forma asíncrona, permitiendo al paciente interactuar con el formulario casi instantáneamente.

### 3.2 Despacho Concurrente de Solicitudes
1. Múltiples clientes realizan solicitudes en paralelo (reserva, autenticación, consulta de comprobantes).
2. El servidor asigna hilos de ejecución de su *thread pool* de manera no bloqueante.
3. Las peticiones a base de datos invocan procedimientos almacenados optimizados que leen sobre índices (`idx_cita_fecha`, `idx_paciente_dni`), completando la transacción en milisegundos.
4. El servidor libera la conexión JDBC al pool inmediatamente después de procesar la respuesta.

---

## 4. Reglas de Negocio Asociadas

1. **RN-RNF04-1 (Umbral Máximo de Latencia):**
   - El tiempo de respuesta promedio de las páginas web y llamadas a controladores no debe superar los **1.500 ms** bajo condiciones normales de red local o servidor institucional.
2. **RN-RNF04-2 (Indexación en Base de Datos):**
   - Las consultas frecuentes de citas, pacientes y usuarios deben operar sobre columnas indexadas (`DNI`, `FechaCita`, `Estado`, `idUsuario`), evitando escaneos completos de tablas (*Full Table Scans*).
3. **RN-RNF04-3 (Timeouts en Servicios Externos):**
   - Las conexiones hacia servicios de terceros (como el servidor SMTP de notificaciones o futuras APIs de pasarelas de pago) deben tener un límite de tiempo de espera (*timeout*) no mayor a 3-5 segundos, garantizando que una lentitud externa no degrade la experiencia del usuario en el sistema.

---

## 5. Evidencias Técnicas de Implementación y Pruebas

### 5.1 Script de Medición de Rendimiento y Concurrencia
Se implementó el script automatizado multihilo [`test_rnf_rendimiento.py`](file:///Users/christhianmeza/IdeaProjects/ArtDent/Sistema-Web-de-Citas-para-el-Centro-Odontologico-Art-Dent/test_rnf_rendimiento.py) utilizando `concurrent.futures.ThreadPoolExecutor` para simular 40 peticiones concurrentes (concurrencia simultánea = 10 trabajadores) distribuidas sobre las rutas más críticas:
- `/index.jsp`
- `/reservapersonal.jsp`
- `/iniciosesion.jsp`
- `/PagoController?action=verBoleta&idCita=1`

### 5.2 Resultados Cuantitativos Obtenidos

```
=== Iniciando Prueba de Concurrencia RNF04 (40 reqs, concurrencia 10) ===
Total Requests: 40
Exitosos (HTTP 200): 40 / 40 (100.0%)
Tiempo Total de la prueba: 0.059 s
Throughput: 675.5 req/s
Latencia Mínima: 2.06 ms
Latencia Promedio: 13.14 ms
Latencia Percentil 95 (P95): 42.72 ms
Latencia Máxima: 43.68 ms

>>> RESULTADO RNF04: Cumplimiento de Rendimiento y Concurrencia EXITOSO (100% OK) <<<
```

### 5.3 Tabla Comparativa de Rendimiento

| Métrica | Requisito Esperado | Resultado Medido en ArtDent | Estado |
| :--- | :--- | :--- | :---: |
| **Tasa de Éxito HTTP 200** | $\ge 99\%$ | **100.0%** (40/40) | **APROBADO** |
| **Latencia Promedio** | $< 1.500\text{ ms}$ | **13.14 ms** | **APROBADO** |
| **Latencia Percentil 95 (P95)** | $< 1.500\text{ ms}$ | **42.72 ms** | **APROBADO** |
| **Latencia Máxima** | $< 2.000\text{ ms}$ | **43.68 ms** | **APROBADO** |
| **Capacidad de Despacho (Throughput)** | $> 50\text{ req/s}$ | **675.5 req/s** | **APROBADO** |

Los resultados demuestran un rendimiento sobresaliente, superando ampliamente el umbral exigido.
