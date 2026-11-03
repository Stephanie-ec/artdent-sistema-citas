/*
 * Horas de atención según el día (las mismas que la tabla Horario):
 * lunes a viernes 08:00–18:30 y sábado 09:00–13:00; domingo cerrado.
 * Cada cita dura 45 minutos, por eso la última hora es 17:45 o 12:15.
 */
(function () {
    function pad(n) { return (n < 10 ? '0' : '') + n; }

    function horasDelDia(fechaTexto) {
        if (!fechaTexto) return null;
        var p = fechaTexto.split('-');
        var dia = new Date(+p[0], +p[1] - 1, +p[2]).getDay(); // 0 domingo ... 6 sábado
        if (dia === 0) return [];
        var ini = dia === 6 ? 9 * 60 : 8 * 60;
        var fin = dia === 6 ? 12 * 60 + 15 : 17 * 60 + 45;
        var lista = [];
        for (var m = ini; m <= fin; m += 15) lista.push(pad(Math.floor(m / 60)) + ':' + pad(m % 60));
        return lista;
    }

    function llenarHoras() {
        var fecha = document.getElementById('fecha');
        var hora = document.getElementById('hora');
        if (!fecha || !hora || hora.tagName !== 'SELECT') return;
        var horas = horasDelDia(fecha.value);
        if (horas === null) {
            hora.innerHTML = '<option value="" selected disabled>Elija primero la fecha</option>';
        } else if (horas.length === 0) {
            hora.innerHTML = '<option value="" selected disabled>Domingo: no hay atención</option>';
        } else {
            hora.innerHTML = '<option value="" selected disabled>Seleccione la hora</option>'
                + horas.map(function (h) { return '<option value="' + h + '">' + h + '</option>'; }).join('');
        }
    }

    document.addEventListener('DOMContentLoaded', function () {
        var fecha = document.getElementById('fecha');
        if (fecha) {
            var hoy = new Date();
            fecha.min = hoy.getFullYear() + '-' + pad(hoy.getMonth() + 1) + '-' + pad(hoy.getDate());
            fecha.addEventListener('change', llenarHoras);
        }
        llenarHoras();
    });

    // Mensaje cuando ningún odontólogo atiende ese servicio, día y hora
    window.avisoSinOdontologo = function (html, contenedorId) {
        var cont = document.getElementById(contenedorId || 'medico-container');
        if (!cont) return;
        var aviso = document.getElementById('avisoSinOdontologo');
        if (!aviso) {
            aviso = document.createElement('div');
            aviso.id = 'avisoSinOdontologo';
            aviso.className = 'alert alert-warning py-2 px-3 small mt-2 mb-0';
            cont.appendChild(aviso);
        }
        if (html.indexOf('<option') === -1) {
            aviso.innerHTML = '<strong>No hay odontólogos libres para ese servicio, día y hora.</strong> '
                + 'Pruebe otra hora u otro día. Atención: lunes a viernes 8:00–18:30 y sábado 9:00–13:00.';
            aviso.style.display = 'block';
        } else {
            aviso.style.display = 'none';
        }
    };
})();
