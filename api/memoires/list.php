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

$memoires = [
    ['id' => 1, 'titre' => 'IA et Éducation', 'etudiant_id' => 1, 'annee' => '2024'],
    ['id' => 2, 'titre' => 'Cybersécurité', 'etudiant_id' => 2, 'annee' => '2024'],
    ['id' => 3, 'titre' => 'DevOps', 'etudiant_id' => 3, 'annee' => '2023'],
];

echo json_encode([
    'success' => true,
    'data' => $memoires,
    'count' => count($memoires)
], JSON_UNESCAPED_UNICODE);
?>
'@ | Out-File -FilePath "C:\wamp64\www\api\memoires\list.php" -Encoding UTF8