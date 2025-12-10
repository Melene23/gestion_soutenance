<?php
/**
 * Script de test pour vérifier la connexion à la base de données
 * Accès: http://localhost/gestsoutenance/api/test/test_database.php
 */

require_once '../config/database.php';

header('Content-Type: application/json; charset=utf-8');

$results = [
    'timestamp' => date('Y-m-d H:i:s'),
    'tests' => []
];

// Test 1: Vérifier les constantes de configuration
$results['tests']['config'] = [
    'name' => 'Configuration de la base de données',
    'status' => 'success',
    'details' => [
        'DB_HOST' => DB_HOST,
        'DB_USER' => DB_USER,
        'DB_NAME' => DB_NAME,
        'DB_PASS' => DB_PASS ? '***' : '(vide)'
    ]
];

// Test 2: Tester la connexion MySQL
try {
    $conn = getConnection();
    
    if ($conn) {
        $results['tests']['connection'] = [
            'name' => 'Connexion MySQL',
            'status' => 'success',
            'details' => [
                'host_info' => $conn->host_info,
                'server_info' => $conn->server_info,
                'charset' => $conn->character_set_name()
            ]
        ];
    } else {
        $results['tests']['connection'] = [
            'name' => 'Connexion MySQL',
            'status' => 'error',
            'message' => 'Impossible de se connecter à la base de données'
        ];
    }
} catch (Exception $e) {
    $results['tests']['connection'] = [
        'name' => 'Connexion MySQL',
        'status' => 'error',
        'message' => $e->getMessage()
    ];
}

// Test 3: Vérifier si la base de données existe
if (isset($conn) && $conn) {
    try {
        $result = $conn->query("SELECT DATABASE() as db_name");
        if ($result) {
            $row = $result->fetch_assoc();
            $results['tests']['database_exists'] = [
                'name' => 'Base de données',
                'status' => 'success',
                'details' => [
                    'database' => $row['db_name']
                ]
            ];
        }
    } catch (Exception $e) {
        $results['tests']['database_exists'] = [
            'name' => 'Base de données',
            'status' => 'error',
            'message' => $e->getMessage()
        ];
    }
}

// Test 4: Vérifier si la table utilisateurs existe
if (isset($conn) && $conn) {
    try {
        $result = $conn->query("SHOW TABLES LIKE 'utilisateurs'");
        if ($result && $result->num_rows > 0) {
            $results['tests']['table_utilisateurs'] = [
                'name' => 'Table utilisateurs',
                'status' => 'success',
                'message' => 'La table utilisateurs existe'
            ];
            
            // Vérifier la structure de la table
            $result = $conn->query("DESCRIBE utilisateurs");
            $columns = [];
            while ($row = $result->fetch_assoc()) {
                $columns[] = $row;
            }
            $results['tests']['table_utilisateurs']['details'] = [
                'columns' => $columns
            ];
        } else {
            $results['tests']['table_utilisateurs'] = [
                'name' => 'Table utilisateurs',
                'status' => 'error',
                'message' => 'La table utilisateurs n\'existe pas. Exécutez le script schema.sql'
            ];
        }
    } catch (Exception $e) {
        $results['tests']['table_utilisateurs'] = [
            'name' => 'Table utilisateurs',
            'status' => 'error',
            'message' => $e->getMessage()
        ];
    }
}

// Test 5: Compter les utilisateurs existants
if (isset($conn) && $conn) {
    try {
        $result = $conn->query("SELECT COUNT(*) as count FROM utilisateurs");
        if ($result) {
            $row = $result->fetch_assoc();
            $results['tests']['user_count'] = [
                'name' => 'Nombre d\'utilisateurs',
                'status' => 'success',
                'details' => [
                    'count' => (int)$row['count']
                ]
            ];
        }
    } catch (Exception $e) {
        $results['tests']['user_count'] = [
            'name' => 'Nombre d\'utilisateurs',
            'status' => 'error',
            'message' => $e->getMessage()
        ];
    }
}

// Test 6: Tester une requête INSERT (simulation)
if (isset($conn) && $conn) {
    try {
        $testEmail = 'test_' . time() . '@test.com';
        $stmt = $conn->prepare("SELECT id FROM utilisateurs WHERE email = ?");
        $stmt->bind_param("s", $testEmail);
        $stmt->execute();
        $result = $stmt->get_result();
        
        $results['tests']['query_test'] = [
            'name' => 'Test de requête préparée',
            'status' => 'success',
            'message' => 'Les requêtes préparées fonctionnent correctement'
        ];
        $stmt->close();
    } catch (Exception $e) {
        $results['tests']['query_test'] = [
            'name' => 'Test de requête préparée',
            'status' => 'error',
            'message' => $e->getMessage()
        ];
    }
}

// Fermer la connexion
if (isset($conn) && $conn) {
    $conn->close();
}

// Calculer le résumé
$totalTests = count($results['tests']);
$successTests = 0;
$errorTests = 0;

foreach ($results['tests'] as $test) {
    if ($test['status'] === 'success') {
        $successTests++;
    } else {
        $errorTests++;
    }
}

$results['summary'] = [
    'total' => $totalTests,
    'success' => $successTests,
    'errors' => $errorTests,
    'all_passed' => $errorTests === 0
];

// Afficher les résultats
echo json_encode($results, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
?>


