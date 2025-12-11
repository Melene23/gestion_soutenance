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

echo json_encode([
    'success' => true,
    'data' => [
        'etudiants' => 3,
        'memoires' => 3,
        'salles' => 3,
        'soutenances' => 2,
        'last_update' => date('Y-m-d H:i:s')
    ]
], JSON_UNESCAPED_UNICODE);
?>
'@ | Out-File -FilePath "C:\wamp64\www\api\metadata\stats.php" -Encoding UTF8