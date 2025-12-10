# Script pour corriger et tester automatiquement
# Usage: .\corriger_et_tester.ps1

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  CORRECTION ET TEST AUTOMATIQUE" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 1. Nettoyer le projet Flutter
Write-Host "1. Nettoyage du projet Flutter..." -ForegroundColor Yellow
Set-Location gestsoutenance
flutter clean
Write-Host "   [OK] Nettoyage termine" -ForegroundColor Green
Write-Host ""

# 2. Recuperer les dependances
Write-Host "2. Recuperation des dependances..." -ForegroundColor Yellow
flutter pub get
Write-Host "   [OK] Dependances recuperees" -ForegroundColor Green
Write-Host ""

# 3. Verifier les fichiers Android
Write-Host "3. Verification des fichiers Android..." -ForegroundColor Yellow
$networkConfig = "android\app\src\main\res\xml\network_security_config.xml"
if (Test-Path $networkConfig) {
    Write-Host "   [OK] network_security_config.xml existe" -ForegroundColor Green
} else {
    Write-Host "   [ERREUR] Fichier manquant!" -ForegroundColor Red
    exit 1
}

$manifest = "android\app\src\main\AndroidManifest.xml"
if (Test-Path $manifest) {
    $content = Get-Content $manifest -Raw
    if ($content -match "usesCleartextTraffic" -and $content -match "networkSecurityConfig") {
        Write-Host "   [OK] AndroidManifest.xml configure correctement" -ForegroundColor Green
    } else {
        Write-Host "   [ERREUR] Configuration manquante dans AndroidManifest.xml!" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "   [ERREUR] AndroidManifest.xml manquant!" -ForegroundColor Red
    exit 1
}
Write-Host ""

# 4. Verifier la configuration API
Write-Host "4. Verification de la configuration API..." -ForegroundColor Yellow
$apiConfig = "lib\core\constants\api_config.dart"
if (Test-Path $apiConfig) {
    $content = Get-Content $apiConfig -Raw
    if ($content -match "10\.0\.2\.2") {
        Write-Host "   [OK] URL API correcte pour emulateur Android" -ForegroundColor Green
    } else {
        Write-Host "   [ATTENTION] URL peut ne pas etre correcte" -ForegroundColor Yellow
    }
} else {
    Write-Host "   [ERREUR] api_config.dart manquant!" -ForegroundColor Red
    exit 1
}
Write-Host ""

# 5. Tester l'API
Write-Host "5. Test de l'API..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost/gestsoutenance/api/test/test_config.php" -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
    if ($response.StatusCode -eq 200) {
        Write-Host "   [OK] API accessible" -ForegroundColor Green
    } else {
        Write-Host "   [ERREUR] API retourne le code: $($response.StatusCode)" -ForegroundColor Red
    }
} catch {
    Write-Host "   [ERREUR] API non accessible. Demarrez Apache dans XAMPP!" -ForegroundColor Red
    Write-Host "   Message: $($_.Exception.Message)" -ForegroundColor Red
}
Write-Host ""

# Resume
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  INSTRUCTIONS FINALES" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Pour resoudre les problemes:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Assurez-vous que Apache et MySQL sont demarres dans XAMPP" -ForegroundColor White
Write-Host ""
Write-Host "2. Reconstruisez l'application:" -ForegroundColor White
Write-Host "   flutter run" -ForegroundColor Cyan
Write-Host ""
Write-Host "3. Si les icones ne s'affichent toujours pas:" -ForegroundColor White
Write-Host "   - Redemarrez l'emulateur/appareil" -ForegroundColor Cyan
Write-Host "   - Les icones Material sont maintenant configurees explicitement" -ForegroundColor Cyan
Write-Host ""
Write-Host "4. Si l'inscription ne fonctionne toujours pas:" -ForegroundColor White
Write-Host "   - Verifiez les logs avec: flutter run -v" -ForegroundColor Cyan
Write-Host "   - Testez l'API dans le navigateur:" -ForegroundColor Cyan
Write-Host "     http://localhost/gestsoutenance/api/test/test_register_endpoint.php" -ForegroundColor Gray
Write-Host ""

Set-Location ..


