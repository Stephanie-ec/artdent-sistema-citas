package pe.edu.utp.utils;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import org.mindrot.jbcrypt.BCrypt;

public class SecurityUtils {

    /**
     * Genera un hash seguro con algoritmo BCrypt y salting automático (factor de costo 10).
     * Cumple con el estándar de seguridad RNF03.
     */
    public static String hashPassword(String password) {
        if (password == null || password.trim().isEmpty()) {
            return null;
        }
        return BCrypt.hashpw(password, BCrypt.gensalt(10));
    }

    /**
     * Verifica una contraseña en texto plano contra el hash almacenado en la base de datos.
     * Soporta nativamente BCrypt y mantiene retrocompatibilidad con hashes previos SHA-256
     * o contraseñas en texto plano para permitir migración transparente.
     */
    public static boolean verifyPassword(String candidatePassword, String storedHash) {
        if (candidatePassword == null || storedHash == null) {
            return false;
        }

        // Si ya es un hash BCrypt ($2a$, $2b$, $2y$)
        if (isBCrypt(storedHash)) {
            try {
                return BCrypt.checkpw(candidatePassword, storedHash);
            } catch (Exception e) {
                return false;
            }
        }

        // Retrocompatibilidad con SHA-256 (64 caracteres hexadecimales)
        if (storedHash.length() == 64) {
            String sha256Candidate = hashSHA256(candidatePassword);
            return storedHash.equalsIgnoreCase(sha256Candidate);
        }

        // Retrocompatibilidad con contraseñas históricas en texto plano
        return candidatePassword.equals(storedHash);
    }

    /**
     * Determina si el hash almacenado requiere migración al estándar BCrypt.
     */
    public static boolean needsRehash(String storedHash) {
        return storedHash != null && !isBCrypt(storedHash);
    }

    /**
     * Verifica si una cadena posee el formato de hash BCrypt.
     */
    public static boolean isBCrypt(String hash) {
        if (hash == null) return false;
        return hash.startsWith("$2a$") || hash.startsWith("$2b$") || hash.startsWith("$2y$");
    }

    /**
     * Genera hash SHA-256 para validación de cuentas heredadas.
     */
    public static String hashSHA256(String password) {
        if (password == null) return null;
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] hash = md.digest(password.getBytes());
            StringBuilder hexString = new StringBuilder();
            for (byte b : hash) {
                String hex = Integer.toHexString(0xff & b);
                if (hex.length() == 1) hexString.append('0');
                hexString.append(hex);
            }
            return hexString.toString();
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("Error al calcular hash SHA-256", e);
        }
    }
}
