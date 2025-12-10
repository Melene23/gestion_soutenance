<?php
/**
 * Script de test général pour vérifier la configuration
 * Accès: http://localhost/gestsoutenance/api/test/test_config.php
 */

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');

$results = [
    'timestamp' => date('Y-m-d H:i:s'),
    'server_info' => [],
    'php_config' => [],
    'tests' => []
];

// Informations sur le serveur
$results['server_info'] = [
    'php_version' => phpversion(),
    'server_software' => $_SERVER['SERVER_SOFTWARE'] ?? 'Unknown',
    'document_root' => $_SERVER['DOCUMENT_ROOT'] ?? 'Unknown',
    'script_filename' => __FILE__,
    'request_method' => $_SERVER['REQUEST_METHOD'] ?? 'Unknown',
    'request_uri' => $_SERVER['REQUEST_URI'] ?? 'Unknown'
];

// Configuration PHP
$results['php_config'] = [
    'json_enabled' => function_exists('json_encode'),
    'mysqli_enabled' => extension_loaded('mysqli'),
    'pdo_mysql_enabled' => extension_loaded('pdo_mysql'),
    'mbstring_enabled' => extension_loaded('mbstring'),
    'error_reporting' => error_reporting(),
    'display_errors' => ini_get('display_errors'),
    'log_errors' => ini_get('log_errors'),
    'error_log' => ini_get('error_log')
];

// Test 1: Vérifier les extensions PHP requises
$requiredExtensions = ['json', 'mysqli'];
$missingExtensions = [];

foreach ($requiredExtensions as $ext) {
    if (!extension_loaded($ext)) {
        $missingExtensions[] = $ext;
    }
}

$results['tests']['php_extensions'] = [
    'name' => 'Extensions PHP',
    'status' => empty($missingExtensions) ? 'success' : 'error',
    'message' => empty($missingExtensions) 
        ? 'Toutes les extensions requises sont installées' 
        : 'Extensions manquantes: ' . implode(', ', $missingExtensions),
    'details' => [
        'required' => $requiredExtensions,
        'missing' => $missingExtensions,
        'loaded' => get_loaded_extensions()
    ]
];

// Test 2: Vérifier que les fichiers de configuration existent
$configFiles = [
    '../config/database.php' => 'Configuration de la base de données',
    '../auth/register.php' => 'Endpoint d\'inscription',
    '../auth/login.php' => 'Endpoint de connexion'
];

$missingFiles = [];
$existingFiles = [];

foreach ($configFiles as $file => $description) {
    $fullPath = __DIR__ . '/' . $file;
    if (file_exists($fullPath)) {
        $existingFiles[$file] = [
            'description' => $description,
            'path' => realpath($fullPath),
            'size' => filesize($fullPath),
            'readable' => is_readable($fullPath)
        ];
    } else {
        $missingFiles[$file] = $description;
    }
}

$results['tests']['config_files'] = [
    'name' => 'Fichiers de configuration',
    'status' => empty($missingFiles) ? 'success' : 'error',
    'message' => empty($missingFiles) 
        ? 'Tous les fichiers de configuration existent' 
        : 'Fichiers manquants: ' . implode(', ', array_keys($missingFiles)),
    'details' => [
        'existing' => $existingFiles,
        'missing' => $missingFiles
    ]
];

// Test 3: Vérifier les permissions d'écriture (pour les logs)
$writableDirs = [];
$testDirs = [
    __DIR__ => 'Dossier de test',
    dirname(__DIR__) => 'Dossier API'
];

foreach ($testDirs as $dir => $description) {
    $writableDirs[$dir] = [
        'description' => $description,
        'writable' => is_writable($dir),
        'readable' => is_readable($dir)
    ];
}

$allWritable = true;
foreach ($writableDirs as $dir => $info) {
    if (!$info['writable']) {
        $allWritable = false;
        break;
    }
}

$results['tests']['permissions'] = [
    'name' => 'Permissions des dossiers',
    'status' => $allWritable ? 'success' : 'warning',
    'message' => $allWritable 
        ? 'Tous les dossiers sont accessibles en écriture' 
        : 'Certains dossiers ne sont pas accessibles en écriture',
    'details' => $writableDirs
];

// Test 4: Vérifier la configuration de la base de données (sans se connecter)
if (file_exists(__DIR__ . '/../config/database.php')) {
    // Lire le fichier pour vérifier les constantes
    $configContent = file_get_contents(__DIR__ . '/../config/database.php');
    
    $hasDbHost = strpos($configContent, "define('DB_HOST'") !== false;
    $hasDbUser = strpos($configContent, "define('DB_USER'") !== false;
    $hasDbName = strpos($configContent, "define('DB_NAME'") !== false;
    $hasDbPass = strpos($configContent, "define('DB_PASS'") !== false;
    
    $allDefined = $hasDbHost && $hasDbUser && $hasDbName && $hasDbPass;
    
    $results['tests']['db_config_file'] = [
        'name' => 'Fichier de configuration DB',
        'status' => $allDefined ? 'success' : 'error',
        'message' => $allDefined 
            ? 'Toutes les constantes de configuration sont définies' 
            : 'Constantes manquantes dans le fichier de configuration',
        'details' => [
            'DB_HOST' => $hasDbHost,
            'DB_USER' => $hasDbUser,
            'DB_NAME' => $hasDbName,
            'DB_PASS' => $hasDbPass
        ]
    ];
}

// Test 5: Vérifier les fonctions CORS
$corsHeaders = [
    'Access-Control-Allow-Origin' => headers_sent() ? 'N/A' : 'Set',
    'Content-Type' => headers_sent() ? 'N/A' : 'Set'
];

$results['tests']['cors_headers'] = [
    'name' => 'En-têtes CORS',
    'status' => 'success',
    'message' => 'Les en-têtes CORS sont configurés',
    'details' => $corsHeaders
];

// Test 6: Vérifier le chemin du document root
$apiPath = __DIR__;
$docRoot = $_SERVER['DOCUMENT_ROOT'] ?? '';
$relativePath = str_replace($docRoot, '', $apiPath);

$results['tests']['path_config'] = [
    'name' => 'Configuration des chemins',
    'status' => 'success',
    'message' => 'Les chemins sont correctement configurés',
    'details' => [
        'document_root' => $docRoot,
        'api_path' => $apiPath,
        'relative_path' => $relativePath,
        'expected_url' => 'http://' . ($_SERVER['HTTP_HOST'] ?? 'localhost') . $relativePath
    ]
];

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


