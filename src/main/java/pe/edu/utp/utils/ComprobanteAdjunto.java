package pe.edu.utp.utils;

import java.awt.image.BufferedImage;
import java.io.*;
import java.nio.file.*;
import java.util.*;
import javax.imageio.*;
import javax.imageio.stream.ImageInputStream;

/** Decodifica y vuelve a codificar: ni extensión ni MIME del cliente son confiables. */
public final class ComprobanteAdjunto {
    public static final int MAX_BYTES=5*1024*1024;
    private ComprobanteAdjunto() { }
    public static byte[] validar(InputStream entrada) throws IOException {
        ByteArrayOutputStream bytes=new ByteArrayOutputStream();byte[] buffer=new byte[8192];int n;
        while((n=entrada.read(buffer))!=-1) {if(bytes.size()+n>MAX_BYTES)throw new IOException("El comprobante supera 5 MB.");bytes.write(buffer,0,n);}
        try(ImageInputStream imagen=ImageIO.createImageInputStream(new ByteArrayInputStream(bytes.toByteArray()))) {
            Iterator<ImageReader> readers=ImageIO.getImageReaders(imagen);
            if(!readers.hasNext())throw new IOException("Adjunte una imagen JPEG o PNG válida.");
            ImageReader reader=readers.next();
            try {
                String formato=reader.getFormatName();
                if(!"PNG".equalsIgnoreCase(formato)&&!"JPEG".equalsIgnoreCase(formato))throw new IOException("Solo se permite JPEG o PNG.");
                reader.setInput(imagen,true,true);
                int ancho=reader.getWidth(0),alto=reader.getHeight(0);
                if(ancho<=0||alto<=0||(long)ancho*alto>12000000L)throw new IOException("La imagen excede 12 megapíxeles.");
                BufferedImage limpia=reader.read(0);ByteArrayOutputStream salida=new ByteArrayOutputStream();
                if(!ImageIO.write(limpia,"png",salida)||salida.size()>MAX_BYTES)throw new IOException("La imagen procesada supera 5 MB; reduzca su tamaño.");
                return salida.toByteArray();
            } finally {reader.dispose();}
        }
    }
    public static Path directorio(String raizWeb) throws IOException {
        String valor=ConfigLoader.getProperty("pagos.adjuntos.dir");
        if(valor==null||!Paths.get(valor).isAbsolute())throw new IOException("El almacenamiento de comprobantes no está configurado.");
        Path dir=Paths.get(valor).toAbsolutePath().normalize();
        Files.createDirectories(dir);dir=dir.toRealPath();
        if(raizWeb!=null&&dir.startsWith(Paths.get(raizWeb).toRealPath()))throw new IOException("El almacenamiento debe estar fuera del sitio público.");
        return dir;
    }
}
