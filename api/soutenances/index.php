<?php
/**
 * API Endpoint pour la gestion des soutenances
 */

// En-têtes CORS (doivent être envoyés avant toute sortie)
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With');
header('Access-Control-Max-Age: 3600');

// Gérer les requêtes OPTIONS (preflight CORS)
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

require_once '../config/database.php';

$method = $_SERVER['REQUEST_METHOD'];
$path = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
$pathParts = explode('/', trim($path, '/'));
$id = end($pathParts) !== 'index.php' && end($pathParts) !== 'soutenances' ? end($pathParts) : null;

try {
    $conn = getConnection();
    
    switch ($method) {
        case 'GET':
            if ($id) {
                $stmt = $conn->prepare("SELECT * FROM soutenances WHERE id = ?");
                $stmt->bind_param("s", $id);
                $stmt->execute();
                $result = $stmt->get_result();
                
                if ($result->num_rows > 0) {
                    $soutenance = $result->fetch_assoc();
                    // Convertir jury JSON
                    if ($soutenance['jury']) {
                        $soutenance['jury'] = json_decode($soutenance['jury'], true) ?? [];
                    } else {
                        $soutenance['jury'] = [];
                    }
                    sendResponse(true, 'Soutenance récupérée', $soutenance, 200);
                } else {
                    sendResponse(false, 'Soutenance non trouvée', null, 404);
                }
                $stmt->close();
            } else {
                $result = $conn->query("SELECT * FROM soutenances ORDER BY date_soutenance DESC");
                $soutenances = [];
                
                while ($row = $result->fetch_assoc()) {
                    if ($row['jury']) {
                        $row['jury'] = json_decode($row['jury'], true) ?? [];
                    } else {
                        $row['jury'] = [];
                    }
                    $soutenances[] = $row;
                }
                
                sendResponse(true, 'Liste des soutenances récupérée', $soutenances, 200);
            }
            break;
            
        case 'POST':
            $data = json_decode(file_get_contents('php://input'), true);
            
            $errors = validateInput($data, ['etudiant_id', 'memoire_id', 'salle_id', 'date_soutenance', 'heure_debut', 'heure_fin']);
            if (!empty($errors)) {
                sendResponse(false, 'Données invalides', ['errors' => $errors], 400);
                exit;
            }
            
            $id = $data['id'] ?? bin2hex(random_bytes(18));
            $etudiant_id = sanitizeInput($data['etudiant_id']);
            $memoire_id = sanitizeInput($data['memoire_id']);
            $salle_id = sanitizeInput($data['salle_id']);
            $date_soutenance = $data['date_soutenance'];
            $heure_debut = $data['heure_debut'];
            $heure_fin = $data['heure_fin'];
            $jury = isset($data['jury']) && is_array($data['jury']) 
                ? json_encode($data['jury']) 
                : '[]';
            $notes = sanitizeInput($data['notes'] ?? '');
            $statut = sanitizeInput($data['statut'] ?? 'planifiee');
            
            // Convertir la date
            $date_soutenance_formatted = date('Y-m-d H:i:s', strtotime($date_soutenance));
            
            $stmt = $conn->prepare("INSERT INTO soutenances (id, etudiant_id, memoire_id, salle_id, date_soutenance, heure_debut, heure_fin, jury, notes, statut) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");
            $stmt->bind_param("ssssssssss", $id, $etudiant_id, $memoire_id, $salle_id, $date_soutenance_formatted, $heure_debut, $heure_fin, $jury, $notes, $statut);
            
            if ($stmt->execute()) {
                $stmt->close();
                $stmt = $conn->prepare("SELECT * FROM soutenances WHERE id = ?");
                $stmt->bind_param("s", $id);
                $stmt->execute();
                $result = $stmt->get_result();
                $soutenance = $result->fetch_assoc();
                if ($soutenance['jury']) {
                    $soutenance['jury'] = json_decode($soutenance['jury'], true) ?? [];
                } else {
                    $soutenance['jury'] = [];
                }
                $stmt->close();
                
                sendResponse(true, 'Soutenance créée avec succès', $soutenance, 201);
            } else {
                $stmt->close();
                sendResponse(false, 'Erreur lors de la création', null, 500);
            }
            break;
            
        case 'PUT':
            if (!$id) {
                sendResponse(false, 'ID requis', null, 400);
                exit;
            }
            
            $data = json_decode(file_get_contents('php://input'), true);
            $errors = validateInput($data, ['etudiant_id', 'memoire_id', 'salle_id', 'date_soutenance', 'heure_debut', 'heure_fin']);
            if (!empty($errors)) {
                sendResponse(false, 'Données invalides', ['errors' => $errors], 400);
                exit;
            }
            
            $etudiant_id = sanitizeInput($data['etudiant_id']);
            $memoire_id = sanitizeInput($data['memoire_id']);
            $salle_id = sanitizeInput($data['salle_id']);
            $date_soutenance = $data['date_soutenance'];
            $heure_debut = $data['heure_debut'];
            $heure_fin = $data['heure_fin'];
            $jury = isset($data['jury']) && is_array($data['jury']) 
                ? json_encode($data['jury']) 
                : '[]';
            $notes = sanitizeInput($data['notes'] ?? '');
            $statut = sanitizeInput($data['statut'] ?? 'planifiee');
            
            $date_soutenance_formatted = date('Y-m-d H:i:s', strtotime($date_soutenance));
            
            $stmt = $conn->prepare("UPDATE soutenances SET etudiant_id = ?, memoire_id = ?, salle_id = ?, date_soutenance = ?, heure_debut = ?, heure_fin = ?, jury = ?, notes = ?, statut = ? WHERE id = ?");
            $stmt->bind_param("ssssssssss", $etudiant_id, $memoire_id, $salle_id, $date_soutenance_formatted, $heure_debut, $heure_fin, $jury, $notes, $statut, $id);
            
            if ($stmt->execute()) {
                $stmt->close();
                $stmt = $conn->prepare("SELECT * FROM soutenances WHERE id = ?");
                $stmt->bind_param("s", $id);
                $stmt->execute();
                $result = $stmt->get_result();
                $soutenance = $result->fetch_assoc();
                if ($soutenance['jury']) {
                    $soutenance['jury'] = json_decode($soutenance['jury'], true) ?? [];
                } else {
                    $soutenance['jury'] = [];
                }
                $stmt->close();
                
                sendResponse(true, 'Soutenance mise à jour avec succès', $soutenance, 200);
            } else {
                $stmt->close();
                sendResponse(false, 'Erreur lors de la mise à jour', null, 500);
            }
            break;
            
        case 'DELETE':
            if (!$id) {
                sendResponse(false, 'ID requis', null, 400);
                exit;
            }
            
            $stmt = $conn->prepare("DELETE FROM soutenances WHERE id = ?");
            $stmt->bind_param("s", $id);
            
            if ($stmt->execute()) {
                $stmt->close();
                sendResponse(true, 'Soutenance supprimée avec succès', null, 200);
            } else {
                $stmt->close();
                sendResponse(false, 'Erreur lors de la suppression', null, 500);
            }
            break;
            
        default:
            sendResponse(false, 'Méthode non autorisée', null, 405);
    }
    
    $conn->close();
    
} catch (Exception $e) {
    sendResponse(false, 'Erreur serveur: ' . $e->getMessage(), null, 500);
}
?>

