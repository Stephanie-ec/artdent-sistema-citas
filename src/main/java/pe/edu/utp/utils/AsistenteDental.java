package pe.edu.utp.utils;
import java.text.Normalizer;
import java.util.*;
import java.util.regex.Pattern;
import pe.edu.utp.entity.Servicio;

/** Respuestas acotadas al catalogo; nunca genera HTML ni diagnosticos. */
public final class AsistenteDental {
    private static final Pattern DENTAL=Pattern.compile("\\b(dient\\w*|muel\\w*|dental\\w*|dentista|odontolog\\w*|bucal|caries|encia\\w*|sarro|bracket\\w*|ortodoncia|endodoncia|protesis|implante\\w*|cordal\\w*|blanque\\w*|limpieza|mordida|frenillo)\\b");
    public static final String ALCANCE="El asistente de ArtDent orienta sobre salud bucal, servicios y reservas dentales. No puedo recomendar tratamientos para otras partes del cuerpo ni resolver consultas ajenas a la clínica. ¿Tu consulta es sobre dientes, encías o una reserva?";
    private AsistenteDental() {}
    private static String normalizar(String s) {return Normalizer.normalize(s.toLowerCase(Locale.ROOT),Normalizer.Form.NFD).replaceAll("\\p{M}","")
            .replaceAll("\\bensias?\\b","encias").replaceAll("\\bcariez\\b","caries");}
    public static boolean esDental(String pregunta) {
        if(pregunta==null)return false;
        String p=normalizar(pregunta);
        if(p.matches(".*\\b(casa|hogar|ropa|piso|ventana|oficina)\\b.*"))return false;
        if(Pattern.compile("\\b(pie|pies|rodilla\\w*|brazo\\w*|estomago|motor\\w*|futbol|politica)\\b").matcher(p).find())return false;
        return DENTAL.matcher(p).find() || p.matches(".*\\b(cita|reserva|horarios|servicios|precios|costos)\\b.*");
    }
    public static Map<String,Object> responder(String pregunta,List<Servicio> servicios) {
        Map<String,Object> r=new LinkedHashMap<>();
        if(!esDental(pregunta)){r.put("mensaje",ALCANCE);return r;}
        String p=normalizar(pregunta);
        if(p.matches(".*\\b(cita|reserva|horarios)\\b.*") && !DENTAL.matcher(p).find()) {
            r.put("mensaje","Puedes consultar horarios disponibles y reservar desde el catálogo de servicios. Para revisar tu cita, abre Mi reserva con tu código y DNI.");return r;
        }
        String termino=null;
        if(p.contains("bracket")||p.contains("ortodon")||p.contains("mordida")||p.contains("torcid"))termino="ortodon";
        else if(p.contains("blanque")||p.contains("amarill"))termino="blanque";
        else if(p.contains("caries")||p.contains("sensib"))termino="caries";
        else if(p.contains("encia")||p.contains("sarro")||p.contains("limpieza"))termino="limpieza";
        else if(p.contains("protesis")||p.contains("implante")||p.contains("perdi"))termino="protesis";
        else if(p.contains("endodon"))termino="endodon";
        else if(p.contains("cordal")||p.contains("juicio")||p.contains("extrac"))termino="cirug";
        Servicio elegido=null;
        if(termino!=null)for(Servicio s:servicios) {
            if(s.getTipoServicio()!=null&&normalizar(s.getTipoServicio()).contains(termino)){elegido=s;break;}
        }
        r.put("mensaje","Los síntomas necesitan una evaluación odontológica para definir el tratamiento. Esta orientación no es un diagnóstico."
                +(elegido==null?" Consulta el catálogo o reserva una evaluación con ArtDent.":" Puedes consultar este servicio del catálogo:"));
        if(elegido!=null) {
            Map<String,Object> servicio=new LinkedHashMap<>();
            servicio.put("id",elegido.getIdServicio());servicio.put("nombre",elegido.getTipoServicio());servicio.put("costo",elegido.getCosto());
            r.put("servicio",servicio);
        }
        return r;
    }
}
