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

$salles = [
    ['id' => 1, 'nom' => 'Salle A1', 'capacite' => 30, 'disponible' => true],
    ['id' => 2, 'nom' => 'Salle B2', 'capacite' => 50, 'disponible' => true],
    ['id' => 3, 'nom' => 'Amphi Principal', 'capacite' => 200, 'disponible' => false],
];

echo json_encode([
    'success' => true,
    'data' => $salles,
    'count' => count($salles)
], JSON_UNESCAPED_UNICODE);
?>
'@ | Out-File -FilePath "C:\wamp64\www\api\salles\list.php" -Encoding UTF8