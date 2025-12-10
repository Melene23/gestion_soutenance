# Script de test complet pour verifier tous les aspects
# Usage: .\test_complet.ps1

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  TEST COMPLET DE L'APPLICATION" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$errors = @()
$warnings = @()

# Test 1: Verifier que Apache est accessible
Write-Host "1. Test de connexion Apache..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost/gestsoutenance/api/test/test_config.php" -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
    if ($response.StatusCode -eq 200) {
        Write-Host "   [OK] Apache est accessible" -ForegroundColor Green
    } else {
        $errors += "Apache retourne le code: $($response.StatusCode)"
        Write-Host "   [ERREUR] Code HTTP: $($response.StatusCode)" -ForegroundColor Red
    }
} catch {
    $errors += "Apache n'est pas accessible: $($_.Exception.Message)"
    Write-Host "   [ERREUR] Apache n'est pas accessible" -ForegroundColor Red
    Write-Host "   Message: $($_.Exception.Message)" -ForegroundColor Red
}
Write-Host ""

# Test 2: Verifier les fichiers API
Write-Host "2. Verification des fichiers API..." -ForegroundColor Yellow
$apiFiles = @(
    "C:\xampp\htdocs\gestsoutenance\api\config\database.php",
    "C:\xampp\htdocs\gestsoutenance\api\auth\register.php",
    "C:\xampp\htdocs\gestsoutenance\api\auth\login.php"
)

foreach ($file in $apiFiles) {
    if (Test-Path $file) {
        Write-Host "   [OK] $(Split-Path $file -Leaf)" -ForegroundColor Green
    } else {
        $errors += "Fichier manquant: $file"
        Write-Host "   [ERREUR] $(Split-Path $file -Leaf) manquant" -ForegroundColor Red
    }
}
Write-Host ""

# Test 3: Tester l'endpoint de configuration
Write-Host "3. Test de l'endpoint de configuration..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost/gestsoutenance/api/test/test_config.php" -UseBasicParsing -TimeoutSec 10 -ErrorAction Stop
    $content = $response.Content
    try {
        $json = $content | ConvertFrom-Json
        if ($json.summary.all_passed) {
            Write-Host "   [OK] Tous les tests de configuration passent" -ForegroundColor Green
        } else {
            $warnings += "Certains tests de configuration ont echoue"
            Write-Host "   [ATTENTION] Certains tests ont echoue" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "   [ATTENTION] Reponse non-JSON" -ForegroundColor Yellow
    }
} catch {
    $errors += "Impossible de tester la configuration: $($_.Exception.Message)"
    Write-Host "   [ERREUR] Impossible de tester" -ForegroundColor Red
}
Write-Host ""

# Test 4: Tester l'endpoint de base de donnees
Write-Host "4. Test de l'endpoint de base de donnees..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost/gestsoutenance/api/test/test_database.php" -UseBasicParsing -TimeoutSec 10 -ErrorAction Stop
    $content = $response.Content
    try {
        $json = $content | ConvertFrom-Json
        if ($json.summary.all_passed) {
            Write-Host "   [OK] Base de donnees fonctionne correctement" -ForegroundColor Green
        } else {
            $errors += "Problemes avec la base de donnees detectes"
            Write-Host "   [ERREUR] Problemes detectes" -ForegroundColor Red
            if ($json.tests) {
                foreach ($test in $json.tests.PSObject.Properties) {
                    if ($test.Value.status -eq "error") {
                        Write-Host "      - $($test.Value.name): $($test.Value.message)" -ForegroundColor Red
                    }
                }
            }
        }
    } catch {
        Write-Host "   [ATTENTION] Reponse non-JSON" -ForegroundColor Yellow
    }
} catch {
    $errors += "Impossible de tester la base de donnees: $($_.Exception.Message)"
    Write-Host "   [ERREUR] Impossible de tester" -ForegroundColor Red
}
Write-Host ""

