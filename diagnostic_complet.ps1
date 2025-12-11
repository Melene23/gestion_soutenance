# Diagnostic complet pour identifier le probleme de connexion
# Usage: .\diagnostic_complet.ps1

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  DIAGNOSTIC COMPLET" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$errors = @()

# Test 1: Verifier Apache
Write-Host "1. Verification d'Apache..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost" -UseBasicParsing -TimeoutSec 3 -ErrorAction Stop
    Write-Host "   [OK] Apache est demarre et repond" -ForegroundColor Green
} catch {
    $errors += "Apache ne repond pas sur localhost"
    Write-Host "   [ERREUR] Apache ne repond pas!" -ForegroundColor Red
    Write-Host "   Demarrez Apache dans XAMPP Control Panel" -ForegroundColor Yellow
}
Write-Host ""

# Test 2: Verifier que les fichiers sont dans htdocs
Write-Host "2. Verification des fichiers dans htdocs..." -ForegroundColor Yellow
$htdocsPath = "C:\xampp\htdocs\gestsoutenance\api\auth\register.php"
if (Test-Path $htdocsPath) {
    Write-Host "   [OK] Fichiers API presents dans htdocs" -ForegroundColor Green
} else {
    $errors += "Les fichiers API ne sont pas dans htdocs"
    Write-Host "   [ERREUR] Fichiers manquants dans htdocs!" -ForegroundColor Red
    Write-Host "   Chemin attendu: $htdocsPath" -ForegroundColor Yellow
    Write-Host "   Copiez les fichiers de api/ vers C:\xampp\htdocs\gestsoutenance\api\" -ForegroundColor Yellow
}
Write-Host ""

# Test 3: Tester l'endpoint directement
Write-Host "3. Test de l'endpoint d'inscription..." -ForegroundColor Yellow
$testUrl = "http://localhost/gestsoutenance/api/auth/register.php"
try {
    $testData = @{
        nom = "Test"
        prenom = "User"
        email = "test_$(Get-Date -Format 'yyyyMMddHHmmss')@example.com"
        password = "password123"
    } | ConvertTo-Json

    $response = Invoke-WebRequest -Uri $testUrl -Method POST -Body $testData -ContentType "application/json" -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
    
    if ($response.StatusCode -eq 201 -or $response.StatusCode -eq 200) {
        Write-Host "   [OK] L'endpoint repond correctement" -ForegroundColor Green
        try {
            $json = $response.Content | ConvertFrom-Json
            if ($json.success) {
                Write-Host "   [OK] L'inscription fonctionne depuis le navigateur" -ForegroundColor Green
            } else {
                Write-Host "   [ATTENTION] Reponse: $($json.message)" -ForegroundColor Yellow
            }
        } catch {
            Write-Host "   [ATTENTION] Reponse non-JSON: $($response.Content.Substring(0, [Math]::Min(100, $response.Content.Length)))" -ForegroundColor Yellow
        }
    } else {
        $errors += "L'endpoint retourne le code: $($response.StatusCode)"
        Write-Host "   [ERREUR] Code HTTP: $($response.StatusCode)" -ForegroundColor Red
    }
} catch {
    $errors += "Impossible d'acceder a l'endpoint: $($_.Exception.Message)"
    Write-Host "   [ERREUR] Impossible d'acceder a l'endpoint" -ForegroundColor Red
    Write-Host "   URL testee: $testUrl" -ForegroundColor Gray
    Write-Host "   Message: $($_.Exception.Message)" -ForegroundColor Red
    
    # Verifier si c'est un probleme de chemin
    Write-Host ""
    Write-Host "   Verification des chemins alternatifs..." -ForegroundColor Yellow
    $alternatives = @(
        "http://localhost/gestsoutenance/api/auth/register.php",
        "http://localhost/api/auth/register.php",
        "http://127.0.0.1/gestsoutenance/api/auth/register.php"
    )
    
    foreach ($alt in $alternatives) {
        try {
            $test = Invoke-WebRequest -Uri $alt -Method GET -UseBasicParsing -TimeoutSec 2 -ErrorAction Stop
            Write-Host "   [OK] Cette URL fonctionne: $alt" -ForegroundColor Green
        } catch {
            # Ignorer les erreurs pour les alternatives
        }
    }
}
Write-Host ""

