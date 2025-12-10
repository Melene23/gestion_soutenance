# Script PowerShell pour copier les fichiers API vers XAMPP
# Exécutez ce script en tant qu'administrateur si nécessaire

$sourceDir = "C:\ENEAM\pratique\Dart\pro_dart\api"
$destDir = "C:\xampp\htdocs\gestsoutenance\api"

Write-Host "Copie des fichiers API vers XAMPP..." -ForegroundColor Yellow
Write-Host "Source: $sourceDir" -ForegroundColor Gray
Write-Host "Destination: $destDir" -ForegroundColor Gray
Write-Host ""

# Vérifier si le dossier source existe
if (-not (Test-Path $sourceDir)) {
    Write-Host "ERREUR: Le dossier source n'existe pas: $sourceDir" -ForegroundColor Red
    exit 1
}

# Créer le dossier de destination s'il n'existe pas
if (-not (Test-Path $destDir)) {
    Write-Host "Création du dossier de destination..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $destDir -Force | Out-Null
}

# Copier tous les fichiers et dossiers
Write-Host "Copie en cours..." -ForegroundColor Yellow
Copy-Item -Path "$sourceDir\*" -Destination $destDir -Recurse -Force

Write-Host ""
Write-Host "Copie terminée avec succès!" -ForegroundColor Green
Write-Host ""
Write-Host "Vérifiez que:" -ForegroundColor Yellow
Write-Host "1. XAMPP est démarré (Apache et MySQL)" -ForegroundColor White
Write-Host "2. Testez l'URL: http://localhost/gestsoutenance/api/test.php" -ForegroundColor White
Write-Host ""

