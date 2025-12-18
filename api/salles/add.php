<?php
// api/salles/add.php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

require_once __DIR__ . '/../config/database.php';

$data = json_decode(file_get_contents('php://input'), true);

if (!$data) {
    echo json_encode(['success' => false, 'message' => 'Données invalides']);
    exit;
}

// Champs requis selon TA table
if (empty($data['nom']) || empty($data['capacite'])) {
    echo json_encode(['success' => false, 'message' => 'Nom et capacité sont requis']);
    exit;
}

try {
    // Vérifier si la salle existe déjà (nom unique)
    $checkSql = "SELECT id FROM salles WHERE nom = :nom";
    $checkStmt = $pdo->prepare($checkSql);
    $checkStmt->execute([':nom' => trim($data['nom'])]);
    
    if ($checkStmt->rowCount() > 0) {
        echo json_encode(['success' => false, 'message' => 'Une salle avec ce nom existe déjà']);
        exit;
    }
    
    // Insérer la salle - ADAPTÉ À TA STRUCTURE
    $sql = "INSERT INTO salles (id, nom, capacite, equipements, disponible) 
            VALUES (UUID(), :nom, :capacite, :equipements, :disponible)";
    
    $stmt = $pdo->prepare($sql);
    $result = $stmt->execute([
        ':nom' => trim($data['nom']),
        ':capacite' => (int)$data['capacite'],
        ':equipements' => trim($data['equipements'] ?? ''),
        ':disponible' => isset($data['disponible']) ? (int)$data['disponible'] : 1
    ]);
    
    if ($result) {
        // Récupérer l'ID généré
        $getIdSql = "SELECT id FROM salles WHERE nom = :nom ORDER BY date_creation DESC LIMIT 1";
        $getIdStmt = $pdo->prepare($getIdSql);
        $getIdStmt->execute([':nom' => $data['nom']]);
        $salle = $getIdStmt->fetch();
        
        echo json_encode([
            'success' => true,
            'message' => 'Salle ajoutée avec succès',
            'data' => ['id' => $salle['id']]
        ]);
    } else {
        echo json_encode(['success' => false, 'message' => 'Erreur lors de l\'insertion']);
    }
    
} catch (PDOException $e) {
    echo json_encode(['success' => false, 'message' => 'Erreur DB: ' . $e->getMessage()]);
}
?>