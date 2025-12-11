<?php
/**
 * Script de test pour vérifier que l'API fonctionne
 * Accédez à : http://localhost/gestsoutenance/api/test.php
 */

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

// Gérer les requêtes OPTIONS
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

$response = [
    'success' => true,
    'message' => 'API fonctionnelle !',
    'data' => [
        'server' => $_SERVER['SERVER_SOFTWARE'] ?? 'Unknown',
        'php_version' => phpversion(),
        'timestamp' => date('Y-m-d H:i:s'),
        'method' => $_SERVER['REQUEST_METHOD'],
        'path' => $_SERVER['REQUEST_URI'] ?? 'Unknown',
    ]
];

// Test de connexion à la base de données
try {
    require_once 'config/database.php';
    $conn = getConnection();
    
    if ($conn) {
        $response['data']['database'] = [
            'status' => 'connected',
            'host' => DB_HOST,
            'database' => DB_NAME
        ];
        $conn->close();
    }
} catch (Exception $e) {
    $response['data']['database'] = [
        'status' => 'error',
        'message' => $e->getMessage()
    ];
}

echo json_encode($response, JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT);
?>











