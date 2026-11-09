import java.net.*;
import java.net.http.*;
import java.nio.charset.StandardCharsets;
import java.time.Duration;

/** Prueba HTTP real, sin dependencias; ejecutar con JDK 17 y la aplicacion iniciada. */
public class HttpSmokeCheck {
    private static final HttpClient HTTP=HttpClient.newBuilder().connectTimeout(Duration.ofSeconds(10))
            .followRedirects(HttpClient.Redirect.NEVER).build();
    private static String base;
    private static HttpResponse<String> post(String ruta,String datos) throws Exception {
        return HTTP.send(HttpRequest.newBuilder(URI.create(base+ruta)).timeout(Duration.ofSeconds(15))
                .header("Content-Type","application/x-www-form-urlencoded; charset=UTF-8")
                .POST(HttpRequest.BodyPublishers.ofString(datos)).build(),HttpResponse.BodyHandlers.ofString());
    }
    private static void exigir(boolean ok,String mensaje){if(!ok)throw new AssertionError(mensaje);System.out.println("OK: "+mensaje);}
    public static void main(String[] args) throws Exception {
        base=(args.length==0?"http://localhost:8080/ArtDent":args[0]).replaceAll("/+$","");
        URI url=URI.create(base);
        exigir("localhost".equals(url.getHost())||"127.0.0.1".equals(url.getHost()),"destino local de pruebas");
        String[] fechas={"2000-01-03","2099-01-04","2099-02-30","2099-01-05"};
        for(int i=0;i<fechas.length;i++) {
            String datos="dni=12345678&nombre=Ana&apellido=Perez&telefono=987654321&correo=ana%40example.test&fecha="+fechas[i]+"&hora="+(i==3?"25%3A00":"10%3A00");
            HttpResponse<String> r=post("/CitaController",datos);exigir(r.statusCode()==400,"F-08 caso "+(i+1)+" devuelve HTTP 400");
            if(i==0)exigir(post("/ReservaController",datos).statusCode()==400,"F-16 conserva validacion del POST legado");
        }
        HttpResponse<String> acceso=HTTP.send(HttpRequest.newBuilder(URI.create(base+"/ADMPInicio.jsp")).timeout(Duration.ofSeconds(15)).GET().build(),HttpResponse.BodyHandlers.ofString());
        exigir(acceso.statusCode()==302&&acceso.headers().firstValue("location").orElse("").endsWith("/iniciosesion.jsp"),"panel sin sesion redirige al login");
        exigir(acceso.headers().firstValue("cache-control").orElse("").contains("no-store"),"panel sin sesion no se guarda en cache");
        HttpResponse<String> chat=post("/api/chatbot","pregunta="+URLEncoder.encode("me duele el pie",StandardCharsets.UTF_8));
        exigir(chat.statusCode()==200&&chat.body().contains("salud bucal")&&!chat.body().contains("\"servicio\""),"chatbot limita la consulta ajena a odontologia");
        HttpResponse<String> xss=post("/api/chatbot","pregunta="+URLEncoder.encode("limpieza dental <script>alert(1)</script>",StandardCharsets.UTF_8));
        exigir(xss.statusCode()==200&&!xss.body().contains("<script>"),"chatbot no devuelve HTML del usuario");
    }
}
