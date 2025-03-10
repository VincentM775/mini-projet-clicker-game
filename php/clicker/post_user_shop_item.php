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

// Vérifier si l'action est définie
if (!isset($data['action'])) {
    echo json_encode(["error" => "Aucune action spécifiée"]);
    exit;
}

$action = $data['action'];
$response = [];

try {
    switch ($action) {
        case "insert_user_shop_item":
            // Vérifier si les données nécessaires sont présentes
            if (!isset($data['user_id']) || !isset($data['shop_item_id'])) {
                throw new Exception("Données insuffisantes pour l'insertion");
            }

            // Insertion de l'objet dans la table user_shop_item (relation entre l'utilisateur et l'item)
            $query = "INSERT INTO user_shop_items (user_id, shop_item_id) VALUES (:user_id, :shop_item_id)";
            $stmt = $db->prepare($query);
            $stmt->execute([
                ':user_id' => filter_var($data['user_id'], FILTER_VALIDATE_INT),
                ':shop_item_id' => filter_var($data['shop_item_id'], FILTER_VALIDATE_INT),
            ]);

            $response = ["success" => "Objet ajouté à l'utilisateur", "id" => $db->lastInsertId()];
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
