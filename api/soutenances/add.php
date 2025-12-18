<?php
// api/soutenances/add.php
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
$required = ['etudiant_id', 'memoire_id', 'salle_id', 'date_soutenance', 'heure_debut', 'heure_fin'];
foreach ($required as $field) {
    if (empty($data[$field])) {
        echo json_encode(['success' => false, 'message' => "Le champ '$field' est requis"]);
        exit;
    }
}

try {
    // Vérifier que l'étudiant existe
    $checkEtudiant = "SELECT id FROM etudiants WHERE id = :etudiant_id";
    $stmtEtudiant = $pdo->prepare($checkEtudiant);
    $stmtEtudiant->execute([':etudiant_id' => $data['etudiant_id']]);
    
    if ($stmtEtudiant->rowCount() === 0) {
        echo json_encode(['success' => false, 'message' => 'Étudiant non trouvé']);
        exit;
    }
    
    // Vérifier que le mémoire existe
    $checkMemoire = "SELECT id FROM memoires WHERE id = :memoire_id";
    $stmtMemoire = $pdo->prepare($checkMemoire);
    $stmtMemoire->execute([':memoire_id' => $data['memoire_id']]);
    
    if ($stmtMemoire->rowCount() === 0) {
        echo json_encode(['success' => false, 'message' => 'Mémoire non trouvé']);
        exit;
    }
    
    // Vérifier que la salle existe
    $checkSalle = "SELECT id FROM salles WHERE id = :salle_id";
    $stmtSalle = $pdo->prepare($checkSalle);
    $stmtSalle->execute([':salle_id' => $data['salle_id']]);
    
    if ($stmtSalle->rowCount() === 0) {
        echo json_encode(['success' => false, 'message' => 'Salle non trouvée']);
        exit;
    }
    
    // Insérer la soutenance - ADAPTÉ À TA STRUCTURE
    $sql = "INSERT INTO soutenances (id, etudiant_id, memoire_id, salle_id, date_soutenance, heure_debut, heure_fin, jury, notes, statut) 
            VALUES (UUID(), :etudiant_id, :memoire_id, :salle_id, :date_soutenance, :heure_debut, :heure_fin, :jury, :notes, :statut)";
    
    $stmt = $pdo->prepare($sql);
    $result = $stmt->execute([
        ':etudiant_id' => $data['etudiant_id'],
        ':memoire_id' => $data['memoire_id'],
        ':salle_id' => $data['salle_id'],
        ':date_soutenance' => $data['date_soutenance'],
        ':heure_debut' => $data['heure_debut'],
        ':heure_fin' => $data['heure_fin'],
        ':jury' => $data['jury'] ?? '',
        ':notes' => $data['notes'] ?? '',
        ':statut' => $data['statut'] ?? 'planifiee'
    ]);
    
    if ($result) {
        // Récupérer l'ID généré
        $getIdSql = "SELECT id FROM soutenances 
                     WHERE etudiant_id = :etudiant_id 
                     AND memoire_id = :memoire_id 
                     AND salle_id = :salle_id 
                     ORDER BY date_creation DESC LIMIT 1";
        $getIdStmt = $pdo->prepare($getIdSql);
        $getIdStmt->execute([
            ':etudiant_id' => $data['etudiant_id'],
            ':memoire_id' => $data['memoire_id'],
            ':salle_id' => $data['salle_id']
        ]);
        $soutenance = $getIdStmt->fetch();
        
        echo json_encode([
            'success' => true,
            'message' => 'Soutenance planifiée avec succès',
            'data' => ['id' => $soutenance['id']]
        ]);
    } else {
        echo json_encode(['success' => false, 'message' => 'Erreur lors de l\'insertion']);
    }
    
} catch (PDOException $e) {
    echo json_encode(['success' => false, 'message' => 'Erreur DB: ' . $e->getMessage()]);
}
?>