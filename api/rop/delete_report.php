<?php
header('Content-Type: application/json');

include_once 'db_connect.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $id = $_POST['id'];

    // Prepare and execute the delete statement
    $stmt = $conn->prepare("DELETE FROM relief_reports WHERE id = ?");
    $stmt->bind_param("i", $id);

    if ($stmt->execute()) {
        echo json_encode(['success' => true]);
    } else {
        echo json_encode(['success' => false, 'message' => 'Failed to delete record']);
    }

    $stmt->close();
}

$conn->close();
