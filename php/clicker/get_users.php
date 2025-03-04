<?php
	require_once('db.php');

	header("Access-Control-Allow-Origin: *");
	header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
	header("Access-Control-Allow-Headers: Content-Type, Authorization");

	$query = 'SELECT * FROM player WHERE 1=1';
	$params = [];

	if (!empty($_GET['id_player'])) {
	    $query .= ' AND id_player = :id_player';
	    $params[':id_player'] = $_GET['id_player'];
	}

	if (!empty($_GET['pseudo'])) {
	    $query .= ' AND pseudo = :pseudo';
	    $params[':pseudo'] = $_GET['pseudo'];
	}

	$statement = $db->prepare($query);
	$statement->execute($params);
	$rows = $statement->fetchAll(PDO::FETCH_ASSOC);

	echo json_encode($rows);
