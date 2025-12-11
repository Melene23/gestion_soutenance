# Mettre à jour metadata/list.php
@'
<?php
// Headers CORS
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=utf-8");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Données de métadonnées réelles
$metadata = [
    'filieres' => [
        ['id' => 1, 'nom' => 'Informatique de gestion'],
        ['id' => 2, 'nom' => 'Planification des projets'],
        ['id' => 3, 'nom' => 'Gestion de Banque et Assurance'],
        ['id' => 4, 'nom' => 'Gestion Commerciale'],
        ['id' => 5, 'nom' => 'Gestion des Transports & Logistiques'],
        ['id' => 6, 'nom' => 'Gestion des Ressources Humaines (GRH)'],
        ['id' => 7, 'nom' => 'Statistiques'],
    ],
    'niveaux' => [
        ['id' => 1, 'nom' => 'Licence 2 (L2)'],
        ['id' => 2, 'nom' => 'Licence 3 (L3)'],
        ['id' => 3, 'nom' => 'Master 2 (M2)'],
    ],
    'encadreurs' => [
        ['id' => 1, 'nom' => 'Dr. Jean Martin', 'specialite' => 'Informatique de gestion'],
        ['id' => 2, 'nom' => 'Dr. Marie Dupont', 'specialite' => 'Planification'],
        ['id' => 3, 'nom' => 'Dr. Pierre Dubois', 'specialite' => 'Gestion financière'],
        ['id' => 4, 'nom' => 'Dr. Sophie Laurent', 'specialite' => 'Ressources humaines'],
        ['id' => 5, 'nom' => 'Dr. Thomas Bernard', 'specialite' => 'Statistiques'],
    ],
    'types_salle' => [
        ['id' => 1, 'nom' => 'Salle de cours'],
        ['id' => 2, 'nom' => 'Laboratoire informatique'],
        ['id' => 3, 'nom' => 'Amphithéâtre'],
        ['id' => 4, 'nom' => 'Salle de conférence'],
    ],
    'annees_universitaires' => [
        ['id' => 1, 'nom' => '2023-2024'],
        ['id' => 2, 'nom' => '2024-2025'],
        ['id' => 3, 'nom' => '2025-2026'],
    ]
];

echo json_encode([
    'success' => true,
    'message' => 'Métadonnées récupérées avec succès',
    'data' => $metadata,
    'timestamp' => date('Y-m-d H:i:s')
], JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT);
?>
'@ | Out-File -FilePath "C:\wamp64\www\api\metadata\list.php" -Encoding UTF8 -Force

Write-Host "✅ Fichier metadata/list.php MIS À JOUR" -ForegroundColor Green