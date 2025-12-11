<?php
/**
 * Endpoint de connexion
 * POST /api/auth/login.php
 * 
 * Body JSON:
 * {
 *   "email": "user@example.com",
 *   "password": "password123"
 * }
 */

// Headers CORS
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}


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

// Valider les données
$errors = validateInput($data, ['email', 'password']);

if (!empty($errors)) {
    sendResponse(false, 'Données invalides', ['errors' => $errors], 400);
}

// Valider l'email
if (!validateEmail($data['email'])) {
    sendResponse(false, 'Format d\'email invalide', null, 400);
}

// Nettoyer les données
$email = sanitizeInput($data['email']);
$password = $data['password']; // Ne pas nettoyer le mot de passe

try {
    $conn = getConnection();
    
    // Préparer la requête
    $stmt = $conn->prepare("SELECT id, nom, prenom, email, password FROM utilisateurs WHERE email = ?");
    
    if (!$stmt) {
        throw new Exception("Erreur de préparation de la requête: " . $conn->error);
    }
    
    $stmt->bind_param("s", $email);
    $stmt->execute();
    $result = $stmt->get_result();
    
    if ($result->num_rows === 0) {
        sendResponse(false, 'Email ou mot de passe incorrect', null, 401);
    }
    
    $user = $result->fetch_assoc();
    
    // Vérifier le mot de passe
    if (!password_verify($password, $user['password'])) {
        sendResponse(false, 'Email ou mot de passe incorrect', null, 401);
    }
    
    // Connexion réussie
    // Retourner les informations de l'utilisateur (sans le mot de passe)
    unset($user['password']);
    
    sendResponse(true, 'Connexion réussie', [
        'user' => $user
    ], 200);
    
    $stmt->close();
    $conn->close();
    
} catch (Exception $e) {
    sendResponse(false, 'Erreur lors de la connexion', ['error' => $e->getMessage()], 500);
}
?>

