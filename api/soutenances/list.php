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

$soutenances = [
    [
        'id' => 1,
        'date' => '2024-12-15 10:00:00',
        'memoire_id' => 1,
        'salle_id' => 1,
        'jury' => ['Prof. Smith', 'Prof. Johnson']
    ],
    [
        'id' => 2,
        'date' => '2024-12-16 14:00:00',
        'memoire_id' => 2,
        'salle_id' => 2,
        'jury' => ['Prof. Brown', 'Prof. Davis']
    ],
];

echo json_encode([
    'success' => true,
    'data' => $soutenances,
    'count' => count($soutenances)
], JSON_UNESCAPED_UNICODE);
?>
'@ | Out-File -FilePath "C:\wamp64\www\api\soutenances\list.php" -Encoding UTF8