/*
 * Validación en el navegador (la misma regla se repite en el servidor con Validador.java):
 * - nombre / apellido: solo letras, espacios, apóstrofo y guion
 * - dni: solo números, 8 dígitos
 * - telefono: solo números, 9 dígitos
 */
document.addEventListener('DOMContentLoaded', function () {
    var soloLetras = /[^A-Za-zÁÉÍÓÚÜÑáéíóúüñ' -]/g;
    var soloNumeros = /\D/g;

    function filtrar(input, regex, max) {
        input.addEventListener('input', function () {
            var limpio = input.value.replace(regex, '');
            if (max) limpio = limpio.slice(0, max);
            if (limpio !== input.value) input.value = limpio;
        });
    }

    document.querySelectorAll('input[name="nombre"], input[name="apellido"]').forEach(function (el) {
        el.setAttribute('pattern', "[A-Za-zÁÉÍÓÚÜÑáéíóúüñ][A-Za-zÁÉÍÓÚÜÑáéíóúüñ' \\-]{1,49}");
        el.setAttribute('title', 'Solo letras, sin números ni símbolos');
        el.setAttribute('maxlength', '50');
        filtrar(el, soloLetras);
    });
    document.querySelectorAll('input[name="dni"]').forEach(function (el) {
        if (el.type === 'number') el.type = 'text';
        el.setAttribute('inputmode', 'numeric');
        el.setAttribute('pattern', '\\d{8}');
        el.setAttribute('maxlength', '8');
        el.setAttribute('title', 'DNI de 8 dígitos');
        filtrar(el, soloNumeros, 8);
    });
    document.querySelectorAll('input[name="telefono"]').forEach(function (el) {
        el.setAttribute('inputmode', 'numeric');
        el.setAttribute('pattern', '9\\d{8}');
        el.setAttribute('maxlength', '9');
        el.setAttribute('title', 'Celular de 9 dígitos que empieza con 9');
        filtrar(el, soloNumeros, 9);
    });
});
