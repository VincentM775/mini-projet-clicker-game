<?php
require_once('db.php');

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

// Gestion des requêtes OPTIONS (pré-vol)
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(["error" => "Méthode non autorisée"]);
    exit;
}

// Lire et décoder les données JSON envoyées
$data = json_decode(file_get_contents("php://input"), true);
if (!$data) {
    echo json_encode(["error" => "Données JSON invalides"]);
    exit;
}

// Vérifier si l'ID utilisateur est défini
if (!isset($data['user_id'])) {
    echo json_encode(["error" => "ID utilisateur manquant"]);
    exit;
}

$userId = filter_var($data['user_id'], FILTER_VALIDATE_INT);

if ($userId === false) {
    echo json_encode(["error" => "ID utilisateur invalide"]);
    exit;
}

$response = [];

// Récupérer l'XP de l'utilisateur à partir de la base de données
try {
    // Requête pour récupérer l'XP de l'utilisateur
    $query = "SELECT total_experience FROM users WHERE id = :user_id";
    $stmt = $db->prepare($query);
    $stmt->execute([':user_id' => $userId]);

    // Vérifier si l'utilisateur existe
    $user = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($user) {
        // Si l'utilisateur existe, retourner l'XP
        $response = ["total_experience" => $user['total_experience']];
    } else {
        // Si l'utilisateur n'existe pas
        $response = ["error" => "Utilisateur non trouvé"];
    }
} catch (Exception $e) {
    $response = ["error" => "Erreur lors de la récupération de l'XP: " . $e->getMessage()];
}

// Retourner une réponse structurée en JSON
echo json_encode($response);
?>
