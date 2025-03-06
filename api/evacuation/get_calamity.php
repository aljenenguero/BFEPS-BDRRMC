<?php
include 'db_connect.php';


$sql = "SELECT id, date_time, calamity_name, calamity_type, severity_level, cause, alert_level, current_status FROM calamity_table";


$result = $conn->query($sql);

$reports = [];

if ($result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        $reports[] = $row;
    }
}

echo json_encode($reports);

$conn->close();
