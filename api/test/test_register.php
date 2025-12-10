<?php
/**
 * Script de test pour vérifier l'endpoint d'inscription
 * Accès: http://localhost/gestsoutenance/api/test/test_register.php
 */

require_once '../config/database.php';

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

$results = [
    'timestamp' => date('Y-m-d H:i:s'),
    'tests' => []
];

// Test 1: Vérifier que le fichier register.php existe
$registerFile = '../auth/register.php';
$results['tests']['file_exists'] = [
    'name' => 'Fichier register.php',
    'status' => file_exists($registerFile) ? 'success' : 'error',
    'message' => file_exists($registerFile) 
        ? 'Le fichier register.php existe' 
        : 'Le fichier register.php n\'existe pas',
    'path' => realpath($registerFile) ?: $registerFile
];

// Test 2: Vérifier la connexion à la base de données
try {
    $conn = getConnection();
    $results['tests']['database_connection'] = [
        'name' => 'Connexion à la base de données',
        'status' => 'success',
        'message' => 'Connexion réussie'
    ];
} catch (Exception $e) {
    $results['tests']['database_connection'] = [
        'name' => 'Connexion à la base de données',
        'status' => 'error',
        'message' => $e->getMessage()
    ];
}

// Test 3: Vérifier la structure de la table utilisateurs
if (isset($conn) && $conn) {
    try {
        $result = $conn->query("DESCRIBE utilisateurs");
        $requiredColumns = ['id', 'nom', 'prenom', 'email', 'password', 'date_creation'];
        $existingColumns = [];
        
        while ($row = $result->fetch_assoc()) {
            $existingColumns[] = $row['Field'];
        }
        
        $missingColumns = array_diff($requiredColumns, $existingColumns);
        
        if (empty($missingColumns)) {
            $results['tests']['table_structure'] = [
                'name' => 'Structure de la table utilisateurs',
                'status' => 'success',
                'message' => 'Toutes les colonnes requises existent',
                'details' => [
                    'columns' => $existingColumns
                ]
            ];
        } else {
            $results['tests']['table_structure'] = [
                'name' => 'Structure de la table utilisateurs',
                'status' => 'error',
                'message' => 'Colonnes manquantes: ' . implode(', ', $missingColumns),
                'details' => [
                    'existing' => $existingColumns,
                    'missing' => $missingColumns
                ]
            ];
        }
    } catch (Exception $e) {
        $results['tests']['table_structure'] = [
            'name' => 'Structure de la table utilisateurs',
            'status' => 'error',
            'message' => $e->getMessage()
        ];
    }
}

// Test 4: Tester la validation des données (simulation)
$testData = [
    'nom' => 'Test',
    'prenom' => 'User',
    'email' => 'test@example.com',
    'password' => 'password123'
];

$errors = validateInput($testData, ['nom', 'prenom', 'email', 'password']);
$results['tests']['validation'] = [
    'name' => 'Validation des données',
    'status' => empty($errors) ? 'success' : 'error',
    'message' => empty($errors) 
        ? 'La validation fonctionne correctement' 
        : 'Erreurs de validation: ' . implode(', ', $errors),
    'details' => [
        'test_data' => $testData,
        'errors' => $errors
    ]
];

// Test 5: Tester la validation de l'email
$testEmails = [
    'valid@example.com' => validateEmail('valid@example.com'),
    'invalid-email' => validateEmail('invalid-email'),
    'test@domain.co.uk' => validateEmail('test@domain.co.uk')
];

$emailValidationWorks = true;
foreach ($testEmails as $email => $isValid) {
    if ($email === 'valid@example.com' && !$isValid) {
        $emailValidationWorks = false;
    }
    if ($email === 'invalid-email' && $isValid) {
        $emailValidationWorks = false;
    }
}

$results['tests']['email_validation'] = [
    'name' => 'Validation de l\'email',
    'status' => $emailValidationWorks ? 'success' : 'error',
    'message' => $emailValidationWorks 
        ? 'La validation d\'email fonctionne correctement' 
        : 'Problème avec la validation d\'email',
    'details' => $testEmails
];

// Test 6: Tester le hash du mot de passe
$testPassword = 'testpassword123';
$hashedPassword = password_hash($testPassword, PASSWORD_DEFAULT);
$passwordVerify = password_verify($testPassword, $hashedPassword);

$results['tests']['password_hashing'] = [
    'name' => 'Hash du mot de passe',
    'status' => $passwordVerify ? 'success' : 'error',
    'message' => $passwordVerify 
        ? 'Le hashage et la vérification des mots de passe fonctionnent' 
        : 'Problème avec le hashage des mots de passe'
];

// Test 7: Simuler une requête d'inscription (sans vraiment insérer)
if (isset($conn) && $conn) {
    try {
        $testEmail = 'test_' . time() . '@test.com';
        
        // Vérifier si l'email existe
        $stmt = $conn->prepare("SELECT id FROM utilisateurs WHERE email = ?");
        $stmt->bind_param("s", $testEmail);
        $stmt->execute();
        $result = $stmt->get_result();
        
        $emailExists = $result->num_rows > 0;
        
        $results['tests']['insert_simulation'] = [
            'name' => 'Simulation d\'insertion',
            'status' => 'success',
            'message' => 'La préparation de la requête d\'insertion fonctionne',
            'details' => [
                'test_email' => $testEmail,
                'email_exists' => $emailExists,
                'can_insert' => !$emailExists
            ]
        ];
        
        $stmt->close();
    } catch (Exception $e) {
        $results['tests']['insert_simulation'] = [
            'name' => 'Simulation d\'insertion',
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






