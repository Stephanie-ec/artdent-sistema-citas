# ArtDent

Sistema de citas odontológicas Java/JSP con MySQL 8.0. Verificado con JDK 17 y Maven 3.9.9.

- [Desplegar en Railway (MySQL + Tomcat 9 + JSP)](docs/DESPLIEGUE_RAILWAY.md)
- [Pago en línea con Mercado Pago (sandbox)](docs/PAGO_EN_LINEA.md)
- [Correo en la aplicación desplegada](docs/CORREO_EN_DESPLIEGUE.md)
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

## Despliegue en contenedor

El proyecto incluye `Dockerfile` (WAR sobre **Tomcat 9**, obligatorio porque el
código usa `javax.servlet`). La configuración del servidor entra por variables
`ARTDENT_*`; la plantilla está en `.env.example` y la guía completa en
[docs/DESPLIEGUE_RAILWAY.md](docs/DESPLIEGUE_RAILWAY.md).

```bash
docker build -t artdent .
docker run --rm -p 8080:8080 --env-file .env -v "$PWD/datos:/data" artdent
```
