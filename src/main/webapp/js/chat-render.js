(function () {
    'use strict';
    window.artdentRenderBot = function (elemento, respuesta, contexto) {
        elemento.textContent = typeof respuesta === 'string' ? respuesta : String(respuesta.mensaje || 'No pude procesar la consulta.');
        elemento.style.whiteSpace = 'pre-wrap';
        var servicio = respuesta && respuesta.servicio;
        if (servicio && Number.isSafeInteger(servicio.id) && servicio.id > 0) {
            var salto = document.createElement('br');
            var enlace = document.createElement('a');
            enlace.href = contexto + '/ServicioController?action=cargar&id=' + encodeURIComponent(servicio.id);
            enlace.textContent = String(servicio.nombre || 'Consultar servicio');
            elemento.appendChild(salto);
            elemento.appendChild(enlace);
            if (servicio.costo !== undefined) elemento.appendChild(document.createTextNode(' · S/ ' + String(servicio.costo)));
        }
    };
})();
