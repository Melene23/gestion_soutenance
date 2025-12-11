<?php
/**
 * Script de vérification de la base de données
 * Vérifie la connexion et l'existence des tables
 * Accédez à : http://localhost/api/check_database.php
 */

require_once 'config/database.php';

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');

$results = [
    'database_connection' => false,
    'tables' => [],
    'admin_account' => false,
    'errors' => []
];

try {
    $conn = getConnection();
    $results['database_connection'] = true;
    
    // Vérifier les tables
    $tables = ['utilisateurs', 'etudiants', 'memoires', 'salles', 'soutenances'];
    
    foreach ($tables as $table) {
        $stmt = $conn->prepare("SHOW TABLES LIKE ?");
        $stmt->bind_param("s", $table);
        $stmt->execute();
        $result = $stmt->get_result();
        
        $results['tables'][$table] = $result->num_rows > 0;
        $stmt->close();
    }
    
    // Vérifier le compte admin
    $email = 'admin@gestsoutenance.com';
    $stmt = $conn->prepare("SELECT id, nom, prenom, email FROM utilisateurs WHERE email = ?");
    $stmt->bind_param("s", $email);
    $stmt->execute();
    $result = $stmt->get_result();
    
    if ($result->num_rows > 0) {
        $results['admin_account'] = true;
        $results['admin_info'] = $result->fetch_assoc();
    }
    
    $stmt->close();
    $conn->close();
    
    sendResponse(true, 'Vérification terminée', $results, 200);
    
} catch (Exception $e) {
    $results['errors'][] = $e->getMessage();
    sendResponse(false, 'Erreur lors de la vérification', $results, 500);
}
?>










