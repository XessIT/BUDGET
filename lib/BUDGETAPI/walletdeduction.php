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

// Handle OPTIONS request for CORS preflight
if ($_SERVER["REQUEST_METHOD"] === "OPTIONS") {
    http_response_code(204);
    exit();
}

// Handle incoming HTTP requests
if ($_SERVER["REQUEST_METHOD"] === "POST") {
    // Receive POST data using $_POST
    $uid = $_POST['uid'] ?? '';
    $incomeId = $_POST['incomeId'] ?? '';
    $amountToDeduct = $_POST['amountToDeduct'] ?? '';

    if (!empty($uid) && !empty($incomeId) && !empty($amountToDeduct)) {
        $conn = connectToDatabase();

        // Sanitize input data to prevent SQL injection
        $uid = $conn->real_escape_string($uid);
        $incomeId = $conn->real_escape_string($incomeId);
        $amountToDeduct = $conn->real_escape_string($amountToDeduct);

        // Update wallet amount
        $sqlUpdate = "UPDATE wallet SET wallet = wallet - '$amountToDeduct' WHERE uid = '$uid' AND incomeId = '$incomeId'";

        if ($conn->query($sqlUpdate) === TRUE) {
            echo json_encode(array("message" => "Wallet amount updated successfully"));
        } else {
            echo json_encode(array("error" => "Error updating wallet amount: " . $conn->error));
        }

        $conn->close();
    } else {
        http_response_code(400); // Bad request
        echo json_encode(array("error" => "Incomplete data received"));
    }
} else {
    http_response_code(405); // Method Not Allowed
    echo json_encode(array("error" => "Invalid request method"));
}
?>
