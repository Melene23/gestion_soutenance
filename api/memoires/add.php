<?php
// api/memoires/add.php
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
if (empty($data['etudiant_id']) || empty($data['theme']) || empty($data['encadreur'])) {
    echo json_encode(['success' => false, 'message' => 'Étudiant, thème et encadreur sont requis']);
    exit;
}

try {
    // Vérifier que l'étudiant existe
    $checkSql = "SELECT id FROM etudiants WHERE id = :etudiant_id";
    $checkStmt = $pdo->prepare($checkSql);
    $checkStmt->execute([':etudiant_id' => $data['etudiant_id']]);
    
    if ($checkStmt->rowCount() === 0) {
        echo json_encode(['success' => false, 'message' => 'Étudiant non trouvé']);
        exit;
    }
    
    // Insérer le mémoire - ADAPTÉ À TA STRUCTURE
    $sql = "INSERT INTO memoires (id, etudiant_id, theme, description, encadreur, etat, date_debut) 
            VALUES (UUID(), :etudiant_id, :theme, :description, :encadreur, :etat, NOW())";
    
    $stmt = $pdo->prepare($sql);
    $result = $stmt->execute([
        ':etudiant_id' => $data['etudiant_id'],
        ':theme' => trim($data['theme']),
        ':description' => trim($data['description'] ?? ''),
        ':encadreur' => trim($data['encadreur']),
        ':etat' => $data['etat'] ?? 'enPreparation'
    ]);
    
    if ($result) {
        // Récupérer l'ID généré
        $getIdSql = "SELECT id FROM memoires WHERE etudiant_id = :etudiant_id AND theme = :theme ORDER BY date_creation DESC LIMIT 1";
        $getIdStmt = $pdo->prepare($getIdSql);
        $getIdStmt->execute([
            ':etudiant_id' => $data['etudiant_id'],
            ':theme' => $data['theme']
        ]);
        $memoire = $getIdStmt->fetch();
        
        echo json_encode([
            'success' => true,
            'message' => 'Mémoire ajouté avec succès',
            'data' => ['id' => $memoire['id']]
        ]);
    } else {
        echo json_encode(['success' => false, 'message' => 'Erreur lors de l\'insertion']);
    }
    
} catch (PDOException $e) {
    echo json_encode(['success' => false, 'message' => 'Erreur DB: ' . $e->getMessage()]);
}
?>