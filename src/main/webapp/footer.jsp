<%@ page pageEncoding="UTF-8" %>
<!-- Footer Institucional Art Dent -->
<footer class="bg-brand-dark text-light pt-5 pb-3 mt-auto">
    <div class="container px-4 px-lg-5">
        <div class="row g-4 justify-content-between">
            <!-- Columna 1: Presentación Institucional -->
            <div class="col-12 col-md-6 col-lg-4">
                <div class="d-flex align-items-center gap-2 mb-3">
                    <img src="https://logomaker.designfreelogoonline.com/media/productdesigner/logo/resized/0001036_dental_logo_maker_dentist_Logo-02.png" 
                         alt="Art Dent Logo" width="40" height="40">
                    <h4 class="fw-bold m-0 text-white">Art <span class="text-brand-primary">Dent</span></h4>
                </div>
                <p class="text-white-50 small mb-3">
                    En nuestro Centro Odontol&oacute;gico Art Dent en Chosica y Chaclacayo, brindamos tratamientos odontol&oacute;gicos integrales con garant&iacute;a, tecnolog&iacute;a de vanguardia y calidez humana.
                </p>
                <a class="text-brand-mint text-decoration-none small fw-semibold" href="nosotros.jsp">
                    Conoce más sobre nosotros <i class="bi bi-arrow-right"></i>
                </a>
            </div>

            <!-- Columna 2: Sedes y Contacto -->
            <div class="col-12 col-md-6 col-lg-3">
                <h5 class="fw-bold text-white mb-3 border-bottom pb-2" style="border-color: rgba(255,255,255,0.15) !important;">
                    <i class="bi bi-geo-alt-fill text-brand-primary me-2"></i>Sedes y Contacto
                </h5>
                <ul class="list-unstyled small text-white-50 mb-0">
                    <li class="py-1">
                        <strong class="text-white">Sede Chosica:</strong> Jr. Chiclayo 268, Chosica, Lima
                    </li>
                    <li class="py-1">
                        <strong class="text-white">Sede Chaclacayo:</strong> Av. Las Palmeras 328, Chaclacayo
                    </li>
                    <li class="py-1">
                        <strong class="text-white">Teléfono:</strong> (01) 361-3634
                    </li>
                    <li class="py-1">
                        <strong class="text-white">Correo:</strong> informes@artdent.pe
                    </li>
                </ul>
            </div>

            <!-- Columna 3: Especialidades -->
            <div class="col-12 col-md-6 col-lg-2">
                <h5 class="fw-bold text-white mb-3 border-bottom pb-2" style="border-color: rgba(255,255,255,0.15) !important;">
                    <i class="bi bi-shield-check text-brand-accent me-2"></i>Servicios
                </h5>
                <ul class="list-unstyled small text-white-50 mb-0">
                    <li class="py-1"><a href="servicios.jsp" class="text-white-50 text-decoration-none hover-primary">Limpieza y Prevención</a></li>
                    <li class="py-1"><a href="servicios.jsp" class="text-white-50 text-decoration-none hover-primary">Endodoncia</a></li>
                    <li class="py-1"><a href="servicios.jsp" class="text-white-50 text-decoration-none hover-primary">Cirugía Oral</a></li>
                    <li class="py-1"><a href="servicios.jsp" class="text-white-50 text-decoration-none hover-primary">Prótesis y Estética</a></li>
                    <li class="py-1"><a href="faq.jsp" class="text-brand-mint text-decoration-none fw-semibold">Preguntas Frecuentes</a></li>
                </ul>
            </div>

            <!-- Columna 4: Horarios y Redes -->
            <div class="col-12 col-md-6 col-lg-3 text-lg-end">
                <h5 class="fw-bold text-white mb-3 border-bottom pb-2" style="border-color: rgba(255,255,255,0.15) !important;">
                    Horario de Atención
                </h5>
                <p class="small text-white-50 mb-3">
                    Lunes a Sábado: 8:00 AM - 8:00 PM<br>
                    Domingos: Previa Cita
                </p>
                <div class="d-flex gap-3 justify-content-lg-end">
                    <a href="https://www.facebook.com/artdentsac" target="_blank" rel="noopener" 
                       class="btn btn-outline-light btn-sm rounded-circle d-inline-flex align-items-center justify-content-center" 
                       style="width: 38px; height: 38px;" title="Facebook">
                        <i class="bi bi-facebook"></i>
                    </a>
                    <a href="https://www.instagram.com/artdent_peru" target="_blank" rel="noopener" 
                       class="btn btn-outline-light btn-sm rounded-circle d-inline-flex align-items-center justify-content-center" 
                       style="width: 38px; height: 38px;" title="Instagram">
                        <i class="bi bi-instagram"></i>
                    </a>
                    <a href="https://wa.me/51987654321" target="_blank" rel="noopener" 
                       class="btn btn-outline-light btn-sm rounded-circle d-inline-flex align-items-center justify-content-center" 
                       style="width: 38px; height: 38px;" title="WhatsApp">
                        <i class="bi bi-whatsapp"></i>
                    </a>
                </div>
            </div>
        </div>

        <hr class="my-4" style="border-color: rgba(255,255,255,0.12);">

        <div class="row align-items-center small text-white-50">
            <div class="col-12 col-md-6 text-center text-md-start mb-2 mb-md-0">
                &copy; <%= java.time.Year.now().getValue() %> Centro Odontol&oacute;gico Art Dent. Todos los derechos reservados.
            </div>
            <div class="col-12 col-md-6 text-center text-md-end">
                <a href="nosotros.jsp" class="text-white-50 text-decoration-none me-3">Privacidad</a>
                <a href="nosotros.jsp" class="text-white-50 text-decoration-none me-3">Términos</a>
                <a href="faq.jsp" class="text-white-50 text-decoration-none">Ayuda</a>
            </div>
        </div>
    </div>
</footer>
