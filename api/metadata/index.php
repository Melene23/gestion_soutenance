<?php
/**
 * API Endpoint pour les métadonnées (filières, niveaux)
 */

require_once '../config/database.php';

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

try {
    $conn = getConnection();
    
    // Récupérer les filières uniques
    $result = $conn->query("SELECT DISTINCT filiere FROM etudiants WHERE filiere IS NOT NULL AND filiere != '' ORDER BY filiere");
    $filieres = [];
    while ($row = $result->fetch_assoc()) {
        $filieres[] = $row['filiere'];
    }
    
    // Récupérer les niveaux uniques
    $result = $conn->query("SELECT DISTINCT niveau FROM etudiants WHERE niveau IS NOT NULL AND niveau != '' ORDER BY niveau");
    $niveaux = [];
    while ($row = $result->fetch_assoc()) {
        $niveaux[] = $row['niveau'];
    }
    
    $conn->close();
    
    sendResponse(true, 'Métadonnées récupérées', [
        'filieres' => $filieres,
        'niveaux' => $niveaux
    ], 200);
    
} catch (Exception $e) {
    sendResponse(false, 'Erreur serveur: ' . $e->getMessage(), null, 500);
}
?>

