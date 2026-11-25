<#
.SYNOPSIS
  R-17: compara los conteos de las tablas criticas entre la base de origen
  y la base restaurada. Sale con codigo 1 si algo no coincide.
#>
param(
    [string]$BaseOrigen = 'db_artdent_apf2',
    [string]$BaseDestino = 'db_artdent_restaurada',
    [string]$ConfigFile = $env:ARTDENT_CONFIG,
    [string]$MysqlBin = ''
)

$ErrorActionPreference = 'Stop'

function Leer-Config([string]$ruta) {
    $cfg = @{}
    if ($ruta -and (Test-Path $ruta)) {
        Get-Content -LiteralPath $ruta | ForEach-Object {
            if ($_ -match '^\s*([^#=]+?)\s*=\s*(.*)$') { $cfg[$matches[1].Trim()] = $matches[2].Trim() }
        }
    }
    return $cfg
}

function Buscar-Mysql {
    if ($MysqlBin) {
        $ruta = Join-Path $MysqlBin 'mysql.exe'
        if (Test-Path $ruta) { return $ruta }
    }
    $cmd = Get-Command mysql.exe -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }
    $servidor = Get-ChildItem 'C:\Program Files\MySQL' -Directory -Filter 'MySQL Server*' -ErrorAction SilentlyContinue |
        Sort-Object Name -Descending | Select-Object -First 1
    if ($servidor) {
        $ruta = Join-Path $servidor.FullName 'bin\mysql.exe'
        if (Test-Path $ruta) { return $ruta }
    }
    throw 'No se encontro mysql.exe. Indique -MysqlBin.'
}

if (-not $ConfigFile) { $ConfigFile = Join-Path $PSScriptRoot '..\src\main\resources\config.properties' }
$cfg = Leer-Config $ConfigFile
$url = $cfg['db.url']
if (-not $url -or $url -notmatch 'jdbc:mysql://([^:/]+)(?::(\d+))?/([^?]+)') { throw 'db.url no es valido.' }
$host_ = $matches[1]
$puerto = if ($matches[2]) { $matches[2] } else { '3306' }
$usuario = $cfg['db.user']
$clave = $cfg['db.password']
if (-not $clave) { $clave = $env:MYSQL_PWD }
if (-not $clave) { throw 'Falta db.password o MYSQL_PWD.' }

$mysql = Buscar-Mysql
$tablas = @('Paciente', 'Cita', 'Pago', 'Comprobante', 'Atencion')
$columnas = ($tablas | ForEach-Object { "SELECT COUNT(*) FROM $_" }) -join '; '

function Conteos([string]$base) {
    $env:MYSQL_PWD = $clave
    $salida = & $mysql --host=$host_ --port=$puerto --user=$usuario --database=$base --batch --skip-column-names --execute="$columnas"
    if ($LASTEXITCODE -ne 0) { throw "No se pudo consultar $base" }
    $valores = @()
    foreach ($linea in $salida) { foreach ($v in ($linea -split "`t")) { if ($v -ne '') { $valores += [int]$v } } }
    if ($valores.Count -ne $tablas.Count) { throw "Respuesta inesperada al contar filas de $base" }
    return $valores
}

try {
    $origen = Conteos $BaseOrigen
    $destino = Conteos $BaseDestino
} finally {
    Remove-Item Env:MYSQL_PWD -ErrorAction SilentlyContinue
}

$fallos = 0
Write-Output ("{0,-14} {1,10} {2,10}  {3}" -f 'TABLA', $BaseOrigen, $BaseDestino, 'RESULTADO')
for ($i = 0; $i -lt $tablas.Count; $i++) {
    $igual = $origen[$i] -eq $destino[$i]
    if (-not $igual) { $fallos++ }
    Write-Output ("{0,-14} {1,10} {2,10}  {3}" -f $tablas[$i], $origen[$i], $destino[$i], $(if ($igual) { 'OK' } else { 'DIFERENTE' }))
}

if ($fallos -eq 0) {
    Write-Output 'Conteos coinciden: la restauracion es completa.'
    exit 0
} else {
    Write-Output "Hay $fallos tabla(s) con diferencias."
    exit 1
}
