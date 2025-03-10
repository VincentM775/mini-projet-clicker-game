<?php
require_once('db.php');

header("Access-Control-Allow-Origin: *");  // Ou remplace * par un domaine spécifique pour plus de sécurité
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

// Initialisation de la requête SQL
$query = 'SELECT id, name, description, price, effect FROM shop_items WHERE 1=1';
$params = [];

// Vérifier si 'id_item' est passé en paramètre GET et l'ajouter à la requête
if (!empty($_GET['id_item']) && is_numeric($_GET['id_item'])) {
    $query .= ' AND id = :id_item';
    $params[':id_item'] = $_GET['id_item'];
}

// Vérifier si 'name' est passé en paramètre GET et l'ajouter à la requête
if (!empty($_GET['name']) && preg_match('/^[a-zA-Z0-9_ ]+$/', $_GET['name'])) {
    $query .= ' AND name LIKE :name';
    $params[':name'] = '%' . $_GET['name'] . '%';  // Rechercher des correspondances partielles
}

try {
    // Préparation et exécution de la requête
    $statement = $db->prepare($query);
    $statement->execute($params);

    // Récupération des résultats sous forme de tableau associatif
    $rows = $statement->fetchAll(PDO::FETCH_ASSOC);

    // Retourner les résultats sous forme JSON
    echo json_encode($rows);

} catch (PDOException $e) {
    // Gestion des erreurs de base de données
    echo json_encode(['error' => 'Database error: ' . $e->getMessage()]);
}
?>
