# ArtDent

Sistema de citas odontológicas Java/JSP con MySQL 8.0. Verificado con JDK 17 y Maven 3.9.9.

- [Preparar y probar en otra PC](src/main/document/PRUEBAS_PLAN_COMPLETO.md)
- [Auditoría del plan F-01 a F-18](src/main/document/AUDITORIA_PLAN_COMPLETO.md)
- [Cierre de pendientes, matriz y límites de aceptación](src/main/document/CIERRE_PENDIENTES.md)
- [Diagrama de casos de uso](src/main/document/CASOS_DE_USO.md)
- SQL de instalación: `src/main/java/pe/edu/utp/bd/db_artdent_apf2_completo.sql`.
- SQL de actualización sin borrar datos: `src/main/java/pe/edu/utp/bd/update_apf2_fallas.sql`.

El SQL de instalación elimina la base anterior. Usa el delta para actualizar una
base existente, con respaldo y la aplicación detenida. No subas tu archivo local
`config.properties` al repositorio ni al ZIP. Configura `ARTDENT_CONFIG` con una ruta
externa o usa variables `ARTDENT_*`; no se carga configuración privada del classpath.

Pruebas sin base de datos: `mvn clean package`. Pruebas MySQL y HTTP: sigue la guía;
usan una base descartable terminada en `_test` y requieren preparación explícita.
