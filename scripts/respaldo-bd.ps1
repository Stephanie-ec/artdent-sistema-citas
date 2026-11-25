<#
.SYNOPSIS
  R-16: respaldo diario de la base ArtDent y de los comprobantes Yape/Plin.

.DESCRIPTION
  - Lee la conexion del mismo config.properties que usa la aplicacion.
  - La contrasena se toma de la configuracion o de la variable MYSQL_PWD y
    nunca se escribe en el script ni en la linea de comandos.
  - Genera un ZIP con fecha, conserva los ultimos 7 y registra un evento
    INFO (o ERROR si falla) en la tabla Evento.

.EJEMPLOS
  powershell -NoProfile -File scripts/respaldo-bd.ps1
  powershell -NoProfile -File scripts/respaldo-bd.ps1 -Destino D:\Respaldos -Conservar 7

  Tarea programada diaria (ejecutar una vez, en una consola del usuario):
  schtasks /Create /TN "ArtDent respaldo diario" /SC DAILY /ST 02:00 ^
    /TR "powershell -NoProfile -ExecutionPolicy Bypass -File \"C:\ruta\artdent\scripts\respaldo-bd.ps1\""
#>
param(
    [string]$ConfigFile = $env:ARTDENT_CONFIG,
    [string]$Destino = (Join-Path $env:USERPROFILE 'ArtDent\Respaldos'),
    [int]$Conservar = 7,
    [string]$MysqlBin = ''
)

$ErrorActionPreference = 'Stop'
$inicio = Get-Date
$nombreBase = 'db_artdent_apf2'

function Leer-Config([string]$ruta) {
    $cfg = @{}
    if ($ruta -and (Test-Path $ruta)) {
        Get-Content -LiteralPath $ruta | ForEach-Object {
            if ($_ -match '^\s*([^#=]+?)\s*=\s*(.*)$') {
                $cfg[$matches[1].Trim()] = $matches[2].Trim()
            }
        }
    }
    return $cfg
}

function Buscar-Herramienta([string]$nombre) {
    if ($MysqlBin) {
        $ruta = Join-Path $MysqlBin $nombre
        if (Test-Path $ruta) { return $ruta }
    }
    $cmd = Get-Command $nombre -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }
    $servidor = Get-ChildItem 'C:\Program Files\MySQL' -Directory -Filter 'MySQL Server*' -ErrorAction SilentlyContinue |
        Sort-Object Name -Descending | Select-Object -First 1
    if ($servidor) {
        $ruta = Join-Path $servidor.FullName ('bin\' + $nombre)
        if (Test-Path $ruta) { return $ruta }
    }
    throw "No se encontro $nombre. Indique -MysqlBin con la carpeta bin de MySQL."
}

if (-not $ConfigFile) {
    $ConfigFile = Join-Path $PSScriptRoot '..\src\main\resources\config.properties'
    if (-not (Test-Path $ConfigFile)) {
        $ConfigFile = Join-Path $PSScriptRoot '..\src\main\resources\config.properties.example'
    }
}
$cfg = Leer-Config $ConfigFile
$url = $cfg['db.url']
if (-not $url -or $url -notmatch 'jdbc:mysql://([^:/]+)(?::(\d+))?/([^?]+)') {
    throw "db.url no es valido en $ConfigFile"
}
$host_ = $matches[1]
$puerto = if ($matches[2]) { $matches[2] } else { '3306' }
$base = $matches[3]

$dump = Buscar-Herramienta 'mysqldump.exe'
$mysql = Buscar-Herramienta 'mysql.exe'

$clave = $cfg['db.password']
if (-not $clave) { $clave = $env:MYSQL_PWD }
if (-not $clave) { throw 'Falta db.password en la configuracion o la variable MYSQL_PWD.' }

