<?php
/**
 * Script de configuration du compte administrateur
 * Exécutez ce script une fois pour créer ou réinitialiser le compte admin
 * Accédez à : http://localhost/api/setup_admin.php
 */

require_once 'config/database.php';

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');

// Vérifier que c'est une requête GET (pour la sécurité, vous pouvez ajouter une vérification)
if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    sendResponse(false, 'Méthode non autorisée. Utilisez GET.', null, 405);
}

try {
    $conn = getConnection();
    
    // Informations du compte admin
    $nom = 'Admin';
    $prenom = 'Système';
    $email = 'admin@gestsoutenance.com';
    $password = 'admin123';
    
    // Hasher le mot de passe
    $hashedPassword = password_hash($password, PASSWORD_DEFAULT);
    
    // Vérifier si le compte existe déjà
    $stmt = $conn->prepare("SELECT id, nom, prenom, email FROM utilisateurs WHERE email = ?");
    $stmt->bind_param("s", $email);
    $stmt->execute();
    $result = $stmt->get_result();
    
    if ($result->num_rows > 0) {
        // Le compte existe, mettre à jour le mot de passe
        $user = $result->fetch_assoc();
        $stmt->close();
        
        $stmt = $conn->prepare("UPDATE utilisateurs SET password = ? WHERE email = ?");
        $stmt->bind_param("ss", $hashedPassword, $email);
        
        if ($stmt->execute()) {
            sendResponse(true, 'Mot de passe admin mis à jour avec succès', [
                'user' => $user,
                'email' => $email,
                'password' => $password,
                'action' => 'updated'
            ], 200);
        } else {
            throw new Exception("Erreur lors de la mise à jour: " . $stmt->error);
        }
    } else {
        // Le compte n'existe pas, le créer
        $stmt->close();
        
        $stmt = $conn->prepare("INSERT INTO utilisateurs (nom, prenom, email, password, date_creation) VALUES (?, ?, ?, ?, NOW())");
        $stmt->bind_param("ssss", $nom, $prenom, $email, $hashedPassword);
        
        if ($stmt->execute()) {
            $userId = $conn->insert_id;
            
            sendResponse(true, 'Compte admin créé avec succès', [
                'id' => $userId,
                'nom' => $nom,
                'prenom' => $prenom,
                'email' => $email,
                'password' => $password,
                'action' => 'created'
            ], 201);
        } else {
            throw new Exception("Erreur lors de la création: " . $stmt->error);
        }
    }
    
    $stmt->close();
    $conn->close();
    
} catch (Exception $e) {
    sendResponse(false, 'Erreur lors de la configuration', [
        'error' => $e->getMessage(),
        'trace' => $e->getTraceAsString()
    ], 500);
}
?>







