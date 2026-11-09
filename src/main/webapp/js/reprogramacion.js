document.addEventListener('DOMContentLoaded', function () {
    var fecha = document.getElementById('new-date');
    var hora = document.getElementById('new-time');
    if (!fecha || !hora) return;
    function ajustarTurno() {
        var domingo = fecha.value && new Date(fecha.value + 'T00:00:00Z').getUTCDay() === 0;
        var sabado = fecha.value && new Date(fecha.value + 'T00:00:00Z').getUTCDay() === 6;
        fecha.setCustomValidity(domingo ? 'No hay atención los domingos.' : '');
        hora.min = sabado ? '09:00' : '08:00';
        hora.max = sabado ? '12:15' : '17:45';
    }
    fecha.addEventListener('change', ajustarTurno);
    ajustarTurno();
});