$fecha = Get-Date
$sello = $fecha.ToString('yyyyMMdd-HHmmss')
New-Item -ItemType Directory -Force -Path $Destino | Out-Null
try {
    # Carpeta privada: solo el usuario que ejecuta el respaldo
    icacls $Destino /inheritance:r /grant:r "$($env:USERNAME):(OI)(CI)F" | Out-Null
} catch { Write-Warning 'No se pudieron ajustar los permisos de la carpeta de respaldos.' }

$sqlTemporal = Join-Path $env:TEMP "artdent-$sello.sql"
$zip = Join-Path $Destino "artdent-$sello.zip"
$mensaje = ''
$ok = $true

try {
    $env:MYSQL_PWD = $clave
    & $dump --host=$host_ --port=$puerto --user=$($cfg['db.user']) --single-transaction --routines --triggers `
        --default-character-set=utf8mb4 --result-file=$sqlTemporal $base
    if ($LASTEXITCODE -ne 0) { throw "mysqldump termino con codigo $LASTEXITCODE" }

    Compress-Archive -Path $sqlTemporal -DestinationPath $zip -CompressionLevel Optimal -Force
    $tamano = [math]::Round((Get-Item $zip).Length / 1MB, 2)

    # Comprobantes Yape/Plin (carpeta privada configurada)
    $adjuntos = $cfg['pagos.adjuntos.dir']
    if ($adjuntos -and -not [System.IO.Path]::IsPathRooted($adjuntos)) {
        $baseDatos = $cfg['datos.dir']
        if (-not $baseDatos) { $baseDatos = Join-Path $env:USERPROFILE 'artdent' }
        $adjuntos = Join-Path $baseDatos $adjuntos
    }
    if ($adjuntos -and (Test-Path $adjuntos)) {
        $zipAdjuntos = Join-Path $Destino "comprobantes-$sello.zip"
        Compress-Archive -Path (Join-Path $adjuntos '*') -DestinationPath $zipAdjuntos -CompressionLevel Optimal -Force
        Write-Output "Comprobantes respaldados en $zipAdjuntos"
    }

    # Conservar solo los ultimos N respaldos de cada tipo
    Get-ChildItem $Destino -Filter 'artdent-*.zip' | Sort-Object LastWriteTime -Descending |
        Select-Object -Skip $Conservar | Remove-Item -Force
    Get-ChildItem $Destino -Filter 'comprobantes-*.zip' | Sort-Object LastWriteTime -Descending |
        Select-Object -Skip $Conservar | Remove-Item -Force

    $mensaje = "Respaldo generado: $(Split-Path $zip -Leaf) ($tamano MB) en $($Destino.Replace('\','/'))"
} catch {
    $ok = $false
    $mensaje = "Fallo el respaldo de la base: $($_.Exception.Message)"
} finally {
    Remove-Item $sqlTemporal -ErrorAction SilentlyContinue
    Remove-Item Env:MYSQL_PWD -ErrorAction SilentlyContinue
}

# R-15: registrar el resultado como evento
try {
    $nivel = if ($ok) { 'INFO' } else { 'ERROR' }
    $texto = $mensaje.Replace("'", ' ')
    $env:MYSQL_PWD = $clave
    & $mysql --host=$host_ --port=$puerto --user=$($cfg['db.user']) --database=$base `
        --execute="INSERT INTO Evento(Nivel,Origen,Mensaje) VALUES('$nivel','Respaldo','$texto')"
    if ($LASTEXITCODE -ne 0) { Write-Warning 'El respaldo se ejecuto pero no se pudo registrar el evento.' }
} catch {
    Write-Warning "No se pudo registrar el evento del respaldo: $($_.Exception.Message)"
} finally {
    Remove-Item Env:MYSQL_PWD -ErrorAction SilentlyContinue
}

$duracion = [math]::Round(((Get-Date) - $inicio).TotalSeconds, 1)
Write-Output $mensaje
Write-Output "Duracion: $duracion s"
if ($ok) { exit 0 } else { exit 1 }
