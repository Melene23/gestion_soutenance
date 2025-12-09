# Script pour executer tous les tests API
# Usage: .\executer_tous_tests.ps1

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Execution de tous les tests API" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$baseUrl = "http://localhost/gestsoutenance/api/test"
$allTestsPassed = $true
$testResults = @()

# Liste des tests a executer
$tests = @(
    @{
        Name = "Test de Configuration Generale"
        Url = "$baseUrl/test_config.php"
        File = "test_config.php"
    },
    @{
        Name = "Test de Base de Donnees"
        Url = "$baseUrl/test_database.php"
        File = "test_database.php"
    },
    @{
        Name = "Test d'Inscription"
        Url = "$baseUrl/test_register.php"
        File = "test_register.php"
    },
    @{
        Name = "Test HTTP de l'Endpoint"
        Url = "$baseUrl/test_register_endpoint.php"
        File = "test_register_endpoint.php"
    }
)

Write-Host "Verification de l'accessibilite des tests..." -ForegroundColor Cyan
Write-Host ""

foreach ($test in $tests) {
    Write-Host "Test: $($test.Name)" -ForegroundColor Yellow
    Write-Host "   URL: $($test.Url)" -ForegroundColor Gray
    
    try {
        $response = Invoke-WebRequest -Uri $test.Url -UseBasicParsing -TimeoutSec 10 -ErrorAction Stop
        $content = $response.Content
        
        # Essayer de parser le JSON
        try {
            $json = $content | ConvertFrom-Json
            
            if ($json.summary) {
                $status = if ($json.summary.all_passed -or ($json.summary.errors -eq 0)) { "SUCCESS" } else { "FAILED" }
                $successCount = $json.summary.success
                $errorCount = $json.summary.errors
                $totalCount = $json.summary.total
                
                $color = if ($json.summary.all_passed -or ($json.summary.errors -eq 0)) { "Green" } else { "Red" }
                Write-Host "   $status" -ForegroundColor $color
                Write-Host "   Resultats: $successCount/$totalCount reussis, $errorCount erreurs" -ForegroundColor Gray
                
                if ($errorCount -gt 0) {
                    $allTestsPassed = $false
                    Write-Host "   Des erreurs ont ete detectees" -ForegroundColor Red
                }
            } else {
                # Verifier les statuts individuels
                $hasErrors = $false
                if ($json.tests) {
                    foreach ($testItem in $json.tests.PSObject.Properties) {
                        if ($testItem.Value.status -eq "error") {
                            $hasErrors = $true
                            break
                        }
                    }
                }
                
                if ($hasErrors) {
                    Write-Host "   FAILED - Erreurs detectees" -ForegroundColor Red
                    $allTestsPassed = $false
                } else {
                    Write-Host "   SUCCESS" -ForegroundColor Green
                }
            }
            
            $testResults += @{
                Name = $test.Name
                Status = if ($json.summary.all_passed -or ($json.summary.errors -eq 0)) { "PASSED" } else { "FAILED" }
                Success = $json.summary.success
                Errors = $json.summary.errors
                Total = $json.summary.total
            }
        } catch {
            Write-Host "   Reponse recue mais format JSON invalide" -ForegroundColor Yellow
            $preview = if ($content.Length -gt 200) { $content.Substring(0, 200) } else { $content }
            Write-Host "   Contenu: $preview" -ForegroundColor Gray
            $allTestsPassed = $false
        }
    } catch {
        Write-Host "   ERREUR: Impossible d'acceder au test" -ForegroundColor Red
        Write-Host "   Message: $($_.Exception.Message)" -ForegroundColor Red
        $allTestsPassed = $false
        
        $testResults += @{
            Name = $test.Name
            Status = "ERROR"
            Success = 0
            Errors = 1
            Total = 0
        }
    }
    
    Write-Host ""
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Resume des Tests" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$totalTests = $testResults.Count
$passedTests = ($testResults | Where-Object { $_.Status -eq "PASSED" }).Count
$failedTests = ($testResults | Where-Object { $_.Status -ne "PASSED" }).Count

Write-Host "Total de tests: $totalTests" -ForegroundColor Cyan
Write-Host "Tests reussis: $passedTests" -ForegroundColor Green
Write-Host "Tests echoues: $failedTests" -ForegroundColor $(if ($failedTests -eq 0) { "Green" } else { "Red" })
Write-Host ""

if ($allTestsPassed -and $failedTests -eq 0) {
    Write-Host "TOUS LES TESTS SONT PASSES!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Vous pouvez maintenant nettoyer les fichiers inutiles." -ForegroundColor Cyan
    Write-Host "Executez: .\nettoyer_fichiers_inutiles.ps1" -ForegroundColor Yellow
    exit 0
} else {
    Write-Host "CERTAINS TESTS ONT ECHOUE" -ForegroundColor Red
    Write-Host ""
    Write-Host "Veuillez corriger les erreurs avant de nettoyer les fichiers." -ForegroundColor Yellow
    exit 1
}
