# Script pour resoudre les problemes d'icones et d'inscription
# Usage: .\resoudre_problemes.ps1

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Resolution des problemes" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Verifier que nous sommes dans le bon dossier
if (-not (Test-Path "gestsoutenance")) {
    Write-Host "Erreur: Le dossier gestsoutenance n'existe pas." -ForegroundColor Red
    Write-Host "Executez ce script depuis la racine du projet." -ForegroundColor Yellow
    exit 1
}

Write-Host "1. Nettoyage du projet Flutter..." -ForegroundColor Yellow
Set-Location gestsoutenance
flutter clean
Write-Host "   Nettoyage termine" -ForegroundColor Green
Write-Host ""

Write-Host "2. Recuperation des dependances..." -ForegroundColor Yellow
flutter pub get
Write-Host "   Dependances recuperees" -ForegroundColor Green
Write-Host ""

Write-Host "3. Verification de la configuration..." -ForegroundColor Yellow
flutter doctor
Write-Host ""

Write-Host "4. Verification des fichiers Android..." -ForegroundColor Yellow

$networkConfig = "android\app\src\main\res\xml\network_security_config.xml"
$manifest = "android\app\src\main\AndroidManifest.xml"

if (Test-Path $networkConfig) {
    Write-Host "   [OK] network_security_config.xml existe" -ForegroundColor Green
} else {
    Write-Host "   [ERREUR] network_security_config.xml manquant!" -ForegroundColor Red
    Write-Host "   Ce fichier est necessaire pour les connexions HTTP." -ForegroundColor Yellow
}

if (Test-Path $manifest) {
    $manifestContent = Get-Content $manifest -Raw
    if ($manifestContent -match "usesCleartextTraffic") {
        Write-Host "   [OK] AndroidManifest.xml configure correctement" -ForegroundColor Green
    } else {
        Write-Host "   [ERREUR] AndroidManifest.xml ne contient pas usesCleartextTraffic!" -ForegroundColor Red
    }
} else {
    Write-Host "   [ERREUR] AndroidManifest.xml manquant!" -ForegroundColor Red
}

Write-Host ""

Write-Host "5. Verification de la configuration API..." -ForegroundColor Yellow
$apiConfig = "lib\core\constants\api_config.dart"
if (Test-Path $apiConfig) {
    $apiContent = Get-Content $apiConfig -Raw
    if ($apiContent -match "10\.0\.2\.2") {
        Write-Host "   [OK] URL API configuree pour emulateur Android" -ForegroundColor Green
    } else {
        Write-Host "   [ATTENTION] URL API peut ne pas etre correcte" -ForegroundColor Yellow
    }
} else {
    Write-Host "   [ERREUR] api_config.dart manquant!" -ForegroundColor Red
}

Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Instructions" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Pour resoudre les problemes:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Assurez-vous que Apache et MySQL sont demarres dans XAMPP" -ForegroundColor White
Write-Host "2. Reconstruisez l'application:" -ForegroundColor White
Write-Host "   flutter run" -ForegroundColor Cyan
Write-Host ""
Write-Host "3. Si les icones ne s'affichent toujours pas:" -ForegroundColor White
Write-Host "   - Redemarrez l'emulateur/appareil" -ForegroundColor Cyan
Write-Host "   - Verifiez que MaterialApp est utilise dans main.dart" -ForegroundColor Cyan
Write-Host ""
Write-Host "4. Si l'inscription ne fonctionne toujours pas:" -ForegroundColor White
Write-Host "   - Verifiez que Apache est demarre" -ForegroundColor Cyan
Write-Host "   - Testez l'API dans le navigateur:" -ForegroundColor Cyan
Write-Host "     http://localhost/gestsoutenance/api/test/test_config.php" -ForegroundColor Gray
Write-Host "   - Verifiez les logs Flutter avec: flutter run -v" -ForegroundColor Cyan
Write-Host ""

Set-Location ..


