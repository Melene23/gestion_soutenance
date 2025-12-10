<?php
/**
 * API Endpoint pour la gestion des étudiants
 * Méthodes supportées: GET, POST, PUT, DELETE
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

// Récupérer la méthode HTTP
$method = $_SERVER['REQUEST_METHOD'];

// Récupérer l'ID depuis l'URL si présent
$path = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
$pathParts = explode('/', trim($path, '/'));
$id = end($pathParts) !== 'index.php' && end($pathParts) !== 'etudiants' ? end($pathParts) : null;

try {
    $conn = getConnection();
    
    switch ($method) {
        case 'GET':
            if ($id) {
                // Récupérer un étudiant spécifique
                $stmt = $conn->prepare("SELECT * FROM etudiants WHERE id = ?");
                $stmt->bind_param("s", $id);
                $stmt->execute();
                $result = $stmt->get_result();
                
                if ($result->num_rows > 0) {
                    $etudiant = $result->fetch_assoc();
                    // Convertir equipements JSON si nécessaire
                    sendResponse(true, 'Étudiant récupéré', $etudiant, 200);
                } else {
                    sendResponse(false, 'Étudiant non trouvé', null, 404);
                }
                $stmt->close();
            } else {
                // Récupérer tous les étudiants
                $result = $conn->query("SELECT * FROM etudiants ORDER BY nom, prenom");
                $etudiants = [];
                
                while ($row = $result->fetch_assoc()) {
                    $etudiants[] = $row;
                }
                
                sendResponse(true, 'Liste des étudiants récupérée', $etudiants, 200);
            }
            break;
            
        case 'POST':
            // Créer un nouvel étudiant
            $data = json_decode(file_get_contents('php://input'), true);
            
            $errors = validateInput($data, ['nom', 'prenom', 'email', 'filiere', 'niveau', 'encadreur']);
            if (!empty($errors)) {
                sendResponse(false, 'Données invalides', ['errors' => $errors], 400);
                exit;
            }
            
            // Générer un ID unique
            $id = $data['id'] ?? bin2hex(random_bytes(18));
            $nom = sanitizeInput($data['nom']);
            $prenom = sanitizeInput($data['prenom']);
            $email = sanitizeInput($data['email']);
            $telephone = sanitizeInput($data['telephone'] ?? '');
            $filiere = sanitizeInput($data['filiere']);
            $niveau = sanitizeInput($data['niveau']);
            $encadreur = sanitizeInput($data['encadreur']);
            
            // Vérifier si l'email existe déjà
            $stmt = $conn->prepare("SELECT id FROM etudiants WHERE email = ?");
            $stmt->bind_param("s", $email);
            $stmt->execute();
            if ($stmt->get_result()->num_rows > 0) {
                $stmt->close();
                sendResponse(false, 'Cet email est déjà utilisé', null, 400);
                exit;
            }
            $stmt->close();
            
            $stmt = $conn->prepare("INSERT INTO etudiants (id, nom, prenom, email, telephone, filiere, niveau, encadreur) VALUES (?, ?, ?, ?, ?, ?, ?, ?)");
            $stmt->bind_param("ssssssss", $id, $nom, $prenom, $email, $telephone, $filiere, $niveau, $encadreur);
            
            if ($stmt->execute()) {
                $stmt->close();
                // Récupérer l'étudiant créé
                $stmt = $conn->prepare("SELECT * FROM etudiants WHERE id = ?");
                $stmt->bind_param("s", $id);
                $stmt->execute();
                $result = $stmt->get_result();
                $etudiant = $result->fetch_assoc();
                $stmt->close();
                
                sendResponse(true, 'Étudiant créé avec succès', $etudiant, 201);
            } else {
                $stmt->close();
                sendResponse(false, 'Erreur lors de la création', null, 500);
            }
            break;
            
        case 'PUT':
            // Mettre à jour un étudiant
            if (!$id) {
                sendResponse(false, 'ID requis', null, 400);
                exit;
            }
            
            $data = json_decode(file_get_contents('php://input'), true);
            $errors = validateInput($data, ['nom', 'prenom', 'email', 'filiere', 'niveau', 'encadreur']);
            if (!empty($errors)) {
                sendResponse(false, 'Données invalides', ['errors' => $errors], 400);
                exit;
            }
            
            $nom = sanitizeInput($data['nom']);
            $prenom = sanitizeInput($data['prenom']);
            $email = sanitizeInput($data['email']);
            $telephone = sanitizeInput($data['telephone'] ?? '');
            $filiere = sanitizeInput($data['filiere']);
            $niveau = sanitizeInput($data['niveau']);
            $encadreur = sanitizeInput($data['encadreur']);
            
            // Vérifier si l'email existe déjà pour un autre étudiant
            $stmt = $conn->prepare("SELECT id FROM etudiants WHERE email = ? AND id != ?");
            $stmt->bind_param("ss", $email, $id);
            $stmt->execute();
            if ($stmt->get_result()->num_rows > 0) {
                $stmt->close();
                sendResponse(false, 'Cet email est déjà utilisé', null, 400);
                exit;
            }
            $stmt->close();
            
            $stmt = $conn->prepare("UPDATE etudiants SET nom = ?, prenom = ?, email = ?, telephone = ?, filiere = ?, niveau = ?, encadreur = ? WHERE id = ?");
            $stmt->bind_param("ssssssss", $nom, $prenom, $email, $telephone, $filiere, $niveau, $encadreur, $id);
            
            if ($stmt->execute()) {
                $stmt->close();
                // Récupérer l'étudiant mis à jour
                $stmt = $conn->prepare("SELECT * FROM etudiants WHERE id = ?");
                $stmt->bind_param("s", $id);
                $stmt->execute();
                $result = $stmt->get_result();
                $etudiant = $result->fetch_assoc();
                $stmt->close();
                
                sendResponse(true, 'Étudiant mis à jour avec succès', $etudiant, 200);
            } else {
                $stmt->close();
                sendResponse(false, 'Erreur lors de la mise à jour', null, 500);
            }
            break;
            
        case 'DELETE':
            // Supprimer un étudiant
            if (!$id) {
                sendResponse(false, 'ID requis', null, 400);
                exit;
            }
            
            $stmt = $conn->prepare("DELETE FROM etudiants WHERE id = ?");
            $stmt->bind_param("s", $id);
            
            if ($stmt->execute()) {
                $stmt->close();
                sendResponse(true, 'Étudiant supprimé avec succès', null, 200);
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

