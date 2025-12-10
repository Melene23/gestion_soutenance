# Script pour reconstruire completement l'application Flutter
# Usage: .\reconstruire_app.ps1

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  RECONSTRUCTION COMPLETE" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Set-Location gestsoutenance

# 1. Nettoyer completement
Write-Host "1. Nettoyage complet..." -ForegroundColor Yellow
flutter clean
Remove-Item -Path "build" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path ".dart_tool" -Recurse -Force -ErrorAction SilentlyContinue
Write-Host "   [OK] Nettoyage termine" -ForegroundColor Green
Write-Host ""

# 2. Recuperer les dependances
Write-Host "2. Recuperation des dependances..." -ForegroundColor Yellow
flutter pub get
Write-Host "   [OK] Dependances recuperees" -ForegroundColor Green
Write-Host ""

# 3. Verifier la configuration
Write-Host "3. Verification de la configuration..." -ForegroundColor Yellow
flutter doctor
Write-Host ""

# 4. Instructions
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  INSTRUCTIONS" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Maintenant, lancez l'application:" -ForegroundColor Yellow
Write-Host ""
Write-Host "  flutter run" -ForegroundColor Cyan
Write-Host ""
Write-Host "OU si vous utilisez Android Studio:" -ForegroundColor Yellow
Write-Host "  1. Fermez completement l'application si elle tourne" -ForegroundColor White
Write-Host "  2. Cliquez sur 'Run' (ou F5)" -ForegroundColor White
Write-Host "  3. Attendez que l'application se reconstruise completement" -ForegroundColor White
Write-Host ""
Write-Host "Si le probleme persiste:" -ForegroundColor Yellow
Write-Host "  1. Fermez completement l'emulateur Android" -ForegroundColor White
Write-Host "  2. Redemarrez l'emulateur" -ForegroundColor White
Write-Host "  3. Relancez: flutter run" -ForegroundColor White
Write-Host ""

Set-Location ..


