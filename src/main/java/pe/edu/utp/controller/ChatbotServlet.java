package pe.edu.utp.controller;

import java.io.IOException;
import java.io.PrintWriter;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.json.Json;
import javax.json.JsonObject;
import javax.json.JsonReader;
import java.io.StringReader;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.StringJoiner;
import pe.edu.utp.config.Conexion;

@WebServlet("/api/chatbot")
public class ChatbotServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("text/plain");
        response.setCharacterEncoding("UTF-8");

        String pregunta = request.getParameter("pregunta");

        String serviciosInfo = obtenerServiciosDeBaseDeDatos();
        String baseUrl = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + request.getContextPath();
        String mensajeParaGPT = "Eres un chatbot integrado en la plataforma de Art Dent, una clínica dental. "
                + "Tu tarea es recomendar servicios dentales basados en los síntomas o preocupaciones que el usuario mencione. "
                + "Utiliza la siguiente información sobre los servicios disponibles para hacer tus recomendaciones:\\n" + serviciosInfo
                + "\\nEl usuario pregunta: " + pregunta
                + "\\nResponde de manera amable y profesional, explicando por qué recomiendas cierto servicio basado en los síntomas mencionados. "
                + "Si el usuario pregunta por el costo, inclúyelo en tu respuesta. "
                + "Si el usuario solicita algo no relacionado con servicios dentales, responde cortésmente y trata de redirigir la conversación hacia la salud dental. "
                + "Usa etiquetas HTML <br> para los saltos de línea en tu respuesta en lugar de \\n. "
                + "Si mencionas un servicio específico, DEBES generar un enlace HTML clickeable usando la etiqueta <a> en este formato exacto: <a href='" + baseUrl + "/ServicioController?action=cargar&id=IdDelServicio'>Nombre del Servicio</a> "
                + "donde reemplazas IdDelServicio con el id correspondiente del servicio del que estás hablando.";

        System.out.println(mensajeParaGPT);

        if (pregunta == null || pregunta.trim().isEmpty()) {
            response.getWriter().write("Por favor, describe tus síntomas o preocupaciones dentales.");
            return;
        }

        String apiKey = pe.edu.utp.utils.ConfigLoader.getProperty("gemini.api.key");

        HttpClient client = HttpClient.newBuilder()
                .connectTimeout(java.time.Duration.ofSeconds(3))
                .build();
        String body = String.format(
                "{ \"model\": \"gemini-3.7-flash\", "
                + "\"input\": \"%s\" }",
                mensajeParaGPT.replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "")
        );

        HttpRequest requestApi = HttpRequest.newBuilder()
                .uri(URI.create("https://generativelanguage.googleapis.com/v1beta/interactions"))
                .header("Content-Type", "application/json")
                .header("x-goog-api-key", apiKey != null ? apiKey : "")
                .header("Api-Revision", "2026-05-20")
                .timeout(java.time.Duration.ofSeconds(4))
                .POST(HttpRequest.BodyPublishers.ofString(body))
                .build();

        try {
            HttpResponse<String> apiResponse = client.send(requestApi, HttpResponse.BodyHandlers.ofString());

            JsonReader jsonReader = Json.createReader(new StringReader(apiResponse.body()));
            JsonObject jsonResponse = jsonReader.readObject();
            jsonReader.close();

            if (jsonResponse.containsKey("steps")) {
                javax.json.JsonArray steps = jsonResponse.getJsonArray("steps");
                String content = null;
                for (int i = 0; i < steps.size(); i++) {
                    JsonObject step = steps.getJsonObject(i);
                    if ("model_output".equals(step.getString("type", ""))) {
                        javax.json.JsonArray contentArray = step.getJsonArray("content");
                        if (contentArray != null && !contentArray.isEmpty()) {
                            JsonObject contentObj = contentArray.getJsonObject(0);
                            if ("text".equals(contentObj.getString("type", ""))) {
                                content = contentObj.getString("text");
                                break;
                            }
                        }
                    }
                }
                
                if (content != null) {
                    PrintWriter out = response.getWriter();
                    out.print(content);
                    out.flush();
                    return;
                }
            }
            
            // Si la API respondió con error o formato diferente, usar motor de recomendación clínico
            String fallback = generarRecomendacionSintomas(pregunta, baseUrl);
            PrintWriter out = response.getWriter();
            out.print(fallback);
            out.flush();

        } catch (Exception e) {
            System.out.println("Aviso: Gemini API no disponible (" + e.getMessage() + "), activando recomendador inteligente local de ArtDent.");
            String fallback = generarRecomendacionSintomas(pregunta, baseUrl);
            PrintWriter out = response.getWriter();
            out.print(fallback);
            out.flush();
        }
    }

    private String generarRecomendacionSintomas(String pregunta, String baseUrl) {
        String p = pregunta != null ? pregunta.toLowerCase() : "";
        java.util.List<pe.edu.utp.entity.Servicio> servicios = new pe.edu.utp.daoImpl.ServicioDaoImpl().listarServicios();
        
        pe.edu.utp.entity.Servicio recomendado = null;
        String explicacion = "";

        if (p.contains("bracket") || p.contains("chuec") || p.contains("torcid") || p.contains("alinea") || p.contains("mordid") || p.contains("frenill")) {
            recomendado = buscarServicio(servicios, "ortodoncia");
            explicacion = "Para corregir la alineación dental y mejorar tanto la función masticatoria como la estética facial.";
        } else if (p.contains("blanque") || p.contains("amarill") || p.contains("mancha") || p.contains("estetic") || p.contains("aclarar")) {
            recomendado = buscarServicio(servicios, "blanqueamiento");
            explicacion = "Para mejorar el tono y remover manchas del esmalte dental, devolviendo el brillo natural a tu sonrisa.";
        } else if (p.contains("caries") || p.contains("curaci") || p.contains("picad") || p.contains("agujero") || p.contains("cavidad") || (p.contains("hueco") && !p.contains("chuec")) || p.contains("sensib")) {
            recomendado = buscarServicio(servicios, "curación");
            if (recomendado == null) recomendado = buscarServicio(servicios, "caries");
            explicacion = "Para remover el tejido dañado y restaurar la pieza con resina estética de alta durabilidad.";
        } else if (p.contains("dolor") || p.contains("puls") || p.contains("intenso") || p.contains("nervio") || p.contains("inflam") || p.contains("no aguanto") || p.contains("muela")) {
            recomendado = buscarServicio(servicios, "endodoncia");
            explicacion = "Cuando el dolor es agudo o compromete el nervio dental, una endodoncia permite salvar la pieza dental eliminando la infección y el dolor.";
        } else if (p.contains("sangr") || p.contains("enci") || p.contains("limpieza") || p.contains("sarro") || p.contains("aliento") || p.contains("placa")) {
            recomendado = buscarServicio(servicios, "limpieza");
            explicacion = "Una profilaxis profunda elimina el sarro acumulado y la placa bacteriana, previniendo gingivitis y mal aliento.";
        } else if (p.contains("sacar") || p.contains("extra") || p.contains("juicio") || p.contains("cordal") || p.contains("cirug")) {
            recomendado = buscarServicio(servicios, "cirug");
            if (recomendado == null) recomendado = buscarServicio(servicios, "extrac");
            explicacion = "Extracción segura realizada por cirujanos con anestesia local para solucionar problemas de terceros molares o piezas no viables.";
        } else if (p.contains("falta") || p.contains("perdi") || p.contains("protesis") || p.contains("corona") || p.contains("implante")) {
            recomendado = buscarServicio(servicios, "prótesis");
            if (recomendado == null) recomendado = buscarServicio(servicios, "protesis");
            explicacion = "Rehabilitación oral para devolver la estética y función dental completa tras la pérdida de una o más piezas.";
        }

        if (recomendado == null && !servicios.isEmpty()) {
            recomendado = servicios.get(0);
            explicacion = "Te sugerimos iniciar con una evaluación odontológica integral para analizar a detalle tu salud bucal.";
        }

        StringBuilder sb = new StringBuilder();
        sb.append("¡Hola! Gracias por consultar con el <b>Asistente Virtual de Art Dent</b>.<br><br>");
        if (recomendado != null) {
            sb.append("De acuerdo con los síntomas que describes (<i>\"").append(pregunta.trim()).append("\"</i>), te recomendamos agendar una evaluación para nuestro servicio de:<br><br>");
            sb.append("🦷 <b><a href='").append(baseUrl).append("/ServicioController?action=cargar&id=").append(recomendado.getIdServicio()).append("' class='text-primary text-decoration-none'>")
              .append(recomendado.getTipoServicio()).append("</a></b><br>");
            sb.append("💰 <b>Costo base:</b> S/ ").append(recomendado.getCosto()).append("<br><br>");
            sb.append("💡 <b>¿Por qué este tratamiento?</b> ").append(explicacion).append("<br><br>");
            sb.append("📅 Puedes reservar tu cita ahora mismo sin registrarte desde nuestra plataforma web.");
        } else {
            sb.append("Te recomendamos agendar una consulta odontológica para evaluar tus síntomas con uno de nuestros especialistas.");
        }
        return sb.toString();
    }

    private pe.edu.utp.entity.Servicio buscarServicio(java.util.List<pe.edu.utp.entity.Servicio> servicios, String termino) {
        String t = termino.toLowerCase();
        for (pe.edu.utp.entity.Servicio s : servicios) {
            if (s.getTipoServicio() != null && s.getTipoServicio().toLowerCase().contains(t)) {
                return s;
            }
        }
        return null;
    }

    private String obtenerServiciosDeBaseDeDatos() {
        StringJoiner servicios = new StringJoiner("\\n");
        String sql = "SELECT * FROM servicio";

        try (Connection conn = Conexion.getConection(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                int id = rs.getInt("idServicio");
                String tipoServicio = rs.getString("TipoServicio");
                String lema = rs.getString("Lema");
                double costo = rs.getDouble("Costo");
                servicios.add(String.format("ID: %d, Tipo: %s, Lema: %s, Costo: %.2f", 
                                            id, tipoServicio, lema, costo));
            }
        } catch (Exception e) {
            e.printStackTrace();
            return "Error al obtener los servicios: " + e.getMessage();
        }

        return servicios.toString();
    }
}