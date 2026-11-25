# syntax=docker/dockerfile:1
# =====================================================================
# ArtDent - WAR + JSP sobre Apache Tomcat 9
#
# La aplicación usa javax.servlet (Servlet 3.1), por lo que Tomcat 9 es
# obligatorio: Tomcat 10/11 migró a jakarta.* y no arranca este WAR.
# Railway detecta este archivo en la raíz del repositorio.
# =====================================================================

# ---------- Etapa 1: compilar el WAR ----------
FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /src

# Sin cache mount: el builder de Railway rechaza `--mount=type=cache`
# (exige un prefijo cacheKey propio) y el despliegue falla antes de compilar.
COPY pom.xml ./
COPY src ./src
RUN mvn -B -q -DskipTests package

# ---------- Etapa 2: ejecutar ----------
FROM tomcat:9.0-jdk17-temurin

ENV LANG=C.UTF-8 \
    LANGUAGE=es_PE:es \
    TZ=America/Lima \
    JAVA_OPTS="-Xms256m -Xmx512m -Duser.timezone=America/Lima -Dfile.encoding=UTF-8" \
    ARTDENT_DATOS_DIR=/data/artdent \
    CATALINA_BASE=/usr/local/tomcat

# Contenedor saneado: sin aplicaciones de ejemplo de Tomcat.
RUN rm -rf /usr/local/tomcat/webapps/* \
 && mkdir -p /data/artdent

# El contexto raíz ("/") evita el prefijo /ArtDent en el dominio de Railway.
COPY --from=build /src/target/ArtDent-1.0-SNAPSHOT.war /usr/local/tomcat/webapps/ROOT.war
COPY docker/entrypoint.sh /usr/local/bin/artdent-entrypoint
RUN chmod 755 /usr/local/bin/artdent-entrypoint

EXPOSE 8080
ENTRYPOINT ["/usr/local/bin/artdent-entrypoint"]
