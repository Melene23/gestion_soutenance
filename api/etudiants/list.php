@'
<?php
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Simuler des données d'étudiants
$etudiants = [
    ['id' => 1, 'nom' => 'Dupont', 'prenom' => 'Jean', 'matricule' => 'ET001'],
    ['id' => 2, 'nom' => 'Martin', 'prenom' => 'Marie', 'matricule' => 'ET002'],
    ['id' => 3, 'nom' => 'Dubois', 'prenom' => 'Pierre', 'matricule' => 'ET003'],
];

echo json_encode([
    'success' => true,
    'data' => $etudiants,
    'count' => count($etudiants)
], JSON_UNESCAPED_UNICODE);
?>
'@ | Out-File -FilePath "C:\wamp64\www\api\etudiants\list.php" -Encoding UTF8