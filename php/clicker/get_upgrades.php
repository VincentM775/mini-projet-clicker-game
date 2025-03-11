<?php
require_once('db.php');  // Connexion à la base de données

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

// Vérifier si 'user_id' est passé en paramètre GET
$user_id = isset($_GET['user_id']) ? intval($_GET['user_id']) : 0;

$query = "
    SELECT
        u.id,
        u.name,
        u.description,
        u.cost,
        COALESCE(uu.level, 0) AS level  -- Si l'amélioration n'est pas encore achetée, on met level = 0
    FROM upgrades u
    LEFT JOIN user_upgrades uu ON u.id = uu.upgrade_id AND uu.user_id = :user_id
";

$params = [':user_id' => $user_id];

try {
    $statement = $db->prepare($query);
    $statement->execute($params);
    $rows = $statement->fetchAll(PDO::FETCH_ASSOC);
    echo json_encode($rows);
} catch (PDOException $e) {
    echo json_encode(['error' => 'Database error: ' . $e->getMessage()]);
}
?>
