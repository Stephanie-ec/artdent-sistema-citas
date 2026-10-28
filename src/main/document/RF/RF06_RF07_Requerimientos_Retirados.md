# Documentación de Requerimientos Retirados: RF06 y RF07

---

## 1. Ficha de Control de Alcance

| Campo | Detalle |
| :--- | :--- |
| **Identificadores** | **RF06** y **RF07** |
| **Nombres** | Sección de servicios (RF06) / Preguntas frecuentes - FAQ (RF07) |
| **Estado en APF2** | **Retirados formalmente de los requerimientos funcionales** |
| **Motivo del Retiro** | **Observación docente y refinamiento de ingeniería de requisitos:** Tanto la sección de listado informativo de servicios con opción "Leer más" (RF06) como la sección de preguntas frecuentes (RF07) constituyen contenido informativo/estático de navegación y diseño web publicitario, y no representan funciones de negocio ni transacciones operativas del software. |

---

## 2. Detalle y Justificación Técnica

### RF06: Sección de Servicios (Retirado)
* **Definición anterior (APF1):** Listado informativo de servicios con opción *"Leer más"*.
* **Dictamen docente:** Los textos y banners explicativos de los tratamientos (ej. qué es una endodoncia, qué incluye un blanqueamiento) son piezas estáticas informativas de la página de inicio (`index.jsp`) orientadas al marketing y difusión de la clínica. No ejecutan flujos de negocio ni almacenan transacciones.
* **Reemplazo funcional:** La administración dinámica de los servicios y sus tarifas se formalizó en el nuevo requerimiento **RF17 (Gestión de servicios)**, donde el Administrador sí ejecuta una función del sistema (crear, editar, activar y desactivar servicios y precios en la base de datos).

---

### RF07: Preguntas Frecuentes (FAQ) (Retirado)
* **Definición anterior (APF1):** Sección de preguntas frecuentes con desplegables informativos.
* **Dictamen docente:** Corresponde a componentes de maquetación HTML/Bootstrap estáticos sin interacción transaccional con la base de datos ni lógica de negocio en Servlets.
* **Reemplazo funcional:** Las dudas de los usuarios que requieran asistencia inteligente ahora son atendidas dinámicamente mediante el **RF11 (Asistente virtual con IA)**, que procesa síntomas del usuario y recomienda servicios odontológicos en tiempo real.

---

## 3. Estado en el Código Fuente

* Las secciones informativas y de preguntas frecuentes se conservan visualmente en la página de inicio pública (`index.jsp`) para la experiencia del usuario y presentación institucional de ArtDent, pero han sido depuradas formalmente de la matriz de requerimientos funcionales evaluables del proyecto de software.
