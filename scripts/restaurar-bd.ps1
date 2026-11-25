<#
.SYNOPSIS
  R-17: restaura el ultimo respaldo (o uno indicado) en db_artdent_restaurada
  y mide el tiempo total (RTO) y la antiguedad del respaldo (RPO).

.EJEMPLOS
  powershell -NoProfile -File scripts/restaurar-bd.ps1
  powershell -NoProfile -File scripts/restaurar-bd.ps1 -Respaldo "C:\...\artdent-20261121-020000.zip"
  powershell -NoProfile -File scripts/verificar-conteos.ps1
#>
param(
    [string]$Respaldo = '',
    [string]$Destino = (Join-Path $env:USERPROFILE 'ArtDent\Respaldos'),
    [string]$BaseDestino = 'db_artdent_restaurada',
    [string]$ConfigFile = $env:ARTDENT_CONFIG,
    [string]$MysqlBin = ''
)

$ErrorActionPreference = 'Stop'
$inicio = Get-Date

function Leer-Config([string]$ruta) {
    $cfg = @{}
    if ($ruta -and (Test-Path $ruta)) {
        Get-Content -LiteralPath $ruta | ForEach-Object {
            if ($_ -match '^\s*([^#=]+?)\s*=\s*(.*)$') { $cfg[$matches[1].Trim()] = $matches[2].Trim() }
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

if (-not $Respaldo) {
    $ultimo = Get-ChildItem $Destino -Filter 'artdent-*.zip' -ErrorAction SilentlyContinue |
        Sort-Object LastWriteTime -Descending | Select-Object -First 1
    if (-not $ultimo) { throw "No hay respaldos en $Destino" }
    $Respaldo = $ultimo.FullName
}
if (-not (Test-Path $Respaldo)) { throw "No existe el respaldo $Respaldo" }

if (-not $ConfigFile) {
    $ConfigFile = Join-Path $PSScriptRoot '..\src\main\resources\config.properties'
}
$cfg = Leer-Config $ConfigFile
$url = $cfg['db.url']
if (-not $url -or $url -notmatch 'jdbc:mysql://([^:/]+)(?::(\d+))?/([^?]+)') {
    throw "db.url no es valido en $ConfigFile"
}
$host_ = $matches[1]
$puerto = if ($matches[2]) { $matches[2] } else { '3306' }
$usuario = $cfg['db.user']
$clave = $cfg['db.password']
if (-not $clave) { $clave = $env:MYSQL_PWD }
if (-not $clave) { throw 'Falta db.password o MYSQL_PWD.' }

$mysql = Buscar-Herramienta 'mysql.exe'
$carpeta = Join-Path $env:TEMP ("artdent-restore-" + (Get-Date).ToString('yyyyMMddHHmmss'))
New-Item -ItemType Directory -Force -Path $carpeta | Out-Null

$antiguedad = (Get-Date) - (Get-Item $Respaldo).LastWriteTime
Write-Output "Respaldo usado: $(Split-Path $Respaldo -Leaf)"
Write-Output ("Antiguedad del respaldo (RPO): {0:N1} horas" -f $antiguedad.TotalHours)

try {
    Expand-Archive -Path $Respaldo -DestinationPath $carpeta -Force
    $sql = Get-ChildItem $carpeta -Filter '*.sql' | Select-Object -First 1
    if (-not $sql) { throw 'El ZIP no contiene un archivo .sql' }

    $env:MYSQL_PWD = $clave
    & $mysql --host=$host_ --port=$puerto --user=$usuario --execute="DROP DATABASE IF EXISTS $BaseDestino; CREATE DATABASE $BaseDestino CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
    if ($LASTEXITCODE -ne 0) { throw "No se pudo crear $BaseDestino" }

    & $mysql --host=$host_ --port=$puerto --user=$usuario --database=$BaseDestino --default-character-set=utf8mb4 -e "source $($sql.FullName)"
    if ($LASTEXITCODE -ne 0) { throw "La restauracion termino con codigo $LASTEXITCODE" }

    $duracion = [math]::Round(((Get-Date) - $inicio).TotalSeconds, 1)
    Write-Output "Base restaurada en: $BaseDestino"
    Write-Output ("Tiempo total de restauracion (RTO): {0} s" -f $duracion)
} finally {
    Remove-Item Env:MYSQL_PWD -ErrorAction SilentlyContinue
    Remove-Item $carpeta -Recurse -Force -ErrorAction SilentlyContinue
}
