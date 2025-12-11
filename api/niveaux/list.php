# Mettre à jour le fichier niveaux avec les vraies données
@'
<?php
// Headers CORS essentiels
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=utf-8");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");

// Gérer les requêtes OPTIONS (preflight)
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Données de niveaux réels
$niveaux = [
    ['id' => 1, 'nom' => 'Licence 2 (L2)', 'code' => 'L2'],
    ['id' => 2, 'nom' => 'Licence 3 (L3)', 'code' => 'L3'],
    ['id' => 3, 'nom' => 'Master 2 (M2)', 'code' => 'M2'],
];

// Réponse JSON
echo json_encode([
    'success' => true,
    'message' => 'Liste des niveaux récupérée avec succès',
    'data' => $niveaux,
    'count' => count($niveaux),
    'timestamp' => date('Y-m-d H:i:s')
], JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT);
?>
'@ | Out-File -FilePath "C:\wamp64\www\api\niveaux\list.php" -Encoding UTF8 -Force

Write-Host "✅ Fichier niveaux/list.php MIS À JOUR avec les vrais niveaux" -ForegroundColor Green