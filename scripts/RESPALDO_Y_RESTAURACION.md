# Respaldo y restauración (R-16 / R-17)

Procedimiento de la base `db_artdent_apf2` y de los comprobantes Yape/Plin.

| Dato | Definición |
| --- | --- |
| **Frecuencia** | Diaria, 02:00 (fuera del horario de atención). |
| **Destino** | Carpeta privada del equipo: `%USERPROFILE%\ArtDent\Respaldos` o una unidad/carpeta sincronizada distinta del servidor de base de datos. |
| **Contenido** | `artdent-AAAAMMDD-HHMMSS.zip` con el volcado completo (`--single-transaction --routines --triggers`) y `comprobantes-AAAAMMDD-HHMMSS.zip` con los adjuntos de pago. |
| **Retención** | 7 respaldos diarios de cada tipo (los más antiguos se eliminan). |
| **Protección** | La carpeta queda restringida al usuario que ejecuta el respaldo (`icacls`); el ZIP no se publica en la web. La contraseña **no** está en el script: se lee de `config.properties` o de `MYSQL_PWD`. |
| **Responsable** | Administrador del sistema de la clínica. |
| **RPO** | ≤ 24 h (respaldo diario). |
| **RTO** | ≤ 30 min (restauración medida, ver evidencia). |
| **Verificación** | Cada mes se restaura el último respaldo en `db_artdent_restaurada` y se comparan los conteos. |
| **Evento** | Cada ejecución escribe un evento INFO en la tabla `Evento`; un fallo escribe ERROR y aparece como alerta en el panel del administrador. |

## Respaldar

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\respaldo-bd.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\respaldo-bd.ps1 -Destino D:\Respaldos -Conservar 7
```

## Programar (tarea diaria de Windows)

Ejecutar una vez en una consola del usuario que deba respaldar:

```powershell
schtasks /Create /TN "ArtDent respaldo diario" /SC DAILY /ST 02:00 /TR "powershell -NoProfile -ExecutionPolicy Bypass -File \"C:\ruta\artdent-sistema-citas-main\scripts\respaldo-bd.ps1\""
```

Comprobar: `schtasks /Query /TN "ArtDent respaldo diario"`. La tarea se crea solo si el equipo lo autoriza; el respaldo también puede ejecutarse a mano.

## Restaurar y validar (R-17)

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\restaurar-bd.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\verificar-conteos.ps1
```

`restaurar-bd.ps1` informa el RTO (tiempo total) y el RPO (antigüedad del respaldo usado).
`verificar-conteos.ps1` compara `Paciente`, `Cita`, `Pago`, `Comprobante` y `Atencion` entre
`db_artdent_apf2` y `db_artdent_restaurada`; termina con código 1 si hay diferencias.

Para probar la aplicación contra la base restaurada sin tocar la de trabajo, cree un archivo
de configuración con `db.url=jdbc:mysql://localhost:3306/db_artdent_restaurada?...` y arranque
una instancia aparte:

```powershell
$env:ARTDENT_CONFIG = "C:\ruta\config-restaurada.properties"
mvn -Djetty.http.port=8081 jetty:run
```

Luego inicie sesión y compruebe que se ve la última cita. Guarde la salida de los scripts y las
capturas como evidencia del informe.

## Evidencia de la prueba (21/11/2026)

Ejecución real sobre la base de trabajo:

| Paso | Resultado |
| --- | --- |
| `respaldo-bd.ps1` | `artdent-20261121-205744.zip` (14 KB) en `C:\Users\<usuario>\ArtDent\Respaldos`; 7.9 s; evento INFO id 7 en `Evento` (Origen `Respaldo`). |
| `restaurar-bd.ps1` | Base `db_artdent_restaurada` creada; **RTO = 10 s**; **RPO = 0.0 h**. |
| `verificar-conteos.ps1` | Paciente 9/9, Cita 15/15, Pago 10/10, Comprobante 10/10, Atencion 0/0 → "Conteos coinciden". |
| Aplicación contra la base restaurada | Instancia en el puerto 8081 con `ARTDENT_CONFIG`; login de administrador correcto y listado con los pacientes de la copia. |

La tarea programada de Windows **no** se creó; queda pendiente de autorización del responsable del equipo.

## Respaldo del servidor en la nube

Si la versión publicada usa MySQL administrado, se suma el respaldo automático del proveedor
(por ejemplo Azure Database for MySQL) a este procedimiento local; la restauración se valida igual.
