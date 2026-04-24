# servidor.ps1
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:8000/")
$listener.Start()
Write-Host "Servidor iniciado en http://localhost:8000" -ForegroundColor Green
Write-Host "Presiona Ctrl+C para detener."

while ($listener.IsListening) {
    $context = $listener.GetContext()
    $request = $context.Request
    $response = $context.Response

    $path = $request.Url.LocalPath
    if ($path -eq "/") { $path = "/index.html" }
    $filePath = Join-Path (Get-Location) $path.TrimStart('/')

    if (Test-Path $filePath -PathType Leaf) {
        $content = [System.IO.File]::ReadAllBytes($filePath)
        $response.ContentType = "text/html"
        $response.OutputStream.Write($content, 0, $content.Length)
    } else {
        $response.StatusCode = 404
        $msg = "Archivo no encontrado"
        $response.OutputStream.Write([System.Text.Encoding]::UTF8.GetBytes($msg), 0, $msg.Length)
    }
    $response.OutputStream.Close()
}