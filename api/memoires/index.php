<?php
/**
 * API Endpoint pour la gestion des mémoires
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
$id = end($pathParts) !== 'index.php' && end($pathParts) !== 'memoires' ? end($pathParts) : null;

try {
    $conn = getConnection();
    
    switch ($method) {
        case 'GET':
            if ($id) {
                $stmt = $conn->prepare("SELECT * FROM memoires WHERE id = ?");
                $stmt->bind_param("s", $id);
                $stmt->execute();
                $result = $stmt->get_result();
                
                if ($result->num_rows > 0) {
                    $memoire = $result->fetch_assoc();
                    sendResponse(true, 'Mémoire récupéré', $memoire, 200);
                } else {
                    sendResponse(false, 'Mémoire non trouvé', null, 404);
                }
                $stmt->close();
            } else {
                $result = $conn->query("SELECT * FROM memoires ORDER BY date_creation DESC");
                $memoires = [];
                
                while ($row = $result->fetch_assoc()) {
                    $memoires[] = $row;
                }
                
                sendResponse(true, 'Liste des mémoires récupérée', $memoires, 200);
            }
            break;
            
        case 'POST':
            $data = json_decode(file_get_contents('php://input'), true);
            
            $errors = validateInput($data, ['etudiant_id', 'theme', 'encadreur', 'date_debut']);
            if (!empty($errors)) {
                sendResponse(false, 'Données invalides', ['errors' => $errors], 400);
                exit;
            }
            
            $id = $data['id'] ?? bin2hex(random_bytes(18));
            $etudiant_id = sanitizeInput($data['etudiant_id']);
            $theme = sanitizeInput($data['theme']);
            $description = sanitizeInput($data['description'] ?? '');
            $encadreur = sanitizeInput($data['encadreur']);
            $etat = sanitizeInput($data['etat'] ?? 'enPreparation');
            $date_debut = $data['date_debut'];
            $date_soutenance = $data['date_soutenance'] ?? null;
            
            // Convertir les dates
            $date_debut_formatted = date('Y-m-d H:i:s', strtotime($date_debut));
            $date_soutenance_formatted = $date_soutenance ? date('Y-m-d H:i:s', strtotime($date_soutenance)) : null;
            
            $stmt = $conn->prepare("INSERT INTO memoires (id, etudiant_id, theme, description, encadreur, etat, date_debut, date_soutenance) VALUES (?, ?, ?, ?, ?, ?, ?, ?)");
            $stmt->bind_param("ssssssss", $id, $etudiant_id, $theme, $description, $encadreur, $etat, $date_debut_formatted, $date_soutenance_formatted);
            
            if ($stmt->execute()) {
                $stmt->close();
                $stmt = $conn->prepare("SELECT * FROM memoires WHERE id = ?");
                $stmt->bind_param("s", $id);
                $stmt->execute();
                $result = $stmt->get_result();
                $memoire = $result->fetch_assoc();
                $stmt->close();
                
                sendResponse(true, 'Mémoire créé avec succès', $memoire, 201);
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
            $errors = validateInput($data, ['etudiant_id', 'theme', 'encadreur', 'date_debut']);
            if (!empty($errors)) {
                sendResponse(false, 'Données invalides', ['errors' => $errors], 400);
                exit;
            }
            
            $etudiant_id = sanitizeInput($data['etudiant_id']);
            $theme = sanitizeInput($data['theme']);
            $description = sanitizeInput($data['description'] ?? '');
            $encadreur = sanitizeInput($data['encadreur']);
            $etat = sanitizeInput($data['etat'] ?? 'enPreparation');
            $date_debut = $data['date_debut'];
            $date_soutenance = $data['date_soutenance'] ?? null;
            
            $date_debut_formatted = date('Y-m-d H:i:s', strtotime($date_debut));
            $date_soutenance_formatted = $date_soutenance ? date('Y-m-d H:i:s', strtotime($date_soutenance)) : null;
            
            $stmt = $conn->prepare("UPDATE memoires SET etudiant_id = ?, theme = ?, description = ?, encadreur = ?, etat = ?, date_debut = ?, date_soutenance = ? WHERE id = ?");
            $stmt->bind_param("ssssssss", $etudiant_id, $theme, $description, $encadreur, $etat, $date_debut_formatted, $date_soutenance_formatted, $id);
            
            if ($stmt->execute()) {
                $stmt->close();
                $stmt = $conn->prepare("SELECT * FROM memoires WHERE id = ?");
                $stmt->bind_param("s", $id);
                $stmt->execute();
                $result = $stmt->get_result();
                $memoire = $result->fetch_assoc();
                $stmt->close();
                
                sendResponse(true, 'Mémoire mis à jour avec succès', $memoire, 200);
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
            
            $stmt = $conn->prepare("DELETE FROM memoires WHERE id = ?");
            $stmt->bind_param("s", $id);
            
            if ($stmt->execute()) {
                $stmt->close();
                sendResponse(true, 'Mémoire supprimé avec succès', null, 200);
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

