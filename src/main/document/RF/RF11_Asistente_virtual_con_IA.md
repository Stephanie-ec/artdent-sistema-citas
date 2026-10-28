# Guía de Usuario y Documentación Funcional: RF11 - Asistente Virtual con IA

---

## 1. Ficha del Requerimiento

| Campo | Detalle |
| :--- | :--- |
| **Identificador** | **RF11** |
| **Nombre del Requerimiento** | Asistente Virtual con IA |
| **Prioridad** | **Media** |
| **Módulo** | Módulo de Orientación al Paciente y Recomendación Inteligente |
| **Roles Autorizados** | **Paciente / Usuario Web** (Público general en página de inicio sin registro) |
| **Cambio en APF2** | **Sin cambio:** El asistente de la página de inicio recomienda el servicio más adecuado según los síntomas descritos por el usuario en lenguaje natural. |

---

## 2. Descripción en Lenguaje Sencillo

Este requerimiento ofrece una experiencia moderna de triaje preliminar y orientación odontológica para los visitantes de la clínica:

1. **Interacción en Lenguaje Natural:**
   * El paciente no necesita saber terminología odontológica compleja. Puede escribir cómo se siente o qué le molesta (por ejemplo: *"tengo un dolor punzante en la muela de atrás"*, *"quiero que mis dientes se vean más blancos"*, *"tengo los dientes torcidos y no mastico bien"*).
2. **Recomendación Inteligente Basada en el Catálogo:**
   * El asistente analiza los síntomas clínicos descritos y recomienda el tratamiento exacto que ofrece ArtDent:
     * Dolor severo, nervio o inflamación aguda $\rightarrow$ **Endodoncia**.
     * Dientes manchados, amarillos o estética dental $\rightarrow$ **Blanqueamiento Dental**.
     * Caries, cavidad, sensibilidad o agujeros $\rightarrow$ **Curación Dental con Resina**.
     * Dientes chuecos, mala mordida o alineación $\rightarrow$ **Ortodoncia**.
     * Sangrado de encías, placa o sarro $\rightarrow$ **Limpieza Dental Profunda**.
     * Tercer molar, muela del juicio o dolor al salir $\rightarrow$ **Cirugía / Extracción Dental**.
     * Falta de piezas dentales $\rightarrow$ **Prótesis Dental / Rehabilitación Oral**.
3. **Enlaces Interactivos y Costos Claros:**
   * La respuesta incluye el costo base oficial del tratamiento y un enlace clickeable directo (`<a href='...'>`) para que el paciente conozca los detalles del servicio y proceda a reservar su cita inmediatamente.
4. **Arquitectura Híbrida de Alta Disponibilidad:**
   * Conexión con **Gemini AI** (`gemini-3.7-flash`) respaldada por un motor experto de reglas clínicas odontológicas que garantiza respuestas instantáneas aún ante contingencias de red o saturación de la API externa.

---

## 3. Proceso Paso a Paso para el Usuario

### Paso 1: Abrir el Asistente en la Página de Inicio
1. Ingresar al portal de ArtDent (`index.jsp`).
2. En la esquina inferior derecha de la pantalla, ubicar el botón flotante circular con el icono del asistente virtual / chatbot.
3. Hacer clic en el icono para desplegar la ventana de conversación.

### Paso 2: Describir los Síntomas
1. El asistente dará la bienvenida: *"¡Hola! Soy el asistente virtual de Art Dent. ¿En qué puedo ayudarte hoy? Puedes describir tus síntomas o preocupaciones dentales..."*.
2. En la caja de texto inferior, escribir la consulta en palabras cotidianas (ejemplo: *"tengo dolor de muela intenso y no aguanto"*).
3. Presionar **Enter** o hacer clic en el botón de enviar.

### Paso 3: Recibir la Recomendación y Costo
1. El sistema procesa la consulta y genera la respuesta personalizada:
   * Identifica el servicio recomendado (ej. *Endodoncia*).
   * Muestra el costo base referencial (ej. *S/ 100.00*).
   * Explica de forma clara y empática por qué ese tratamiento es el adecuado para su molestia.
   * Proporciona un enlace destacado al servicio.

### Paso 4: Reservar la Cita
1. El paciente puede hacer clic directamente en el nombre del servicio para ver sus detalles clínicos o dirigirse a la opción **"Reservar Cita"** para agendar su atención médica.

---

## 4. Consideraciones Técnicas y de Seguridad (RNF03)

1. **Privacidad de Datos de Salud:**
   * La consulta es completamente anónima. No se solicita nombre, DNI ni datos personales al interactuar con el chatbot; únicamente se procesa el texto descriptivo de los síntomas.
2. **Endpoint Seguro:**
   * La consulta se despacha vía POST asíncrono (`fetch('/ArtDent/api/chatbot')`) con codificación UTF-8 para garantizar soporte de caracteres especiales y tildes en español.
3. **Manejo de Errores y Uptime:**
   * El servlet implementa un timeout estricto de 4 segundos y fallback autónomo local para asegurar que el paciente nunca reciba un error técnico en pantalla.

---

## 5. Evidencias de Verificación y Auditoría

* **Suite de Pruebas Automatizada:** Ejecución exitosa de `test_lote3_admin.py` (Paso 5) probando tres familias clínicas distintas (dolor agudo, estética dental y ortodoncia).
* **Captura de Pantalla en Google Chrome:** Archivo `asistente_ia_ui.png` generado mediante CDP en puerto 9222 mostrando el diálogo interactivo del chatbot.
