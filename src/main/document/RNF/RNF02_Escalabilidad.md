# RNF02: Escalabilidad de la Arquitectura y Servicios

## 1. Ficha Técnica del Requerimiento

| Campo | Detalle |
| :--- | :--- |
| **Identificador** | `RNF02` |
| **Nombre** | Escalabilidad de la Arquitectura y Servicios |
| **Tipo** | Requerimiento No Funcional (Arquitectura / Escalabilidad / Mantenibilidad) |
| **Prioridad** | **Media** |
| **Cambio en APF2** | **Sin cambio** |
| **Módulos Afectados** | Todos los módulos del sistema (Controladores, DAOs, Base de Datos, Servicios Auxiliares). |
| **Patrón Arquitectónico** | MVC (Modelo - Vista - Controlador) en 3 capas desacopladas con Inversión de Control ligera. |
| **Gestor de Persistencia** | Conexiones JDBC optimizadas con `PreparedStatement`, llamadas a Procedimientos Almacenados (36 SPs) y modelo relacional normalizado de 13 tablas. |
| **Mecanismos de Escalado** | Pool de conexiones a base de datos, separación estricta de responsabilidades (Separation of Concerns), DTOs para transferencia de datos entre capas, diseño *stateless* en peticiones de consulta y persistencia en sesión únicamente para estados de identidad mínima. |

---

## 2. Explicación en Lenguaje Sencillo (para el Product Owner / Docente)

A medida que el Centro Odontológico Art Dent crezca, sume más odontólogos, atienda más pacientes diarios o incorpore nuevas sedes y servicios (como pasarelas de pago en línea adicionales o integración con WhatsApp Business), el sistema no debe colapsar ni ralentizarse.

Para garantizar esto, la plataforma no fue construida con código mezclado o monolítico desordenado, sino en **capas independientes**:
1. **Capa de Presentación (Vistas JSP/CSS/JS):** Se encarga únicamente de mostrar información y recibir las interacciones del usuario. Si se rediseña una pantalla, no se altera la lógica de negocio ni la base de datos.
2. **Capa de Control y Negocio (Servlets Java):** Valida las reglas médicas y administrativas (por ejemplo, verificar que una reserva no se apruebe si no fue pagada, o bloquear intentos fallidos). Los controladores pueden ampliarse o reemplazarse sin afectar el almacenamiento de datos.
3. **Capa de Persistencia (DAOs y Procedimientos Almacenados en MySQL):** Los datos se consultan y modifican mediante interfaces DAO claras y procedimientos almacenados precompilados. Esto permite afinar consultas complejas o migrar el motor de base de datos a un clúster en la nube sin tener que reescribir la aplicación.

---

## 3. Paso a Paso de Funcionamiento en el Sistema

### 3.1 Flujo de Petición Desacoplada
```
[Navegador / Cliente]
         │ (HTTP Request: POST /CitaController)
         ▼
[Capa de Control (Servlet)] ──► Valida sesión, permisos y parámetros
         │
         ▼
[Capa de Datos (DAO / DAOImpl)] ──► Invoca interfaz abstracta (ej: CitaDao)
         │
         ▼
[Pool de Conexiones JDBC] ──► Obtiene conexión activa
         │
         ▼
[MySQL (13 Tablas / 36 SPs)] ──► Ejecuta Stored Procedure precompilado
         │
         ▼
[DTO / Entidad] ──► Mapea resultado y retorna a la Vista JSP correspondiente
```

