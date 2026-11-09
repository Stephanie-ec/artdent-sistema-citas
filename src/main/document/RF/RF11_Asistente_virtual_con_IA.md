# RF11 — Asistente virtual con IA y respaldo local

El asistente orienta sobre salud bucal y reservas; no diagnostica. Usa Gemini solo
cuando están configurados `gemini.enabled=true`, `gemini.api.key` y `gemini.model`.
El modelo debe estar disponible en la cuenta; no se fija un nombre supuesto.
Sin configuración, caída, bloqueo o JSON inválido se utiliza el catálogo local.

Entrada: POST `/api/chatbot`, parámetro `pregunta`, entre 1 y 1000 caracteres.
Salida: JSON con `mensaje` y, opcionalmente, `servicio` (`id`, `nombre`, `costo`).
El proveedor devuelve texto estructurado (`mensaje`, `servicioId`); el servidor
valida el identificador contra su catálogo y construye precio y enlace. Rechaza
HTML, enlaces, cifras e importes en el texto del proveedor. El cliente utiliza
texto y elementos DOM, nunca HTML del modelo. El JSON mantiene escape HTML de Gson.

La puerta de contexto opera antes de consultar IA o BD. Contempla «ensias»,
«cariez» y consultas de citas. Excluye pie, rodilla, motor y limpieza de casa.
Es un filtro acotado: no se afirma comprensión universal ni diagnóstico clínico.
Las respuestas se acompañan de la necesidad de evaluación odontológica.

La integración usa REST `generateContent`, cabecera `x-goog-api-key`, JSON de
respuesta y límites de conexión/lectura de 3/6 segundos. No sigue redirecciones;
limita la respuesta a 64 KiB. Se envía solo la pregunta y nombres/ids del catálogo,
no la ficha clínica, DNI o expediente. El usuario debe evitar datos personales
en el texto libre. La clave no se envía al navegador ni se incluye en URLs.

Pruebas: `ChatbotSeguroTest`, `CierreServiciosTest` y los cinco casos JS de
`scripts/test-ui-segura.cjs`. Los dobles del proveedor prueban respaldo y validación;
la cuenta real y la captura de conversación siguen pendientes. Las capturas y los
scripts antiguos no constituyen evidencia de esta versión.

Referencia del protocolo: [Gemini generateContent](https://ai.google.dev/api/generate-content).