<?php

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS, PUT, DELETE");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

// Database connection function
function connectToDatabase() {
    $servername = "localhost";
    $username = "root";
    $password = "";
    $dbname = "budget";

    // Create connection
    $conn = new mysqli($servername, $username, $password, $dbname);

    // Check connection
    if ($conn->connect_error) {
        die("Connection failed: " . $conn->connect_error);
    }

    return $conn;
}

// Update Record (UPDATE operation)
function updateRecord($data) {
    $conn = connectToDatabase();

    $incomeId = mysqli_real_escape_string($conn, $data->incomeId);
    $fromDate = mysqli_real_escape_string($conn, $data->fromDate);
    $toDate = mysqli_real_escape_string($conn, $data->toDate);
    $status = mysqli_real_escape_string($conn, $data->status);

    // Update status based on incomeId, fromDate, and toDate
    $query = "UPDATE monthly_credit SET status = '$status' WHERE incomeId = '$incomeId' AND fromDate = '$fromDate' AND toDate = '$toDate'";
    $result = mysqli_query($conn, $query);

    if ($result) {
        echo json_encode(array("message" => "Status updated successfully"));
    } else {
        echo json_encode(array("error" => "Failed to update status"));
    }

    $conn->close();
}

if ($_SERVER["REQUEST_METHOD"] === "PUT") {
    $data = json_decode(file_get_contents("php://input"));
    updateRecord($data);
} else {
    echo json_encode(array("error" => "Invalid request method"));
}

?>