### 3.2 Incorporación de Nuevas Funcionalidades sin Impacto Negativo
1. **Agregar un nuevo servicio clínico:** Se registra en la tabla `Servicio` a través del módulo de administración (`ADMPServicios.jsp`). De inmediato, el nuevo servicio queda disponible en el selector de la reserva web (`reservapersonal.jsp`), en la asignación de odontólogos (`ADMPDisponibilidad.jsp`) y en los reportes analíticos, sin necesidad de compilar código nuevo ni alterar tablas existentes.
2. **Agregar una nueva sede:** Las tablas `TurnoOdontologo` y `Disponibilidad` admiten la asociación a múltiples horarios y sedes (Chosica / Chaclacayo) mediante llaves foráneas (`idUsuario`, `idServicio`), permitiendo escalar territorialmente el centro.
3. **Agregar nuevos proveedores de notificación o pago:** La arquitectura DAO y los controladores delegan el envío de correos y la validación de pagos en componentes desacoplados (`EmailSenderService`, `PagoController`), permitiendo intercambiar proveedores en el futuro (por ejemplo, pasar de SMTP a SendGrid o integrar Culqi/Niubiz en lugar de Stripe) modificando únicamente una clase de servicio.

---

## 4. Reglas de Negocio Asociadas

1. **RN-RNF02-1 (Modularidad de Tablas y Procedimientos):**
   - El esquema `db_artdent_apf2` mantiene 13 tablas con relaciones íntegras (`ON DELETE RESTRICT` / `CASCADE` según criticidad médica) y 36 Procedimientos Almacenados que aíslan la lógica SQL del código Java.
2. **RN-RNF02-2 (Desacoplamiento DAO):**
   - Toda interacción con la base de datos se realiza a través de interfaces (`UsuarioDao`, `CitaDao`, `PacienteDao`, `ServicioDao`, `PagoDao`, `DisponibilidadDao`) implementadas en sus respectivas clases `DaoImpl`. Ningún controlador ejecuta sentencias SQL en línea.
3. **RN-RNF02-3 (Stateless en Consultas y Sesión Mínima):**
   - La sesión HTTP solo almacena atributos esenciales de identidad (`idUsuario`, `Nombre`, `TipoRol`, `Correo`). Los catálogos, listas de citas y reportes se cargan bajo demanda en el ámbito de petición (`request`), evitando el consumo excesivo de memoria RAM del servidor de aplicaciones cuando concurren múltiples usuarios.

---

## 5. Evidencias Técnicas de Implementación y Pruebas

### 5.1 Estructura Desacoplada del Proyecto
- **Paquete de Controladores:** [`pe.edu.utp.controller`](file:///Users/christhianmeza/IdeaProjects/ArtDent/Sistema-Web-de-Citas-para-el-Centro-Odontologico-Art-Dent/src/main/java/pe/edu/utp/controller) (`CitaController`, `ReservaController`, `UsuarioController`, `PagoController`, `ServicioController`, `InicioSesionController`, `CerrarSesionController`).
- **Paquete de Interfaces DAO:** [`pe.edu.utp.dao`](file:///Users/christhianmeza/IdeaProjects/ArtDent/Sistema-Web-de-Citas-para-el-Centro-Odontologico-Art-Dent/src/main/java/pe/edu/utp/dao) (`UsuarioDao`, `CitaDao`, `PacienteDao`, `ServicioDao`, `PagoDao`, `DisponibilidadDao`, `NotificacionDao`).
- **Paquete de Implementaciones:** [`pe.edu.utp.daoImpl`](file:///Users/christhianmeza/IdeaProjects/ArtDent/Sistema-Web-de-Citas-para-el-Centro-Odontologico-Art-Dent/src/main/java/pe/edu/utp/daoImpl).
- **Paquete de Transferencia de Datos:** [`pe.edu.utp.dto`](file:///Users/christhianmeza/IdeaProjects/ArtDent/Sistema-Web-de-Citas-para-el-Centro-Odontologico-Art-Dent/src/main/java/pe/edu/utp/dto) (`LoginResultDTO`, `ComprobantePagoDTO`).

### 5.2 Capacidad de Concurrencia y Escalabilidad Horizontal
La prueba de estrés y concurrencia demostró la capacidad de la arquitectura de despachar ráfagas de 40 solicitudes concurrentes sin degradación de memoria ni bloqueos de transacciones:
- **Throughput medido:** **675.5 solicitudes por segundo**.
- **Tasa de éxito:** **100% (40/40)** sin errores de *Thread Starvation* ni desconexiones de base de datos.
