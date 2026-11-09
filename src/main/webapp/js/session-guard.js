window.addEventListener('pageshow', function (event) {
    var navegacion = performance.getEntriesByType('navigation')[0];
    if (event.persisted || (navegacion && navegacion.type === 'back_forward')) {
        window.location.reload();
    }
});
