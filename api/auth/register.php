<?php
/**
 * Endpoint d'inscription
 * POST /api/auth/register.php
 * 
 * Body JSON:
 * {
 *   "nom": "Doe",
 *   "prenom": "John",
 *   "email": "user@example.com",
 *   "password": "password123"
 * }
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

// Vérifier que la méthode est POST
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendResponse(false, 'Méthode non autorisée', null, 405);
}

// Récupérer les données JSON
$input = file_get_contents('php://input');
$data = json_decode($input, true);

// Vérifier si le JSON est valide
if (json_last_error() !== JSON_ERROR_NONE) {
    sendResponse(false, 'Format JSON invalide', ['error' => json_last_error_msg()], 400);
}

// Vérifier que les données ne sont pas null
if ($data === null) {
    sendResponse(false, 'Données manquantes', null, 400);
}

// Valider les données
$errors = validateInput($data, ['nom', 'prenom', 'email', 'password']);

if (!empty($errors)) {
    sendResponse(false, 'Données invalides', ['errors' => $errors], 400);
}

// Valider l'email
if (!validateEmail($data['email'])) {
    sendResponse(false, 'Format d\'email invalide', null, 400);
}

// Valider le mot de passe (minimum 6 caractères)
if (strlen($data['password']) < 6) {
    sendResponse(false, 'Le mot de passe doit contenir au moins 6 caractères', null, 400);
}

// Nettoyer les données
$nom = sanitizeInput($data['nom']);
$prenom = sanitizeInput($data['prenom']);
$email = sanitizeInput($data['email']);
$password = $data['password']; // Ne pas nettoyer le mot de passe

try {
    $conn = getConnection();
    
    // Vérifier si l'email existe déjà
    $stmt = $conn->prepare("SELECT id FROM utilisateurs WHERE email = ?");
    $stmt->bind_param("s", $email);
    $stmt->execute();
    $result = $stmt->get_result();
    
    if ($result->num_rows > 0) {
        $stmt->close();
        $conn->close();
        sendResponse(false, 'Cet email est déjà utilisé', null, 409);
    }
    $stmt->close();
    
    // Hasher le mot de passe
    $hashedPassword = password_hash($password, PASSWORD_DEFAULT);
    
    // Insérer le nouvel utilisateur (par défaut role='etudiant')
    $stmt = $conn->prepare("INSERT INTO utilisateurs (nom, prenom, email, password, role, date_creation) VALUES (?, ?, ?, ?, 'etudiant', NOW())");
    
    if (!$stmt) {
        throw new Exception("Erreur de préparation de la requête: " . $conn->error);
    }
    
    $stmt->bind_param("ssss", $nom, $prenom, $email, $hashedPassword);
    
    if ($stmt->execute()) {
        $userId = $conn->insert_id;
        
        // Récupérer les informations de l'utilisateur créé (avec role)
        $stmt = $conn->prepare("SELECT id, nom, prenom, email, COALESCE(role, 'etudiant') as role FROM utilisateurs WHERE id = ?");
        $stmt->bind_param("i", $userId);
        $stmt->execute();
        $result = $stmt->get_result();
        $user = $result->fetch_assoc();
        
        sendResponse(true, 'Inscription réussie', [
            'user' => $user
        ], 201);
    } else {
        throw new Exception("Erreur lors de l'inscription: " . $stmt->error);
    }
    
    $stmt->close();
    $conn->close();
    
} catch (Exception $e) {
    // Log de l'erreur pour le débogage (à retirer en production)
    error_log("Erreur d'inscription: " . $e->getMessage());
    error_log("Stack trace: " . $e->getTraceAsString());
    
    sendResponse(false, 'Erreur lors de l\'inscription: ' . $e->
    Message(), ['error' => $e->getMessage()], 500);
}
?>