# Test 5: Tester l'endpoint d'inscription
Write-Host "5. Test de l'endpoint d'inscription..." -ForegroundColor Yellow
try {
    $testData = @{
        nom = "Test"
        prenom = "User"
        email = "test_$(Get-Date -Format 'yyyyMMddHHmmss')@example.com"
        password = "password123"
    } | ConvertTo-Json

    $response = Invoke-WebRequest -Uri "http://localhost/gestsoutenance/api/auth/register.php" -Method POST -Body $testData -ContentType "application/json" -UseBasicParsing -TimeoutSec 10 -ErrorAction Stop
    $content = $response.Content
    try {
        $json = $content | ConvertFrom-Json
        if ($json.success -eq $true) {
            Write-Host "   [OK] L'inscription fonctionne correctement" -ForegroundColor Green
        } else {
            $errors += "L'inscription a echoue: $($json.message)"
            Write-Host "   [ERREUR] $($json.message)" -ForegroundColor Red
        }
    } catch {
        Write-Host "   [ERREUR] Reponse invalide: $content" -ForegroundColor Red
        $errors += "Reponse invalide de l'endpoint d'inscription"
    }
} catch {
    $errors += "Impossible de tester l'inscription: $($_.Exception.Message)"
    Write-Host "   [ERREUR] Impossible de tester: $($_.Exception.Message)" -ForegroundColor Red
}
Write-Host ""

# Test 6: Verifier les fichiers Flutter
Write-Host "6. Verification des fichiers Flutter..." -ForegroundColor Yellow
$flutterFiles = @(
    "gestsoutenance\lib\core\constants\api_config.dart",
    "gestsoutenance\lib\core\services\auth_service.dart",
    "gestsoutenance\android\app\src\main\AndroidManifest.xml",
    "gestsoutenance\android\app\src\main\res\xml\network_security_config.xml"
)

foreach ($file in $flutterFiles) {
    if (Test-Path $file) {
        Write-Host "   [OK] $(Split-Path $file -Leaf)" -ForegroundColor Green
    } else {
        $errors += "Fichier Flutter manquant: $file"
        Write-Host "   [ERREUR] $(Split-Path $file -Leaf) manquant" -ForegroundColor Red
    }
}
Write-Host ""

# Test 7: Verifier la configuration API
Write-Host "7. Verification de la configuration API..." -ForegroundColor Yellow
$apiConfigFile = "gestsoutenance\lib\core\constants\api_config.dart"
if (Test-Path $apiConfigFile) {
    $content = Get-Content $apiConfigFile -Raw
    if ($content -match "10\.0\.2\.2") {
        Write-Host "   [OK] URL configuree pour emulateur Android" -ForegroundColor Green
    } else {
        $warnings += "URL API peut ne pas etre correcte pour l'emulateur"
        Write-Host "   [ATTENTION] URL peut ne pas etre correcte" -ForegroundColor Yellow
    }
} else {
    $errors += "Fichier api_config.dart manquant"
    Write-Host "   [ERREUR] Fichier manquant" -ForegroundColor Red
}
Write-Host ""

# Resume
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  RESUME" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

if ($errors.Count -eq 0) {
    Write-Host "Aucune erreur critique detectee!" -ForegroundColor Green
} else {
    Write-Host "Erreurs detectees: $($errors.Count)" -ForegroundColor Red
    foreach ($error in $errors) {
        Write-Host "  - $error" -ForegroundColor Red
    }
}

if ($warnings.Count -gt 0) {
    Write-Host ""
    Write-Host "Avertissements: $($warnings.Count)" -ForegroundColor Yellow
    foreach ($warning in $warnings) {
        Write-Host "  - $warning" -ForegroundColor Yellow
    }
}

Write-Host ""

# Retourner le code d'erreur
if ($errors.Count -gt 0) {
    exit 1
} else {
    exit 0
}


