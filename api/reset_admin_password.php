<?php
/**
 * Script pour réinitialiser le mot de passe de l'admin
 * Accédez à : http://localhost/gestsoutenance/api/reset_admin_password.php
 * 
 * ATTENTION: Supprimez ce fichier après utilisation en production !
 */

require_once 'config/database.php';

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');

try {
    $conn = getConnection();
    
    // Nouveau mot de passe (changez-le après utilisation)
    $newPassword = 'admin123';
    $hashedPassword = password_hash($newPassword, PASSWORD_DEFAULT);
    
    // Mettre à jour le mot de passe de l'admin
    $stmt = $conn->prepare("UPDATE utilisateurs SET password = ? WHERE email = 'admin@gestsoutenance.com'");
    $stmt->bind_param("s", $hashedPassword);
    
    if ($stmt->execute()) {
        $response = [
            'success' => true,
            'message' => 'Mot de passe admin réinitialisé avec succès',
            'data' => [
                'email' => 'admin@gestsoutenance.com',
                'password' => $newPassword,
                'warning' => 'SUPPRIMEZ CE FICHIER APRÈS UTILISATION !'
            ]
        ];
    } else {
        $response = [
            'success' => false,
            'message' => 'Erreur lors de la réinitialisation',
            'error' => $stmt->error
        ];
    }
    
    $stmt->close();
    $conn->close();
    
    echo json_encode($response, JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT);
    
} catch (Exception $e) {
    echo json_encode([
        'success' => false,
        'message' => 'Erreur: ' . $e->getMessage()
    ], JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT);
}
?>




