<?php
/**
 * API Endpoint pour la gestion des salles
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
$id = end($pathParts) !== 'index.php' && end($pathParts) !== 'salles' ? end($pathParts) : null;

try {
    $conn = getConnection();
    
    switch ($method) {
        case 'GET':
            if ($id) {
                $stmt = $conn->prepare("SELECT * FROM salles WHERE id = ?");
                $stmt->bind_param("s", $id);
                $stmt->execute();
                $result = $stmt->get_result();
                
                if ($result->num_rows > 0) {
                    $salle = $result->fetch_assoc();
                    // Convertir equipements JSON
                    if ($salle['equipements']) {
                        $salle['equipements'] = json_decode($salle['equipements'], true) ?? [];
                    } else {
                        $salle['equipements'] = [];
                    }
                    sendResponse(true, 'Salle récupérée', $salle, 200);
                } else {
                    sendResponse(false, 'Salle non trouvée', null, 404);
                }
                $stmt->close();
            } else {
                $result = $conn->query("SELECT * FROM salles ORDER BY nom");
                $salles = [];
                
                while ($row = $result->fetch_assoc()) {
                    if ($row['equipements']) {
                        $row['equipements'] = json_decode($row['equipements'], true) ?? [];
                    } else {
                        $row['equipements'] = [];
                    }
                    $salles[] = $row;
                }
                
                sendResponse(true, 'Liste des salles récupérée', $salles, 200);
            }
            break;
            
        case 'POST':
            $data = json_decode(file_get_contents('php://input'), true);
            
            $errors = validateInput($data, ['nom', 'capacite']);
            if (!empty($errors)) {
                sendResponse(false, 'Données invalides', ['errors' => $errors], 400);
                exit;
            }
            
            $id = $data['id'] ?? bin2hex(random_bytes(18));
            $nom = sanitizeInput($data['nom']);
            $capacite = intval($data['capacite']);
            $equipements = isset($data['equipements']) && is_array($data['equipements']) 
                ? json_encode($data['equipements']) 
                : '[]';
            $disponible = isset($data['disponible']) ? (boolval($data['disponible']) ? 1 : 0) : 1;
            
            // Vérifier si le nom existe déjà
            $stmt = $conn->prepare("SELECT id FROM salles WHERE nom = ?");
            $stmt->bind_param("s", $nom);
            $stmt->execute();
            if ($stmt->get_result()->num_rows > 0) {
                $stmt->close();
                sendResponse(false, 'Ce nom de salle est déjà utilisé', null, 400);
                exit;
            }
            $stmt->close();
            
            $stmt = $conn->prepare("INSERT INTO salles (id, nom, capacite, equipements, disponible) VALUES (?, ?, ?, ?, ?)");
            $stmt->bind_param("ssisi", $id, $nom, $capacite, $equipements, $disponible);
            
            if ($stmt->execute()) {
                $stmt->close();
                $stmt = $conn->prepare("SELECT * FROM salles WHERE id = ?");
                $stmt->bind_param("s", $id);
                $stmt->execute();
                $result = $stmt->get_result();
                $salle = $result->fetch_assoc();
                if ($salle['equipements']) {
                    $salle['equipements'] = json_decode($salle['equipements'], true) ?? [];
                } else {
                    $salle['equipements'] = [];
                }
                $stmt->close();
                
                sendResponse(true, 'Salle créée avec succès', $salle, 201);
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
            $errors = validateInput($data, ['nom', 'capacite']);
            if (!empty($errors)) {
                sendResponse(false, 'Données invalides', ['errors' => $errors], 400);
                exit;
            }
            
            $nom = sanitizeInput($data['nom']);
            $capacite = intval($data['capacite']);
            $equipements = isset($data['equipements']) && is_array($data['equipements']) 
                ? json_encode($data['equipements']) 
                : '[]';
            $disponible = isset($data['disponible']) ? (boolval($data['disponible']) ? 1 : 0) : 1;
            
            // Vérifier si le nom existe déjà pour une autre salle
            $stmt = $conn->prepare("SELECT id FROM salles WHERE nom = ? AND id != ?");
            $stmt->bind_param("ss", $nom, $id);
            $stmt->execute();
            if ($stmt->get_result()->num_rows > 0) {
                $stmt->close();
                sendResponse(false, 'Ce nom de salle est déjà utilisé', null, 400);
                exit;
            }
            $stmt->close();
            
            $stmt = $conn->prepare("UPDATE salles SET nom = ?, capacite = ?, equipements = ?, disponible = ? WHERE id = ?");
            $stmt->bind_param("sisis", $nom, $capacite, $equipements, $disponible, $id);
            
            if ($stmt->execute()) {
                $stmt->close();
                $stmt = $conn->prepare("SELECT * FROM salles WHERE id = ?");
                $stmt->bind_param("s", $id);
                $stmt->execute();
                $result = $stmt->get_result();
                $salle = $result->fetch_assoc();
                if ($salle['equipements']) {
                    $salle['equipements'] = json_decode($salle['equipements'], true) ?? [];
                } else {
                    $salle['equipements'] = [];
                }
                $stmt->close();
                
                sendResponse(true, 'Salle mise à jour avec succès', $salle, 200);
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
            
            $stmt = $conn->prepare("DELETE FROM salles WHERE id = ?");
            $stmt->bind_param("s", $id);
            
            if ($stmt->execute()) {
                $stmt->close();
                sendResponse(true, 'Salle supprimée avec succès', null, 200);
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

