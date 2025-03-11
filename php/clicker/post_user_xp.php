<?php
require_once('db.php');  // Assurez-vous que ce fichier contient la connexion à votre base de données

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

// Gestion des requêtes OPTIONS (pré-vol)
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Vérification de la méthode HTTP
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

// Vérifier si l'action est définie
if (!isset($data['action'])) {
    echo json_encode(["error" => "Aucune action spécifiée"]);
    exit;
}

$action = $data['action'];
$response = [];

try {
    switch ($action) {
        case "update_user_xp":
            // Vérifier que les données nécessaires sont présentes
            if (!isset($data['user_id']) || !isset($data['xp'])) {
                throw new Exception("Données insuffisantes pour la mise à jour de l'XP");
            }

            // Mise à jour de l'expérience de l'utilisateur
            $query = "UPDATE player SET total_experience = total_experience + :xp WHERE id = :user_id";
            $stmt = $db->prepare($query);
            $stmt->execute([
                ':xp' => filter_var($data['xp'], FILTER_VALIDATE_INT),
                ':user_id' => filter_var($data['user_id'], FILTER_VALIDATE_INT)
            ]);

            // Réponse de succès
            $response = ["success" => "XP de l'utilisateur mis à jour"];
            break;

        default:
            throw new Exception("Action non reconnue");
    }
} catch (Exception $e) {
    $response = ["error" => $e->getMessage()];
}

// Retourner une réponse structurée en JSON
echo json_encode($response);
?>
