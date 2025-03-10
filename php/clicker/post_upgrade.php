<?php
require_once('db.php');

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

$data = json_decode(file_get_contents("php://input"), true);

if (!isset($data['user_id'], $data['upgrade_id'])) {
    echo json_encode(['error' => 'Paramètres manquants']);
    exit;
}

$user_id = (int)$data['user_id'];
$upgrade_id = (int)$data['upgrade_id'];

try {
    // Récupérer le coût de base de l'amélioration
    $stmt = $db->prepare("SELECT cost FROM upgrades WHERE id = :upgrade_id");
    $stmt->execute([':upgrade_id' => $upgrade_id]);
    $upgrade = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$upgrade) {
        echo json_encode(['error' => 'Amélioration introuvable']);
        exit;
    }

    $base_cost = (int)$upgrade['cost'];

    // Vérifier si l'utilisateur a déjà cette amélioration
    $stmt = $db->prepare("SELECT level FROM user_upgrades WHERE user_id = :user_id AND upgrade_id = :upgrade_id");
    $stmt->execute([':user_id' => $user_id, ':upgrade_id' => $upgrade_id]);
    $user_upgrade = $stmt->fetch(PDO::FETCH_ASSOC);

    $level = $user_upgrade ? (int)$user_upgrade['level'] + 1 : 1;
    $new_cost = (int) round($base_cost * pow(2.1, $level)); // Calcul du nouveau coût

    // Vérifier si l'utilisateur a assez d'expérience
    $stmt = $db->prepare("SELECT total_experience FROM player WHERE id_player = :user_id");
    $stmt->execute([':user_id' => $user_id]);
    $player = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$player || (int)$player['total_experience'] < $new_cost) {
        echo json_encode(['error' => 'Expérience insuffisante']);
        exit;
    }

    // Déduire l'expérience du joueur
    $stmt = $db->prepare("UPDATE player SET total_experience = total_experience - :cost WHERE id_player = :user_id");
    $stmt->execute([':cost' => $new_cost, ':user_id' => $user_id]);

    // Insérer ou mettre à jour le niveau de l'amélioration
    if ($user_upgrade) {
        $stmt = $db->prepare("UPDATE user_upgrades SET level = :level WHERE user_id = :user_id AND upgrade_id = :upgrade_id");
    } else {
        $stmt = $db->prepare("INSERT INTO user_upgrades (user_id, upgrade_id, level) VALUES (:user_id, :upgrade_id, :level)");
    }
    $stmt->execute([':user_id' => $user_id, ':upgrade_id' => $upgrade_id, ':level' => $level]);

    echo json_encode(['success' => true, 'new_cost' => $new_cost, 'new_level' => $level]);

} catch (PDOException $e) {
    echo json_encode(['error' => 'Erreur base de données: ' . $e->getMessage()]);
}
?>
