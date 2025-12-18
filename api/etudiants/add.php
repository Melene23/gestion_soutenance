<?php
// api/etudiants/add.php
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
$required = ['nom', 'prenom', 'email', 'telephone', 'filiere', 'niveau', 'encadreur'];
foreach ($required as $field) {
    if (empty($data[$field])) {
        echo json_encode(['success' => false, 'message' => "Le champ '$field' est requis"]);
        exit;
    }
}

try {
    // Vérifier si l'email existe déjà
    $checkSql = "SELECT id FROM etudiants WHERE email = :email";
    $checkStmt = $pdo->prepare($checkSql);
    $checkStmt->execute([':email' => trim($data['email'])]);
    
    if ($checkStmt->rowCount() > 0) {
        echo json_encode(['success' => false, 'message' => 'Cet email est déjà utilisé']);
        exit;
    }
    
    // Insérer l'étudiant - ADAPTÉ À TA STRUCTURE
    $sql = "INSERT INTO etudiants (id, nom, prenom, email, telephone, filiere, niveau, encadreur) 
            VALUES (UUID(), :nom, :prenom, :email, :telephone, :filiere, :niveau, :encadreur)";
    
    $stmt = $pdo->prepare($sql);
    $result = $stmt->execute([
        ':nom' => trim($data['nom']),
        ':prenom' => trim($data['prenom']),
        ':email' => trim($data['email']),
        ':telephone' => trim($data['telephone']),
        ':filiere' => trim($data['filiere']),
        ':niveau' => trim($data['niveau']),
        ':encadreur' => trim($data['encadreur'])
    ]);
    
    if ($result) {
        // Récupérer le dernier ID inséré
        $lastId = $pdo->lastInsertId();
        
        // Pour UUID, on récupère l'ID généré
        $getIdSql = "SELECT id FROM etudiants WHERE email = :email";
        $getIdStmt = $pdo->prepare($getIdSql);
        $getIdStmt->execute([':email' => $data['email']]);
        $student = $getIdStmt->fetch();
        
        echo json_encode([
            'success' => true,
            'message' => 'Étudiant ajouté avec succès',
            'data' => [
                'id' => $student['id'],
                'nom' => $data['nom'],
                'prenom' => $data['prenom'],
                'email' => $data['email']
            ]
        ]);
    } else {
        echo json_encode(['success' => false, 'message' => 'Erreur lors de l\'insertion']);
    }
    
} catch (PDOException $e) {
    echo json_encode(['success' => false, 'message' => 'Erreur DB: ' . $e->getMessage()]);
}
?>