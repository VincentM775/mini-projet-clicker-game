<?php

    $dns = 'mysql:host=localhost;dbname=clicker;charset=utf8mb4';
    $user = 'root';
    $password = 'root';

    try {
        $db = new PDO($dns, $user, $password);
    } catch (PDOException $e) {
        $error = $e->getMessage();
        echo $error;
    }

