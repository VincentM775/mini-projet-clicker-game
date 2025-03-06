<?php
require_once('db.php');

header("Access-Control-Allow-Origin: *"); // Autorise toutes les origines
header("Access-Control-Allow-Methods: POST, GET, OPTIONS"); // Autorise les méthodes HTTP nécessaires
header("Access-Control-Allow-Headers: Content-Type"); // Autorise les headers personnalisés

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
        case "insert":
            if (!isset($data['pseudo'])) {
                throw new Exception("Données insuffisantes pour l'insertion");
            }

            $query = "INSERT INTO player (id_player, pseudo, total_experience, id_ennemy) VALUES (DEFAULT, :pseudo, :total_experience, :id_ennemy)";
            $stmt = $db->prepare($query);
            $stmt->execute([
                ':pseudo' => htmlspecialchars(strip_tags($data['pseudo'])),
                ':total_experience' => 0,
                ':id_ennemy' => 1
            ]);

            $response = ["success" => "Joueur ajouté", "id" => $db->lastInsertId()];
            break;

        case "update":
            if (!isset($data['id_player'])) {
                throw new Exception("ID manquant");
            }

            $fields = [];
            $params = [':id_player' => filter_var($data['id_player'], FILTER_VALIDATE_INT)];

            if (!empty($data['pseudo'])) {
                $fields[] = "pseudo = :pseudo";
                $params[':pseudo'] = htmlspecialchars(strip_tags($data['pseudo']));
            }
            if (!empty($data['total_experience'])) {
                $fields[] = "total_experience = :total_experience";
                $params[':total_experience'] = filter_var($data['total_experience'], FILTER_VALIDATE_INT);
            }
            if (!empty($data['id_ennemy'])) {
                $fields[] = "id_ennemy = :id_ennemy";
                $params[':id_ennemy'] = filter_var($data['id_ennemy'], FILTER_VALIDATE_INT);
            }

            if (empty($fields)) {
                throw new Exception("Aucune donnée à modifier.");
            }

            $query = "UPDATE player SET " . implode(", ", $fields) . " WHERE id_player = :id_player";
            $stmt = $db->prepare($query);
            $stmt->execute($params);

            $response = ["success" => "Utilisateur modifié !"];
            break;

        case "delete":
            if (!isset($data['id_player'])) {
                throw new Exception("L'identifiant utilisateur est manquant.");
            }

            $query = "DELETE FROM player WHERE id_player = :id_player";
            $stmt = $db->prepare($query);
            $stmt->execute([':id_player' => filter_var($data['id_player'], FILTER_VALIDATE_INT)]);

            $response = ["success" => "Utilisateur supprimé."];
            break;

        case "update_total_experience":
            if (!isset($data['id_player']) || !isset($data['total_experience'])) {
                throw new Exception("Données insuffisantes");
            }

            // Mise à jour de l'expérience
            $query = "UPDATE player SET total_experience = :total_experience WHERE id_player = :id_player";
            $stmt = $db->prepare($query);
            $stmt->execute([
                ':total_experience' => filter_var($data['total_experience'], FILTER_VALIDATE_INT),
                ':id_player' => filter_var($data['id_player'], FILTER_VALIDATE_INT)
            ]);

            // Réponse de succès
            $response = ["success" => "Experience mise à jour"];
            break;

        default:
            throw new Exception("Action non reconnue");
    }
} catch (Exception $e) {
    $response = ["error" => $e->getMessage()];
}

// Retourne une réponse structurée en JSON
echo json_encode($response);
