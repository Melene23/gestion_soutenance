# Script de test pour vérifier la configuration API
Write-Host "=== Test de Configuration API ===" -ForegroundColor Cyan
Write-Host ""

# Test 1: Vérifier si XAMPP est installé
Write-Host "1. Vérification de XAMPP..." -ForegroundColor Yellow
$xamppPath = "C:\xampp"
if (Test-Path $xamppPath) {
    Write-Host "   [OK] XAMPP est installé" -ForegroundColor Green
} else {
    Write-Host "   [ERREUR] XAMPP n'est pas installé à C:\xampp" -ForegroundColor Red
    exit 1
}

# Test 2: Vérifier si les fichiers API existent
Write-Host ""
Write-Host "2. Vérification des fichiers API..." -ForegroundColor Yellow
$apiPath = "C:\xampp\htdocs\gestsoutenance\api"
if (Test-Path $apiPath) {
    Write-Host "   [OK] Le dossier API existe" -ForegroundColor Green
    
    $loginFile = "$apiPath\auth\login.php"
    if (Test-Path $loginFile) {
        Write-Host "   [OK] login.php existe" -ForegroundColor Green
    } else {
        Write-Host "   [ERREUR] login.php n'existe pas" -ForegroundColor Red
    }
} else {
    Write-Host "   [ERREUR] Le dossier API n'existe pas: $apiPath" -ForegroundColor Red
    Write-Host "   Exécutez: .\copier_api.ps1" -ForegroundColor Yellow
    exit 1
}

# Test 3: Vérifier si Apache est en cours d'exécution
Write-Host ""
Write-Host "3. Vérification d'Apache..." -ForegroundColor Yellow
$apacheProcess = Get-Process -Name "httpd" -ErrorAction SilentlyContinue
if ($apacheProcess) {
    Write-Host "   [OK] Apache est en cours d'exécution" -ForegroundColor Green
} else {
    Write-Host "   [ATTENTION] Apache ne semble pas être en cours d'exécution" -ForegroundColor Yellow
    Write-Host "   Démarrez Apache depuis le panneau de contrôle XAMPP" -ForegroundColor Yellow
}

# Test 4: Tester l'URL de l'API
Write-Host ""
Write-Host "4. Test de l'URL de l'API..." -ForegroundColor Yellow
$testUrl = "http://localhost/gestsoutenance/api/test.php"
try {
    $response = Invoke-WebRequest -Uri $testUrl -Method GET -TimeoutSec 5 -ErrorAction Stop
    if ($response.StatusCode -eq 200) {
        Write-Host "   [OK] L'API répond correctement" -ForegroundColor Green
        Write-Host "   Réponse: $($response.Content.Substring(0, [Math]::Min(100, $response.Content.Length)))..." -ForegroundColor Gray
    }
} catch {
    Write-Host "   [ERREUR] Impossible d'accéder à l'API" -ForegroundColor Red
    Write-Host "   URL testée: $testUrl" -ForegroundColor Gray
    Write-Host "   Erreur: $($_.Exception.Message)" -ForegroundColor Gray
    Write-Host ""
    Write-Host "   Vérifiez que:" -ForegroundColor Yellow
    Write-Host "   - Apache est démarré dans XAMPP" -ForegroundColor White
    Write-Host "   - Le port 80 n'est pas utilisé par un autre service" -ForegroundColor White
    Write-Host "   - Les fichiers sont bien dans C:\xampp\htdocs\gestsoutenance\api\" -ForegroundColor White
}

# Test 5: Vérifier la base de données
Write-Host ""
Write-Host "5. Vérification de MySQL..." -ForegroundColor Yellow
$mysqlProcess = Get-Process -Name "mysqld" -ErrorAction SilentlyContinue
if ($mysqlProcess) {
    Write-Host "   [OK] MySQL est en cours d'exécution" -ForegroundColor Green
} else {
    Write-Host "   [ATTENTION] MySQL ne semble pas être en cours d'exécution" -ForegroundColor Yellow
    Write-Host "   Démarrez MySQL depuis le panneau de contrôle XAMPP" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "=== Fin des tests ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Si tous les tests passent, votre API devrait fonctionner." -ForegroundColor Green
Write-Host "Testez dans votre navigateur: $testUrl" -ForegroundColor Cyan




