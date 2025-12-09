<?php
/**
 * Script de test pour tester l'endpoint d'inscription avec une vraie requête
 * Accès: http://localhost/gestsoutenance/api/test/test_register_endpoint.php
 */

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');

$results = [
    'timestamp' => date('Y-m-d H:i:s'),
    'tests' => []
];

// Fonction pour faire une requête HTTP POST sans cURL
function httpPost($url, $data, $timeout = 10) {
    $options = [
        'http' => [
            'method' => 'POST',
            'header' => [
                'Content-Type: application/json',
                'Accept: application/json'
            ],
            'content' => json_encode($data),
            'timeout' => $timeout,
            'ignore_errors' => true
        ]
    ];
    
    $context = stream_context_create($options);
    $response = @file_get_contents($url, false, $context);
    
    // Récupérer le code HTTP depuis les headers
    $httpCode = 500;
    if (isset($http_response_header)) {
        if (preg_match('/HTTP\/\d\.\d\s+(\d+)/', $http_response_header[0], $matches)) {
            $httpCode = (int)$matches[1];
        }
    }
    
    return [
        'body' => $response,
        'http_code' => $httpCode,
        'error' => $response === false ? 'Erreur lors de la requête HTTP' : null
    ];
}

// Fonction pour vérifier si un endpoint est accessible
function checkEndpointAccessible($url) {
    $options = [
        'http' => [
            'method' => 'HEAD',
            'timeout' => 5,
            'ignore_errors' => true
        ]
    ];
    
    $context = stream_context_create($options);
    $response = @file_get_contents($url, false, $context);
    
    $httpCode = 500;
    if (isset($http_response_header)) {
        if (preg_match('/HTTP\/\d\.\d\s+(\d+)/', $http_response_header[0], $matches)) {
            $httpCode = (int)$matches[1];
        }
    }
    
    return [
        'http_code' => $httpCode,
        'accessible' => $response !== false || $httpCode < 500
    ];
}

// URL de l'endpoint d'inscription
$baseUrl = 'http://' . ($_SERVER['HTTP_HOST'] ?? 'localhost');
$registerUrl = $baseUrl . '/gestsoutenance/api/auth/register.php';

$results['endpoint_info'] = [
    'url' => $registerUrl,
    'method' => 'POST',
    'curl_available' => function_exists('curl_init'),
    'using_alternative' => !function_exists('curl_init')
];

// Test 1: Vérifier que l'endpoint est accessible
$accessCheck = checkEndpointAccessible($registerUrl);

if ($accessCheck['accessible']) {
    $results['tests']['endpoint_accessible'] = [
        'name' => 'Accessibilité de l\'endpoint',
        'status' => 'success',
        'message' => 'L\'endpoint est accessible',
        'details' => [
            'http_code' => $accessCheck['http_code'],
            'url' => $registerUrl
        ]
    ];
} else {
    $results['tests']['endpoint_accessible'] = [
        'name' => 'Accessibilité de l\'endpoint',
        'status' => 'error',
        'message' => 'Impossible d\'accéder à l\'endpoint',
        'details' => [
            'http_code' => $accessCheck['http_code'],
            'url' => $registerUrl
        ]
    ];
}

// Test 2: Tester avec des données valides (mais email unique)
$testData = [
    'nom' => 'Test',
    'prenom' => 'User',
    'email' => 'test_' . time() . '@example.com',
    'password' => 'password123'
];

$response = httpPost($registerUrl, $testData);

if ($response['error']) {
    $results['tests']['valid_request'] = [
        'name' => 'Requête avec données valides',
        'status' => 'error',
        'message' => 'Erreur HTTP: ' . $response['error']
    ];
} else {
    $responseData = json_decode($response['body'], true);
    
    if (($response['http_code'] == 201 || $response['http_code'] == 200) && isset($responseData['success']) && $responseData['success']) {
        $results['tests']['valid_request'] = [
            'name' => 'Requête avec données valides',
            'status' => 'success',
            'message' => 'L\'inscription fonctionne correctement',
            'details' => [
                'http_code' => $response['http_code'],
                'response' => $responseData
            ]
        ];
    } else {
        $results['tests']['valid_request'] = [
            'name' => 'Requête avec données valides',
            'status' => 'error',
            'message' => 'L\'inscription a échoué',
            'details' => [
                'http_code' => $response['http_code'],
                'response' => $responseData
            ]
        ];
    }
}

