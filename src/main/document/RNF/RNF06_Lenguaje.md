# RNF06: Soporte de Lenguaje e Internacionalización

## 1. Ficha Técnica del Requerimiento

| Campo | Detalle |
| :--- | :--- |
| **Identificador** | `RNF06` |
| **Nombre** | Soporte de Lenguaje e Internacionalización |
| **Tipo** | Requerimiento No Funcional (Localización / Internacionalización / i18n) |
| **Prioridad** | **Media** |
| **Cambio en APF2** | **Sin cambio: Sigue fuera del alcance de la primera versión (APF1, sección 3.2 y APF2).** |
| **Idioma Nativo del Sistema** | Español de Perú (`es-PE` / `UTF-8`). |
| **Módulos Afectados** | Todos los módulos clínicos, administrativos y formularios de cara al paciente. |
| **Mecanismo Asistencial Incorporado** | Widget de traducción dinámica en cliente (Google Translate Element) en el pie de página de las vistas públicas para soporte asistido en inglés y otros idiomas. |

---

## 2. Explicación en Lenguaje Sencillo (para el Product Owner / Docente)

El Centro Odontológico Art Dent opera en las localidades de Chosica y Chaclacayo (Lima, Perú). Por ende, el 100% de sus operaciones médicas, recetas, comprobantes tributarios (Boletas de Venta Electrónicas) y comunicaciones del personal interno se realizan en **idioma español**.

Durante la definición de alcance del proyecto (APF1, 3.2) y ratificado en el Sprint 4 (APF2):
- **Alcance Oficial:** Se estableció formalmente que el desarrollo de un motor nativo multilenguaje con archivos de recursos duales (*ResourceBundles* en español e inglés para cada etiqueta y mensaje de error) queda **fuera del alcance de la primera versión** del producto mínimo viable (MVP).
- **Solución Asistida para Pacientes Extranjeros:** No obstante, para brindar soporte a visitantes extranjeros o turistas que requieran atención de urgencia, se implementó en la esquina inferior derecha de las páginas de reserva un selector de idiomas asistido. Este permite a cualquier usuario traducir automáticamente la interfaz al inglés en tiempo real sin recargar ni alterar los procesos del servidor.

---

## 3. Paso a Paso de Funcionamiento en el Sistema

### 3.1 Operación Estándar en Español
1. Todo el sistema (portal web, panel administrativo, agenda médica y reportes) se presenta de forma predeterminada en español nativo con codificación estándar `UTF-8` para admitir acentos, caracteres especiales y la letra "ñ".
2. Las confirmaciones de citas por correo electrónico (`Notificacion`) y las boletas de venta se emiten en castellano conforme a las directivas de SUNAT y la Ley N.° 29733.

### 3.2 Traducción Dinámica Asistida
1. Un paciente angloparlante ingresa a la página de reserva web [`reservapersonal.jsp`](file:///Users/christhianmeza/IdeaProjects/ArtDent/Sistema-Web-de-Citas-para-el-Centro-Odontologico-Art-Dent/src/main/webapp/reservapersonal.jsp).
2. En la barra inferior visualiza el selector **"Seleccionar idioma / Select Language"**.
3. Al seleccionar "English", el navegador traduce instantáneamente los rótulos ("DNI del Paciente", "Fecha de Cita", "Confirmar Reserva") al inglés ("Patient ID", "Appointment Date", "Confirm Reservation").
4. El paciente completa la reserva sin barreras idiomáticas, y el registro se guarda en la base de datos de manera uniforme.

---

## 4. Reglas de Negocio Asociadas

1. **RN-RNF06-1 (Delimitación de Alcance en APF2):**
   - El soporte multilingüe completo a nivel de backend y base de datos (tablas con nombres de servicios en múltiples idiomas) se mantiene formalmente **fuera del alcance** para la versión APF2, posponiendo su inclusión completa a futuras versiones evolutivas (APF3+).
2. **RN-RNF06-2 (Codificación de Caracteres UTF-8):**
   - Todas las páginas JSP, servlets y la conexión a MySQL deben operar obligatoriamente en juego de caracteres `UTF-8` para garantizar la correcta visualización de tildes, signos de puntuación y nombres propios de pacientes y médicos.
3. **RN-RNF06-3 (Boletas y Documentos Legales en Español):**
   - Las Boletas de Venta Electrónicas y las notificaciones oficiales emitidas por el sistema deben permanecer invariablemente en idioma español para cumplir con las disposiciones tributarias peruanas.

---

## 5. Evidencias Técnicas de Implementación y Pruebas

### 5.1 Codificación UTF-8 en Cabeceras JSP
Verificación de directiva de codificación en todas las vistas:
```jsp
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
```
Presente en `index.jsp`, `reservapersonal.jsp`, `boleta.jsp`, `PDCSolicitudes.jsp`, `PDCCalendario.jsp`, `PDCReportes.jsp`.

### 5.2 Widget de Traducción en la Vista de Reserva Web
Implementado en [`reservapersonal.jsp`](file:///Users/christhianmeza/IdeaProjects/ArtDent/Sistema-Web-de-Citas-para-el-Centro-Odontologico-Art-Dent/src/main/webapp/reservapersonal.jsp#L210-L225):
```html
<div id="google_translate_element" class="position-fixed bottom-0 end-0 p-2 bg-dark bg-opacity-75 rounded-top-start z-3"></div>
<script type="text/javascript">
    function googleTranslateElementInit() {
        new google.translate.TranslateElement({
            pageLanguage: 'es',
            includedLanguages: 'en,es,pt,it,fr',
            layout: google.translate.TranslateElement.InlineLayout.SIMPLE
        }, 'google_translate_element');
    }
</script>
<script type="text/javascript" src="//translate.google.com/translate_a/element.js?cb=googleTranslateElementInit"></script>
```

### 5.3 Evidencia Visual
En la captura de pantalla [`reserva_web_clean_ui.png`](file:///Users/christhianmeza/IdeaProjects/ArtDent/Sistema-Web-de-Citas-para-el-Centro-Odontologico-Art-Dent/reserva_web_clean_ui.png) se puede apreciar en la esquina inferior derecha el botón de selección de idioma ("Seleccionar idioma"), certificando la disponibilidad de la solución asistida sin violar la delimitación de alcance del proyecto.
