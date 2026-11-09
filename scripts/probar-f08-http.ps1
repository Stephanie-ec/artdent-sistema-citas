param([string]$BaseUrl = 'http://localhost:8080/ArtDent')

# Prueba HTTP real contra la aplicacion ya iniciada. No requiere Python.
# Usa solo fechas invalidas; ninguna solicitud debe crear una cita.
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Net.Http
$handler = [System.Net.Http.HttpClientHandler]::new()
$handler.AllowAutoRedirect = $false
$client = [System.Net.Http.HttpClient]::new($handler)
$client.Timeout = [TimeSpan]::FromSeconds(15)
$casos = @(
    @{ Nombre = 'fecha pasada'; Fecha = '2000-01-03'; Hora = '10:00'; Mensaje = 'pasada' },
    @{ Nombre = 'domingo'; Fecha = '2099-01-04'; Hora = '10:00'; Mensaje = 'domingos' },
    @{ Nombre = 'fecha inexistente'; Fecha = '2099-02-30'; Hora = '10:00'; Mensaje = 'fecha' },
    @{ Nombre = 'hora inexistente'; Fecha = '2099-01-05'; Hora = '25:00'; Mensaje = 'hora' }
)
try {
    foreach ($caso in $casos) {
        $datos = [Collections.Generic.Dictionary[string,string]]::new()
        $datos.Add('dni', '12345678')
        $datos.Add('nombre', 'Ana')
        $datos.Add('apellido', 'Perez')
        $datos.Add('telefono', '987654321')
        $datos.Add('correo', 'ana@example.test')
        $datos.Add('fecha', $caso.Fecha)
        $datos.Add('hora', $caso.Hora)
        $contenido = [System.Net.Http.FormUrlEncodedContent]::new($datos)
        $respuesta = $null
        try {
            $respuesta = $client.PostAsync($BaseUrl.TrimEnd('/') + '/CitaController', $contenido).GetAwaiter().GetResult()
            $cuerpo = $respuesta.Content.ReadAsStringAsync().GetAwaiter().GetResult()
            if ([int]$respuesta.StatusCode -ne 400 -or $cuerpo -notmatch $caso.Mensaje) {
                throw ("FALLO {0}: HTTP {1}; se esperaba HTTP 400 con aviso contextual." -f $caso.Nombre, [int]$respuesta.StatusCode)
            }
            Write-Output ("OK: {0} -> HTTP 400 y mensaje contextual" -f $caso.Nombre)
        } finally {
            if ($null -ne $respuesta) { $respuesta.Dispose() }
            $contenido.Dispose()
        }
    }
} finally {
    $client.Dispose()
    $handler.Dispose()
}
