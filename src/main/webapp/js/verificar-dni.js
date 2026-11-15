/*
 * Aviso temprano de DNI repetido: cuando el DNI, el nombre y el apellido están completos,
 * consulta al servidor si ese DNI ya pertenece a otro paciente y bloquea el envío.
 * La misma regla se aplica en el servidor (CitaController), esta es solo la primera barrera.
 */
(function () {
    function iniciar() {
        var dni = document.getElementById('dni'), nombre = document.getElementById('nombre'),
            apellido = document.getElementById('apellido');
        if (!dni || !nombre || !apellido) return;
        var form = dni.form;
        var boton = form ? form.querySelector('button[type="submit"]') : null;
        var aviso = document.createElement('div');
        aviso.id = 'avisoDni';
        aviso.className = 'alert py-2 px-3 small mt-2 mb-0';
        aviso.style.display = 'none';
        (dni.closest('.col-12') || dni.parentNode).appendChild(aviso);
        var bloqueado = false;

        function mostrar(clase, texto) {
            aviso.className = 'alert py-2 px-3 small mt-2 mb-0 ' + clase;
            aviso.innerHTML = texto;
            aviso.style.display = texto ? 'block' : 'none';
        }
        function verificar() {
            var d = dni.value.trim(), n = nombre.value.trim(), a = apellido.value.trim();
            if (!/^\d{8}$/.test(d) || !n || !a) { mostrar('', ''); bloqueado = false; return; }
            fetch('ConsultaDniController?verificar=1&dni=' + encodeURIComponent(d)
                    + '&nombre=' + encodeURIComponent(n) + '&apellido=' + encodeURIComponent(a))
                .then(function (r) { return r.json(); })
                .then(function (res) {
                    if (res.estado === 'NO_COINCIDE') {
                        bloqueado = true;
                        mostrar('alert-danger', '<i class="bi bi-exclamation-triangle-fill me-1"></i>' + res.mensaje);
                    } else if (res.estado === 'COINCIDE') {
                        bloqueado = false;
                        mostrar('alert-success', '<i class="bi bi-check-circle-fill me-1"></i>' + res.mensaje);
                    } else {
                        bloqueado = false; mostrar('', '');
                    }
                })
                .catch(function () { bloqueado = false; });
        }
        [dni, nombre, apellido].forEach(function (el) { el.addEventListener('change', verificar); el.addEventListener('blur', verificar); });
        if (form) form.addEventListener('submit', function (e) {
            if (bloqueado) { e.preventDefault(); aviso.scrollIntoView({ behavior: 'smooth', block: 'center' }); }
        });
    }
    if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', iniciar); else iniciar();
})();