// Test 3: Tester avec des données invalides (email manquant)
$invalidData = [
    'nom' => 'Test',
    'prenom' => 'User',
    'password' => 'password123'
];

$response = httpPost($registerUrl, $invalidData);
$responseData = json_decode($response['body'], true);
$httpCode = $response['http_code'];

if ($httpCode == 400 && isset($responseData['success']) && !$responseData['success']) {
    $results['tests']['invalid_request'] = [
        'name' => 'Validation des données invalides',
        'status' => 'success',
        'message' => 'La validation fonctionne correctement (rejette les données invalides)',
        'details' => [
            'http_code' => $httpCode,
            'response' => $responseData
        ]
    ];
} else {
    $results['tests']['invalid_request'] = [
        'name' => 'Validation des données invalides',
        'status' => 'warning',
        'message' => 'La validation pourrait ne pas fonctionner correctement',
        'details' => [
            'http_code' => $httpCode,
            'response' => $responseData
        ]
    ];
}

// Test 4: Tester avec un email déjà utilisé
// D'abord, créer un utilisateur
$existingEmail = 'existing_' . time() . '@example.com';
$firstUserData = [
    'nom' => 'Existing',
    'prenom' => 'User',
    'email' => $existingEmail,
    'password' => 'password123'
];

// Créer le premier utilisateur
httpPost($registerUrl, $firstUserData);

// Maintenant, essayer de créer un autre utilisateur avec le même email
$duplicateData = [
    'nom' => 'Duplicate',
    'prenom' => 'User',
    'email' => $existingEmail,
    'password' => 'password123'
];

$response = httpPost($registerUrl, $duplicateData);
$responseData = json_decode($response['body'], true);
$httpCode = $response['http_code'];

if ($httpCode == 409 && isset($responseData['success']) && !$responseData['success']) {
    $results['tests']['duplicate_email'] = [
        'name' => 'Détection d\'email dupliqué',
        'status' => 'success',
        'message' => 'La détection d\'email dupliqué fonctionne correctement',
        'details' => [
            'http_code' => $httpCode,
            'response' => $responseData
        ]
    ];
} else {
    $results['tests']['duplicate_email'] = [
        'name' => 'Détection d\'email dupliqué',
        'status' => 'warning',
        'message' => 'La détection d\'email dupliqué pourrait ne pas fonctionner',
        'details' => [
            'http_code' => $httpCode,
            'response' => $responseData
        ]
    ];
}

// Test 5: Tester avec un mot de passe trop court
$shortPasswordData = [
    'nom' => 'Test',
    'prenom' => 'User',
    'email' => 'shortpass_' . time() . '@example.com',
    'password' => '12345' // Moins de 6 caractères
];

$response = httpPost($registerUrl, $shortPasswordData);
$responseData = json_decode($response['body'], true);
$httpCode = $response['http_code'];

if ($httpCode == 400 && isset($responseData['success']) && !$responseData['success']) {
    $results['tests']['password_validation'] = [
        'name' => 'Validation du mot de passe',
        'status' => 'success',
        'message' => 'La validation de la longueur du mot de passe fonctionne',
        'details' => [
            'http_code' => $httpCode,
            'response' => $responseData
        ]
    ];
} else {
    $results['tests']['password_validation'] = [
        'name' => 'Validation du mot de passe',
        'status' => 'warning',
        'message' => 'La validation de la longueur du mot de passe pourrait ne pas fonctionner',
        'details' => [
            'http_code' => $httpCode,
            'response' => $responseData
        ]
    ];
}

// Calculer le résumé
$totalTests = count($results['tests']);
$successTests = 0;
$errorTests = 0;
$warningTests = 0;

foreach ($results['tests'] as $test) {
    if ($test['status'] === 'success') {
        $successTests++;
    } elseif ($test['status'] === 'error') {
        $errorTests++;
    } else {
        $warningTests++;
    }
}

$results['summary'] = [
    'total' => $totalTests,
    'success' => $successTests,
    'errors' => $errorTests,
    'warnings' => $warningTests,
    'all_passed' => $errorTests === 0
];

// Afficher les résultats
echo json_encode($results, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
?>

