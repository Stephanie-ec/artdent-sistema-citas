# RNF05: Compatibilidad Multi-Navegador y Dispositivos Móviles

## 1. Ficha Técnica del Requerimiento

| Campo | Detalle |
| :--- | :--- |
| **Identificador** | `RNF05` |
| **Nombre** | Compatibilidad Multi-Navegador y Dispositivos Móviles |
| **Tipo** | Requerimiento No Funcional (Portabilidad / Responsividad / Cross-Browser) |
| **Prioridad** | **Media** |
| **Cambio en APF2** | **Sin cambio** |
| **Navegadores Objetivo** | Google Chrome (v100+), Mozilla Firefox (v100+), Apple Safari (iOS / macOS v15+), Microsoft Edge (v100+). |
| **Dispositivos Objetivo** | Smartphones (iOS / Android, viewports de 360px a 430px), Tablets (768px a 1024px), Laptops y Computadoras de Escritorio (1280px a 1920px+). |
| **Tecnologías Frontend** | HTML5 W3C Estándar, CSS3 Flexbox y CSS Grid, Bootstrap 5.3.3 Mobile-First, Viewport Meta Tag, Media Queries estándar. |

---

## 2. Explicación en Lenguaje Sencillo (para el Product Owner / Docente)

Los pacientes del Centro Odontológico Art Dent acceden a separar citas desde una variedad de dispositivos cotidianos: la mayoría lo hace desde su teléfono celular (ya sea Android o iPhone), mientras que el personal administrativo y los odontólogos utilizan computadoras de escritorio o laptops en la clínica con distintos navegadores (Chrome, Firefox, Safari o Edge).

Para garantizar una experiencia consistente sin fallas visuales:
1. **Diseño Adaptativo (*Responsive Design*):** Las páginas no se cortan ni requieren desplazamientos horizontales incómodos en teléfonos. Los campos del formulario de reserva se acomodan en una sola columna en pantallas verticales y en dos columnas en computadoras.
2. **Menú Desplegable Móvil:** En teléfonos, la barra de navegación colapsa automáticamente en un botón de menú de tipo hamburguesa accesible para el pulgar.
3. **Tablas con Desplazamiento Seguro:** Las bandejas de citas y reportes clínicos cuentan con contenedores elásticos (`table-responsive`) que permiten revisar toda la información en pantallas pequeñas sin romper la estructura de la página.
4. **Estándares Web Universales:** No se utilizan plugins obsoletos ni características propietarias incompatibles con Safari o Firefox.

---

## 3. Paso a Paso de Funcionamiento en el Sistema

### 3.1 Experiencia Móvil (Paciente)
1. El paciente abre el enlace del sistema en el navegador Safari o Chrome de su teléfono inteligente.
2. El navegador detecta la directiva `<meta name="viewport" content="width=device-width, initial-scale=1.0">` y ajusta la escala automáticamente sin reducir artificialmente la letra.
3. El logotipo institucional y el menú colapsan de forma ordenada en la parte superior.
4. El paciente completa los campos (DNI, Nombres, Celular, Servicio y Fecha) con teclados virtuales adaptados (teclado numérico para DNI/celular, selector nativo de fecha y hora).
5. El botón de reserva ocupa el ancho total del dispositivo con un área táctil óptima (> 48px de altura) para facilitar el toque con el dedo.

### 3.2 Experiencia de Escritorio (Secretaría y Odontólogo)
1. El personal accede en monitores de recepción o consultorio clínico.
2. La interfaz se expande aprovechando la pantalla ancha con barra lateral fija (*sidebar*), tablas detalladas de pacientes y panel analítico de KPIs.

---

## 4. Reglas de Negocio Asociadas

1. **RN-RNF05-1 (Viewport Obligatorio):**
   - Todas las páginas JSP del sistema deben incluir en su bloque `<head>` la etiqueta meta de escala adaptable:
     ```html
     <meta name="viewport" content="width=device-width, initial-scale=1.0">
     ```
2. **RN-RNF05-2 (Compatibilidad de Renderizado Cross-Browser):**
   - Los estilos CSS deben utilizar propiedades compatibles con los motores Blink (Chrome, Edge), Gecko (Firefox) y WebKit (Safari). No se permite el uso de prefijos experimentales no estandarizados que comprometan la visualización en iOS.
3. **RN-RNF05-3 (Accesibilidad Táctil en Móviles):**
   - Todos los botones interactivos principales (`Confirmar Reserva`, `Iniciar Sesión`, `Imprimir Boleta`) deben tener un área mínima de toque de 44x44 píxeles para cumplir con las directrices de accesibilidad móvil W3C WCAG 2.1.

---

## 5. Evidencias Técnicas de Implementación y Pruebas

### 5.1 Verificación de Meta Viewport en Páginas Clave
Se confirmó la presencia de la etiqueta de adaptación en todos los encabezados:
- `index.jsp`: Configurado con Bootstrap 5.3.3.
- `reservapersonal.jsp`: Línea 7.
- `boleta.jsp`: Línea 8.
- `iniciosesion.jsp` / `iniciosesionerror.jsp`: Líneas 7-8.
- `PDCSolicitudes.jsp`, `PDCCalendario.jsp`, `PDCReportes.jsp`: Configurados con layout elástico.

### 5.2 Emulación Móvil y Captura de Evidencia en Chrome CDP
Se ejecutó la prueba de emulación en Google Chrome mediante el script [`capture_mobile_cdp.js`](file:///Users/christhianmeza/IdeaProjects/ArtDent/Sistema-Web-de-Citas-para-el-Centro-Odontologico-Art-Dent/capture_mobile_cdp.js) configurando métricas de dispositivo móvil (390 x 844 px, factor de escala 2.0x, simulando iPhone 13/14/15):
- **Archivo de Evidencia Generado:** [`reserva_mobile_ui.png`](file:///Users/christhianmeza/IdeaProjects/ArtDent/Sistema-Web-de-Citas-para-el-Centro-Odontologico-Art-Dent/reserva_mobile_ui.png).
- **Inspección de Resultados Visuales:**
  - Menú superior colapsado en botón hamburguesa (`navbar-toggler`) alineado a la derecha.
  - Título `"RESERVA TU CITA EN LÍNEA"` centrado y legible sin desbordes.
  - Campos de entrada verticalizados con espaciado uniforme.
  - Botón `"Confirmar Reserva"` de ancho completo en azul corporativo `#30a4c6`.
  - Selector de idioma inferior integrado fluidamente sin solapamiento de contenido.
