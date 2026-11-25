package pe.edu.utp.filter;

import java.io.IOException;
import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import pe.edu.utp.utils.MetricasRendimiento;

/**
 * R-14: mide la duración real de cada reserva enviada al servlet de citas
 * para calcular el p95 que se muestra en la página de estado.
 */
@WebFilter(filterName = "RendimientoFilter", urlPatterns = {"/CitaController"})
public class RendimientoFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) {
    }

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest request = (HttpServletRequest) req;
        boolean medir = "POST".equalsIgnoreCase(request.getMethod());
        long inicio = System.currentTimeMillis();
        try {
            chain.doFilter(req, res);
        } finally {
            if (medir) {
                MetricasRendimiento.registrarReserva(System.currentTimeMillis() - inicio);
            }
        }
    }

    @Override
    public void destroy() {
    }
}
