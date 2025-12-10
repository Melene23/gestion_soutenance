# Test de l'endpoint avec POST
$url = "http://localhost/gestsoutenance/api/auth/register.php"
$body = @{
    nom = "Test"
    prenom = "User"
    email = "test_$(Get-Date -Format 'yyyyMMddHHmmss')@example.com"
    password = "password123"
} | ConvertTo-Json

try {
    $response = Invoke-WebRequest -Uri $url -Method POST -Body $body -ContentType "application/json" -UseBasicParsing -TimeoutSec 10
    Write-Host "Code HTTP: $($response.StatusCode)" -ForegroundColor Green
    Write-Host "Reponse:" -ForegroundColor Cyan
    Write-Host $response.Content -ForegroundColor White
} catch {
    Write-Host "Erreur: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "Reponse du serveur: $responseBody" -ForegroundColor Yellow
    }
}


