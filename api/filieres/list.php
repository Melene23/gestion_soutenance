# Mettre à jour le fichier filières avec les vraies données
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

// Données de filières réelles
$filieres = [
    ['id' => 1, 'nom' => 'Informatique de gestion', 'code' => 'INFO_GEST'],
    ['id' => 2, 'nom' => 'Planification des projets', 'code' => 'PLAN_PROJ'],
    ['id' => 3, 'nom' => 'Gestion de Banque et Assurance', 'code' => 'BANQUE_ASS'],
    ['id' => 4, 'nom' => 'Gestion Commerciale', 'code' => 'GEST_COM'],
    ['id' => 5, 'nom' => 'Gestion des Transports & Logistiques', 'code' => 'TRANS_LOG'],
    ['id' => 6, 'nom' => 'Gestion des Ressources Humaines (GRH)', 'code' => 'GRH'],
    ['id' => 7, 'nom' => 'Statistiques', 'code' => 'STAT'],
];

// Réponse JSON
echo json_encode([
    'success' => true,
    'message' => 'Liste des filières récupérée avec succès',
    'data' => $filieres,
    'count' => count($filieres),
    'timestamp' => date('Y-m-d H:i:s')
], JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT);
?>
'@ | Out-File -FilePath "C:\wamp64\www\api\filieres\list.php" -Encoding UTF8 -Force

Write-Host "✅ Fichier filières/list.php MIS À JOUR avec les vraies filières" -ForegroundColor Green