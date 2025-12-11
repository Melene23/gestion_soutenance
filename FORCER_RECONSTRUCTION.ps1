# Script pour FORCER la reconstruction complete de l'application
# Usage: .\FORCER_RECONSTRUCTION.ps1

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  RECONSTRUCTION FORCEE" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Ce script va:" -ForegroundColor Yellow
Write-Host "1. Nettoyer completement le projet" -ForegroundColor White
Write-Host "2. Supprimer tous les caches" -ForegroundColor White
Write-Host "3. Reconstruire l'application" -ForegroundColor White
Write-Host ""

Set-Location gestsoutenance

# 1. Nettoyer Flutter
Write-Host "1. Nettoyage Flutter..." -ForegroundColor Yellow
flutter clean
Write-Host "   [OK]" -ForegroundColor Green

# 2. Supprimer les dossiers de build
Write-Host "2. Suppression des dossiers de build..." -ForegroundColor Yellow
Remove-Item -Path "build" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path ".dart_tool" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path ".flutter-plugins" -Force -ErrorAction SilentlyContinue
Remove-Item -Path ".flutter-plugins-dependencies" -Force -ErrorAction SilentlyContinue
Write-Host "   [OK]" -ForegroundColor Green

# 3. Nettoyer Android
Write-Host "3. Nettoyage Android..." -ForegroundColor Yellow
if (Test-Path "android\app\build") {
    Remove-Item -Path "android\app\build" -Recurse -Force -ErrorAction SilentlyContinue
}
if (Test-Path "android\.gradle") {
    Remove-Item -Path "android\.gradle" -Recurse -Force -ErrorAction SilentlyContinue
}
Write-Host "   [OK]" -ForegroundColor Green

# 4. Recuperer les dependances
Write-Host "4. Recuperation des dependances..." -ForegroundColor Yellow
flutter pub get
Write-Host "   [OK]" -ForegroundColor Green

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  ETAPES SUIVANTES" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "IMPORTANT: Vous DEVEZ maintenant:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. FERMER completement l'application si elle tourne" -ForegroundColor White
Write-Host "2. FERMER l'emulateur Android (si utilise)" -ForegroundColor White
Write-Host "3. REDEMARRER l'emulateur" -ForegroundColor White
Write-Host "4. Lancer: flutter run" -ForegroundColor Cyan
Write-Host ""
Write-Host "OU depuis Android Studio:" -ForegroundColor Yellow
Write-Host "1. Fermez l'application" -ForegroundColor White
Write-Host "2. Fermez l'emulateur" -ForegroundColor White
Write-Host "3. Redemarrez l'emulateur" -ForegroundColor White
Write-Host "4. Cliquez sur 'Run' (F5)" -ForegroundColor White
Write-Host ""
Write-Host "La reconstruction complete est necessaire pour que" -ForegroundColor Yellow
Write-Host "la configuration Android (network_security_config.xml)" -ForegroundColor Yellow
Write-Host "soit prise en compte!" -ForegroundColor Yellow
Write-Host ""

Set-Location ..










