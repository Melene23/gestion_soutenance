# Script pour nettoyer les fichiers inutiles du projet
# Usage: .\nettoyer_fichiers_inutiles.ps1

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Nettoyage des fichiers inutiles" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Fichiers a supprimer (scripts de test temporaires)
$filesToDelete = @(
    "test_api.ps1",
    "test_final.ps1",
    "test_login_detailed.ps1",
    "test_login.ps1",
    "executer_tous_tests.ps1",
    "copier_tests_api.ps1",
    "nettoyer_fichiers_inutiles.ps1"
)

# Fichiers de documentation redondants a supprimer
$docsToDelete = @(
    "RESULTAT_TEST.md",
    "CONFIGURATION_API.md",
    "INSTALLATION.md",
    "README_API.md",
    "INSTRUCTIONS_TESTS.md",
    "RESUME_TESTS_API.md",
    "ACTIVER_CURL.md",
    "SOLUTION_ADMIN.md"
)

$deletedCount = 0
$skippedCount = 0

Write-Host "Suppression des scripts de test temporaires..." -ForegroundColor Yellow
Write-Host ""

foreach ($file in $filesToDelete) {
    $filePath = Join-Path $PSScriptRoot $file
    if (Test-Path $filePath) {
        try {
            Remove-Item -Path $filePath -Force
            Write-Host "   Supprime: $file" -ForegroundColor Green
            $deletedCount++
        } catch {
            Write-Host "   Erreur lors de la suppression de $file : $_" -ForegroundColor Red
            $skippedCount++
        }
    } else {
        Write-Host "   Non trouve: $file" -ForegroundColor Gray
    }
}

Write-Host ""
Write-Host "Suppression des fichiers de documentation redondants..." -ForegroundColor Yellow
Write-Host ""

foreach ($file in $docsToDelete) {
    $filePath = Join-Path $PSScriptRoot $file
    if (Test-Path $filePath) {
        try {
            Remove-Item -Path $filePath -Force
            Write-Host "   Supprime: $file" -ForegroundColor Green
            $deletedCount++
        } catch {
            Write-Host "   Erreur lors de la suppression de $file : $_" -ForegroundColor Red
            $skippedCount++
        }
    } else {
        Write-Host "   Non trouve: $file" -ForegroundColor Gray
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Resume du Nettoyage" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Fichiers supprimes: $deletedCount" -ForegroundColor Green
if ($skippedCount -gt 0) {
    Write-Host "Fichiers ignores: $skippedCount" -ForegroundColor Yellow
}
Write-Host ""

Write-Host "Nettoyage termine!" -ForegroundColor Green
Write-Host ""
Write-Host "Note: Les fichiers de test dans api/test/ sont conserves" -ForegroundColor Cyan
Write-Host "   car ils peuvent etre utiles pour le debogage." -ForegroundColor Cyan
Write-Host "   Vous pouvez les supprimer manuellement si necessaire." -ForegroundColor Cyan
Write-Host ""