# Test 4: Verifier la configuration Flutter
Write-Host "4. Verification de la configuration Flutter..." -ForegroundColor Yellow
$apiConfig = "gestsoutenance\lib\core\constants\api_config.dart"
if (Test-Path $apiConfig) {
    $content = Get-Content $apiConfig -Raw
    if ($content -match "10\.0\.2\.2/gestsoutenance/api/") {
        Write-Host "   [OK] URL configuree correctement pour emulateur" -ForegroundColor Green
        Write-Host "   URL: http://10.0.2.2/gestsoutenance/api/" -ForegroundColor Gray
    } elseif ($content -match "10\.0\.2\.2") {
        Write-Host "   [ATTENTION] URL peut ne pas etre complete" -ForegroundColor Yellow
        $match = [regex]::Match($content, "baseUrl = '([^']+)'")
        if ($match.Success) {
            Write-Host "   URL actuelle: $($match.Groups[1].Value)" -ForegroundColor Gray
        }
    } else {
        $errors += "URL API peut ne pas etre correcte"
        Write-Host "   [ERREUR] URL peut ne pas etre correcte" -ForegroundColor Red
    }
} else {
    $errors += "Fichier api_config.dart manquant"
    Write-Host "   [ERREUR] Fichier manquant!" -ForegroundColor Red
}
Write-Host ""

# Test 5: Verifier la configuration Android
Write-Host "5. Verification de la configuration Android..." -ForegroundColor Yellow
$networkConfig = "gestsoutenance\android\app\src\main\res\xml\network_security_config.xml"
$manifest = "gestsoutenance\android\app\src\main\AndroidManifest.xml"

if (Test-Path $networkConfig) {
    Write-Host "   [OK] network_security_config.xml existe" -ForegroundColor Green
    $configContent = Get-Content $networkConfig -Raw
    if ($configContent -match "10\.0\.2\.2") {
        Write-Host "   [OK] Configuration autorise 10.0.2.2" -ForegroundColor Green
    } else {
        $errors += "network_security_config.xml ne contient pas 10.0.2.2"
        Write-Host "   [ERREUR] Configuration incomplete!" -ForegroundColor Red
    }
} else {
    $errors += "network_security_config.xml manquant"
    Write-Host "   [ERREUR] Fichier manquant!" -ForegroundColor Red
}

if (Test-Path $manifest) {
    $manifestContent = Get-Content $manifest -Raw
    if ($manifestContent -match "usesCleartextTraffic.*true" -and $manifestContent -match "networkSecurityConfig") {
        Write-Host "   [OK] AndroidManifest.xml configure correctement" -ForegroundColor Green
    } else {
        $errors += "AndroidManifest.xml mal configure"
        Write-Host "   [ERREUR] Configuration incomplete!" -ForegroundColor Red
    }
} else {
    $errors += "AndroidManifest.xml manquant"
    Write-Host "   [ERREUR] Fichier manquant!" -ForegroundColor Red
}
Write-Host ""

# Test 6: Verifier la base de donnees
Write-Host "6. Verification de la base de donnees..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost/gestsoutenance/api/test/test_database.php" -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
    $content = $response.Content
    try {
        $json = $content | ConvertFrom-Json
        if ($json.summary.all_passed) {
            Write-Host "   [OK] Base de donnees fonctionne correctement" -ForegroundColor Green
        } else {
            $warnings = @()
            foreach ($test in $json.tests.PSObject.Properties) {
                if ($test.Value.status -eq "error") {
                    $warnings += "$($test.Value.name): $($test.Value.message)"
                }
            }
            if ($warnings.Count -gt 0) {
                Write-Host "   [ATTENTION] Problemes detectes:" -ForegroundColor Yellow
                foreach ($w in $warnings) {
                    Write-Host "      - $w" -ForegroundColor Yellow
                }
            }
        }
    } catch {
        Write-Host "   [ATTENTION] Reponse non-JSON" -ForegroundColor Yellow
    }
} catch {
    Write-Host "   [ATTENTION] Impossible de tester la base de donnees" -ForegroundColor Yellow
}
Write-Host ""

# Resume
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  RESUME ET SOLUTIONS" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

if ($errors.Count -eq 0) {
    Write-Host "Aucune erreur critique detectee!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Le probleme peut etre:" -ForegroundColor Yellow
    Write-Host "1. L'application n'a pas ete reconstruite apres les modifications" -ForegroundColor White
    Write-Host "   Solution: cd gestsoutenance && flutter clean && flutter run" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "2. L'emulateur ne peut pas acceder a 10.0.2.2" -ForegroundColor White
    Write-Host "   Solution: Redemarrez l'emulateur" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "3. Le cache Flutter est corrompu" -ForegroundColor White
    Write-Host "   Solution: flutter clean && flutter pub get && flutter run" -ForegroundColor Cyan
} else {
    Write-Host "Erreurs detectees:" -ForegroundColor Red
    foreach ($error in $errors) {
        Write-Host "  - $error" -ForegroundColor Red
    }
    Write-Host ""
    Write-Host "Corrigez ces erreurs avant de continuer." -ForegroundColor Yellow
}

Write-Host ""










